% EPOCH2GSTTOW Convert calendar day/time to Galileo time of week
%  [tow, week] = EPOCH2GSTTOW(epoch)
%
% Inputs: 
%    epoch : Mx6, calendar day/time 
%               {year, month, day, hour, minute, second}
%
% Outputs:
%    tow   : Mx1, Galileo time of week (sec)
%    week  : Mx1, Galileo week
%
% Author: 
%    Taro Suzuki