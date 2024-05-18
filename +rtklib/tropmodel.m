% TROPMODEL Compute tropospheric delay by standard atmosphere and saastamoinen model
%  [delay, var] = TROPMODEL(epochs, llh, az, el)
%
% Inputs: 
%    epoch : Mx6, calendar day/time in GPST
%                {year, month, day, hour, minute, second}
%    llh   : Mx3 or 1x3, receiver geodetic position (deg, deg, m)
%    az    : MxN, satellite azimuth (deg)
%                M: number of epochs
%                N: number of satellites
%    el    : MxN, satellite elevation (deg)
%
% Outputs:
%    delay : MxN, tropospheric delay (m)
%    var   : MxN, variance of tropospheric delay (m^2)
% 
% Author: 
%    Taro Suzuki