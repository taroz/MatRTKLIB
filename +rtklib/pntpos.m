% PNTPOS Compute receiver position, velocity, clock bias by single-point positioning
%  [sol, ssat] = PNTPOS(obs, nav, opt)
%
% Inputs: 
%    obs   : 1x1, observation data struct
%    nav   : 1x1, navigation data struct
%    [opt] : 1x1, option struct
%
% Outputs:
%    sol   : 1x1, solution struct
%    ssat  : 1x1, satellite status struct
%
% Notes:
% 
% Author: 
%    Taro Suzuki