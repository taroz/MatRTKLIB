% GEOIDH Get geoid height from geoid model
%  geoh = GEOIDH(lat, lon)
%  geoh = GEOIDH(lat, lon, model, file)
%
% Inputs: 
%    lat   : Mx1, Latitude(degree)
%    lon   : Mx1, Longitude(degree)
%    model : 1x1, geoid model type
%              0: EMBEDDED (default) 1: EGM96_M150, 
%              2: EGM2008_M25, 3: EGM2008_M10, 4: GSI2000_M15
%   [file] : 1x1, geoid model file path
%
% Outputs:
%    geoh  : Mx1, geoid height (m) (0.0:error)
%
% Note:
%    RTKLIB embedded geoid model (EGM96, 1x1deg) is used in default
%    the following geoid models can be used
%    EGM96_M150:  WW15MGH.DAC: EGM96 15x15" binary grid height
%    EGM2008_M25: Und_min2.5x2.5_egm2008_isw=82_WGS84_TideFree_SE: EGM2008 2.5x2.5"
%    EGM2008_M10: Und_min1x1_egm2008_isw=82_WGS84_TideFree_SE    : EGM2008 1.0x1.0"
%    GSI2000_M15: gsigeome_ver4 : GSI geoid 2000 1.0x1.5" (japanese area)
%
% Author: 
%    Taro Suzuki
