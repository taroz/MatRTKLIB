classdef ARMODE < double
    enumeration
        ARMODE_OFF    (0) % AR mode: off
        ARMODE_CONT   (1) % AR mode: continuous
        ARMODE_INST   (2) % AR mode: instantaneous
        ARMODE_FIXHOLD(3) % AR mode: fix and hold
        ARMODE_WLNL   (4) % AR mode: wide lane/narrow lane
        ARMODE_TCAR   (5) % AR mode: triple carrier ar
    end
end