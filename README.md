program BINDING_EPH
===================
author : frokaikan<br>
It's free to use, you can use or change it without my authorization.<br>
<br>
How to use this program?
------------------------
You need :<br>
>   Linux : <br>
>>      GCC (GNU Compiler Collections)<br>
>>      Python3<br>
>   Windows : <br>
>>      MinGW (Minimum GCC for Windows)<br>
>>      Python3<br>
You should : ("xxx" can be any name)<br>
>   1. Put all your file to "source/" directory.<br>
>   2. Rename your header file to "xxx.header". (Necessary)<br>
>   3. choose ONE of the following three steps : <br>
>>      3-1. Rename all your ascii file to "xxx.asc", and let them sorted in lexicographical order. (If you have DE format ascii file)<br>
>>>          This program will automatically change fortran-style float number (e.g. 1.2D+03) to C-style float number (e.g. 1.2E+03)<br>
>>      3-2. Rename your binary file to "JPLEPH". (If you have DE format binary file)<br>
>>      3-3. Rename your BINDED ascii file to "xxx.in". (If you have binded your .header file and .asc files)<br>
>   (Just for test) 4. Rename your testpo file to "xxx.testpo". If you don't have testpo file, ignore this step.<br>
>   5. type "make" (Linux) or "mingw32-make" (Windows), and wait.<br>
>   6. find your JPLEPH file at "output/" directory. The outputs are :<br>
>>      6-1. asc2eph.exe :: change your .in file to JPLEPH.<br>
>>      6-2. JPLEPH :: the binary eph file.<br>
>>      6-3. libeph.so :: the Shared Object (Dynamic Link Library) contains all JPL functions.<br>
>>      6-4. testeph.exe (Need libeph.so) :: test your JPLEPH file.<br>
>   (Just for test) 7. type "make test" (Linux) or "mingw32-make test" (Windows) to run testeph.<br>
<br>
If you have any problem, please send an e-mail to "541240857@qq.com". I'll reply you ASAP.<br>
Thanks for using this program.<br>