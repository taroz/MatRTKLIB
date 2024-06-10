% XYZ2ENU Transform ECEF position to local ENU position
%  [enu, E] = XYZ2ENU(xyz, orgllh)
%
% Inputs: 
%    xyz   : Mx3, geodetic position in ECEF coordinate (m)
%    orgllh: 1x3, orgin of geodetic position (deg, deg, m)
%
% Outputs:
%    enu   : Mx3, local ENU position (m)
%    E     : 3x3, ECEF to ENU transformation matrix
% 
% Notes: The function is different from the original xyz2enu in RTKLIB that 
%        only computes the coordinate transformation matrix
%        Use ecef2enu to rotate a vector between two coordinate systems
% 
% Author: 
%    Taro Suzuki