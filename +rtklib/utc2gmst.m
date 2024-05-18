% UTC2GMST Convert utc to GMST (Greenwich Mean Sidereal Time)
%  gmst = UTC2GPST(utcepoch, ut1_utc)
%
% Inputs: 
%    utcepoch : Mx6, calendar day/time in UTC
%                {year, month, day, hour, minute, second}
%    ut1_utc  : 1x1, UT1-UTC (s)
%
% Outputs:
%    gmst     : Mx1, GMST (rad)
%
% Author: 
%    Taro Suzuki