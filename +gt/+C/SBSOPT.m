classdef SBSOPT < double
    enumeration
        SBSOPT_LCORR(1) % SBAS option: long term correction
        SBSOPT_FCORR(2) % SBAS option: fast correction
        SBSOPT_ICORR(4) % SBAS option: ionosphere correction
        SBSOPT_RANGE(8) % SBAS option: ranging
    end
end