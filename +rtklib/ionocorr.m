% IONOCORR Compute ionospheric correction
%  [delay, var] = IONOCORR(epoch, nav, llh, az, el, ionoopt, freq)
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
%    ionoopt : 1x1, ionospheric correction option (IONOOPT_???)
%    freq    : 1xN, carrier frequency (Hz)
%
% Outputs:
%    delay   : MxN, ionospheric delay (m)
%    var     : MxN, variance of ionospheric delay (m^2)
%
%  Notes:
%    Frequency compensation is applied
% 
% Author: 
%    Taro Suzuki