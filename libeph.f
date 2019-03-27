      subroutine PLEPH( TDB, NTARG, NCENT, PV)
C
C++++++++++++++++++++++++++
C
C     PLEPH reads the JPL planetary ephemeris file.
C     For 'bodies' (Sun, Moon, planets, Earth-Moon barycenter, 
C     solar-system-barycenter) the position and velocity of the 'body' NTARG 
C     are given with respect to the 'body' NCENT. 
C     
C     Auxiliary values are 1980 IAU nutation angles, lunar libration angles,
C     lunar Euler angle rates, and TT-TDB may also be available.
C
C     TDB is Ephemeris coordinate time, expressed in Julian days
C
C     The numbering for NTARG and NCENT is:
C
C                 1 = Mercury
C                 2 = Venus
C                 3 = Earth
C                 4 = Mars system barycenter
C                 5 = Jupiter system barycenter
C                 6 = Saturn system barycenter
C                 7 = Uranus system barycenter
C                 8 = Neptune system barycenter
C                 9 = Pluto system barycenter
C                10 = Moon (of Earth)
C                11 = Sun
C                12 = Solar-System Barycenter
C                13 = Earth-Moon barycenter
C                14 = Nutations (Longitude and Obliquity)
C                15 = Lunar Euler angles: phi, theta, psi
C                16 = Lunar angular velocity: omegax, omegay, omegaz
C                17 = TT - TDB
C
C     Note that not all ephemerides include all of the above quantities.
C     When a quantity is requested that is not on the file,
C     a warning is printed and the components of PV are set to -99.d99,
C     which is not a valid value for any quantity.
C
C      For nutations, librations, and TT-TDB,  NCENT is ignored     
C
C      PV(6)    Returned values; 
C 
C            For 'bodies', x,y,z, and vx,vy,vz are returned.
C            The values stored on the files are in units of km and km/s.
C            By default, the positions are scaled the value of the astronomical
C            unit used in the ephemeris integration to return units of 
C            au and au/day.
C            The user can override the default units by calling PLUNITS 
C            as described below.
C
C            For nutation angles, the returned values in PV are 
C                 [1-longitude, 2-obliquity, 3-long. rate, 4-oblq. rate]
C                 in units of radians and radians/day.
C            
C            For libration angles, the returned values in PV are 
C                 [1-omegax, 2-omega-y, 3=omega-z, 4-6 rates]
C                 in units of radians/day and radians/day**2.
C            
C            For TDB-TT, PV(1) is TT-TDB in seconds, 
C                        PV(2) rate of change of TT-TDB in sec/day
C
C     In addition to the main entry PLEPH, there are optional entry points.
C
C
C     entry DPLEPH( TDB2, NTARG, NCENT, PV)
C
C     Inputs TDB2, NTARG, NCENT and output PV are as described above for PLEPH,
C     except that TDB2 is a two-element array allowing the possibility
C     of specifying the TDB coordinate time with greater numerical precision.
C     Typically TDB2(1) is set to the integer number of the Julian day,
C     and TDB(2) is set to the fraction of the Julian day.
C
C     Note that with ephemeris data in 32-day long blocks, the 
C     precision of the ephemeris lookup time is limited to approximately
C     ~1.e-15*(32 days) = ~3 nanoseconds
C     since the Chebyshev coefficients are interpolated using a
C     double precision representation of a fraction of the block time span.
C
C
C     entry CONST(NAMS,VALS,SS,NCON)
C
C     No input arguments, output quantities are:
C
C        NAMS       6-character names of ephemeris constants
C        VALS       double precision values of ephemeris constants
C        SS         earliest TDB time on ephemeris (Julian days),
C                   latest TDB time on ephemeris   (Julian days), and
C                   number of days covered by each ephemeris record
C        NCON       number of ephemeris constants
C
C
C     entry PL_UNITS(AU_KM,DAY_SEC,IAU_AU)
C
C     When called before first call to PLEPH or DPLEPH or CONST, this entry
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
C
C     Defaults correspond to PL_UNITS(.TRUE. , .TRUE. , .FALSE.)
C
C     Last updated 14 March 2015
C
C$ Disclaimer
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
C++++++++++++++++++++++++++

      implicit none

      integer NMAX
      parameter (NMAX=3000)

C++++++++++++++++++++++++++

C     arguments for main call PLEPH

