% LLH2ENU Transform geodetic position to local ENU position
%  [enu, E] = LLH2ENU(llh, orgllh)
%
% Inputs: 
%    llh   : Mx3, geodetic position (deg, deg, m)
%    orgllh: 1x3, origin of geodetic position (deg, deg, m)
%
% Outputs:
%    enu   : Mx3, local ENU position (m)
%    E     : 3x3, ECEF to ENU transformation matrix
%
% Author: 
%    Taro Suzuki