%% edit_rinex_observation4.m
% Exclude satellites from RINEX observation
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Read RINEX observation file
gobs = gt.Gobs(datapath+"rover_1Hz.obs");

%% Exclude satellite system
% Plot number of satellites
gobs.plotNSat();

% Exclude satellite
gobs_exsys = gobs.selectSat(gobs.sys==gt.C.SYS_GPS); % Only GPS

% Plot number of satellites
gobs_exsys.plotNSat();

%% Exclude G05 and G06
fprintf('Original: nsat:%d\n', gobs_exsys.nsat);
disp(gobs_exsys.satstr);

% Sattelite indexes not excluded
satidx = ~ismember(gobs_exsys.satstr, {'G05','G06'}); 

% Exclude satellite
gobs_exsat = gobs_exsys.selectSat(satidx);

fprintf('Excluded: nsat:%d\n', gobs_exsat.nsat);
disp(gobs_exsat.satstr);