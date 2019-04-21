#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include "asc2eph_struct.cpp"

#define LOG_INFO

int main(int argc, char **argv)
{
    // parse options
    io_info o;
    // o.parse(argc, argv);
    if (!o.valid)
    {
        o.err << "Usage :: " << argv[0] << " [-i [input]] [-o [output]] [-l [log]] [-e [error]]" << std::endl;
        return 1;
    }
    
    // temporary variables
    std::string _;
    
    // constant
    const int oldmax = 400;
    const int nmax = 1000;
    
    // main function
    int group;
    int nrecl = 4;
    double 
        db2z = -99999999,
        t1 = -99999999,
        t2 = 99999999;
    if (nrecl != 4 && nrecl != 1)
    {
        o.err << "Please set nrecl first!\nDefault : 4";
        return 2;
    }
        
    // readin KSIZE
    int ksize;
    o.in >> _ >> ksize;
#ifdef LOG_INFO
    o.log << "ksize = " << ksize << std::endl;
#endif
    int irecsz = nrecl * ksize;
    
    // readin NCOEFF
    int ncoeff;
    o.in >> _ >> ncoeff;
    
    _.clear();
    // next group (1010)
    while ( _ != "GROUP" ) o.in >> _;
    o.in >> group;
    if (group != 1010)
    {
        o.err << "ERROR header position 1010";
        return 1010;
    }
    
    // TTL
    // Different from origin fortran
    std::string ttl;
    ttl += "KSIZE=";
    int cnt_ksize = 0;
    for ( int kk = ksize ; kk ; kk /= 10 ) ++cnt_ksize;
    for ( int cc = 6-cnt_ksize ; cc ; --cc ) ttl += ' ';
    ttl += std::to_string(ksize);
    ttl += ' ';
    _.clear();
    while (true)
    {
        o.in >> _;
        if ( _ == "GROUP" ) break;
        ttl += _ + ' ';
    }
    while ( static_cast<int>(ttl.size()) != 84*3) ttl += ' ';
#ifdef LOG_INFO
    o.log << ttl << std::endl;
#endif

    // next group (1030)
    while ( _ != "GROUP" ) o.in >> _;
    o.in >> group;
    if (group != 1030)
    {
        o.err << "ERROR header position 1030";
        return 1030;
    }
    
    // SS
    double ss[3];
    for ( int _i = 0 ; _i < 3 ; ++_i ) o.in >> ss[_i];
    
    _.clear();
    // next group (1040)
    while ( _ != "GROUP" ) o.in >> _ ;
    o.in >> group;
    if (group != 1040)
    {
        o.err << "ERROR header position 1040";
        return 1040;
    }
    
    // CNAM
    int N;
    o.in >> N;
    std::vector<std::string> cNam;
    for ( int _i = 0 ; _i < N ; ++_i )
    {
        o.in >> _;
        cNam.push_back(_);
    }
    int NCon = N;
    
    _.clear();
    // next group (1041)
    while ( _ != "GROUP" ) o.in >> _ ;
    o.in >> group;
    if (group != 1041)
    {
        o.err << "ERROR header position 1041";
        return 1041;
    }
    
    // CVAL
    o.in >> N;
    std::vector<double> cVal(N);
    for ( int _i = 0 ; _i < N ; ++_i ) o.in >> cVal[_i];
    double AU, EMRAT, NUMDE;
    for ( int _i = 0 ; _i < N ; ++_i )
    {
        if (cNam[_i] == "AU") AU = cVal[_i];
        if (cNam[_i] == "EMRAT") EMRAT = cVal[_i];
        if (cNam[_i] == "DENUM" ) NUMDE = cVal[_i];
    }
    o.log << AU << ' ' << EMRAT << ' ' << NUMDE << std::endl;
#ifdef LOG_INFO
    for ( int _i = 0 ; _i < N ; ++_i ) o.log << cNam[_i] << "\t=\t" << cVal[_i] << std::endl;
#endif
    
    _.clear();
    // next group (1050)
    while ( _ != "GROUP" ) o.in >> _ ;
    o.in >> group;
    if (group != 1050)
    {
        o.err << "ERROR header position 1050";
        return 1050;
    }
    
    // IPT LPT RPT TPT
    std::vector<int> vec1;
    while (true)
    {
        o.in >> _;
        if ( _ == "GROUP" ) break;
        vec1.push_back(std::stoi(_));
    }
    std::vector<int>::iterator p1 = vec1.begin();
    int sz = vec1.size();
    int ipt[3][12], lpt[3], rpt[3], tpt[3];
    for ( int _i = 0 ; _i < 3 ; ++_i )
    {
        for ( int _j = 0 ; _j < 12 ; ++_j ) ipt[_i][_j] = *p1++;
        lpt[_i] = *p1++;
        if (sz == 3*15)
        {
            rpt[_i] = *p1++;
            tpt[_i] = *p1++;
        }
        else if (sz == 3*13)
        {
            rpt[_i] = tpt[_i] = 0;
        }
        else
        {
            o.err << "UNKNOWN GROUP 1050 size " << sz << std::endl;
            return 10501;
        }
    }
    
    // next group (1070) and last group
    while ( _ != "GROUP" ) o.in >> _ ;
    o.in >> group;
    if (group != 1070)
    {
        o.err << "ERROR header position 1070";
        return 1070;
    }
    
    // header_pre
    o.new_block(irecsz);
    o.new_block(irecsz);
    
    // ephemeris
    // pass ending 0.0000000000000000D+00
    int nrw;
    while (o.in)
    {
        bool flag = true;
        o.in >> _;
        for (char x : _)
        {
            if (not ('0' <= x && x <= '9')) break;
            flag = false;
        }
        if (!flag) break;
    }
    
    nrw = std::stoi(_);
    o.in >> ncoeff;
    std::vector<double> db;
    for ( int _i = 0 ; _i < ncoeff ; _i += 3 )
    {
        int kp2 = std::min(_i+3, ncoeff);
        for ( int _j = _i ; _j < kp2 ; ++_j )
        {
            while (static_cast<int>(db.size()) <= _j) db.push_back(0);
            o.in >> db[_j];
            if (!o.in)
            {
                o.err << "ERROR Reading 1st coeffs" << std::endl;
                return 10701;
            }
        }
    }
    bool first = true;
    int nrout = 0;
    while (o.in && db[1] < t2)
    {
        if (2 * ncoeff != ksize)
        {
            o.err << "2*ncoeff != ksize" << std::endl;
            return 10702;
        }
        if (db[1] >= t1 && db[0] >= db2z)
        {
            if (first)
            {
                db2z = db[0];
                first = false;
            }
            if (db[0] != db2z)
            {
                o.err << nrw << "nd do not overlap or abut" << std::endl;
                return 10703;
            }
            db2z = db[1];
            ++nrout;
            for ( int _i = 0 ; _i < ncoeff ; ++_i ) o << db[_i];
            o.add_out(irecsz);
            if (!o.out)
            {
                o.err << nrout << "th record ERROR" << std::endl;
                return 10704;
            }
            if (nrout == 1)
            {
                ss[0] = db[0];
                ss[2] = db[1] - db[0];
            }
            ss[1] = db[1];
#ifdef LOG_INFO
            if (nrout % 100 == 1)
            {
                if (db[0] >= t1)
                    o.log << nrout << " EPHEMERIS RECORDS WRITTEN.  LAST JED = " << db[1] << std::endl;
                else
                    o.log << " Searching for first requested record... " << std::endl;
            }
#endif
        }
        
        // pass ending 0.0000000000000000D+00
        while (o.in)
        {
            bool flag = true;
            o.in >> _;
            for (char x : _)
            {
                if (not ('0' <= x && x <= '9'))
                {
                    flag = false;
                    break;
                }
            }
            if (flag) break;
        }
    
        nrw = std::stoi(_);
        o.in >> ncoeff;
        
        if (o.in) for ( int _i = 0 ; _i < ncoeff ; _i += 3 )
        {
            int kp2 = std::min(_i+3, ncoeff);
            for ( int _j = _i ; _j < kp2 ; ++_j )
            {
                while (static_cast<int>(db.size()) <= _j) db.push_back(0);
                o.in >> db[_j];
            }
            if (!o.in)
            {
                o.err << "ERROR Reading nth coeffs" << std::endl;
                return 10701;
            }
        }
    }
#ifdef LOG_INFO
    o.log << nrout << " EPHEMERIS RECORDS WRITTEN.  LAST JED = " << db[1];
#endif

    // header
    const std::string ZERO = {'\0', '\0', '\0', '\0', '\0', '\0'};
    for ( int _i = cNam.size() ; _i < oldmax ; ++_i )
    {
        cNam.push_back(ZERO);
        cVal.push_back(0);
    }
    o.seekp(0);
    if (NCon <= oldmax)
    {
        o << ttl;
        for ( int _i = 0 ; _i < oldmax ; ++_i ) o << cNam[_i];
        for ( int _i = 0 ; _i < 3 ; ++_i ) o << ss[_i];
        o << NCon << AU << EMRAT;
        for ( int _j = 0 ; _j < 12 ; ++_j ) for ( int _i = 0 ; _i < 3 ; ++_i ) o << ipt[_i][_j];
        o << static_cast<int>(NUMDE);
        for ( int _i = 0 ; _i < 3 ; ++_i ) o << lpt[_i];    
        if ( sz == 3*15 )
        {
            for ( int _i = 0 ; _i < 3 ; ++_i ) o << rpt[_i];        
            for ( int _i = 0 ; _i < 3 ; ++_i ) o << tpt[_i];
        }
    }
    else
    {
        o << ttl;
        for ( int _i = 0 ; _i < oldmax ; ++_i ) o << cNam[_i];
        for ( int _i = 0 ; _i < 3 ; ++_i ) o << ss[_i];
        o << NCon << AU << EMRAT;
        for ( int _j = 0 ; _j < 12 ; ++_j ) for ( int _i = 0 ; _i < 3 ; ++_i ) o << ipt[_i][_j];
        o << static_cast<int>(NUMDE);
        for ( int _i = 0 ; _i < 3 ; ++_i ) o << lpt[_i];
        for ( int _i = oldmax ; _i < NCon ; ++_i ) o << cNam[_i];
        if ( sz == 3*15 )
        {
            for ( int _i = 0 ; _i < 3 ; ++_i ) o << rpt[_i];        
            for ( int _i = 0 ; _i < 3 ; ++_i ) o << tpt[_i];
        }
    }
    o.nxt_block(irecsz);
    if (!o.out)
    {
        o.err << "1st record not written because of error" << std::endl;
        return 10709;
    }
    if (NCon <= oldmax) for ( int _i = 0 ; _i < oldmax ; ++_i ) o << cVal[_i];
    else for ( int _i = 0 ; _i < NCon ; ++_i ) o << cVal[_i];
    o.add_out(irecsz);
    if (!o.out)
    {
        o.err << "2nd record not written because of error" << std::endl;
        return 10709;
    }
    o.close();
    return 0;
}
