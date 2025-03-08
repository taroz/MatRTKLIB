%% Example2_PPK_analysis.m
% Post-processing kinematic example
% Example 2 in GPS solutions paper
% Author: Taro Suzuki
clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Postpprocessing Kinematic
gobsr = gt.Gobs(datapath+"rover_1Hz.obs"); % Rover RINEX observation
gobsb = gt.Gobs(datapath+"base.obs");      % Base RINEX observation
gnav  = gt.Gnav(datapath+"base.nav");      % RINEX navigation
gopt  = gt.Gopt(datapath+"rtk.conf");      % Process options
grtk  = gt.Grtk(gopt);                     % RTK object
[grtk, gsol] = ...                         % Call rtkpos function
    gt.Gfun.rtkpos(grtk, gobsr, gnav, gopt, gobsb);
gsol.plot();                               % Plot solution
gsol.outSol(datapath+"rover.pos");         % Save solution
