"""Delta-Delta-Ct on the qpcr package's own example files (actin = reference)."""
import sys, qpcr
from qpcr.Pipes import BasicPlus
d = sys.argv[1]
p = BasicPlus()
p.save_to(sys.argv[2])
p.add_assays([f"{d}/HNRNPL_nmd.csv", f"{d}/SRSF11_nmd.csv"])
p.add_normalisers([f"{d}/actin.csv", f"{d}/28S.csv"])
p.run()
print(p.get(kind="df").head(12))
