classdef SYSNAME < double
    enumeration
        GPS     (1)   % navigation system: GPS
        SBAS    (2)   % navigation system: SBAS
        GLONASS (4)   % navigation system: GLONASS
        Galileo (8)   % navigation system: Galileo
        QZSS    (16)  % navigation system: QZSS
        BeiDou  (32)  % navigation system: BeiDou
        IRNSS   (64)  % navigation system: IRNSS
        LEO     (128) % navigation system: LEO
        ALL     (255) % All navigation satellites
    end
end