C++++++++++++++++++++++++++

      double precision TDB
      integer          NTARG,NCENT

      double precision PV(6)

C     argument for DPLEPH

      real*8         TDB2(2)

C++++++++++++++++++++++++++

C     arguments for return CONST

C++++++++++++++++++++++++++

      character*6      NAMS1(*)
      double precision VALS1(*)
      double precision SS1(*)
      integer NCON1

C++++++++++++++++++++++++++

C     arguments for PL_UNITS (overwrite default values in PLEPH)
      
C++++++++++++++++++++++++++

      logical AU_KM1
      logical DAY_SEC1
      logical IAU_AU1

C++++++++++++++++++++++++++

C     internal variables

C++++++++++++++++++++++++++

      character*6      NAMS(NMAX)
      double precision VALS(NMAX)
      double precision SS(3)
      double precision data(NMAX)
      double precision PV1(6),PV2(6),PVM(6),PVB(6)

      integer NCON

      double precision T1,T2,TF,TF1,TF2
      double precision FACTE,FACTM,XSCALE,VSCALE,SUMT
      integer          NRFILE,NCOEFF
      integer          IPT(3,15)

      double precision SECSPAN
      double precision SECDAY/86400.D0/

      integer IPVA     /2/

      integer          KODE(15)
      data KODE        /1,2,13,4,5,6,7,8,9,13,11,0,3,3,15/

      logical          AU_KM    /.true./
      logical          DAY_SEC  /.true./
      logical          IAU_AU   /.false./

      logical          FIRST    /.true./
      logical          RDCONST  /.false./

      integer          I
      integer          NRREC / 0/

      save

C++++++++++++++++++++++++++

C     Main entry point PLEPH

      T1 = TDB
      T2 = 0.D0

      go to 1

C++++++++++++++++++++++++++

      entry DPLEPH( TDB2, NTARG, NCENT, PV)

C     Typically TDB2(1) is set to the integer number of the Julian day,
C     and TDB(2) is set to the fraction of the Julian day.

      T1 = TDB2(1)
      T2 = TDB2(2)

      go to 1

C++++++++++++++++++++++++++

      entry CONST(NAMS1,VALS1,SS1,NCON1)
C
C     This entry allows one to retrieve all of the constants associated with
C     the ephemeris file. The values returned are copies of the values
C     read off the ephemeris file and saved within PLEPH.
C
C     There is no INPUT
C
C     OUTPUT:
C
C     NCON           [integ.] : number of ephemeris constants
C     NAMS           [char*6] : names of NCON ephemeris constants
C     VALS           [d.p.]   : values of NCON ephemeris constants
C     SS(3)          [d.p.]   : SS(1) is starting JED of the ephemeris file
C                               SS(2) is  ending JED of the ephemeris file
C                               SS(3) is the length(in days) of a file record
C
      RDCONST = .true.

C++++++++++++++++++++++++++

 1    continue

      if (FIRST) then 
        call READHD( 
     &       AU_KM,DAY_SEC,IAU_AU,
     &       NMAX,NCON,NAMS,VALS,SS,IPT,
     &       FACTE,FACTM,XSCALE,VSCALE,
     &       NRFILE,NCOEFF)
         if(NCOEFF .gt. NMAX)stop 'Coefficient array too small in PLEPH' 
         FIRST = .false.
         SECSPAN = SECDAY * SS(3)
         do I = 1,NMAX
           DATA(I) = -999999999999999.d0
         enddo
       endif

      if(RDCONST) then

        NCON1 = NCON
        do I = 1,NCON
          NAMS1(I) = NAMS(I)
          VALS1(I) = VALS(I)
        enddo

        do I = 1,3
          SS1(I) = SS(I)
        enddo
        RDCONST = .false.
        return
      endif

C-----------------------------------------------------------------------
C     start main ephemeris lookup operation
C-----------------------------------------------------------------------

C-----------------------------------------------------------------------
C     first check to see if NTARG and NCENT in allowed ranges
C-----------------------------------------------------------------------

      if (NTARG .le. 0)  stop 'invalid NTARG < 0 in PLEPH'
      if (NTARG .gt. 17) stop 'invalid NTARG >17 in PLEPH'
      if (NCENT .le. 0)then
        if(NTARG .lt. 14) stop 'invalid NCENT < 0 in PLEPH'
      endif
      if (NCENT .gt. 13)then
        if(NTARG .lt. 14) stop 'invalid NCENT > 13 in PLEPH'
      endif

      if(NTARG .le. 13 .and. NCENT .ge. 14)then
        stop 'invalid NCENT >13 in for body PLEPH'
      endif

      if(NTARG .le. 13 .and. NTARG .eq. NCENT)then
        do i=1,6
          PV(I) = 0.d0
        enddo
        return
      endif

