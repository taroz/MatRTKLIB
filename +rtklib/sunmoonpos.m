% SUNMOONPOS Get sun and moon position in ECEF
%  [rsun, rmoon, gmst] = SUNMOONPOS(utcepoch, erpv)
%
% Inputs: 
%    utcepoch : Mx6, calendar day/time in UTC
%                 {year, month, day, hour, minute, second}
%    erpv     : 1x4, earth rotation parameter value 
%                 {xp,yp,ut1_utc,lod} (rad, rad, s, s/d)
%
% Outputs:
%    rsun     : Mx3, sun position in ECEF (m) 
%    rmoon    : Mx3, moon position in ECEF (m)
%    gmst     : Mx1, Greenwich Mean Sidereal Time (rad)
%
% Author: 
%    Taro Suzuki