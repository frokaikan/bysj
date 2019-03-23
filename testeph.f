      program TESTEPH
C
C    *****    JPL Planetary and Lunar Ephemerides read and test   *****
C
C                    Version : 15 March 2014
C
C     ---------------
C  
C     TESTEPH tests the JPL ephemeris reading and interpolating routine using
C     test printouts computed from the original ephemeris.
C
C     TESTEPH contains the reading and interpolating subroutines that are of 
C     eventual interest to the user.  Once TESTEPH is working correctly, the 
C     user can extract those subroutines.
C
C     The user must supply "testpo.XXX" to TESTEPH, via standard input.  
C     "testpo.XXX is the specially formatted text file that contains 
C     the test cases for the ephemeris, DEXXX.
C     e.g., on unix, type the command line;
C
C                          cat testpo.xxx | testeph.e
C
C     After the initial identifying text which is concluded by an "EOT" in
C     columns 1-3, the testpo.xxx file contains the following quantities:
C
C         JPL Ephemeris Number
C         Coordinate time:  TDB expressed as year:month:day
C         Coordinate time:  TDB, expressed as Julian Date
C         Target number:     1 - Mercury
C                            2 - Venus 
C                            3 - Earth (geocenter)
C                            4 - Mars (system barycenter)
C                            5 - Jupiter (system barycenter)
C                            6 - Saturn (system barycenter)
C                            7 - Uranus (system barycenter)
C                            8 - Neptune (system barycenter)
C                            9 - Pluto (system barycenter)
C                           10 - Moon
C                           11 - Sun
C                           12 - Solar System Barycenter
C                           13 - Earth-Moon Barycenter
C                           14 - 1980 IAU nutation angles
C                           15 - Lunar libration (Euler) angles
C                           16 - Lunar angular velocity
C                           17 - TT-TDB (at geocenter)
C
C         Center number:    [same codes as target number]
C
C         Coordinate:       [1-x, 2-y, 3-z, 4-dx/dt, 
C                            5-dy/dt, 6-dz/dt] for bodies
C                           [1-longitude, 2-obliquity, 
C                            3-long. rate, 4-oblq. rate] for nutation
C                           [1-phi, 2-theta,3-psi,
C                            4-dpsi/dt,5-dtheta/dt,6-dpsi/dt] for libration
C                           [1-omegax,2-omega-y,3-omega-z, 
C                            4-6 rates] for lunar Euler angle rates
C                           [1-TT-TDB, 2-rate] for TT-TDB.
C
C         Units:            Bodies: [au, au/day]
C                           Nutation angles: [radians, radians/day] 
C                           Libration angles: [radians, radians/day] 
C                           Euler angle rates: [radians/day, radians/day**2]
C                           TT-TDB: [seconds, seconds/day]
C
C     Note that the body positions are stored in units of km and km/s.
C     By default these are scaled by the value of the astronomical unit
C     read from the header of the ephemeris file to units of au and au/day.
C     The testpo.xx print out is in units of au and au/day.
C     The users of the PLEPH subroutine can choose other units for body
C     position and velocity by first calling PL_UNITS with the desired inputs.
C
C     For each test case input, TESTEPH
C
C         - computes the corresponding state from data contained 
C           in the binary ephemeris file,
C
C         - compares the data read with the value from the testpo.xxx file,
C
C         - writes an error message if the difference between
C           any of the state components is greater than 10**(-13).
C
C         - writes state and difference information for every 100th
C           test case processed.
C
C      This program is written in standard Fortran-77.  
C
C      HOWEVER, there are two parts which are compiler dependent; both have
C      to do with opening and reading a direct-access file.  They are dealt
C      with in the subroutine FSIZERi, i=1,3.  (There are three versions of 
C      this subroutine.
C
C      1) The parameter RECL in the OPEN statement is the number of units per 
C         record.  For some compilers, it is given in bytes; 
C         in some, it is given in single precision words.  
C         In the subroutine FSIZER of TESTEPH, 
C         the  parameter NRECL must  be set to 4 if RECL is given in bytes; 
C         NRECL must be set to 1 if RECL is given in words.  
C         (If in doubt, use 4 for UNIX; 1 for VAX)
C
C      2) Also for the OPEN statement, the program needs to know 
C         the exact value of RECL (number of single precision words 
C         times NRECL).  Since this varies from one JPL ephemeris to another, 
C         RECL must be determined somehow and given to the OPEN statement.  
C         There are three methods, depending upon the compiler.  
C         We have included three versions of the subroutine  FSIZER, 
C         one for each method.
C
C         a)  Use the INQUIRE statement to find the length of the records 
C             automatically before opening the file.  This works for VAX's; 
C             not in UNIX.
C
C         b)  Open the file with an arbitrary value of RECL, 
C             read the first record, and use the information on that record 
C             to determine the exact value of RECL.  
C             Then, close the file and re-open it with the exact value.
C             This seems to work for UNIX compilers as long as 
C             the initial value of RECL is less than the exact value 
C             but large enough to get the required information from the file.
C             (For some compilers, this doesn't work since you can open a file
C              only with the exact value of RECL.)
C
C         c)  Hardwire the value of RECL.
C                For  de200, RECL = NRECL * 1652
C                For  de405, RECL = NRECL * 2036
C                For  de406, RECL = NRECL * 1456
C                For  de414 through de429,  RECL = NRECL * 2036
C                For  de430 & de431, without TT-TDB; RECL = NRECL * 2036
C                                    with    TT-TDB; RECL = NRECL * 1964
C
C
C $ Disclaimer
C
C     THIS SOFTWARE AND ANY RELATED MATERIALS WERE CREATED BY THE
C     CALIFORNIA INSTITUTE OF TECHNOLOGY (CALTECH) UNDER A U.S.
C     GOVERNMENT CONTRACT WITH THE NATIONAL AERONAUTICS AND SPACE
C     ADMINISTRATION (NASA). THE SOFTWARE IS TECHNOLOGY AND SOFTWARE
C     PUBLICLY AVAILABLE UNDER U.S. EXPORT LAWS AND IS PROVIDED "AS-IS"
C     TO THE RECIPIENT WITHOUT WARRANTY OF ANY KIND, INCLUDING ANY
C     WARRANTIES OF PERFORMANCE OR MERCHANTABILITY OR FITNESS FOR A
C     PARTICULAR USE OR PURPOSE (AS SET FORTH IN UNITED STATES UCC
C     SECTIONS 2312-2313) OR FOR ANY PURPOSE WHATSOEVER, FOR THE
C     SOFTWARE AND RELATED MATERIALS, HOWEVER USED.
C
C     IN NO EVENT SHALL CALTECH, ITS JET PROPULSION LABORATORY, OR NASA
C     BE LIABLE FOR ANY DAMAGES AND/OR COSTS, INCLUDING, BUT NOT
C     LIMITED TO, INCIDENTAL OR CONSEQUENTIAL DAMAGES OF ANY KIND,
C     INCLUDING ECONOMIC DAMAGE OR INJURY TO PROPERTY AND LOST PROFITS,
C     REGARDLESS OF WHETHER CALTECH, JPL, OR NASA BE ADVISED, HAVE
C     REASON TO KNOW, OR, IN FACT, SHALL KNOW OF THE POSSIBILITY.
C
C     RECIPIENT BEARS ALL RISK RELATING TO QUALITY AND PERFORMANCE OF
C     THE SOFTWARE AND ANY RELATED MATERIALS, AND AGREES TO INDEMNIFY
C     CALTECH AND NASA FOR ALL THIRD-PARTY CLAIMS RESULTING FROM THE
C     ACTIONS OF RECIPIENT IN THE USE OF THE SOFTWARE.
C
       implicit none

       integer NMAX                    ! Maximum number of ephemeris constants 
       parameter (NMAX = 1000)

       character*6       NAMS(NMAX)    ! Names of ephemeris constants
       double precision  VALS(NMAX)    ! Values of ephemeris constants

       character*3  ALF3

       double precision  TDB            ! Ephemeris time, in Julian days
       double precision  PV(6)          ! Quantity requested 
       double precision  SS(3)          ! Start JD, end JD of ephemeris file
