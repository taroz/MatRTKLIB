%% estimate_position_spp.m
% Single point positioning using RTKLIB
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Read RINEX observation and navigation file
nav = gt.Gnav(datapath+"base.nav");
obs = gt.Gobs(datapath+"rover_1Hz.obs");

%% Plot RINEX observation data
obs.plot("L1");
obs.plotNSat("L1");

%% Load RTKLIB config file
opt = gt.Gopt(datapath+"spp.conf");
% gopt.out.trace = gt.C.TRACE_LV3; % Trace option is not saved in the config file
disp(opt.pos1);

%% Single point positioning
[sol, stat] = gt.Gfun.pntpos(obs, nav, opt);

%% Plot solution
sol.plot();

%% Save to RTKLIB position file
sol.outSol(datapath+"rover_1Hz_spp.pos", opt);