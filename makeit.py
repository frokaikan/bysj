# !/usr/bin/env python3
# coding = utf-8
# @author : frokaikan

import os
import sys
import shutil
import re
from getopt import gnu_getopt

def check_input():
    os.chdir('source')
    if os.path.exists('full_asc.in'):
        os.remove('full_asc.in')
    files = [x for x in os.listdir('.')]
    # No directory, all files must be '*.header', '*.asc', '*.in', '*.testpo', or '*EPH'
    for f in files:
        if os.path.isdir(f):
            print('%s is a directory'%f)
            return 0
        if not (f.endswith('.header') or f.endswith('.asc') or f.endswith('.in') or f.endswith('.testpo') or f.endswith('EPH')):
            print('Invalid file : %s'%f)
            return 0
    # part 1 : ONE *.header and some *.asc
    # At most ONE .header file
    header = 0
    for f in files:
        if f.endswith('.header'):
            header += 1
    if header > 1:
        print('%d .header file. At most ONE.'%header_cnt)
        return 0
    # any .asc?
    asc = False
    if header:
        for f in files:
            if f.endswith('.asc'):
                asc = True
                break
    # part 2 : ONE *.in
    # any .in?
    in_f = 0
    for f in files:
        if f.endswith('.in'):
            in_f += 1
    if in_f > 1:
        print('%d .in file. At most ONE.'%in_f)
        return 0
    # part 3 : *EPH
    EPH = 0
    for f in files:
        if f.endswith('EPH'):
            EPH += 1
    if EPH > 1:
        print('%d EPH file. At most ONE.'%EPH)
    # One of the Three options?
    if asc + in_f + EPH != 1:
        print('You can choose just ONE options. See README.md')
        return 0
    os.chdir('..')
    if asc:
        return 1
    elif in_f:
        return 2
    elif EPH:
        return 3
    else:
        raise NotImplementedError("Unknown Error. Please contact me by 541240857@qq.com")

def get_ksize_from_header():
    ksize = 0
    os.chdir('source')
    header_file = [x for x in os.listdir('.') if x.endswith('.header')]
    if len(header_file) == 1:
        with open(header_file[0], 'rt') as f:
            ksize = re.search(r'\d+', f.readline()).group(0)
            print('Found ksize at %s : %s'%(header_file[0], ksize))
    os.chdir('..')
    return ksize
    
def get_namfil_from_source():
    namfil = ''
    os.chdir('source')
    eph_file = [x for x in os.listdir('.') if x.endswith('EPH')]
    if len(eph_file) == 1:
        namfil = eph_file[0]
    os.chdir('..')
    return namfil

def ksize_namfil(opts):
    ksize = 0
    namfil = ''
    if '-k' in opts:
        ksize = opts['-k']
        print('ksize set by user : %s'%ksize)
    else:
        _k = get_ksize_from_header()
        if _k:
            ksize = _k
        else:
            ksize = input('Not found ksize. KSIZE = ')
    if '-n' in opts:
        namfil = opts['-n']
        print('namfil set by user : %s'%namfil)
    else:
        _n = get_namfil_from_source()
        if _n:
            namfil = _n
        else:
            namfil = input('Not found namfil. NAMFIL = ')
    ksize = ksize.strip()
    namfil = namfil.strip()
    try:
        ksize = int(ksize)
    except ValueError:
        raise ValueError('Invalid ksize')
    if all((x not in namfil) for x in '/\\<>|?*:"'):
        if not namfil.endswith('EPH'):
            raise ValueError('eph file must ends with EPH.')
    else:
        raise ValueError('Invalid namfil')
    return ksize, namfil
    
def gen_fsizer3(ksize, namfil):
    fsizer3 = ''
    with open('fsizer3.f.config', 'rt') as f:
        fsizer3 = f.read()
    fsizer3 = re.sub('__namfil__', namfil, fsizer3)
    fsizer3 = re.sub('__ksize__', str(ksize), fsizer3)
    with open('fsizer3.f', 'wt') as f:
        f.write(fsizer3)
    
def gen_asc2eph(namfil):
    asc2eph = ''
    with open('asc2eph_struct.cpp.config', 'rt') as f:
        asc2eph = f.read()
    asc2eph = re.sub('__namfil__', namfil, asc2eph)
    with open('asc2eph_struct.cpp', 'wt') as f:
        f.write(asc2eph)
    
def do_compile():
    def c(command):
        print('run : %s'%command)
        os.system(command)
    c('g++ -O3 -c -fPIC -std=gnu++14 -o output/asc2eph_struct.o asc2eph_struct.cpp')
    c('g++ -O3 -std=gnu++14 -o output/asc2eph.exe asc2eph.cpp output/asc2eph_struct.o')
    c('gfortran -O3 -c -fPIC -o output/fsizer3.o fsizer3.f')
    c('gfortran -O3 -c -fPIC -o output/libeph.o libeph.f')
    c('gfortran -O3 -o output/testeph.exe testeph.f output/libeph.o output/fsizer3.o')

