#include <SprClassifierReader.hh>
#include <SprAbsTrainedClassifier.hh>
cdef extern from "<string>" namespace "std":
    cdef cppclass string:
        char* c_str()

cdef extern from "<vector>" namespace "std":
    cdef cppclass vector[T]:
        cppclass iterator:
            T operator*()
            iterator operator++()
            bint operator==(iterator)
            bint operator!=(iterator)
        vector()
        void push_back(T&)
        T& operator[](int)
        T& at(int)
        iterator begin()
        iterator end()
        int size()

cdef extern from "SprAbsTrainedClassifier.hh":
    cdef cppclass SprAbsTrainedClassifier:
        vector[string]* getVars()
        double response(vector[double] v) 

cdef extern from "static.h":
    SprAbsTrainedClassifier* ReadClassifier(char* f)

cdef class SPR:
    cdef SprAbsTrainedClassifier* classifier
    cdef int numvar
    cdef object variables
    def __init__(self,fname):
        cdef char* tmp
        cdef vector[string]* tmpvar
        cdef bytes tmpvarname
        cdef int i
        tmp = fname
        self.classifier = ReadClassifier(tmp)
        assert(self.classifier!=NULL)
        tmpvar = self.classifier.getVars()
        self.variables = []
        for i in range(tmpvar.size()):
            tmpvarname = tmpvar.at(i).c_str()
            self.variables.append(tmpvarname)
        self.numvar = tmpvar.size()
        del tmpvar
    
    def response(self,v):
        if len(v) != self.numvar:
            raise ValueError("Expect list of length %d"%self.numvar)
        cdef vector[double] vd
        for x in v:
            vd.push_back(x)
        return self.classifier.response(vd)
    
    def response_dict(self,d):
        cdef vector[double] vd
        for v in self.variables:
            vd.push_back(d[v])
        return self.classifier.response(vd)
    
    def response_attr(self,o):
        cdef vector[double] vd
        for v in self.variables:
            vd.push_back(getattr(o,v))
        return self.classifier.response(vd) 
    
    def varnames(self):
        return self.variables
    
    def __del__(self):
        del self.classifier
