% CONVGPX Convert from solution files to GPX files
%  CONVGPX(file, qflag, outtrk, outpnt, outalt)
%
% Inputs:
%    file   : 1x1, RTKLIB solution file (???.pos)
%                  (wild-card (*) is expanded)
%   [qflag] : 1x1, Quality flag (0:all), Dafult: 0
%   [outtrk]: 1x1, Output track (0:off,1:on), Dafult: 1
%   [outpnt]: 1x1, Output waypoint (0:off,1:on), Dafult: 1
%   [outalt]: 1x1, Output altitude, Dafult: 0
%                 (0:off,1:elipsoidal,2:geodetic)
%
% Author:
%    Taro Suzuki
