% PEPH2POS Compute satellite position/clock with precise ephemeris/clock
%  [x, y, z, vx, vy, vz, dts, ddts, var] = PEPH2POS(epoch, sat, nav, opt)
%
% Inputs: 
%    epoch : Mx6, calendar day/time in GPST
%                {year, month, day, hour, minute, second}
%    sat   : 1xN, satellite number defined in RTKLIB
%    nav   : 1x1, navigation data struct
%    opt   : 1x1, sat position option
%                (0: center of mass, 1: antenna phase center)
%
% Outputs:
%    x     : MxN, satellite position X in ECEF coordinate (m)
%    y     : MxN, satellite position Y in ECEF coordinate (m)
%    z     : MxN, satellite position Z in ECEF coordinate (m)
%    vx    : MxN, satellite velocity X in ECEF coordinate (m/s)
%    vy    : MxN, satellite velocity Y in ECEF coordinate (m/s)
%    vz    : MxN, satellite velocity Z in ECEF coordinate (m/s)
%    dts   : MxN, satellite clock bias (m)
%    ddts  : MxN, satellite clock drift (m/s)
%    var   : MxN, satellite position and clock error variance (m^2)
%
% Notes:
%    clock includes relativistic correction but does not contain code bias
%    if precise clocks are not set, clocks in sp3 are used instead
% 
% Author: 
%    Taro Suzuki