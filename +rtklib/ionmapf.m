% IONMAPF Compute ionospheric delay mapping function by single layer model
%  ionmap = IONMAPF(llh, az, el)
%
% Inputs: 
%    llh    : Mx3 or 1x3, receiver geodetic position (deg, deg, m)
%    az     : MxN, satellite azimuth (deg)
%                M: number of epochs
%                N: number of satellites
%    el     : MxN, satellite elevation (deg)
%
% Outputs:
%    ionmap : MxN, ionospheric mapping function
% 
% Author: 
%    Taro Suzuki