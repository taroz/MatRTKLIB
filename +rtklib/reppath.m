% REPPATH Replace keywords in file path
%  rpath = REPPATH(path, [epoch])
%
% Inputs: 
%    path   : 1x1, file path (see below)
%   [epoch] : 1x6, time (optional)
%
% Outputs:
%    rpath  : 1x1, replaced file path
% 
% Note: the following keywords in path are replaced by date and time
%              %Y -> yyyy : year (4 digits) (1900-2099)
%              %y -> yy   : year (2 digits) (00-99)
%              %m -> mm   : month           (01-12)
%              %d -> dd   : day of month    (01-31)
%              %h -> hh   : hours           (00-23)
%              %M -> mm   : minutes         (00-59)
%              %S -> ss   : seconds         (00-59)
%              %n -> ddd  : day of year     (001-366)
%              %W -> wwww : gps week        (0001-9999)
%              %D -> d    : day of gps week (0-6)
%              %H -> h    : hour code       (a=0,b=1,c=2,...,x=23)
%              %ha-> hh   : 3 hours         (00,03,06,...,21)
%              %hb-> hh   : 6 hours         (00,06,12,18)
%              %hc-> hh   : 12 hours        (00,12)
%              %t -> mm   : 15 minutes      (00,15,30,45)
%
%    If no epoch is input, the path is replaced by the current GPS time
%
% Author: 
%    Taro Suzuki
