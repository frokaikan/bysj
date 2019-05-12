#include <cstdio>
#include <inttypes.h>
extern "C" void pleph_(double*, int*, int*, double(*)[6]);
extern "C" void pl_units_(int*, int*, int*);

double pos[6];
void output(FILE* stream)
{
    std::fprintf(stream, "%0.10lf,%0.10lf,%0.10lf,,%0.10lf,%0.10lf,%0.10lf\n", 
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
}
int main()
{
    FILE* csv = fopen("out.csv", "w");
    int t = 1, f = 0;
    pl_units_(&f, &f, &t);
    for (double tx = 2454102; tx <= 2461770+1e-9; ++tx)
    {
        query(tx, 11, 3);
        output(csv);
    }
}