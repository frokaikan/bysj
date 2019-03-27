# !/usr/bin/env python3
# coding = utf-8
# @author : frokaikan

import os
import sys
import shutil
import re
from getopt import getopt

def check_input():
    os.chdir('source')
    if os.path.exists('in.eph'):
        os.remove('in.eph')
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
    if header_cnt > 1:
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
    elif jpleph:
        return 3
    else:
        raise NotImplementedError("Unknown Error. Please contact me by 541240857@qq.com")

def get_ksize_from_header():
    os.chdir('source')
    header_file = [x for x in os.listdir('.') if x.endswith('.header')]
    if len(header_file != 1)
        return 0
    header_file = header_file[0]
    with open(header_file, 'rt') as f:
        ksize = re.search(r'\d+', f.readline())
    return ksize

def ksize_namfil(opts):
    ksize = 0
    namfil = ''
    if '-k' in opts:
        try:
            ksize = int(opts['-k'])
        except ValueError:
            print('Invalid ksize.')
            return 0
    else:
        _k = get_ksize_from_header()
        if _k:
            ksize = _k
        else:
            while True:
                try:
                    ksize = int(input('Not found ksize. Your KSIZE is : '))
                except ValueError:
                    print('Invalid ksize. Please enter again...')
                else:
                    break
    if '-n' in opts:
        namfil = opts['-n']
    else:
        _n = input('Input your NAMFIL. (Or JPLEPH by default) : ')
        _n = _n.strip()
        if _n:
            if all((x not in _n) for x in '/\\<>|?*:"')：
                if _n.endswith('EPH'):
                    namfil = _n
                else:
                    print('EPH file must ends with EPH. Use default : JPLEPH')
            else:
                print('/\\<>|?*:" Can\'t in NAMFIL. Use default : JPLEPH')
                namfil = 'JPLEPH'
        else:
            print('Use default : JPLEPH')
            namfil = 'JPLEPH'
    return ksize, namfil
    
def gen_fsizer3(opts):
    ksize, namfil = ksize_namfil(opts)
    fsizer3 = ''
    with open('fsizer3.f.config', 'rt') as f:
        fsizer3 = f.read()
    fsizer3 = re.sub('__namfil__', namfil, fsizer3)
    fsizer3 = re.sub('__ksize__', str(ksize), fsizer3)
    with open('fsizer3.f', 'wt') as f:
        f.write(fsizer3)
    
def do_compile():
    def c(out_file, in_file, command):
        if os.path.exists(out_file) and os.stat(out_file).st_mtime > os.stat(in_file).st_mtime:
            return
        print('run : %s'%command)
        os.system(command)
    c('output/asc2eph.exe', 'asc2eph.cpp', 'g++ -O3 -g3 -std=gnu++14 -o output/asc2eph.exe asc2eph.cpp')
    c('output/libeph.so', 'libeph.f', 'gfortran -O3 -g3 -fPIC -shared -o output/libeph.so libeph.f')
    c('output/fsizer3.so', 'FSIZER3.f', 'gfortran -O3 -g3 -fPIC -shared -o output/fsizer3.so fsizer3.f')
    c('output/testeph.exe', 'testeph.f', 'gfortran -O3 -g3 -o output/testeph.exe testeph.f -L. -Loutput output/libeph.so output/fsizer3.so')

def merge_asc():
    os.chdir('source')
    header = [f for f in os.listdir('.') if f.endswith('.header')][0]
    asc = [f for f in os.listdir('.') if f.endswith('.asc')]
    asc.sort()
    def sub(t):
        return re.sub(r'(\d)\.(\d+)D([\+\-]\d+)', r'\1.\2E\3', t)
    with open('in.eph', 'wt') as fw:
        print('copy : %s'%header)
        with open(header, 'rt') as f:
            fw.write(sub(f.read()))
        for f in asc:
            print('copy : %s'%f)
            with open(f, 'rt') as fc:
                fw.write(sub(fc.read()))
    os.chdir('..')

#unfinish!!!
#asc2eph.cpp should also be change. 
def main():
    __doc__ = '''
Usage :: python %s op [-k ksize] [-n namfil]
op : make test clean
    make : compile the program and generate EPH file.
    test : test the EPH file by .testpo
    clean : clean all binary files, result files and intermidiate files.
-k ksize : (Needed by <make>, No default value)
    declare ksize
-n namfil : (Needed by <make> and <test>, default : JPLEPH)
    declare your EPH file name (Must ends with EPH, e.g. {JPLEPH} {JPL.EPH} {JPLEPH.EPH} {inpop.EPH})
    '''%__file__
    opts = getopt(sys.argv[1:])
    ksize, namfil = ksize_namfil
    if op == 'make':
        if not os.path.exists('output'):
            os.mkdir('output')
        do_compile()
        c = check_input()
        if c == 0:
            raise NotImplementedError('Invalid input. Please check "source/" directory.')
        elif c == 1 or c == 2:
            if c == 1:
                merge_asc()
                if os.path.exists('output/in.eph'):
                    os.remove('output/in.eph')
                shutil.move('source/in.eph', 'output/in.eph')
            elif c == 2:
                in_f = [f for f in os.listdir('source') if f.endswith('.in')][0]
                if os.path.exists('output/in.eph'):
                    os.remove('output/in.eph')
                shutil.copy('source/%s'%in_f, 'output/in.eph')
            os.chdir('output')
            print('gen %s...')
            os.system('asc2eph.exe < in.eph')
            os.chdir('..')
        elif c == 3:
            if os.path.exists('output/JPLEPH'):
                os.remove('output/JPLEPH')
            shutil.copy('source/JPLEPH', 'output/')
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
        os.system(r'testeph.exe < TESTPO')
        os.chdir('..')
    elif op == 'clean':
        if os.path.exists('output'):
            shutil.rmtree('output')
    else:
        raise NotImplementedError('%s Not Implement!'%op)
        
main()