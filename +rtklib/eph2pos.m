% EPH2POS Compute satellite position and clock bias with broadcast ephemeris (GPS, GAL, QZS, BDS, IRN)
%  [rs, dts, var] = EPH2POS(epoch, eph)
%
% Inputs: 
%    epoch : Mx6, calendar day/time
%              {year, month, day, hour, minute, second}
%    eph   : 1x1, ephemeris struct
%
% Outputs:
%    rs    : Mx3, satellite position in ECEF {x,y,z} (m)
%    dts   : Mx1, satellite clock bias (s)
%    var   : Mx1, satellite position and clock variance (m^2)
%
% Notes:
%    satellite clock includes relativity correction without code bias
% 
% Author: 
%    Taro Suzuki
