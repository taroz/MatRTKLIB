% TOW2EPOCH Convert GPS time of week to calendar day/time
%  epoch = TOW2EPOCH(tow, week)
%  epoch = TOW2EPOCH(tow, week, utcflag)
%
% Inputs: 
%    tow     : Mx1, GPS time of week (sec)
%    week    : Mx1, GPS week
%    utcflag : 1x1, UTC flag (0: GPST, 1:UTC time) {default = GPST}
%
% Outputs:
%    epoch   : Mx1, calendar day/time
%                {year, month, day, hour, minute, second}
%
% Author: 
%    Taro Suzuki
