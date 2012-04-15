from distutils.core import setup, Extension
import distutils.util
import subprocess
import numpy as np
from os.path import isdir,exists
import subprocess

def find_sprbase():
    #TODO: implement this properly
    findlist = ['/usr/local/src/statpatrec']
    for f in findlist:
        if isdir(f): return f
    return None

def find_sprlib():
    sprlib = ['libSPR.dylib','libSPR.so']
    sprtry = ['/usr/local/lib']
    for d in sprtry:
        for f in sprlib:
            if exists(d+'/'+f):
                return d
    return None

def find_root():
    try:
        root_inc = subprocess.Popen(["root-config", "--incdir"], 
                            stdout=subprocess.PIPE).communicate()[0].strip()
        root_ldflags = subprocess.Popen(["root-config", "--libs"], 
                            stdout=subprocess.PIPE).communicate()[0].strip().split(' ')
    except OSError:
        rootsys = os.environ['ROOTSYS']
        root_inc = subprocess.Popen([rootsys+"/bin/root-config", "--incdir"], 
                            stdout=subprocess.PIPE).communicate()[0].strip()
        root_ldflags = subprocess.Popen([rootsys+"/bin/root-config", "--libs"], 
                            stdout=subprocess.PIPE).communicate()[0].strip().split(' ')
    return root_inc, root_ldflags

sprbase = find_sprbase()
assert(sprbase is not None)
sprlib = find_sprlib()
assert(sprlib is not None)
root_inc,root_ldflags = find_root()


libpyspr = Extension('pyspr._libpyspr',
                    sources = ['pyspr/_libpyspr.cpp'],
                    include_dirs= [sprbase+'/include',sprbase,'pyspr'],
                    library_dirs=[sprlib],
                    libraries=['SPR'],
                    extra_link_args=[] + root_ldflags)

setup (name = 'pyspr',
       version = '1.00',
       description = 'Binding for SPR',
       author='Piti Ongmongkolkul',
       author_email='piti118@gmail.com',
       url='https://github.com/piti118/pyspr',
       package_dir = {'pyspr': 'pyspr'},
       packages = ['pyspr'],
       ext_modules = [libpyspr]
       )