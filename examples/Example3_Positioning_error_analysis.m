%% Example3_Positioning_error_analysis.m
% Positioning error analysis
% Example 3 in GPS solutions paper
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Positioining error analysis
gsol = gt.Gsol(datapath+"rover.pos");       % Read position solution
gsol = gsol.fixedInterval();                % Constant time interval
ref = readmatrix(datapath+"reference.csv"); % Read reference position
gpos = gt.Gpos(ref(1:5:end,3:5), "llh");    % Create Gpos object
gerr = gsol-gpos;                           % Create Gerr object
gerr.plotCDF3D                              % Plot CDF of 3D error