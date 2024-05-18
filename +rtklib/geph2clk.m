% GEPH2CLK Compute satellite clock bias with GLONASS ephemeris
%  dts = GEPH2CLK(epoch, eph)
%
% Inputs: 
%    epoch : Mx6, calendar day/time
%              {year, month, day, hour, minute, second}
%    geph  : 1x1, GLONASS ephemeris struct
%
% Outputs:
%    dts   : Mx1, satellite clock bias (s)
%
% Author: 
%    Taro Suzuki
