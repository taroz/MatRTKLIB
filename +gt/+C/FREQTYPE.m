classdef FREQTYPE < double
    enumeration
        FREQTYPE_L1   (1) % frequency type: L1/E1/B1
        FREQTYPE_L2   (2) % frequency type: L2/E5b/B2
        FREQTYPE_L3   (4) % frequency type: L5/E5a/L3
        FREQTYPE_L4   (8) % frequency type: L6/E6/B3
        FREQTYPE_L5  (16) % frequency type: E5ab
        FREQTYPE_ALL(255) % frequency type: all
    end
end