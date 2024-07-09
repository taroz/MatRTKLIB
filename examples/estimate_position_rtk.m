%% estimate_position_rtk.m
% RTK-GNSS positioning using RTKLIB
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Read RINEX observation and navigation file
gnav = gt.Gnav(datapath+"base.nav");
gobsr = gt.Gobs(datapath+"rover_1Hz.obs");
gobsb = gt.Gobs(datapath+"base.obs");

%% Make base and rover time the same
gobsb = gobsb.sameTime(gobsr);

%% Load RTKLIB config file
gopt = gt.Gopt(datapath+"rtk.conf");
% gopt.out.trace = gt.C.TRACE_LV3; % Trace option is not saved in the config file
disp(gopt.pos1);

%% RTK Positioning
grtk = gt.Grtk(gopt); % RTK control object

disp('run rtkpos...')
[grtk, gsol, gstat] = gt.Gfun.rtkpos(grtk, gobsr, gnav, gopt, gobsb);

%% Plot solution
gsol.plot();

%% Output solution
gsol.outSol(datapath+"rover_1Hz_rtk.pos",gopt);


