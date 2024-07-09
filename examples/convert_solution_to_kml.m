%% convert_solution_to_kml.m
% Convert positioning solution to Google Earth KML file
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Read RTKLIB solution file
gsol = gt.Gsol(datapath+"rover_rtk.pos");

%% Convert solution to KML file
open = 1; % Open Google Earth (0:off,1:on)
lw = 1;    % Line width (0: No line)
lc = "w";  % Line Color (e.g. "r" or [1 0 0])
ps = 0.5; % Point size (0: No point)
pc = 0; % Point Color (0: Solution status)

% Save KML file
gsol.outKML(datapath+"rover_rtk.kml", open, lw, lc, ps, pc);