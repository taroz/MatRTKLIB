classdef OBSTYPE < double
    enumeration
        OBSTYPE_PR   (1) % observation type: pseudorange
        OBSTYPE_CP   (2) % observation type: carrier-phase
        OBSTYPE_DOP  (4) % observation type: doppler-freq
        OBSTYPE_SNR  (8) % observation type: SNR
        OBSTYPE_ALL(255) % observation type: all
    end
end