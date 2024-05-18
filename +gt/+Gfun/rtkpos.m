function [grtk, gsol, gstat] = rtkpos(grtk, gobsr, gnav, gopt, gobsb)
arguments
    grtk gt.Grtk
    gobsr gt.Gobs
    gnav gt.Gnav
    gopt gt.Gopt
    gobsb gt.Gobs
end
[rtk, sol, stat] = rtklib.rtkpos(grtk.struct, gobsr.struct, gnav.struct, gopt.struct, gobsb.struct);
grtk = gt.Grtk(rtk);
gsol = gt.Gsol(sol);
gstat = gt.Gstat(stat);