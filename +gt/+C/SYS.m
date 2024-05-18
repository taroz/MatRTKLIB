classdef SYS < double
    enumeration
        SYS_NONE(0)   % navigation system: none
        SYS_GPS (1)   % navigation system: GPS
        SYS_SBS (2)   % navigation system: SBAS
        SYS_GLO (4)   % navigation system: GLONASS
        SYS_GAL (8)   % navigation system: Galileo
        SYS_QZS (16)  % navigation system: QZSS
        SYS_CMP (32)  % navigation system: BeiDou
        SYS_IRN (64)  % navigation system: IRNS
        SYS_LEO (128) % navigation system: LEO
        SYS_ALL (255) % navigation system: all
    end
end