% BDT2GPST Convert BDT epoch to GPST epoch
%  epoch = BDT2GPST(bdtepoch)
%
% Inputs: 
%    bdtepoch: Nx6, calendar day/time in BeiDou time (BDT)
%                {year, month, day, hour, minute, second}
%
% Outputs:
%    epoch   : Nx6, calendar day/time in GPST
%                {year, month, day, hour, minute, second}
%
% Author: 
%    Taro Suzuki