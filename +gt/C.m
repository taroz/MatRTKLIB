classdef C
    % C: RTKLIB constants class
    % ---------------------------------------------------------------------
    % Grtk Declaration:
    % C = gt.C();   Create constants used for RTKLIB
    % ---------------------------------------------------------------------
    properties (Constant)
        PI        = 3.1415926535897932  % pi
        D2R       = (gt.C.PI/180.0)     % deg to rad
        R2D       = (180.0/gt.C.PI)     % rad to deg
        CLIGHT    = 299792458.0         % speed of light (m/s)
        SC2RAD    = 3.1415926535898     % semi-circle to radian (IS-GPS)
        AU        = 149597870691.0      % 1 AU (m)
        AS2R      = (gt.C.D2R/3600.0)   % arc sec to radian
        OMGE      = 7.2921151467E-5     % earth angular velocity (IS-GPS) (rad/s)
        RE_WGS84  = 6378137.0           % earth semimajor axis (WGS84) (m)
        FE_WGS84  = (1.0/298.257223563) % earth flattening (WGS84)
        HION      = 350000.0            % ionosphere height (m)
        MAXFREQ   = 7                   % max number of frequency
        NFREQ     = 7                   % number of carrier frequencies
        NFREQGLO  = 2                   % number of carrier frequencies of GLONASS
        NEXOBS    = 0                   % number of extended obs codes
        SNR_UNIT  = 0.001               % SNR unit (dBHz)

        % carrier frequency
        FREQ1     = gt.C.FREQ(1.57542E9)  % L1/E1/B1C  frequency= gt.C.FREQ(Hz)
        FREQ2     = gt.C.FREQ(1.22760E9)  % L2 frequency= gt.C.FREQ(Hz)
        FREQ5     = gt.C.FREQ(1.17645E9)  % L5/E5a/B2a frequency= gt.C.FREQ(Hz)
        FREQ6     = gt.C.FREQ(1.27875E9)  % E6/L6  frequency= gt.C.FREQ(Hz)
        FREQ7     = gt.C.FREQ(1.20714E9)  % E5b    frequency= gt.C.FREQ(Hz)
        FREQ8     = gt.C.FREQ(1.191795E9) % E5a+b  frequency= gt.C.FREQ(Hz)
        FREQ9     = gt.C.FREQ(2.492028E9) % S      frequency= gt.C.FREQ(Hz)
        FREQ1_GLO = gt.C.FREQ(1.60200E9)  % GLONASS G1 base frequency= gt.C.FREQ(Hz)
        DFRQ1_GLO = gt.C.FREQ(0.56250E6)  % GLONASS G1 bias frequency= gt.C.FREQ(Hz/n)
        FREQ2_GLO = gt.C.FREQ(1.24600E9)  % GLONASS G2 base frequency= gt.C.FREQ(Hz)
        DFRQ2_GLO = gt.C.FREQ(0.43750E6)  % GLONASS G2 bias frequency= gt.C.FREQ(Hz/n)
        FREQ3_GLO = gt.C.FREQ(1.202025E9) % GLONASS G3 frequency= gt.C.FREQ(Hz)
        FREQ1a_GLO= gt.C.FREQ(1.600995E9) % GLONASS G1a frequency= gt.C.FREQ(Hz)
        FREQ2a_GLO= gt.C.FREQ(1.248060E9) % GLONASS G2a frequency= gt.C.FREQ(Hz)
        FREQ1_CMP = gt.C.FREQ(1.561098E9) % BDS B1I     frequency= gt.C.FREQ(Hz)
        FREQ2_CMP = gt.C.FREQ(1.20714E9)  % BDS B2I/B2b frequency= gt.C.FREQ(Hz)
        FREQ3_CMP = gt.C.FREQ(1.26852E9)  % BDS B3      frequency= gt.C.FREQ(Hz)

        EFACT_GPS = 1.0                 % error factor: GPS
        EFACT_GLO = 1.5                 % error factor: GLONASS
        EFACT_GAL = 1.0                 % error factor: Galileo
        EFACT_QZS = 1.0                 % error factor: QZSS
        EFACT_CMP = 1.0                 % error factor: BeiDou
        EFACT_IRN = 1.5                 % error factor: IRNSS
        EFACT_SBS = 3.0                 % error factor: SBAS

        % navigation systems
        SYS_NONE  = gt.C.SYS(0)         % navigation system: none
        SYS_GPS   = gt.C.SYS(1)         % navigation system: GPS
        SYS_SBS   = gt.C.SYS(2)         % navigation system: SBAS
        SYS_GLO   = gt.C.SYS(4)         % navigation system: GLONASS
        SYS_GAL   = gt.C.SYS(8)         % navigation system: Galileo
        SYS_QZS   = gt.C.SYS(16)        % navigation system: QZSS
        SYS_CMP   = gt.C.SYS(32)        % navigation system: BeiDou
        SYS_IRN   = gt.C.SYS(64)        % navigation system: IRNS
        SYS_LEO   = gt.C.SYS(128)       % navigation system: LEO
        SYS_ALL   = gt.C.SYS(255)       % navigation system: all

        % time systems
        TSYS_GPS  = gt.C.TSYS(0)        % time system: GPS time
        TSYS_UTC  = gt.C.TSYS(1)        % time system: UTC
        TSYS_GLO  = gt.C.TSYS(2)        % time system: GLONASS time
        TSYS_GAL  = gt.C.TSYS(3)        % time system: Galileo time
        TSYS_QZS  = gt.C.TSYS(4)        % time system: QZSS time
        TSYS_CMP  = gt.C.TSYS(5)        % time system: BeiDou time
        TSYS_IRN  = gt.C.TSYS(6)        % time system: IRNSS time

        % PRNs
        MINPRNGPS = 1                   % min satellite PRN number of GPS
        MAXPRNGPS = 32                  % max satellite PRN number of GPS
        NSATGPS   = (gt.C.MAXPRNGPS-gt.C.MINPRNGPS+1) % number of GPS satellites
        NSYSGPS   = 1

        MINPRNGLO = 1                   % min satellite slot number of GLONASS
        MAXPRNGLO = 27                  % max satellite slot number of GLONASS
        NSATGLO   = (gt.C.MAXPRNGLO-gt.C.MINPRNGLO+1) % number of GLONASS satellites
        NSYSGLO   = 1

        MINPRNGAL = 1                   % min satellite PRN number of Galileo
        MAXPRNGAL = 36                  % max satellite PRN number of Galileo
        NSATGAL   =(gt.C.MAXPRNGAL-gt.C.MINPRNGAL+1) % number of Galileo satellites
        NSYSGAL   = 1

        MINPRNQZS = 193                 % min satellite PRN number of QZSS
        MAXPRNQZS = 202                 % max satellite PRN number of QZSS
        MINPRNQZS_S=183                 % min satellite PRN number of QZSS L1S
        MAXPRNQZS_S=191                 % max satellite PRN number of QZSS L1S
        NSATQZS   = (gt.C.MAXPRNQZS-gt.C.MINPRNQZS+1) % number of QZSS satellites
        NSYSQZS   = 1

        MINPRNCMP = 1                   % min satellite sat number of BeiDou
        MAXPRNCMP = 63                  % max satellite sat number of BeiDou
        NSATCMP   = (gt.C.MAXPRNCMP-gt.C.MINPRNCMP+1) % number of BeiDou satellites
        NSYSCMP   = 1

        MINPRNIRN = 1                   % min satellite sat number of IRNSS
        MAXPRNIRN = 14                  % max satellite sat number of IRNSS
        NSATIRN   = (gt.C.MAXPRNIRN-gt.C.MINPRNIRN+1) % number of IRNSS satellites
        NSYSIRN   = 1

        % #ifdef ENALEO
        %         MINPRNLEO = 1                 % min satellite sat number of LEO
        %         MAXPRNLEO = 10                % max satellite sat number of LEO
        %         NSATLEO   = (gt.C.MAXPRNLEO-gt.C.MINPRNLEO+1) % number of LEO satellites
        %         NSYSLEO   = 1
        % #else
        MINPRNLEO = 0
        MAXPRNLEO = 0
        NSATLEO   = 0
        NSYSLEO   = 0

        NSYS      = (gt.C.NSYSGPS+gt.C.NSYSGLO+gt.C.NSYSGAL+gt.C.NSYSQZS+gt.C.NSYSCMP+gt.C.NSYSIRN+gt.C.NSYSLEO) % number of systems

        MINPRNSBS = 120                 % min satellite PRN number of SBAS
        MAXPRNSBS = 158                 % max satellite PRN number of SBAS
        NSATSBS   = (gt.C.MAXPRNSBS-gt.C.MINPRNSBS+1) % number of SBAS satellites

        % max satellite number (1 to MAXSAT)
        MAXSAT    = (gt.C.NSATGPS+gt.C.NSATGLO+gt.C.NSATGAL+gt.C.NSATQZS+gt.C.NSATCMP+gt.C.NSATIRN+gt.C.NSATSBS+gt.C.NSATLEO)

        MAXSTA    = 255                 % max number of stations
        MAXOBS    = 96                  % max number of obs in an epoch
        MAXRCV    = 64                  % max receiver number (1 to MAXRCV)
        MAXOBSTYPE= 64                  % max number of obs type in RINEX

        MAXDTOE   = 7200.0              % max time difference to GPS Toe (s)
        MAXDTOE_QZS=7200.0              % max time difference to QZSS Toe (s)
        MAXDTOE_GAL=14400.0             % max time difference to Galileo Toe (s)
        MAXDTOE_CMP=21600.0             % max time difference to BeiDou Toe (s)
        MAXDTOE_GLO=1800.0              % max time difference to GLONASS Toe (s)
        MAXDTOE_IRN=7200.0              % max time difference to IRNSS Toe (s)
        MAXDTOE_SBS=360.0               % max time difference to SBAS Toe (s)
        MAXDTOE_S = 86400.0             % max time difference to ephem toe (s) for other
        MAXGDOP   = 300.0               % max GDOP

        INT_SWAP_TRAC=86400.0           % swap interval of trace file (s)
        INT_SWAP_STAT=86400.0           % swap interval of solution status file (s)

        MAXEXFILE = 1024                % max number of expanded files
        MAXSBSAGEF= 30.0                % max age of SBAS fast correction (s)
        MAXSBSAGEL= 1800.0              % max age of SBAS long term corr (s)
        MAXSBSURA = 8                   % max URA of SBAS satellite
        MAXBAND   = 10                  % max SBAS band of IGP
        MAXNIGP   = 201                 % max number of IGP in SBAS band
        MAXNGEO   = 4                   % max number of GEO satellites
        MAXCOMMENT= 100                 % max number of RINEX comments
        MAXSTRPATH= 1024                % max length of stream path
        MAXSTRMSG = 1024                % max length of stream message
        MAXSTRRTK = 8                   % max number of stream in RTK server
        MAXSBSMSG = 32                  % max number of SBAS msg in RTK server
        MAXSOLMSG = 8191                % max length of solution message
        MAXRAWLEN = 16384               % max length of receiver raw message
        MAXERRMSG = 4096                % max length of error/warning message
        MAXANT    = 64                  % max length of station name/antenna type
        MAXSOLBUF = 256                 % max number of solution buffer
        MAXOBSBUF = 128                 % max number of observation data buffer
        MAXNRPOS  = 16                  % max number of reference positions
        MAXLEAPS  = 64                  % max number of leap seconds table
        MAXGISLAYER=32                  % max number of GIS data layers
        MAXRCVCMD = 4096                % max length of receiver commands

        % observation type
        OBSTYPE_PR= gt.C.OBSTYPE(1)     % observation type: pseudorange
        OBSTYPE_CP= gt.C.OBSTYPE(2)     % observation type: carrier-phase
        OBSTYPE_DOP=gt.C.OBSTYPE(4)     % observation type: doppler-freq
        OBSTYPE_SNR=gt.C.OBSTYPE(8)     % observation type: SNR
        OBSTYPE_ALL=gt.C.OBSTYPE(255)   % observation type: all

        % frequency type
        FREQTYPE_L1= gt.C.FREQTYPE(1)   % frequency type: L1/E1/B1
        FREQTYPE_L2= gt.C.FREQTYPE(2)   % frequency type: L2/E5b/B2
        FREQTYPE_L3= gt.C.FREQTYPE(4)   % frequency type: L5/E5a/L3
        FREQTYPE_L4= gt.C.FREQTYPE(8)   % frequency type: L6/E6/B3
        FREQTYPE_L5= gt.C.FREQTYPE(16)  % frequency type: E5ab
        FREQTYPE_ALL=gt.C.FREQTYPE(255) % frequency type: all

        % code type
        CODE_NONE = gt.C.CODE(0)        % obs code: none or unknown
        CODE_L1C  = gt.C.CODE(1)        % obs code: L1C/A,G1C/A,E1C (GPS,GLO,GAL,QZS,SBS)
        CODE_L1P  = gt.C.CODE(2)        % obs code: L1P,G1P,B1P (GPS,GLO,BDS)
        CODE_L1W  = gt.C.CODE(3)        % obs code: L1 Z-track (GPS)
        CODE_L1Y  = gt.C.CODE(4)        % obs code: L1Y        (GPS)
        CODE_L1M  = gt.C.CODE(5)        % obs code: L1M        (GPS)
        CODE_L1N  = gt.C.CODE(6)        % obs code: L1codeless,B1codeless (GPS,BDS)
        CODE_L1S  = gt.C.CODE(7)        % obs code: L1C(D)     (GPS,QZS)
        CODE_L1L  = gt.C.CODE(8)        % obs code: L1C(P)     (GPS,QZS)
        CODE_L1E  = gt.C.CODE(9)        % (not used)
        CODE_L1A  = gt.C.CODE(10)       % obs code: E1A,B1A    (GAL,BDS)
        CODE_L1B  = gt.C.CODE(11)       % obs code: E1B        (GAL)
        CODE_L1X  = gt.C.CODE(12)       % obs code: E1B+C,L1C(D+P),B1D+P (GAL,QZS,BDS)
        CODE_L1Z  = gt.C.CODE(13)       % obs code: E1A+B+C,L1S (GAL,QZS)
        CODE_L2C  = gt.C.CODE(14)       % obs code: L2C/A,G1C/A (GPS,GLO)
        CODE_L2D  = gt.C.CODE(15)       % obs code: L2 L1C/A-(P2-P1) (GPS)
        CODE_L2S  = gt.C.CODE(16)       % obs code: L2C(M)     (GPS,QZS)
        CODE_L2L  = gt.C.CODE(17)       % obs code: L2C(L)     (GPS,QZS)
        CODE_L2X  = gt.C.CODE(18)       % obs code: L2C(M+L),B1_2I+Q (GPS,QZS,BDS)
        CODE_L2P  = gt.C.CODE(19)       % obs code: L2P,G2P    (GPS,GLO)
        CODE_L2W  = gt.C.CODE(20)       % obs code: L2 Z-track (GPS)
        CODE_L2Y  = gt.C.CODE(21)       % obs code: L2Y        (GPS)
        CODE_L2M  = gt.C.CODE(22)       % obs code: L2M        (GPS)
        CODE_L2N  = gt.C.CODE(23)       % obs code: L2codeless (GPS)
        CODE_L5I  = gt.C.CODE(24)       % obs code: L5I,E5aI   (GPS,GAL,QZS,SBS)
        CODE_L5Q  = gt.C.CODE(25)       % obs code: L5Q,E5aQ   (GPS,GAL,QZS,SBS)
        CODE_L5X  = gt.C.CODE(26)       % obs code: L5I+Q,E5aI+Q,L5B+C,B2aD+P (GPS,GAL,QZS,IRN,SBS,BDS)
        CODE_L7I  = gt.C.CODE(27)       % obs code: E5bI,B2bI  (GAL,BDS)
        CODE_L7Q  = gt.C.CODE(28)       % obs code: E5bQ,B2bQ  (GAL,BDS)
        CODE_L7X  = gt.C.CODE(29)       % obs code: E5bI+Q,B2bI+Q (GAL,BDS)
        CODE_L6A  = gt.C.CODE(30)       % obs code: E6A,B3A    (GAL,BDS)
        CODE_L6B  = gt.C.CODE(31)       % obs code: E6B        (GAL)
        CODE_L6C  = gt.C.CODE(32)       % obs code: E6C        (GAL)
        CODE_L6X  = gt.C.CODE(33)       % obs code: E6B+C,LEXS+L,B3I+Q (GAL,QZS,BDS)
        CODE_L6Z  = gt.C.CODE(34)       % obs code: E6A+B+C,L6D+E (GAL,QZS)
        CODE_L6S  = gt.C.CODE(35)       % obs code: L6S        (QZS)
        CODE_L6L  = gt.C.CODE(36)       % obs code: L6L        (QZS)
        CODE_L8I  = gt.C.CODE(37)       % obs code: E5abI      (GAL)
        CODE_L8Q  = gt.C.CODE(38)       % obs code: E5abQ      (GAL)
        CODE_L8X  = gt.C.CODE(39)       % obs code: E5abI+Q,B2abD+P (GAL,BDS)
        CODE_L2I  = gt.C.CODE(40)       % obs code: B1_2I      (BDS)
        CODE_L2Q  = gt.C.CODE(41)       % obs code: B1_2Q      (BDS)
        CODE_L6I  = gt.C.CODE(42)       % obs code: B3I        (BDS)
        CODE_L6Q  = gt.C.CODE(43)       % obs code: B3Q        (BDS)
        CODE_L3I  = gt.C.CODE(44)       % obs code: G3I        (GLO)
        CODE_L3Q  = gt.C.CODE(45)       % obs code: G3Q        (GLO)
        CODE_L3X  = gt.C.CODE(46)       % obs code: G3I+Q      (GLO)
        CODE_L1I  = gt.C.CODE(47)       % obs code: B1I        (BDS) (obsolute)
        CODE_L1Q  = gt.C.CODE(48)       % obs code: B1Q        (BDS) (obsolute)
        CODE_L5A  = gt.C.CODE(49)       % obs code: L5A SPS    (IRN)
        CODE_L5B  = gt.C.CODE(50)       % obs code: L5B RS(D)  (IRN)
        CODE_L5C  = gt.C.CODE(51)       % obs code: L5C RS(P)  (IRN)
        CODE_L9A  = gt.C.CODE(52)       % obs code: SA SPS     (IRN)
        CODE_L9B  = gt.C.CODE(53)       % obs code: SB RS(D)   (IRN)
        CODE_L9C  = gt.C.CODE(54)       % obs code: SC RS(P)   (IRN)
        CODE_L9X  = gt.C.CODE(55)       % obs code: SB+C       (IRN)
        CODE_L1D  = gt.C.CODE(56)       % obs code: B1D        (BDS)
        CODE_L5D  = gt.C.CODE(57)       % obs code: L5D(L5S),B2aD (QZS,BDS)
        CODE_L5P  = gt.C.CODE(58)       % obs code: L5P(L5S),B2aP (QZS,BDS)
        CODE_L5Z  = gt.C.CODE(59)       % obs code: L5D+P(L5S) (QZS)
        CODE_L6E  = gt.C.CODE(60)       % obs code: L6E        (QZS)
        CODE_L7D  = gt.C.CODE(61)       % obs code: B2bD       (BDS)
        CODE_L7P  = gt.C.CODE(62)       % obs code: B2bP       (BDS)
        CODE_L7Z  = gt.C.CODE(63)       % obs code: B2bD+P     (BDS)
        CODE_L8D  = gt.C.CODE(64)       % obs code: B2abD      (BDS)
        CODE_L8P  = gt.C.CODE(65)       % obs code: B2abP      (BDS)
        CODE_L4A  = gt.C.CODE(66)       % obs code: G1aL1OCd   (GLO)
        CODE_L4B  = gt.C.CODE(67)       % obs code: G1aL1OCd   (GLO)
        CODE_L4X  = gt.C.CODE(68)       % obs code: G1al1OCd+p (GLO)
        MAXCODE   = 68                  % max number of obs code

        % positioning mode
        PMODE_SINGLE    = gt.C.PMODE(0) % positioning mode: single
        PMODE_DGPS      = gt.C.PMODE(1) % positioning mode: DGPS/DGNSS
        PMODE_KINEMA    = gt.C.PMODE(2) % positioning mode: kinematic
        PMODE_STATIC    = gt.C.PMODE(3) % positioning mode: static
        PMODE_MOVEB     = gt.C.PMODE(4) % positioning mode: moving-base
        PMODE_FIXED     = gt.C.PMODE(5) % positioning mode: fixed
        PMODE_PPP_KINEMA= gt.C.PMODE(6) % positioning mode: PPP-kinemaric
        PMODE_PPP_STATIC= gt.C.PMODE(7) % positioning mode: PPP-static
        PMODE_PPP_FIXED = gt.C.PMODE(8) % positioning mode: PPP-fixed

        % solution format
        SOLF_LLH  = gt.C.SOLF(0)        % solution format: lat/lon/height
        SOLF_XYZ  = gt.C.SOLF(1)        % solution format: x/y/z-ecef
        SOLF_ENU  = gt.C.SOLF(2)        % solution format: e/n/u-baseline
        SOLF_NMEA = gt.C.SOLF(3)        % solution format: NMEA-183
        SOLF_STAT = gt.C.SOLF(4)        % solution format: solution status
        SOLF_GSIF = gt.C.SOLF(5)        % solution format: GSI F1/F2

        % solution status
        SOLQ_NONE = gt.C.SOLQ(0)        % solution status: no solution
        SOLQ_FIX  = gt.C.SOLQ(1)        % solution status: fix
        SOLQ_FLOAT= gt.C.SOLQ(2)        % solution status: float
        SOLQ_SBAS = gt.C.SOLQ(3)        % solution status: SBAS
        SOLQ_DGPS = gt.C.SOLQ(4)        % solution status: DGPS/DGNSS
        SOLQ_SINGLE=gt.C.SOLF(5)        % solution status: single
        SOLQ_PPP  = gt.C.SOLQ(6)        % solution status: PPP
        SOLQ_DR   = gt.C.SOLQ(7)        % solution status: dead reconing
        MAXSOLQ   = 7                   % max number of solution status

        % time system
        TIMES_GPST= gt.C.TIMES(0)       % time system: gps time
        TIMES_UTC = gt.C.TIMES(1)       % time system: utc
        TIMES_JST = gt.C.TIMES(2)       % time system: jst

        % ionosphere option
        IONOOPT_OFF = gt.C.IONOOPT(0)   % ionosphere option: correction off
        IONOOPT_BRDC= gt.C.IONOOPT(1)   % ionosphere option: broadcast model
        IONOOPT_SBAS= gt.C.IONOOPT(2)   % ionosphere option: SBAS model
        IONOOPT_IFLC= gt.C.IONOOPT(3)   % ionosphere option: L1/L2 iono-free LC
        IONOOPT_EST = gt.C.IONOOPT(4)   % ionosphere option: estimation
        IONOOPT_TEC = gt.C.IONOOPT(5)   % ionosphere option: IONEX TEC model
        IONOOPT_QZS = gt.C.IONOOPT(6)   % ionosphere option: QZSS broadcast model
        IONOOPT_STEC= gt.C.IONOOPT(8)   % ionosphere option: SLANT TEC model

        % troposphere option
        TROPOPT_OFF = gt.C.TROPOPT(0)   % troposphere option: correction off
        TROPOPT_SAAS= gt.C.TROPOPT(1)   % troposphere option: Saastamoinen model
        TROPOPT_SBAS= gt.C.TROPOPT(2)   % troposphere option: SBAS model
        TROPOPT_EST = gt.C.TROPOPT(3)   % troposphere option: ZTD estimation
        TROPOPT_ESTG= gt.C.TROPOPT(4)   % troposphere option: ZTD+grad estimation
        TROPOPT_ZTD = gt.C.TROPOPT(5)   % troposphere option: ZTD correction

        % ephemeris option
        EPHOPT_BRDC  = gt.C.EPHOPT(0)  % ephemeris option: broadcast ephemeris
        EPHOPT_PREC  = gt.C.EPHOPT(1)  % ephemeris option: precise ephemeris
        EPHOPT_SBAS  = gt.C.EPHOPT(2)  % ephemeris option: broadcast + SBAS
        EPHOPT_SSRAPC= gt.C.EPHOPT(3)  % ephemeris option: broadcast + SSR_APC
        EPHOPT_SSRCOM= gt.C.EPHOPT(4)  % ephemeris option: broadcast + SSR_COM

        % AR mode
        ARMODE_OFF    = gt.C.ARMODE(0)  % AR mode: off
        ARMODE_CONT   = gt.C.ARMODE(1)  % AR mode: continuous
        ARMODE_INST   = gt.C.ARMODE(2)  % AR mode: instantaneous
        ARMODE_FIXHOLD= gt.C.ARMODE(3)  % AR mode: fix and hold
        ARMODE_WLNL   = gt.C.ARMODE(4)  % AR mode: wide lane/narrow lane
        ARMODE_TCAR   = gt.C.ARMODE(5)  % AR mode: triple carrier ar

        % SBAS option
        SBSOPT_LCORR = gt.C.SBSOPT(1)   % SBAS option: long term correction
        SBSOPT_FCORR = gt.C.SBSOPT(2)   % SBAS option: fast correction
        SBSOPT_ICORR = gt.C.SBSOPT(4)   % SBAS option: ionosphere correction
        SBSOPT_RANGE = gt.C.SBSOPT(8)   % SBAS option: ranging

        % POSOPT option
        POSOPT_LLH  =  gt.C.POSOPT(0)   % pos option: LLH
        POSOPT_XYZ  =  gt.C.POSOPT(1)   % pos option: XYZ
        POSOPT_SINGLE= gt.C.POSOPT(2)   % pos option: average of single pos
        POSOPT_FILE  = gt.C.POSOPT(3)   % pos option: read from pos file
        POSOPT_RINEX = gt.C.POSOPT(4)   % pos option: rinex header pos
        POSOPT_RTCM  = gt.C.POSOPT(5)   % pos option: rtcm station pos
        POSOPT_RAW   = gt.C.POSOPT(6)   % pos option: raw station pos

        % stream type
        STR_NONE    = gt.C.STR(0)       % stream type: none
        STR_SERIAL  = gt.C.STR(1)       % stream type: serial
        STR_FILE    = gt.C.STR(2)       % stream type: file
        STR_TCPSVR  = gt.C.STR(3)       % stream type: TCP server
        STR_TCPCLI  = gt.C.STR(4)       % stream type: TCP client
        STR_NTRIPSVR= gt.C.STR(5)       % stream type: NTRIP server
        STR_NTRIPCLI= gt.C.STR(6)       % stream type: NTRIP client
        STR_FTP     = gt.C.STR(7)       % stream type: ftp
        STR_HTTP    = gt.C.STR(8)       % stream type: http
        STR_NTRIPCAS= gt.C.STR(9)       % stream type: NTRIP caster
        STR_UDPSVR  = gt.C.STR(10)      % stream type: UDP server
        STR_UDPCLI  = gt.C.STR(11)      % stream type: UDP server
        STR_MEMBUF  = gt.C.STR(12)      % stream type: memory buffer

        % stream format
        STRFMT_RTCM2= gt.C.STRFMT(0)    % stream format: RTCM 2
        STRFMT_RTCM3= gt.C.STRFMT(1)    % stream format: RTCM 3
        STRFMT_OEM4 = gt.C.STRFMT(2)    % stream format: NovAtel OEMV/4
        STRFMT_OEM3 = gt.C.STRFMT(3)    % stream format: NovAtel OEM3
        STRFMT_UBX  = gt.C.STRFMT(4)    % stream format: u-blox LEA-*T
        STRFMT_SS2  = gt.C.STRFMT(5)    % stream format: NovAtel Superstar II
        STRFMT_CRES = gt.C.STRFMT(6)    % stream format: Hemisphere
        STRFMT_STQ  = gt.C.STRFMT(7)    % stream format: SkyTraq S1315F
        STRFMT_JAVAD= gt.C.STRFMT(8)    % stream format: JAVAD GRIL/GREIS
        STRFMT_NVS  = gt.C.STRFMT(9)    % stream format: NVS NVC08C
        STRFMT_BINEX= gt.C.STRFMT(10)   % stream format: BINEX
        STRFMT_RT17 = gt.C.STRFMT(11)   % stream format: Trimble RT17
        STRFMT_SEPT = gt.C.STRFMT(12)   % stream format: Septentrio
        STRFMT_RINEX= gt.C.STRFMT(13)   % stream format: RINEX
        STRFMT_SP3  = gt.C.STRFMT(14)   % stream format: SP3
        STRFMT_RNXCLK= gt.C.STRFMT(15)  % stream format: RINEX CLK
        STRFMT_SBAS = gt.C.STRFMT(16)   % stream format: SBAS messages
        STRFMT_NMEA = gt.C.STRFMT(17)   % stream format: NMEA 0183
        MAXRCVFMT   = 12                % max number of receiver format

        % stream mode
        STR_MODE_R = gt.C.STR_MODE(1)   % stream mode: read
        STR_MODE_W = gt.C.STR_MODE(2)   % stream mode: write
        STR_MODE_RW= gt.C.STR_MODE(3)   % stream mode: read/write

        % geoid model
        GEOID_EMBEDDED  = gt.C.GEOID(0) % geoid model: embedded geoid
        GEOID_EGM96_M150= gt.C.GEOID(1) % geoid model: EGM96 15x15"
        GEOID_EGM2008_M25=gt.C.GEOID(2) % geoid model: EGM2008 2.5x2.5"
        GEOID_EGM2008_M10=gt.C.GEOID(3) % geoid model: EGM2008 1.0x1.0"
        GEOID_GSI2000_M15=gt.C.GEOID(4) % geoid model: GSI geoid 2000 1.0x1.5"
        GEOID_RAF09     = gt.C.GEOID(5) % geoid model: IGN RAF09 for France 1.5"x2"

        % download option
        DLOPT_FORCE   = gt.C.DLOPT(1)   % download option: force download existing
        DLOPT_KEEPCMP = gt.C.DLOPT(2)   % download option: keep compressed file
        DLOPT_HOLDERR = gt.C.DLOPT(4)   % download option: hold on error file
        DLOPT_HOLDLST = gt.C.DLOPT(8)   % download option: hold on listing file

        % LLI
        LLI_SLIP   =1                   % LLI: cycle-slip
        LLI_HALFC  =2                   % LLI: half-cycle not resovled
        LLI_BOCTRK =4                   % LLI: boc tracking of mboc signal
        LLI_HALFA  =64                  % LLI: half-cycle added
        LLI_HALFS  =128                 % LLI: half-cycle subtracted

        P2_5       =0.03125               % 2^-5
        P2_6       =0.015625              % 2^-6
        P2_11      =4.882812500000000E-04 % 2^-11
        P2_15      =3.051757812500000E-05 % 2^-15
        P2_17      =7.629394531250000E-06 % 2^-17
        P2_19      =1.907348632812500E-06 % 2^-19
        P2_20      =9.536743164062500E-07 % 2^-20
        P2_21      =4.768371582031250E-07 % 2^-21
        P2_23      =1.192092895507810E-07 % 2^-23
        P2_24      =5.960464477539063E-08 % 2^-24
        P2_27      =7.450580596923828E-09 % 2^-27
        P2_29      =1.862645149230957E-09 % 2^-29
        P2_30      =9.313225746154785E-10 % 2^-30
        P2_31      =4.656612873077393E-10 % 2^-31
        P2_32      =2.328306436538696E-10 % 2^-32
        P2_33      =1.164153218269348E-10 % 2^-33
        P2_35      =2.910383045673370E-11 % 2^-35
        P2_38      =3.637978807091710E-12 % 2^-38
        P2_39      =1.818989403545856E-12 % 2^-39
        P2_40      =9.094947017729280E-13 % 2^-40
        P2_43      =1.136868377216160E-13 % 2^-43
        P2_48      =3.552713678800501E-15 % 2^-48
        P2_50      =8.881784197001252E-16 % 2^-50
        P2_55      =2.775557561562891E-17 % 2^-55

        % switch status
        OFF   = gt.C.SWITCH(0)          % OFF
        ON    = gt.C.SWITCH(1)          % ON

        % navigation systems
        NAVSYS_G = gt.C.NAVSYS(1)
        NAVSYS_R = gt.C.NAVSYS(4)
        NAVSYS_E = gt.C.NAVSYS(8)
        NAVSYS_Q = gt.C.NAVSYS(16)
        NAVSYS_C = gt.C.NAVSYS(32)
        NAVSYS_GR = gt.C.NAVSYS(5)
        NAVSYS_GE = gt.C.NAVSYS(9)
        NAVSYS_GQ = gt.C.NAVSYS(17)
        NAVSYS_GC = gt.C.NAVSYS(33)
        NAVSYS_RE = gt.C.NAVSYS(12)
        NAVSYS_RQ = gt.C.NAVSYS(20)
        NAVSYS_RC = gt.C.NAVSYS(36)
        NAVSYS_EQ = gt.C.NAVSYS(17)
        NAVSYS_EC = gt.C.NAVSYS(40)
        NAVSYS_QC = gt.C.NAVSYS(48)
        NAVSYS_GRE = gt.C.NAVSYS(13)
        NAVSYS_GRQ = gt.C.NAVSYS(21)
        NAVSYS_GRC = gt.C.NAVSYS(37)
        NAVSYS_GEQ = gt.C.NAVSYS(25)
        NAVSYS_GEC = gt.C.NAVSYS(41)
        NAVSYS_GQC = gt.C.NAVSYS(49)
        NAVSYS_REQ = gt.C.NAVSYS(28)
        NAVSYS_REC = gt.C.NAVSYS(44)
        NAVSYS_RQC = gt.C.NAVSYS(52)
        NAVSYS_EQC = gt.C.NAVSYS(56)
        NAVSYS_GREQ = gt.C.NAVSYS(29)
        NAVSYS_GREC = gt.C.NAVSYS(45)
        NAVSYS_GRQC = gt.C.NAVSYS(53)
        NAVSYS_GEQC = gt.C.NAVSYS(57)
        NAVSYS_REQC = gt.C.NAVSYS(60)
        NAVSYS_GREQC = gt.C.NAVSYS(61)

        % frequency option for positioning
        FREQOPT_L1    = gt.C.FREQOPT(1) % L1
        FREQOPT_L12   = gt.C.FREQOPT(2) % L1+2
        FREQOPT_L125  = gt.C.FREQOPT(3) % L1+2+5
        FREQOPT_L1256 = gt.C.FREQOPT(4) % L1+2+5+6
        FREQOPT_L12567= gt.C.FREQOPT(5) % L1+2+5+6+7

        % tide correction
        TIDE_OFF = gt.C.TIDE(0)         % OFF
        TIDE_ON  = gt.C.TIDE(1)         % ON
        TIDE_OTL = gt.C.TIDE(2)         % OTL

        % time format
        TIMEF_TOW = gt.C.TIMEF(0)       % TOW
        TIMEF_HMS = gt.C.TIMEF(1)       % hh:mm:ss

        % degree format
        DEGF_DEG = gt.C.DEGF(0)         % degree
        DEGF_DMS = gt.C.DEGF(1)         % degree-minute-second

        % hight format
        HIGHTF_ELLI = gt.C.HIGHTF(0)    % ellipsoidal
        HIGHTF_GEOD = gt.C.HIGHTF(1)    % geodetic
        
        % GNSS name        
        SYSNAME_GPS = gt.C.SYSNAME(1);  % GPS
        SYSNAME_SBS = gt.C.SYSNAME(2);  % SBAS
        SYSNAME_GLO = gt.C.SYSNAME(4);  % GLONASS
        SYSNAME_GAL = gt.C.SYSNAME(8);  % Galileo
        SYSNAME_QZS = gt.C.SYSNAME(16); % QZSS
        SYSNAME_CMP = gt.C.SYSNAME(32); % BeiDou
        SYSNAME_IRN = gt.C.SYSNAME(64); % IRNS
        SYSNAME_LEO = gt.C.SYSNAME(128);% LEO
        SYSNAME_ALL = gt.C.SYSNAME(255);% ALL

        % solution status name
        SOLQNAME_NONE  = gt.C.SOLQNAME(0); % solution status: no solution
        SOLQNAME_FIX   = gt.C.SOLQNAME(1); % solution status: fix
        SOLQNAME_FLOAT = gt.C.SOLQNAME(2); % solution status: float
        SOLQNAME_SBAS  = gt.C.SOLQNAME(3); % solution status: SBAS
        SOLQNAME_DGNSS = gt.C.SOLQNAME(4); % solution status: DGPS/DGNSS
        SOLQNAME_SPP   = gt.C.SOLQNAME(4); % solution status: single
        SOLQNAME_PPP   = gt.C.SOLQNAME(6); % solution status: PPP
        SOLQNAME_DR    = gt.C.SOLQNAME(7); % solution status: dead reconing

        % trace level
        TRACE_OFF = gt.C.TRACE(0)
        TRACE_LV1 = gt.C.TRACE(1)
        TRACE_LV2 = gt.C.TRACE(2)
        TRACE_LV3 = gt.C.TRACE(3)
        TRACE_LV4 = gt.C.TRACE(4)
        TRACE_LV5 = gt.C.TRACE(5)

        % color
        C_LINE = [192, 192, 192]/255;
        C_SOL = [[0, 128, 0]/255;
                 [255, 170, 0]/255;
                 [255, 0, 255]/255;
                 [0, 0, 255]/255;
                 [255, 0, 0]/255;
                 [0, 128, 128]/255;
                 [192, 192, 192]/255];
        C_SYS = gt.C.SYSCOL();
    end
end