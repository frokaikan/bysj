program BINDING_EPH
author : frokaikan
It's free to use, you can use or change it without my authorization.

How to use this program?
    You need :
        Linux : 
            GCC (GNU Compiler Collections)
            Python3
        Windows : 
            MinGW (Minimum GCC for Windows)
            Python3
    You should : ("xxx" can be any name)
        1. Put all your file to "source/" directory.
        2. Rename your header file to "xxx.header". (Necessary)
        3. choose ONE of the following three steps : 
            3-1. Rename all your ascii file to "xxx.asc", and let them sorted in lexicographical order. (If you have DE format ascii file)
                This program will automatically change fortran-style float number (e.g. 1.2D+03) to C-style float number (e.g. 1.2E+03)
            3-2. Rename your binary file to "JPLEPH". (If you have DE format binary file)
            3-3. Rename your BINDED ascii file to "xxx.in". (If you have binded your .header file and .asc files)
        (Just for test) 4. Rename your testpo file to "xxx.testpo". If you don't have testpo file, ignore this step.
        5. type "make" (Linux) or "mingw32-make" (Windows), and wait.
        6. find your JPLEPH file at "output/" directory. The outputs are :
            6-1. asc2eph.exe :: change your .in file to JPLEPH.
            6-2. JPLEPH :: the binary eph file.
            6-3. libeph.so :: the Shared Object (Dynamic Link Library) contains all JPL functions.
            6-4. testeph.exe (Need libeph.so) :: test your JPLEPH file.
        (Just for test) 7. type "make test" (Linux) or "mingw32-make test" (Windows) to run testeph.
        
If you have any problem, please send an e-mail to "541240857@qq.com". I'll reply you ASAP.
Thanks for using this program.