C-----------------------------------------------------------------------
C     determine which data record needed; read in if not already in DATA array
C-----------------------------------------------------------------------

      SUMT = T1+T2

      if (SUMT .lt. SS(1)) stop 'input time before file start in PLEPH'
      if (SUMT .gt. SS(2)) stop 'input time after  file start in PLEPH'

      I = INT( (SUMT-SS(1))/SS(3) ) + 3
      if(SUMT .eq. SS(2)) I = I - 1

      if (I .ne. NRREC)then
        NRREC = I
        read (NRFILE, rec = NRREC, ERR = 99)(DATA(I),I=1,NCOEFF)
      endif

      TF1 = dble(int(T1))
      TF2 = T1-TF1
      TF  = (TF1-DATA(1))/SS(3)
      TF  = TF + ((TF2+T2)/SS(3))

C-----------------------------------------------------------------------
C     do lookups for nutations, Euler angles, omega, or TT-TDB
C     which do not require a center, and might not be on file
C-----------------------------------------------------------------------

C     nutation

      if(NTARG .eq. 14) then
        if(IPT(1,12) .gt. 0  .and. IPT(2,12)*IPT(3,12) .ne. 0)then
          call INTCHB( DATA(IPT(1,12)), TF, SECSPAN,
     *                 IPT(2,12), 2, IPT(3,12), IPVA, PV)
          PV(3) = SECDAY*PV(3)   ! always convert radian/second to radian/day
          PV(4) = SECDAY*PV(4)
          PV(5) = -99.D99
          PV(6) = -99.D99
          return
        else
          write(6,*)'Nutations requested but not found on file'
          do I = 1,6
            PV(I) = -99.d99
          enddo
        endif
        return
      endif

C     Lunar mantle Euler angles

      if(NTARG .eq. 15) then
        if(IPT(1,13) .gt. 0  .and. IPT(2,13)*IPT(3,13) .ne. 0)then
          call INTCHB( DATA(IPT(1,13)), TF, SECSPAN,
     *                 IPT(2,13), 3, IPT(3,13), IPVA, PV)
          PV(4) = SECDAY*PV(4)   ! always convert radian/second to radian/day
          PV(5) = SECDAY*PV(5)
          PV(6) = SECDAY*PV(6)
          return
        else
          write(6,*)'Mantle Euler angles requested but not on file'
          do I = 1,6
            PV(I) = -99.d99
          enddo
        endif
        return
      endif

C     Lunar mantle angular velocity

      if(NTARG .eq. 16) then
        if(IPT(1,14) .gt. 0  .and. IPT(2,14)*IPT(3,14) .ne. 0)then
          call INTCHB( DATA(IPT(1,14)), TF, SECSPAN,
     *                 IPT(2,14), 3, IPT(3,14), IPVA, PV)
          PV(4) = SECDAY*PV(4)   ! always convert to radian/day**2
          PV(5) = SECDAY*PV(5)
          PV(6) = SECDAY*PV(6)
          return
        else
          write(6,*)'Mantle angular velocity requested but not on file'
          do I = 1,6
            PV(I) = -99.d99
          enddo
        endif
        return
      endif

C     TT-TDB

      if(NTARG .eq. 17) then
        if(IPT(1,15) .gt. 0  .and. IPT(2,15)*IPT(3,15) .ne. 0)then
          call INTCHB( DATA(IPT(1,15)), TF, SECSPAN,
     *                 IPT(2,15), 1, IPT(3,15), IPVA, PV)
          PV(2) = SECDAY*PV(2)   ! always convert second/second to second/day
          do I = 3,6
            PV(I) = -99.d99
          enddo
          return
        else
          write(6,*)'TT-TDB requested but not found on file'
          do I = 1,6
            PV(I) = -99.d99
          enddo
        endif
        return
      endif

