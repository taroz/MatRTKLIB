classdef STRFMT < double
    enumeration
        STRFMT_RTCM2(0)   % stream format: RTCM 2
        STRFMT_RTCM3(1)   % stream format: RTCM 3
        STRFMT_OEM4 (2)   % stream format: NovAtel OEMV/4
        STRFMT_OEM3 (3)   % stream format: NovAtel OEM3
        STRFMT_UBX  (4)   % stream format: u-blox LEA-*T
        STRFMT_SS2  (5)   % stream format: NovAtel Superstar II
        STRFMT_CRES (6)   % stream format: Hemisphere
        STRFMT_STQ  (7)   % stream format: SkyTraq S1315F
        STRFMT_JAVAD(8)   % stream format: JAVAD GRIL/GREIS
        STRFMT_NVS  (9)   % stream format: NVS NVC08C
        STRFMT_BINEX(10)  % stream format: BINEX
        STRFMT_RT17 (11)  % stream format: Trimble RT17
        STRFMT_SEPT (12)  % stream format: Septentrio
        STRFMT_RINEX(13)  % stream format: RINEX
        STRFMT_SP3  (14)  % stream format: SP3
        STRFMT_RNXCLK(15) % stream format: RINEX CLK
        STRFMT_SBAS (16)  % stream format: SBAS messages
        STRFMT_NMEA (17)  % stream format: NMEA 0183
        MAXRCVFMT   (12)  % max number of receiver format
    end
end