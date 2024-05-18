% SEARCHPCV Search antenna parameter
%  pcv = SEARCHPCV(sat, type, epoch, pcvs)
%
% Inputs: 
%    sat   : 1x1, satellite number defined in RTKLIB (0: receiver antenna)
%    type  : 1x1, antenna type for receiver antenna
%    epoch : 1x6, calendar day/time in GPST
%                {year, month, day, hour, minute, second}
%    pcvs  : 1x1, pcvs struct
% 
% Outputs:
%    pcv   : 1x1, pcv struct
%
% Author: 
%    Taro Suzuki
