% SATPOSS Compute satellite position, velocity and clock
%  [x, y, z, vx, vy, vz, dts, ddts, var, svh] = SATPOSS(obs, nav, opt)
%
% Inputs: 
%    obs   : 1x1, observation data struct
%    nav   : 1x1, navigation data struct
%    opt   : 1x1, ephemeris option (EPHOPT_???)
%
% Outputs:
%    x     : MxN, satellite position X in ECEF (m)
%               M: number of epochs {obs.n}
%               N: number of satellites {obs.nsat}
%    y     : MxN, satellite position Y in ECEF (m)
%    z     : MxN, satellite position Z in ECEF (m)
%    vx    : MxN, satellite velocity X in ECEF (m/s)
%    vy    : MxN, satellite velocity Y in ECEF (m/s)
%    vz    : MxN, satellite velocity Z in ECEF (m/s)
%    dts   : MxN, satellite clock bias (m)
%    ddts  : MxN, satellite clock drift (m/s)
%    var   : MxN, sat position and clock error variance (m^2)
%    svh   : MxN, sat health flag (-1:correction not available)
%
% Notes:
%    satellite position and clock are values at signal transmission time
%    pseudorange and broadcast ephemeris are needed to get signal transmission time
%    satellite position is referenced to antenna phase center
%    satellite clock does not include code bias correction (tgd or bgd)
% 
% Author: 
%    Taro Suzuki