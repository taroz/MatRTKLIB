clc; clear; close all;
addpath ..\
basepath = ".\data\";

%% Read RINEX observation and navigation file
gnav = gt.Gnav(basepath+"base.nav");
gobs = gt.Gobs(basepath+"rover.obs");

%% Plot RINEX observation data
gobs.plot("L1");
gobs.plotNSat("L1");

%% Load RTKLIB config file
gopt = gt.Gopt(basepath+"spp.conf");
% gopt.out.trace = gt.C.TRACE_LV3; % trace option is not saved in the config file
disp(gopt.pos1);

%% Single point positioning
[gsol, gstat] = gt.Gfun.pntpos(gobs, gnav, gopt);

%% Plot solution
gsol.plot();

%% Save to RTKLIB position file
gsol.outSol(basepath+"rover_spp.pos", gopt);