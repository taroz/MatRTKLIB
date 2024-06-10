% COVENUSOL Transform xyz-ECEF covariance to local ENU coordinate
%  Qenu = COVENUSOL(Qecef, orgllh)
%
% Inputs: 
%    Qecef  : Mx6, Covariance in xyz-ECEF coordinate (m or m/s)
%                  RTKLIB solution format: {xx, yy, zz, xy, yz, zx}
%    orgllh : 1x3, origin of geodetic position (deg, deg, m)
%
% Outputs:
%    Qenu   : Mx6, covariance in local ENU coordinate (m or m/s)
%                  RTKLIB solution format: {ee, nn, uu, en, nu, ue}
%
% Author: 
%    Taro Suzuki