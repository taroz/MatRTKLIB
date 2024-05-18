classdef SOLQ < double
    enumeration        
        SOLQ_NONE  (0) % solution status: no solution
        SOLQ_FIX   (1) % solution status: fix
        SOLQ_FLOAT (2) % solution status: float
        SOLQ_SBAS  (3) % solution status: SBAS
        SOLQ_DGPS  (4) % solution status: DGPS/DGNSS
        SOLQ_SINGLE(5) % solution status: single
        SOLQ_PPP   (6) % solution status: PPP
        SOLQ_DR    (7) % solution status: dead reconing
    end
end