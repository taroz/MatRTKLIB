classdef GEOID < double
    enumeration
        GEOID_EMBEDDED   (0) % geoid model: embedded geoid
        GEOID_EGM96_M150 (1) % geoid model: EGM96 15x15"
        GEOID_EGM2008_M25(2) % geoid model: EGM2008 2.5x2.5"
        GEOID_EGM2008_M10(3) % geoid model: EGM2008 1.0x1.0"
        GEOID_GSI2000_M15(4) % geoid model: GSI geoid 2000 1.0x1.5"
        GEOID_RAF09      (5) % geoid model: IGN RAF09 for France 1.5"x2"
    end
end