%% generate_configuration_file.m
% Generate RTKLIB configuration file
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% % RTKLIB constants
C = gt.C; 

%% Generate RTKLIB configuration
opt = gt.Gopt();                    % RTKLIB default option
opt.pos1.navsys = C.NAVSYS_GREQC;   % Satellite system used for positioning
opt.pos1.elmask = 30;               % Elevation mask (deg)
opt.pos1.snrmask_r = C.ON;          % SNR mask ON
opt.pos1.snrmask_L1 = 35*ones(1,9); % L1 SNR mask (dB-Hz)

%% Wrtite configration to file
opt.saveOpt(datapath+"spp.conf"); % Save configration to file

%% Show options
opt.show