C-----------------------------------------------------------------------
C     do lookups for bodies
C-----------------------------------------------------------------------

      if(NTARG .eq. 10 .and. NCENT .eq. 3)then
        call INTCHB( DATA(IPT(1,10)), TF, SECSPAN,
     *               IPT(2,10), 3, IPT(3,10), IPVA, PVM)
        do I = 1,3
          PV(i)   = PVM(i)*XSCALE
          PV(i+3) = PVM(i+3)*VSCALE
        enddo
        return
      endif

      if(NTARG .eq. 3 .and. NCENT .eq. 10)then
        call INTCHB( DATA(IPT(1,10)), TF, SECSPAN,
     *               IPT(2,10), 3, IPT(3,10), IPVA, PVM)
        do I = 1,3
          PV(i)   = -PVM(i)*XSCALE
          PV(i+3) = -PVM(i+3)*VSCALE
        enddo
        return
      endif

      do I = 1,6
        PV1(I) = 0.d0
        PV2(I) = 0.d0
      enddo

      if(NTARG .eq. 3 .or. NTARG .eq. 10 .or.
     &   NCENT .eq. 3 .or. NCENT .eq. 10)then

         call INTCHB( DATA(IPT(1,10)),
     *               TF, SECSPAN, IPT(2,10), 3, IPT(3,10), IPVA, PVM)
         call INTCHB( DATA(IPT(1,3)),
     *               TF, SECSPAN, IPT(2,3),  3, IPT(3,3),  IPVA, PVB)

        if(NTARG .eq. 3 .or. NTARG .eq. 10)then

          if(NCENT .lt. 12)then
            call INTCHB( DATA(IPT(1,NCENT)),TF, SECSPAN,
     *                 IPT(2,NCENT), 3, IPT(3,NCENT), IPVA, PV2)
          else if(NCENT .eq. 13)then
            call INTCHB( DATA(IPT(1,3)),TF, SECSPAN,
     *                 IPT(2,3), 3, IPT(3,3), IPVA, PV2)
          endif

          if(NTARG .eq. 3)then
            do I = 1,6
              PV(I) = PVB(I) - FACTE*PVM(I) - PV2(I)
            enddo
          else
            do I=1,6
              PV(I) = PVB(I) - FACTM*PVM(I) - PV2(I)
            enddo
          endif

        else 

          if(NTARG .lt. 12) then
            call INTCHB( DATA(IPT(1,NTARG)),TF, SECSPAN,
     *                 IPT(2,NTARG), 3, IPT(3,NTARG), IPVA, PV1)
          else if (NTARG .eq. 13)then
            call INTCHB( DATA(IPT(1,3)),TF, SECSPAN,
     *                 IPT(2,3), 3, IPT(3,3), IPVA, PV1)
          endif

          if(NCENT .eq. 3)then
            do I = 1,6
              PV(I) = PV1(I) - (PVB(I) - FACTE*PVM(I))
            enddo
          else
            do I=1,6
              PV(I) = PV1(I) - (PVB(I) - FACTM*PVM(I))
            enddo
          endif
        endif

        do I = 1,3
          PV(i)   = PV(i)*XSCALE
          PV(i+3) = PV(i+3)*VSCALE
        enddo
        return
      endif

C -- Only cases left involve neither Earth nor Moon

      if(NTARG .lt. 12) then
        call INTCHB( DATA(IPT(1,NTARG)),TF, SECSPAN,
     *                 IPT(2,NTARG), 3, IPT(3,NTARG), IPVA, PV1)
      else if (NTARG .eq.13)then
        call INTCHB( DATA(IPT(1,3)),TF, SECSPAN,
     *                 IPT(2,3), 3, IPT(3,3), IPVA, PV1)
        endif
        
      if(NCENT .lt. 12)then
        call INTCHB( DATA(IPT(1,NCENT)),TF, SECSPAN,
     *                 IPT(2,NCENT), 3, IPT(3,NCENT), IPVA, PV2)
      else if (NCENT .eq. 13)then
        call INTCHB( DATA(IPT(1,3)),TF, SECSPAN,
     *                 IPT(2,3), 3, IPT(3,3), IPVA, PV2)
      endif

      do I = 1,3
        PV(i)   = (PV1(I) - PV2(I) )     * XSCALE
        PV(i+3) = (PV1(I+3) - PV2(I+3) ) * VSCALE
      enddo
      return

C-----------------------------------------------------------------------

      entry PL_UNITS(AU_KM1, DAY_SEC1, IAU_AU1)

      AU_KM   = AU_KM1
      DAY_SEC = DAY_SEC1
      IAU_AU  = IAU_AU1

      return

