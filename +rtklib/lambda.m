% LAMBDA Integer least-square estimation
%  [F, s] = LAMBDA(nfix, a, Q)
%
% Inputs:
%    nfix : 1x1, number of fixed solutions, typically 2
%    a    : 1xN, float parameters
%    Q    : NxNx1, covariance matrix of float parameters
% Outputs:
%    F   : (nfix)xN, fixed solutions
%    s   : (nfix)x1, sum of squared residuals of fixed solutions
%
% Author: 
%    Taro Suzuki