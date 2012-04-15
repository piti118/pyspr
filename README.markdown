pyspr
-----

StatPatternRecognition python binding.

Requirement
-----------
My version of SPR at https://github.com/piti118/SPR (just 1 method added to access the variable names order)

Example
-------
```python
from pyspr import SPR

spr = SPR('test/cleveland.spr')
print spr.varnames() #print variable names in the right order 
#['age', 'sex', 'cp', 'trestbps', 'chol', 'fbs', 'restecg', 'thalach', 'exang', 'oldpeak', 'slope', 'ca', 'thal']
#i know it needs 13
myvar = [0.5]*13
print spr.response(myvar)
#you can also give it a dictionary make sure you have all the variables or it will raise error
#numpy record works here as well
d ={'age':0.3, 'sex':1, 
    'cp':23, 'trestbps':1.0, 
    'chol':-1, 'fbs':10., 
    'restecg':0.2, 'thalach':0.1, 
    'exang':0.2, 'oldpeak':0.1, 
    'slope':1.0, 'ca':0.3, 
    'thal':0.6}
print spr.response_dict(d)
```