C-----------------------------------------------------------------------

 99   continue

      write(6,*)'Error reading ephemeris data record in PLEPH'
      write(6,*)'T1,T2 = ',T1,T2
      write(6,*)'Record not found = ',NRREC
      stop

      end
C
CCC
C
      subroutine READHD(
     &           AU_KM,DAY_SEC,IAU_AU,
     &           NMAX,NCON,NAMS,VALS,SS,IPT,
     &           FACTE,FACTM,XSCALE,VSCALE,
     &           NRFILE,NCOEFF)
C
C     Read the first record of a JPL binary planetary ephemeris file
C     to determine the record length, return the ephemeris constants,
C     and calculate scale factors to be used in PLEPH.
C
C$ Disclaimer
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

C     Input parameters:

      logical AU_KM
      logical DAY_SEC
      logical IAU_AU
      integer NMAX

C     Output parameters: 

      integer          NCON
      integer          NCOEFF
      integer          NRFILE
      integer          IPT(3,15)
      double precision VALS(*),SS(3)
      double precision FACTE,FACTM
      double precision XSCALE,VSCALE
      character*6      NAMS(*)

C     Local variables

      integer   OLDMAX
      parameter ( OLDMAX = 400)

      integer NRECL/0/
      integer KSIZE
      integer NUMDE
      data NUMDE /0/
      character*6 TTL (14,3)
      character*80 NAMFIL

      double precision AU,EMRAT
      double precision iau/149597870.700d0/

      integer I,J,K,IRECSZ

C ************************************************************************
C ************************************************************************

C     The user must select one of the following by deleting the 'C' in column 1

C ************************************************************************

C        call FSIZER1(NRECL,KSIZE,NRFILE,NAMFIL)
C        call FSIZER2(NRECL,KSIZE,NRFILE,NAMFIL)
         call FSIZER3(NRECL,KSIZE,NRFILE,NAMFIL)

C ************************************************************************
C ************************************************************************

      if(NRECL .EQ. 0) WRITE(*,*)'  ***** FSIZER IS NOT WORKING *****'

      IRECSZ = NRECL*KSIZE
      NCOEFF = KSIZE/2

      open(NRFILE,
     *       FILE   = NAMFIL,
     *       ACCESS ='DIRECT',
     *       FORM   ='UNFORMATTED',
     *       RECL   = IRECSZ,
     *       STATUS ='OLD')

      read(NRFILE,REC=1)TTL,(NAMS(K),K=1,OLDMAX),SS,NCON,AU,EMRAT

      if (NCON .le. OLDMAX) then

        read(NRFILE,REC=1)TTL,(NAMS(K),K=1,OLDMAX),SS,NCON,AU,EMRAT,
     &       ((IPT(I,J),I=1,3),J=1,12),NUMDE,(IPT(I,13),I=1,3),
     &                                       (IPT(I,14),I=1,3),
     &                                       (IPT(I,15),I=1,3)

        read(NRFILE,REC=2)(VALS(I),I=1,OLDMAX)

      else

        if(NCON .gt. NMAX) then
          write(*,*)'Number of ephemeris constants too big in READHD'
          stop
        endif

        read(NRFILE,REC=1)TTL,(NAMS(K),K=1,OLDMAX),SS,NCON,AU,EMRAT,
     &       ((IPT(I,J),I=1,3),J=1,12),NUMDE,(IPT(I,13),I=1,3),
     &       (NAMS(J),J=K,NCON),
     &                                       (IPT(I,14),I=1,3),
     &                                       (IPT(I,15),I=1,3)

        read(NRFILE,REC=2)(VALS(I),I=1,NCON)

      endif

      FACTE = 1.D0/(1.D0+EMRAT)
      FACTM = FACTE - 1.D0

      if(FACTE .eq. 0.D0) then
        write(*,*)'Invalid value of EMRAT from file in READHD'
        stop
      endif

      if(AU_KM)then
        if(IAU_AU)then
          XSCALE = 1.d0/IAU
        else
          XSCALE = 1.d0/AU
        endif
      else
        XSCALE = 1.d0
      endif

      if(DAY_SEC) then
        VSCALE = XSCALE*86400.d0
      else
        VSCALE = XSCALE
      endif

      if(NUMDE .eq. 0) stop 'DENUM not found by READHD in constants'
      write(6,*)
      write(6,'(a27,i3.3)')' JPL planetary ephemeris DE',NUMDE
      write(6,*)'Requested output units are :'
      if(AU_KM)then
        if(IAU_AU)then
          write(6,*)'IAU au for distance'
          if(DAY_SEC)then
            write(6,*)'IAU au/day for velocity'
          else
            write(6,*)'IAU au/sec for velocity'
          endif
        else
          write(6,'(a2,i3.3,a16)')'DE',NUMDE,' au for distance'
          if(DAY_SEC)then
            write(6,'(a2,i3.3,a20)')'DE',NUMDE,' au/day for velocity'
          else
            write(6,'(a2,i3.3,a20)')'DE',NUMDE,' au/sec for velocity'
          endif
        endif
      else
        write(6,*)'km for distance'
        if(DAY_SEC)then
          write(6,*)'km/day for velocity'
        else
          write(6,*)'km/sec for velocity'
        endif
      endif

      return
      end
