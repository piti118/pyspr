import numpy as np
cimport numpy as np

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
        void clear()

cdef extern from "SprAbsTrainedClassifier.hh":
    cdef cppclass SprAbsTrainedClassifier:
        vector[string]* getVars()
        double response(vector[double] v) 

cdef extern from "SprAbsVarTransformer.hh":
    cdef cppclass SprAbsVarTransformer:
        void transform(vector[double] vin,vector[double] vout)

cdef extern from "static.h":
    SprAbsTrainedClassifier* ReadClassifier(char* f)
    SprAbsVarTransformer* ReadTransformer(char* filename)

def float2double(a):
    if a is None or a.dtype == np.float64:
        return a
    else:
        return a.astype(np.float64)

cdef class SPR:
    cdef SprAbsTrainedClassifier* classifier
    cdef SprAbsVarTransformer* transformer
    cdef int numvar
    cdef object variables
    def __init__(self,fname,transformer=None):
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
        if transformer is None:
            self.transformer=NULL
        else:
            self.transformer = ReadTransformer(transformer)
        del tmpvar

    cdef double compute_response(self,vector[double] vd):
        cdef vector[double] tv
        if self.transformer !=NULL:
            self.transformer.transform(vd,tv)
            return self.classifier.response(tv)
        else:
            return self.classifier.response(vd)
    
    def response(self,v):
        if len(v) != self.numvar:
            raise ValueError("Expect list of length %d"%self.numvar)
        cdef vector[double] vd
        for x in v:
            vd.push_back(x)
        return self.compute_response(vd)
    
    def response_dict(self,d):
        cdef vector[double] vd
        for v in self.variables:
            vd.push_back(d[v])
        return self.compute_response(vd)
        
    def response_kwd(self,**kwd):
        cdef vector[double] vd
        for v in self.variables:
            vd.push_back(kwd[v])
        return self.compute_response(vd)
        
    #each element of dictionary is assumed to be 1d array
    def vresponse(self,rec,**kwd):
        cdef vector[double] tmp
        cdef int idata
        cdef int length
        cdef double dtmp
        cdef int numvar =0
        cdef np.ndarray[np.double_t] ret
        orderd = []
        #is there a way to work around passing in float array without copying and have it emit the right code?
        for v in self.variables:
            if v in kwd:
                orderd.append(float2double(kwd[v]))
            else:
                orderd.append(float2double(rec[v]))
        length = len(orderd[0])
        
        ret = np.zeros(length)
        numvar = len(orderd)
        for idata in range(length):
            tmp.clear()
            for i in range(numvar):
                dtmp = (<double*>np.PyArray_GETPTR1(orderd[i],idata))[0] #hack to help cython emit smart code
                tmp.push_back(dtmp)
            ret[idata] = self.compute_response(tmp)
        return ret
    
    def response_attr(self,o):
        cdef vector[double] vd
        for v in self.variables:
            vd.push_back(getattr(o,v))
        return self.compute_response(vd)
    
    def varnames(self):
        return self.variables
    
    def __del__(self):
        del self.classifier
        del self.transformer


cdef class SPRTransformer:
    cdef SprAbsVarTransformer* transformer
    
    def __init__(self,f=None):
        cdef char* fname = f
        self.transformer = ReadTransformer(fname)
    
    def transform(self,np.ndarray var):
        cdef vector[double] vi
        cdef int mylen = len(var)
        cdef vector[double] vo
        cdef np.ndarray[np.double_t] orgvar = float2double(var)
        cdef double tmp
        cdef np.ndarray[np.double_t] ret = np.zeros(mylen)
        for i in range(mylen):
            tmp = <double> orgvar[i]
            vi.push_back(tmp)
        self.transformer.transform(vi,vo);
        #TODO: make these unnecessary copying go away
        for i in range(mylen):
            ret[i] = vo[i]
        return ret
    
    def __del__(self):
        del self.transformer

        
        