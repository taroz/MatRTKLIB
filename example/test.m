clc; clear; close all;
addpath ..\
basepath = '.\data\';

%%
gnav = gt.Gnav([basepath 'base.nav']);
gobsr = gt.Gobs([basepath 'rover.obs']);
gobsb = gt.Gobs([basepath 'base.obs']);

% gopt = gt.Gopt();
% gopt.pos1.posmode = gt.C.PMODE_KINEMA;
% gopt.pos1.navsys = gt.C.NAVSYS_GREQC;
% gopt.pos1.snrmask_r = gt.C.ON;
% gopt.pos1.snrmask_b = gt.C.ON;
% gopt.pos1.snrmask_L1(:) = 35;
% gopt.pos1.snrmask_L2(:) = 30;
% gopt.pos1.elmask = 30;
% gopt.pos2.armode = gt.C.ARMODE_INST;
% gopt.ant.reftype = gt.C.POSOPT_LLH;
% gopt.ant.refpos = gobsb.pos.llh;
% gopt.saveOpt([basepath 'rtk.conf']);

gopt = gt.Gopt([basepath 'rtk.conf']);
gopt.out.trace = gt.C.TRACE_LV3; % this option is not saved in the .conf file.

gobsr = gobsr.fixedInterval(1.0);
gobsb = gobsb.commonTime(gobsr);

grtk = gt.Gfun.rtkinit(gopt);

disp('run rtkpos...')
[grtk, gsol, gstat] = gt.Gfun.rtkpos(grtk, gobsr, gnav, gopt, gobsb);
gsol.outSol([basepath 'rover_1hz_rtk_matlab.pos'],gopt.struct);


