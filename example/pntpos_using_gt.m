clc; clear; close all;
addpath ..\
basepath = '.\data\';

%% read RINEX observation and navigation file
gnav = gt.Gnav([basepath 'base.nav']);
gobs = gt.Gobs([basepath 'rover.obs']);

%% plot RINEX observation data
gobs.plot('L1');
gobs.plotNSat('L1');

%% load RTKLIB config file
gopt = gt.Gopt([basepath 'spp.conf']);
% gopt.out.trace = gt.C.TRACE_LV3; % trace option is not saved in the config file
disp(gopt.pos1);

%% single point positioning
[gsol, gstat] = gt.Gfun.pntpos(gobs, gnav, gopt);

%% plot solution
gsol.plot();

%% save to RTKLIB position file
gsol.outSol([basepath 'rover_spp.pos'], gopt);