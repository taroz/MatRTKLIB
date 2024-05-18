% IONPPP Compute ionospheric pierce point (ipp) position and slant factor
%  [fs, latp, lonp, hp] = IONPPP(llh, az, el, re, hion)
%
% Inputs: 
%    llh  : Mx3 or 1x3, receiver geodetic position (deg, deg, m)
%    az   : MxN, satellite azimuth (deg)
%              M: number of epochs
%              N: number of satellites
%    el   : MxN, satellite elevation (deg)
%    re   : 1x1, earth radius (km)
%    hion : 1x1, altitude of ionosphere (km)
%
% Outputs:
%    fs   : MxN, slant factor
%    latp : MxN, latitude of pierce point position (deg)
%    lonp : MxN, longitude of pierce point position (deg)
%    hp   : MxN, ellipsoid height of pierce point position (m)
% 
% Author: 
%    Taro Suzuki