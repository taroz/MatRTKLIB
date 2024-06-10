% GEODIST Compute geometric distance and receiver-to-satellite unit vector
%  [d, ex, ey, ez] = GEODIST(rsx, rsx, rsz, rr)
%
% Inputs: 
%    rsx  : MxN, satellite position X in ECEF (m)
%              M: number of epochs
%              N: number of satellites
%    rsy  : MxN, satellite position Y in ECEF (m)
%    rsz  : MxN, satellite position Z in ECEF (m)
%    rr   : Mx3 or 1x3, receiver position in ECEF (m)
%
% Outputs:
%    d  : MxN, geometric distance (m) (-1: error/no satellite position)
%    ex : MxN, line-of-sight vector X in ECEF coordinate
%    ey : MxN, line-of-sight vector Y in ECEF coordinate
%    ez : MxN, line-of-sight vector Z in ECEF coordinate
%
% Notes:
%    Distance includes Sagnac effect correction
% 
% Author: 
%    Taro Suzuki