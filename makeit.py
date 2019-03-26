# !/usr/bin/env python3
# coding = utf-8
# @author : frokaikan

import os
import sys
import shutil
import re
import subprocess

def check_input():
    os.chdir('source')
    if os.path.exists('in.eph'):
        os.remove('in.eph')
    files = [x for x in os.listdir('.')]
    # No directory, all files must be '.header', '.asc', '.in', '.testpo', or 'JPLEPH'
    for f in files:
        if os.path.isdir(f):
            print('%s is a directory'%f)
            return 0
        if not (f.endswith('.header') or f.endswith('.asc') or f == 'JPLEPH' or f.endswith('.in') or f.endswith('.testpo')):
            print('Invalid file : %s'%f)
            return 0
    # Must be one .header file
    header_cnt = 0
    for f in files:
        if f.endswith('.header'):
            header_cnt += 1
    if header_cnt != 1:
        print('%d .header file'%header_cnt)
        return 0
    # any JPLEPH?
    jpleph = False
    for f in files:
        if f == 'JPLEPH':
            jpleph = True
            break
    # any .asc?
    asc = False
    for f in files:
        if f.endswith('.asc'):
            asc = True
            break
    # any .in?
    in_f = 0
    for f in files:
        if f.endswith('.in'):
            in_f += 1
    if in_f > 1:
        raise NotImplementedError('at most ONE .in')
    # One of the Three options?
    if jpleph + asc + in_f != 1:
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

def do_compile():
    def c(out_file, in_file, command):
        if os.path.exists(out_file) and os.stat(out_file).st_mtime > os.stat(in_file).st_mtime:
            return
        print('run : %s'%command)
        os.system(command)
    c('output/asc2eph.exe', 'asc2eph.cpp', 'g++ -O3 -g3 -std=gnu++14 -o output/asc2eph.exe asc2eph.cpp')
    c('output/libeph.so', 'libeph.f', 'gfortran -O3 -g3 -fPIC -shared -o output/libeph.so libeph.f')
    c('output/testeph.exe', 'testeph.f', 'gfortran -O3 -g3 -o output/testeph.exe testeph.f -L. -Loutput output/libeph.so')

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
    
def main():
    op = ''
    if len(sys.argv) >= 2:
        op = sys.argv[1]
    else:
        raise NotImplementedError('Usage :: python %s <op>'%__file__)
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
            print('gen JPLEPH...')
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