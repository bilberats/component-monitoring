# yoctowatt_log_fast_autosave.py
import argparse, csv, time, sys, os
from yoctopuce.yocto_api import *
from yoctopuce.yocto_power import *

p = argparse.ArgumentParser()
p.add_argument("--hub", default="127.0.0.1:4444", help="Adresse du VirtualHub ou 'usb'")
p.add_argument("--name", default="", help="Nom logique ex: YWATT.power ; vide = 1er capteur trouvé")
p.add_argument("--out", default="yoctowatt.csv", help="Nom du fichier CSV de sortie")
p.add_argument("--seconds", type=float, default=60.0, help="Durée totale en secondes")
p.add_argument("--req_hz", type=float, default=100.0, help="Fréquence demandée (Hz)")
p.add_argument("--save_interval", type=float, default=10.0, help="Sauvegarde toutes les X secondes")
a = p.parse_args()

errmsg = YRefParam()
if YAPI.RegisterHub(a.hub, errmsg) != YAPI.SUCCESS:
    sys.exit(f"Init error: {errmsg.value}")

sensor = YPower.FindPower(a.name) if a.name else YPower.FirstPower()
if sensor is None or not sensor.isOnline():
    sys.exit("Yocto-Watt non trouvé ou offline")

# Demande de fréquence
req = f"{int(a.req_hz)}/s"
try:
    sensor.set_reportFrequency(req)
except Exception as e:
    print(f"[WARN] Impossible de définir reportFrequency({req}): {e}")

try:
    eff = sensor.get_reportFrequency()
except Exception:
    eff = "unknown"
print(f"[INFO] reportFrequency demandé={req}, effectif={eff}")

rows = []

# Callback TimedReport
def on_timed(func, m: YMeasure):
    rows.append((m.get_endTimeUTC(), m.get_averageValue()))

sensor.registerTimedReportCallback(on_timed)

# Fonction pour sauvegarder le CSV
def save_csv():
    tmp_file = a.out + ".tmp"
    with open(tmp_file, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["timestamp_iso", "timestamp_unix", "watts", "reportFrequency_effective"])
        for ts, val in rows:
            iso = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(ts))
            w.writerow([iso, f"{ts:.6f}", f"{val:.6f}", eff])
    os.replace(tmp_file, a.out)
    print(f"[AUTOSAVE] {len(rows)} mesures → {a.out}")

# Boucle principale avec autosave
t_end = time.monotonic() + float(a.seconds)
next_save = time.monotonic() + a.save_interval

try:
    while time.monotonic() < t_end:
        YAPI.HandleEvents()
        time.sleep(0.005)
        if time.monotonic() >= next_save:
            save_csv()
            next_save = time.monotonic() + a.save_interval
except KeyboardInterrupt:
    print("\n[STOP] Interruption par l’utilisateur.")
finally:
    save_csv()
    YAPI.FreeAPI()
    print("[OK] Fin du script.")

