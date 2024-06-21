function [gsol, gstat] = pntpos(gobs, gnav, gopt)
% pntpos: Call pntpos() in RTKLIB
% -------------------------------------------------------------
% Compute receiver position, velocity, clock bias by single-point
% positioning.
%
% Call rtklib.pntpos. Input is the gt objects.
%
% Usage: ------------------------------------------------------
%   [gsol, gstat] = gt.Gfun.pntpos(gobs, gnav, gopt)
%
% Input: ------------------------------------------------------
%   gobs : 1x1, gt.Gobs, GNSS observation object
%   gnav : 1x1, gt.Gnav, GNSS navigation data object
%   gopt : 1x1, gt.Gopt, RTKLIB process option object
%
% Output: ------------------------------------------------------
%   gsol : 1x1, gt.Gsol, GNSS solution object
%   gstat: 1x1, gt.Gstat, GNSS solution status object
%
% Author: ------------------------------------------------------
%    Taro Suzuki
%
arguments
    gobs gt.Gobs
    gnav gt.Gnav
    gopt gt.Gopt
end
[sol, stat] = rtklib.pntpos(gobs.struct, gnav.struct, gopt.struct);
gsol = gt.Gsol(sol);
gstat = gt.Gstat(stat);