classdef FREQ < double
    enumeration
        FREQ1    (1.57542E9)  % L1/E1/B1C  frequency (Hz)
        FREQ2    (1.22760E9)  % L2)frequency (Hz)
        FREQ5    (1.17645E9)  % L5/E5a/B2a frequency (Hz)
        FREQ6    (1.27875E9)  % E6/L6  frequency (Hz)
        FREQ7    (1.20714E9)  % E5b    frequency (Hz)
        FREQ8    (1.191795E9) % E5a+b  frequency (Hz)
        FREQ9    (2.492028E9) % S      frequency (Hz)
        FREQ1_GLO(1.60200E9)  % GLONASS G1 base frequency (Hz)
        DFRQ1_GLO(0.56250E6)  % GLONASS G1 bias frequency (Hz/n)
        FREQ2_GLO(1.24600E9)  % GLONASS G2 base frequency (Hz)
        DFRQ2_GLO(0.43750E6)  % GLONASS G2 bias frequency (Hz/n)
        FREQ3_GLO(1.202025E9) % GLONASS G3 frequency (Hz)
        FREQ1a_GLO(1.600995E9)% GLONASS G1a frequency (Hz)
        FREQ2a_GLO(1.248060E9)% GLONASS G2a frequency (Hz)
        FREQ1_CMP(1.561098E9) % BDS B1I     frequency (Hz)
        FREQ2_CMP(1.20714E9)  % BDS B2I/B2b frequency (Hz)
        FREQ3_CMP(1.26852E9)  % BDS B3      frequency (Hz)
    end
end