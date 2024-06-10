% SATAZEL Compute satellite azimuth/elevation angle
%  [az, el] = SATAZEL(llh, ex, ey, ez)
%
% Inputs: 
%    llh   : Mx3 or 1x3, receiver geodetic position (deg, deg, m)
%    ex    : MxN, receiver-to-satellite unit vector X in ECEF coordinate
%    ey    : MxN, receiver-to-satellite unit vector Y in ECEF coordinate
%    ez    : MxN, receiver-to-satellite unit vector Z in ECEF coordinate
%
% Outputs:
%    az    : MxN, satellite azimuth angle (deg)
%    el    : MxN, satellite elevation angle (deg)
%
% Author: 
%    Taro Suzuki
