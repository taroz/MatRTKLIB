% DOPS Compute DOP (dilution of precision) from azimuth and elevation
%  dop = DOPS(az, el, elmin)
%
% Inputs: 
%    az      : MxN, satellite azimuth (deg)
%                 M: number of epochs
%                 N: number of satellites {N>=4}
%    el      : MxN, satellite elevation (deg)
%    [elmin] : 1x1, elevation cut-off angle (deg) (default: 0 deg)
%
% Outputs:
%    dop   : Mx4, DOPs {GDOP, PDOP, HDOP, VDOP}
%
% Author: 
%    Taro Suzuki