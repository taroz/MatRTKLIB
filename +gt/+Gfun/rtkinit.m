function grtk = rtkinit(gopt)
arguments
    gopt gt.Gopt
end
grtk = gt.Grtk(rtklib.rtkinit(gopt.struct));