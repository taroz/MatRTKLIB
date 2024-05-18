classdef PMODE < double
    enumeration
        PMODE_SINGLE    (0) % positioning mode: single
        PMODE_DGPS      (1) % positioning mode: DGPS/DGNSS
        PMODE_KINEMA    (2) % positioning mode: kinematic
        PMODE_STATIC    (3) % positioning mode: static
        PMODE_MOVEB     (4) % positioning mode: moving-base
        PMODE_FIXED     (5) % positioning mode: fixed
        PMODE_PPP_KINEMA(6) % positioning mode: PPP-kinemaric
        PMODE_PPP_STATIC(7) % positioning mode: PPP-static
        PMODE_PPP_FIXED (8) % positioning mode: PPP-fixed
    end
end