C                                       ! and span (days) of basic data block
       double precision  JDEPOC         ! Initial JD for integration
       double precision  XI
       double precision  DEL
       double precision TDBMIN, TDBMAX
       data TDBMIN / 99.D99/
       data TDBMAX /-99.d99/
  
       integer  I
       integer  LINE
       data LINE/0/
       integer  NCON,NTARG,NCTR,NCOORD
       integer  NPT
       data NPT/100/

       logical OKAY
       data OKAY/.true./

       logical AU_KM, DAY_SEC, IAU_AU
       data AU_KM /.true./
       data DAY_SEC/.true./
       data IAU_AU/.false./

C      Write a fingerprint to the screen.

       write(*,*) ' JPL TEST-EPHEMERIS program. ' //
     .            ' Last modified 15 March 2014.'

       call PL_UNITS(AU_KM , DAY_SEC , IAU_AU)

C     When called before first call to PLEPH or DPLEPH, PL_UNITS
C     allows overriding the default units returned for positions and velocities.
C
C     AU_KM        True  means output length unit is astronomical units
C                  False means output length unit is km
C
C     DAY_SEC      True means velocities are returned in length/day
C                  False means velocities are returned in length/second
C
C     IAU_AU       True means use value of astronomical unit adopted in 2012
C                       (149597870.700 km) if AU_KM is True
C                  False means use value of astronomical units used at time
C                        of ephemeris integration.
C                  (Note that the value of AU returned in the ephemeris
C                   constants will not be changed by this option).

