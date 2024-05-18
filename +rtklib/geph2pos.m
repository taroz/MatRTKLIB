% GEPH2POS Compute satellite position and clock bias with GLONASS ephemeris
%  [rs, dts, var] = GEPH2POS(epoch, geph)
%
% Inputs: 
%    epoch : Mx6, calendar day/time
%               {year, month, day, hour, minute, second}
%    geph  : 1x1, GLONASS ephemeris struct
%
% Outputs:
%    rs    : Mx3, satellite position in ECEF {x,y,z} (m)
%    dts   : Mx1, satellite clock bias (s)
%    var   : Mx1, satellite position and clock variance (m^2)
%
% Author: 
%    Taro Suzuki
