classdef EPHOPT < double
    enumeration
        EPHOPT_BRDC  (0) % ephemeris option: broadcast ephemeris
        EPHOPT_PREC  (1) % ephemeris option: precise ephemeris
        EPHOPT_SBAS  (2) % ephemeris option: broadcast + SBAS
        EPHOPT_SSRAPC(3) % ephemeris option: broadcast + SSR_APC
        EPHOPT_SSRCOM(4) % ephemeris option: broadcast + SSR_COM
    end
end