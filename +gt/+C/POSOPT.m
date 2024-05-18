classdef POSOPT < double
    enumeration
        POSOPT_LLH   (0) % pos option: LLH
        POSOPT_XYZ   (1) % pos option: XYZ
        POSOPT_SINGLE(2) % pos option: average of single pos
        POSOPT_FILE  (3) % pos option: read from pos file
        POSOPT_RINEX (4) % pos option: rinex header pos
        POSOPT_RTCM  (5) % pos option: rtcm station pos
        POSOPT_RAW   (6) % pos option: raw station pos
    end
end