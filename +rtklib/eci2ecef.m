% ECI2ECEF Compute ECI to ECEF transformation matrix
%  [U, gmst] = ECI2ECEF(utcepoch, erpv)
%
% Inputs:
%    utcepoch : Mx6, calendar day/time in UTC
%                  {year, month, day, hour, minute, second} 
%    erpv     : 1x4, erp values {xp, yp, ut1_utc, lod} (rad, rad, s, s/d)
%
% Outputs:
%    U        : 3x3xM, ECI to ECEF transformation matrix
%    gmst     : Mx1, Greenwich Mean Sidereal Time (rad)
%
% Author: 
%    Taro Suzuki