from pyspr import SPR

spr = SPR('test/cleveland.spr')
print spr.varnames()
for i in range(100):
    d = [i*1.0]*12
    r = spr.response(d)
    print r