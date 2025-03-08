%% Example1_visualization_RINEX_observation.m
% Visualization of RINEX observation
% Example 1 in GPS solutions paper
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Vizualization of RINEX observation
gobs = gt.Gobs(datapath+"rover.obs"); % Read RINEX observation
gobs.plot                             % Plot observation
gobs.plotNSat                         % Plot number of observation
gnav = gt.Gnav(datapath+"base.nav");  % Read RINEX navigation
gobs.plotSky(gnav);                   % Plot satellite
