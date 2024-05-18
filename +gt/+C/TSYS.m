classdef TSYS < double
    enumeration
        TSYS_GPS(0) % time system: GPS time
        TSYS_UTC(1) % time system: UTC
        TSYS_GLO(2) % time system: GLONASS time
        TSYS_GAL(3) % time system: Galileo time
        TSYS_QZS(4) % time system: QZSS time
        TSYS_CMP(5) % time system: BeiDou time
        TSYS_IRN(6) % time system: IRNSS time
    end
end