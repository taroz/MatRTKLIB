classdef LLI < double
    enumeration
        LLI_SLIP  (1)   % LLI: cycle-slip
        LLI_HALFC (2)   % LLI: half-cycle not resovled
        LLI_BOCTRK(4)   % LLI: boc tracking of mboc signal
        LLI_HALFA (64)  % LLI: half-cycle added
        LLI_HALFS (128) % LLI: half-cycle subtracted
    end
end