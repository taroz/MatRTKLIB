% SATANTOFF Compute satellite antenna phase center offset in ECEF coordinate
%  [dx, dy, dz] = SATANTOFF(epoch, rsx, rsy, rsz, sat, nav)
%
% Inputs: 
%    epoch : Mx6, calendar day/time in GPST
%               {year, month, day, hour, minute, second}
%    rsx   : MxN, satellite position X in ECEF (m)
%               M: number of epochs
%               N: number of satellites
%    rsy   : MxN, satellite position Y in ECEF (m)
%    rsz   : MxN, satellite position Z in ECEF (m)
%    sat   : 1xN, satellite number defined in RTKLIB
%    nav   : 1x1, navigation data struct
%
% Outputs:
%    dx    : MxN, satellite antenna phase center offset X in ECEF (m)
%    dy    : MxN, satellite antenna phase center offset Y in ECEF (m)
%    dz    : MxN, satellite antenna phase center offset Z in ECEF (m)
%
% Author: 
%    Taro Suzuki
