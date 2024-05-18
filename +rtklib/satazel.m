% SATAZEL Compute satellite azimuth/elevation angle
%  [az, el] = SATAZEL(llh, ex, ey, ez)
%
% Inputs: 
%    llh   : Mx3 or 1x3, receiver geodetic position (deg, deg, m)
%    ex    : MxN, receiver-to-satellilte unit vevtor X in ECEF coordinate
%    ey    : MxN, receiver-to-satellilte unit vevtor Y in ECEF coordinate
%    ez    : MxN, receiver-to-satellilte unit vevtor Z in ECEF coordinate
%
% Outputs:
%    az    : MxN, satellite azimuth angle (deg)
%    el    : MxN, satellite elevation angle (deg)
%
% Author: 
%    Taro Suzuki
