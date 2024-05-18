% EPOCH2TOW Convert calendar day/time to GPS time of week
%  [tow, week] = EPOCH2TOW(epoch)
%  [tow, week] = EPOCH2TOW(epoch, utcflag)
%
% Inputs: 
%    epoch   : Mx6, calendar day/time 
%                {year, month, day, hour, minute, second}
%    utcflag : 1x1, UTC flag (0: GPST, 1:UTC time) {default = GPST}
%
% Outputs:
%    tow     : Mx1, GPS time of week (sec)
%    week    : Mx1, GPS week
%
% Author: 
%    Taro Suzuki