% READSAP Read satellite antenna parameters
%  nav = READSAP(file, epoch)
%  nav = READSAP(file, epoch, nav)
%
% Inputs: 
%    file  : 1x1, antenna parameter file (ANTEX format)
%    epoch : 1x6, time {year, month, day, hour, minute, second}
%    nav   : 1x1, navigation data struct
%
% Outputs:
%    nav   : 1x1, navigation data struct
%
% Author: 
%    Taro Suzuki
