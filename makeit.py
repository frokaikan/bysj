# !/usr/bin/env python3
# coding = utf-8
# @author : frokaikan

import os
import sys
import shutil
import re

def check_input():
    os.chdir('source')
    if os.path.exists('in.eph'):
        os.remove('in.eph')
    files = [x for x in os.listdir('.')]
    # No directory, all files must be '.header', '.asc', or 'JPLEPH'
    for f in files:
        if os.path.isdir(f):
            print('%s is a directory'%f)
            return 0
        if not (f.endswith('.header') or f.endswith('.asc') or f == 'JPLEPH' or f.endswith('.in')):
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
    # any .asc or .in?
    asc = False
    for f in files:
        if f.endswith('.asc'):
            asc = True
            break
    in_f = 0
    for f in files:
        if f.endswith('.in'):
            in_f += 1
    if in_f > 1:
        raise NotImplementedError('At most ONE .in')
    if in_f:
        asc = True
    # Either jpleph or asc?
    if jpleph and asc:
        print('Can\'t exists both JPLEPH and .asc')
        return 0
    if not jpleph and not asc:
        print('No JPLEPH and NO .asc')
        return 0
    os.chdir('..')
    if asc:
        if in_f:
            return 2
        else:
            return 1
    else:
        return 3

def do_compile():
    def c(out_file, in_file, command):
        if os.path.exists(out_file) and os.stat(out_file).st_mtime > os.stat(in_file).st_mtime:
            return
        print('run : %s'%command)
        os.system(command)
    c('output/asc2eph.exe', 'asc2eph.cpp', 'g++ -O3 -g3 -std=gnu++14 -o output/asc2eph.exe asc2eph.cpp')
    c('output/libeph.o', 'libeph.f', 'gfortran -O3 -g3 -o output/libeph.o -c libeph.f')
    c('output/testeph.exe', 'testeph.f', 'gfortran -O3 -g3 -o output/testeph.exe testeph.f output/libeph.o')

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
                shutil.copy('source/in.eph', 'source/auto_gen.in')
                if os.path.exists('output/in.eph'):
                    os.remove('output/in.eph')
                shutil.move('source/in.eph', 'output/in.eph')
            else:
                in_f = [f for f in os.listdir('source') if f.endswith('.in')][0]
                if os.path.exists('output/in.eph'):
                    os.remove('output/in.eph')
                shutil.copy('source/%s'%in_f, 'output/in.eph')
            os.chdir('output')
            os.system('asc2eph.exe < in.eph')
            os.chdir('..')
        elif c == 3:
            if os.path.exists('output/JPLEPH'):
                os.remove('output/JPLEPH')
            shutil.copy('source/JPLEPH', 'output/')
    elif op == 'test':
        os.chdir('output')
        with os.popen(r'testeph.exe < in.eph', 'r') as f:
            print(f.read())
        os.chdir('..')
    elif op == 'clear':
        if os.path.exists('output'):
            shutil.rmtree('output')
        if os.path.exists('source/in.eph'):
            os.remove('source/in.eph')
        if os.path.exists('source/auto_gen.in'):
            os.remove('source/auto_gen.in')
    else:
        raise NotImplementedError('%s Not Implement!'%op)
main()