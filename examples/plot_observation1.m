%% plot_observation1.m
% Show observation status and number of satellite
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/static/";

%% Read RINEX observation file
gobs = gt.Gobs(datapath+"rover.obs");

%% Plot observation
gobs.plot("L1");
gobs.plot("L2");

%%  Plot number of satellites
gobs.plotNSat(); % L1, Threshold: 0dB-Hz

snr_th = 35; % dB-Hz
gobs.plotNSat("L1",snr_th);  % L1, Threshold: 35dB-Hz