C      Print the ephemeris constants.

       call  CONST (NAMS, VALS, SS, NCON)

       write (*,'(/3F14.2)') SS
       
       JDEPOC = 2440400.5d0

       do I = 1,NCON
         if (NAMS(I) .EQ. 'JDEPOC') JDEPOC = VALS(I)
         write(6,'(A8,D24.16)')NAMS(I),VALS(I)
       enddo

C     Skip the testpo.xxx comments at top of file

   1  continue

      read(*,'(a3)') ALF3
      if (ALF3 .ne. 'EOT') go to 1

      write(*,*) 
     & '  line -- jed --   t#   c#   x#   --- jpl value ---'//
     & '   --- user value --    -- difference --'
      write(*,*) 

C     Read a value from the test case; skip if not within the time-range
C     of the present version of the ephemeris

   2  continue

      read(*,'(15X,D10.1,3I3,F30.20)',END=9)  
     & TDB,NTARG,NCTR,NCOORD,XI

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      if (TDB .lt. SS(1)) go to 2
      if (TDB .gt. SS(2)) go to 2

      call  PLEPH ( TDB, NTARG, NCTR, PV )

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

C     For testing purposes DEL is the computation of the difference in
C       read values of the ephemeris converted from the export ascii files
C       versus those printed form the original integration.
C     The difference is checked for random parameters, 
C     one every 32 day interval.
C     The agreement is considered okay if DEL is less that 1e-13.
C     This corresponds to a few cm for body positions, and very small
C     values for velocities, and angles and their rates.
C       (A fractional test isn't suitable since sometimes the values will
C        be near zero for particular components.)
C     For lunar libration psi, NCOORD=15, the angle accumulates in time
C     so precision is lost after several centuries. 
C     This is handled below by scaling DEL down for psi, 
C     by 100 radians per year from the reference epoch,
c     as opposed to having different tolerances for different quantities.

      DEL = abs(PV(NCOORD)-XI)

      if(NTARG .eq. 15 .and. NCOORD .eq. 3)then
        DEL = DEL/(1.D0+100.D0*abs(TDB-JDEPOC)/365.25d0)
      endif

      LINE = LINE+1

      if ( mod(LINE,NPT) .eq. 0 )then
        write(*,200) LINE,TDB,NTARG,NCTR,NCOORD,XI,PV(NCOORD),DEL
      endif

      if(TDB .lt. TDBMIN) TDBMIN = TDB 
      if(TDB .gt. TDBMAX) TDBMAX = TDB 

 200  format(i6,f10.1,3i5,2f25.13,1e13.5)

C     Print out WARNING if difference greater than tolerance.

      if (DEL .ge. 1.d-13) then
        write(*,201)LINE,TDB,NTARG,NCTR,NCOORD,XI,PV(NCOORD),DEL
        OKAY = .false.
      endif

 201  format(/ '*****  WARNING : next difference >= 1.D-13  *****'//
     & I6,F10.1,3I3,2F25.13,1E13.5/' ')

      go to 2

   9  continue

      if(OKAY)then
        write(*,*)'TESTEPH checked successfully against ephemeris file'
        write(*,*)'over Julian day range ',TDBMIN,' to ',TDBMAX
      else
        write(*,*)'TESTEPH found problems with ephemeris file'
      endif

      stop
      end