C
CCC
C

      subroutine INTCHB( BUF, T, LINT, NCF, NCM, NSC, REQ, PV)
C
C-----------------------------------------------------------------------
C  INTCHB (INTerpolate CHeByshev polynomial) computes the components of
C  position by interpolating Chebyshev polynomials, and if requested, it
C  also computes the components of velocity by differentiating the
C  Chebyshev polynomials and then interpolating.
C
C  Inputs:
C
C   BUF(1..NCF, 1..NCM, 1..NSC)  Chebyshev coefficients
C   T     Fractional time within the interval covered by the
C         coefficients at which the interpolation is required.
C         T must satisfy 0 .LE. T .LE. 1
C   LINT  Length of the interval in input time units
C   NCF   Number of coefficients per component
C   NCM   Number of components per set of coefficients
C   NSC   Number of sets of coefficients within interval
C   REQ   Request indicator:
C           REQ= 1 for position components only,
C           REQ= 2 for both position and velocity components.
C
C  Output:
C
C   PV(i)    Computed position and velocity components:
C            1 to NCM are position components.
C            NCM+1 to 2*NCM  are velocity components.
C-----------------------------------------------------------------------
C
C$ Disclaimer
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

C     Input variables:

      integer            NCF, NCM, NSC, REQ
      double precision   BUF(NCF,NCM,NSC), T, LINT

C     Output variables

      double precision   PV(*)

C     Local variable

      double precision  PC(18), VC(2:18), TEMP, TC, TTC, BMA
      integer    NS, L, NP, NV, NC, I, J

      data       PC(1) /1.D0/, PC(2) /2.D0/, VC(2) /1.D0/

      save

C     Compute set number within interval (L), and scaled Chebyshev time
C     within that set (TC).

      NS   = NSC
      TEMP = T * dble(NS)
      TC   = 2.d0 * ( TEMP-DINT(TEMP) ) - 1.d0
      L    = TEMP + 1
      if (L .gt. NS) then
        L  = L - 1
        TC = TC + 2.d0
      endif

C-- If the Chebyshev time has changed, compute new polynomial values.

      if (TC .ne. PC(2)) then
        NP = 3
        NV = 4
        PC(2) = TC
        TTC   = TC + TC
        VC(3) = TTC + TTC
       endif

C-- Compute position polynomial values.

      NC = NCF
      do  NP = NP,NC
        PC(NP) = TTC*PC(NP-1) - PC(NP-2)
      enddo

C-- Compute position components.

      do I = 1,NCM
        TEMP = 0.D0
        do  J = NC,1,-1
          TEMP= TEMP + PC(J)*BUF(J,I,L)
        enddo
        PV(I) = TEMP
      enddo

C-- If only positions are requested, exit

      IF (REQ .LE. 1) RETURN

C-- Compute velocity polynomial values.

      do  NV = NV,NC
        VC(NV)= TTC*VC(NV-1) + PC(NV-1) + PC(NV-1) - VC(NV-2)
      enddo

C-- Compute velocity components.

      BMA = DBLE( 2*NS ) / LINT
      do  I = 1,NCM
        TEMP= 0.D0
        do  J = NC,2,-1
          TEMP= TEMP + VC(J)*BUF(J,I,L)
        enddo
        PV(I+NCM) = TEMP*BMA
      enddo

      return

      end
