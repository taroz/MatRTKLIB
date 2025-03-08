function [grtk, gsol, gstat] = rtkpos(grtk, gobsr, gnav, gopt, gobsb)
% rtkpos: Call rtkpos() in RTKLIB
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
%   grtk : 1x1, gt.Grtk, RTK control object
%   gobsr: 1x1, gt.Gobs, GNSS observation object for rover
%   gnav : 1x1, gt.Gnav, GNSS navigation data object
%   gopt : 1x1, gt.Gopt, RTKLIB process option object
%  [gobsb] : 1x1, gt.Gobs, RTKLIB observation object for base
%
% Output: ------------------------------------------------------
%   grtk : 1x1, gt.Grtk, RTK control object
%   gsol : 1x1, gt.Gsol, GNSS solution object
%   gstat: 1x1, gt.Gstat, GNSS solution status object
%
% Author: ------------------------------------------------------
%    Taro Suzuki
%
arguments
    grtk  gt.Grtk
    gobsr gt.Gobs
    gnav  gt.Gnav
    gopt  gt.Gopt
    gobsb gt.Gobs = gt.Gobs()
end
if gobsr.n~=gobsb.n
    gobsb = gobsb.sameTime(gobsr);
end
if gobsb.n==0
    [rtk, sol, stat] = rtklib.rtkpos(grtk.struct, gobsr.struct, gnav.struct, gopt.struct);
else
    [rtk, sol, stat] = rtklib.rtkpos(grtk.struct, gobsr.struct, gnav.struct, gopt.struct, gobsb.struct);
end
grtk = gt.Grtk(rtk);
gsol = gt.Gsol(sol);
gstat = gt.Gstat(stat);