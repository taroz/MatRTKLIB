classdef DLOPT < double
    enumeration
        DLOPT_FORCE  (1) % download option: force download existing
        DLOPT_KEEPCMP(2) % download option: keep compressed file
        DLOPT_HOLDERR(4) % download option: hold on error file
        DLOPT_HOLDLST(8) % download option: hold on listing file
    end
end