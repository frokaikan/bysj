#include <cstdio>
int main()
{
    unsigned int t = 0x11223344;
    unsigned char* pt = reinterpret_cast<unsigned char*>(&t);
    if (pt[0] == 0x11 && pt[1] == 0x22 && pt[2] == 0x33 && pt[4] == 0x44)
        std::printf("Big Endian\n");
    else if (pt[3] == 0x11 && pt[2] == 0x22 && pt[1] == 0x33 && pt[0] == 0x44)
        std::printf("Little Endian\n");
    else
        std::printf("Unknown Error. Please mail to me :: 541240857@qq.com");
}