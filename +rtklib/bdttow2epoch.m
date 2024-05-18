% BDTTOW2EPOCH Convert BeiDou time of week to calendar day/time
%  epoch = BDTTOW2EPOCH(tow, week)
%
% Inputs: 
%    tow   : Nx1, BeiDou time of week (sec)
%    week  : Nx1, BeiDou week
%
% Outputs:
%    epoch : Nx1, calendar day/time
%              {year, month, day, hour, minute, second}
%
% Author: 
%    Taro Suzuki
