% ENU2XYZ Transform local ENU position to ECEF position
%  [xyz, E] = ENU2XYZ(enu, orgllh)
%
% Inputs: 
%    enu    : Mx3, local ENU position (m)
%    orgllh : 1x3, origin of geodetic position (deg, deg, m)
%
% Outputs:
%    xyz    : Mx3, geodetic position in ECEF coordinate (m)
%    E      : 3x3, ENU to ECEF transformation matrix
%
% Notes:  Use enu2ecef to rotate a vector between two coordinate systems
% 
% Author: 
%    Taro Suzuki