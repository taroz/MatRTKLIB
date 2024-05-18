% EPOCH2BDTTOW Convert calendar day/time to BeiDou time of week
%  [tow, week] = EPOCH2BDTTOW(epoch)
%
% Inputs: 
%    epoch  : Mx6, calendar day/time 
%                {year, month, day, hour, minute, second}
%
% Outputs:
%    tow    : Mx1, BeiDou time of week (sec)
%    week   : Mx1, BeiDou week
%
% Author: 
%    Taro Suzuki