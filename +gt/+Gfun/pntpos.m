function [gsol, gstat] = pntpos(gobs, gnav, gopt)
arguments
    gobs gt.Gobs
    gnav gt.Gnav
    gopt gt.Gopt
end
[sol, stat] = rtklib.pntpos(gobs.struct, gnav.struct, gopt.struct);
gsol = gt.Gsol(sol);
gstat = gt.Gstat(stat);