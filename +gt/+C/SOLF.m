classdef SOLF < double
    enumeration
        SOLF_LLH (0) % solution format: lat/lon/height
        SOLF_XYZ (1) % solution format: x/y/z-ecef
        SOLF_ENU (2) % solution format: e/n/u-baseline
        SOLF_NMEA(3) % solution format: NMEA-183
        SOLF_STAT(4) % solution format: solution status
        SOLF_GSIF(5) % solution format: GSI F1/F2
    end
end