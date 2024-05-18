% EPOCH2DOY Convert calendar day/time to day of year
%  doy = EPOCH2DOY(epoch)
%  doy = EPOCH2DOY(epoch, utcflag)
%
% Inputs: 
%    epoch   : Mx6, calendar day/time
%                {year, month, day, hour, minute, second}
%    utcflag : 1x1, UTC flag (0: GPST, 1:UTC time) {default = GPST}
%
% Outputs:
%    doy     : Mx1, day of year (days)
%
% Author: 
%    Taro Suzuki
