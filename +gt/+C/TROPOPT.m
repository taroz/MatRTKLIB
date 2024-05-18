classdef TROPOPT < double
    enumeration
        TROPOPT_OFF (0) % troposphere option: correction off
        TROPOPT_SAAS(1) % troposphere option: Saastamoinen model
        TROPOPT_SBAS(2) % troposphere option: SBAS model
        TROPOPT_EST (3) % troposphere option: ZTD estimation
        TROPOPT_ESTG(4) % troposphere option: ZTD+grad estimation
        TROPOPT_ZTD (5) % troposphere option: ZTD correction
    end
end