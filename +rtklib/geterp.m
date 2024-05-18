% GETERP Get earth rotation parameter values
%  erpv = GETERP(erp, epoch)
%
% Inputs: 
%    erp   : 1x1, earth rotation parameter struct
%    epoch : Mx6, calendar day/time in GPST
%               {year, month, day, hour, minute, second}
%
% Outputs:
%    erpv  : Mx4, erp values {xp, yp, ut1_utc, lod} (rad, rad, s, s/d)
% 
% Author: 
%    Taro Suzuki