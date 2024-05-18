classdef IONOOPT < double
    enumeration
        IONOOPT_OFF (0) % ionosphere option: correction off
        IONOOPT_BRDC(1) % ionosphere option: broadcast model
        IONOOPT_SBAS(2) % ionosphere option: SBAS model
        IONOOPT_IFLC(3) % ionosphere option: L1/L2 iono-free LC
        IONOOPT_EST (4) % ionosphere option: estimation
        IONOOPT_TEC (5) % ionosphere option: IONEX TEC model
        IONOOPT_QZS (6) % ionosphere option: QZSS broadcast model
        IONOOPT_STEC(8) % ionosphere option: SLANT TEC model
    end
end