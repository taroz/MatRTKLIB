% RTKPOS Compute rover position by precise positioning
%  rtk = RTKPOS(rtk, obs, nav, opt)
%  rtk = RTKPOS(rtk, obs, nav, opt, obsb)
%
% Inputs: 
%    rtk   : 1x1, rtk control struct
%    obs   : 1x1, observation data struct
%    nav   : 1x1, navigation data struct
%    opt   : 1x1, option struct
%    [obsb]: 1x1, observation data struct for base station
%
% Outputs:
%    rtk   : 1x1, rtk control struct
% 
% Author: 
%    Taro Suzuki