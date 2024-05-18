% TROPMAPF Compute tropospheric mapping function by NMF
%  [mapd, mapw] = TROPMAPF(epochs, llh, az, el)
%
% Inputs: 
%    epoch : Mx6, calendar day/time in GPST
%                {year, month, day, hour, minute, second}
%    llh   : Mx3 or 1x3, receiver geodetic position (deg, deg, m)
%    az    : MxN, satellite azimuth (deg)
%                M: number of epochs
%                N: number of satellites
%    el    : MxN, satellite elevation (deg)
%
% Outputs:
%    mapd  : MxN, dry mapping function (m)
%    mapw  : MxN, wet mapping function (m)
% 
% Notes: 
%    -DIERS_MODEL use GMF instead of NMF 
% 
% Author: 
%    Taro Suzuki