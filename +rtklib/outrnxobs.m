% OUTRNXOBS Output RINEX observation file
%  OUTRNXOBS(file, obs)
%  OUTRNXOBS(file, obs, pos)
%  OUTRNXOBS(file, obs, pos, fcn, rnxver)
%  OUTRNXOBS(file, obs, pos, fcn, rnxver)
%
% Inputs: 
%    file   : 1x1, file name {???.obs}
%    obs    : 1x1, observation struct
%    pos    : 1x3, approximate position in ECEF
%    fcn    : 1x32, GLONASS FCN
%    rnxver : 1x1, RINEX version (x100) default: 303
%     
% Author: 
%    Taro Suzuki
