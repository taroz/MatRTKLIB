% EPH2CLK Compute satellite clock bias with broadcast ephemeris (GPS, GAL, QZS, BDS, IRN)
%  dts = EPH2CLK(epoch, eph)
%
% Inputs: 
%    epoch : Mx6, calendar day/time
%              {year, month, day, hour, minute, second}
%    eph   : 1x1, ephemeris struct
%
% Outputs:
%    dts   : Mx1, satellite clock bias (s)
%
% Notes:
%    satellite clock does not include relativity correction and tdg
% 
% Author: 
%    Taro Suzuki
