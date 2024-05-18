classdef SOLQNAME < double
    enumeration
        NONE  (0) % solution status: no solution
        FIX   (1) % solution status: fix
        FLOAT (2) % solution status: float
        SBAS  (3) % solution status: SBAS DGNSS
        DGNSS (4) % solution status: Code DGPS/DGNSS
        SPP   (5) % solution status: single point positioning
        PPP   (6) % solution status: PPP
        DR    (7) % solution status: dead reconing
    end
end