def merge_asc():
    os.chdir('source')
    header = [f for f in os.listdir('.') if f.endswith('.header')][0]
    asc = [f for f in os.listdir('.') if f.endswith('.asc')]
    asc.sort()
    def sub(t):
        return re.sub(r'(\d)\.(\d+)D([\+\-]\d+)', r'\1.\2E\3', t)
    with open('full_asc.in', 'wt') as fw:
        print('copy : %s'%header)
        with open(header, 'rt') as f:
            fw.write(sub(f.read()))
        for f in asc:
            print('copy : %s'%f)
            with open(f, 'rt') as fc:
                fw.write(sub(fc.read()))
    os.chdir('..')

def main():
    __doc__ = '''
Usage :: python %s op [-k ksize] [-n namfil]
op : make test clean endian
    make : compile the program and generate EPH file.
    test : test the EPH file by .testpo
    clean : clean all binary files, result files and intermidiate files.
    endian : check your CPU byte order (Little endian or Big endian)
-k ksize : (Needed by <make>)
    declare ksize
-n namfil : (Needed by <make>)
    declare your EPH file name (Must ends with EPH, e.g. {JPLEPH} {JPL.EPH} {JPLEPH.EPH} {inpop.EPH})
    '''%__file__
    args = [] if len(sys.argv) == 1 else sys.argv[1:]
    opts, op = gnu_getopt(args, 'k:n:')
    opts = dict(opts)
    if len(op) != 1:
        raise NotImplementedError('You can just set ONE operation in <make> <test> <clean> <endian>')
    op = op[0]
    if op == 'make':
        c = check_input()
        ksize, namfil = ksize_namfil(opts)
        if not os.path.exists('output'):
            os.mkdir('output')
        gen_asc2eph(namfil)
        gen_fsizer3(ksize, namfil)
        do_compile()
        if c == 0:
            raise NotImplementedError('Invalid input. Please check "source/" directory.')
        elif c == 1 or c == 2:
            if c == 1:
                merge_asc()
                if os.path.exists('output/full_asc.in'):
                    os.remove('output/full_asc.in')
                shutil.move('source/full_asc.in', 'output/full_asc.in')
            elif c == 2:
                in_f = [f for f in os.listdir('source') if f.endswith('.in')][0]
                if os.path.exists('output/full_asc.in'):
                    os.remove('output/full_asc.in')
                shutil.copy('source/%s'%in_f, 'output/full_asc.in')
            os.chdir('output')
            print('gen %s...'%namfil)
            ASC2EPH = os.path.join('.', 'asc2eph.exe')
            os.system('%s < full_asc.in'%ASC2EPH)
            os.chdir('..')
        elif c == 3:
            ephfile = [x for x in os.listdir('source') if x.endswith('EPH')][0]
            if ephfile != namfil:
                raise ValueError('Found eph : <%s>, but namfil == <%s>.'%(ephfile, namfil))
            if os.path.exists('output/%s'%namfil):
                os.remove('output/%s'%namfil)
            shutil.copy('source/%s'%namfil, 'output/%s'%namfil)
        else:
            raise NotImplementedError('Unknown error. Please contact me by 541240857@qq.com')
    elif op == 'test':
        testpo = [f for f in os.listdir('source') if f.endswith('.testpo')]
        if len(testpo) == 0:
            raise NotImplementedError('No .testpo file')
        elif len(testpo) >= 2:
            raise NotImplementedError('At most ONE .testpo file')
        if os.path.exists('output/TESTPO'):
            os.remove('output/TESTPO')
        testpo = testpo[0]
        shutil.copy('source/%s'%testpo, 'output/TESTPO')
        os.chdir('output')
        TESTEPH = os.path.join('.', 'testeph.exe')
        os.system(r'%s < TESTPO'%TESTEPH)
        os.chdir('..')
    elif op == 'clean':
        if os.path.exists('output'):
            shutil.rmtree('output')
        if os.path.exists('asc2eph_struct.cpp'):
            os.remove('asc2eph_struct.cpp')
        if os.path.exists('fsizer3.f'):
            os.remove('fsizer3.f')
    elif op == 'endian':
        os.system('g++ -O3 -std=gnu++14 -o test_endian.exe test_endian.cpp')
        os.system(os.path.join('.', 'test_endian.exe'))
        os.remove('test_endian.exe')
    else:
        raise NotImplementedError('%s Not Implement!'%op)
        
main()