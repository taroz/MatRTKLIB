% CONVKML Convert from solution files to Google Earth KML files
%  CONVKML(file, qflag, tcolor, pcolor, outalt)
%
% Inputs:
%    file   : 1x1, RTKLIB solution file (???.pos)
%                  (wild-card (*) is expanded)
%   [qflag] : 1x1, Quality flag (0:all), Dafult: 0
%   [tcolor]: 1x1, Track color, Dafult: 1
%                 (0:none,1:white,2:green,3:orange,4:red,5:yellow)
%   [pcolor]: 1x1, Point color, Dafult: 5
%                 (0:none,1:white,2:green,3:orange,4:red,5:by qflag)
%   [outalt]: 1x1, Output altitude, Dafult: 0
%                 (0:off,1:elipsoidal,2:geodetic)
%
% Author:
%    Taro Suzuki
