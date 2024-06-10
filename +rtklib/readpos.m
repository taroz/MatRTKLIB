% READPOS Read positions from station position file
%  pos = READPOS(file, station)
%
% Inputs: 
%    file    : 1x1, station position file containing
%                      lat(deg) lon(deg) height(m) name in a line
%    station : 1x1, station name
%
% Outputs:
%    pos     : 1x3, station position {lat,lon,h} (deg, deg, m)
%                      all 0 if search error
%
%  Notes:
%    Use the "readsol" function to read a solution file (???.pos).
% 
% Author: 
%    Taro Suzuki
