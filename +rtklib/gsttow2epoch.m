% GSTTOW2EPOCH Convert Galileo time of week to calendar day/time
%  epoch = GSTTOW2EPOCH(tow, week)
%
% Inputs: 
%    tow     : Nx1, Galileo time of week (sec)
%    week    : Nx1, Galileo week
%
% Outputs:
%    epoch   : Nx1, calendar day/time
%                {year, month, day, hour, minute, second}
%
% Author: 
%    Taro Suzuki
