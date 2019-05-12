#include <cstdio>
#include <vector>
#include <inttypes.h>

extern "C" void pleph_(double*, int*, int*, double(*)[6]);
extern "C" void pl_units_(int*, int*, int*);

double pos[6];
void print()
{
    std::printf("Position :: %20.10lf %20.10lf %20.10lf\nSpeed    :: %20.10lf %20.10lf %20.10lf\n",
        pos[0],
        pos[1],
        pos[2],
        pos[3],
        pos[4],
        pos[5]
    );
}
void query(double time, int p1, int p2)
{
    pleph_(&time, &p1, &p2, &pos);
    print();
}
std::vector<double> save_pos()
{
    std::vector<double> ret(6);
    std::copy(pos, pos+6, ret.begin());
    return ret;
}
int main()
{
    int t = 1, f = 0;
    pl_units_(&f, &f, &t);
    double dt;
    std::scanf("%lf", &dt);
    query(dt, 11, 3);
    auto v1 = save_pos();
    query(dt, 10, 3);
    auto v2 = save_pos();
    for (int i=0; i<6; ++i)
        std::printf("part %d : %20.10f\n", i, v1[i]/v2[i]);
}