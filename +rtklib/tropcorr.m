% TROPCORR Compute tropospheric correction
%  [delay, var] = TROPCORR(epochs, nav, llh, az, el, tropopt)
%
% Inputs: 
%    epoch   : Mx6, calendar day/time in GPST
%                 {year, month, day, hour, minute, second}
%    nav     : 1x1, navigation data struct
%    llh     : Mx3 or 1x3, receiver geodetic position (deg, deg, m)
%    az      : MxN, satellite azimuth (deg)
%                 M: number of epochs
%                 N: number of satellites
%    el      : MxN, satellite elevation (deg)
%    tropopt : 1x1, tropospheric correction option (TROPOPT_???)
%
% Outputs:
%    delay   : MxN, tropospheric delay (m)
%    var     : MxN, variance of tropospheric delay (m^2)
% 
% Author: 
%    Taro Suzuki