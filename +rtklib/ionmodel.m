% IONMODEL Compute ionospheric delay by broadcast ionosphere model (klobuchar model)
%  [delay, var] = IONMODEL(epochs, ion, llh, az, el, freq)
%
% Inputs: 
%    epoch : Mx6, calendar day/time in GPST
%               {year, month, day, hour, minute, second}
%    ion   : 1x8, ionosphere model parameters {a0,a1,a2,a3,b0,b1,b2,b3}
%    llh   : Mx3 or 1x3, receiver geodetic position (deg, deg, m)
%    az    : MxN, satellite azimuth (deg)
%               M: number of epochs
%               N: number of satellites
%    el    : MxN, satellite elevation (deg)
%    freq  : 1xN, carrier frequency (Hz)
%
% Outputs:
%    delay : MxN, ionospheric delay (m)
%    var   : MxN, variance of ionospheric delay (m^2)
%
%  Notes:
%    Frequency compensation is applied
% 
% Author: 
%    Taro Suzuki