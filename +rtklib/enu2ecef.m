% ENU2ECEF Transform ENU "vector" to ECEF coordinate
%  [vecef, E] = ENU2ECEF(venu, orgllh)
% 
% Inputs: 
%    venu   : Mx3, vector in ENU coordinate (m or m/s)
%    orgllh : 1x3, origin of geodetic position (deg, deg, m)
%
% Outputs:
%    vecef  : Mx3, vector in ECEF coordinate (m or m/s)
%    E      : 3x3, ENU to ECEF transformation matrix
%
% Notes:  Use enu2xyz to transform local ENU position to ECEF position
% 
% Author: 
%    Taro Suzuki