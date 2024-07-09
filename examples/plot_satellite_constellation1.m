%% plot_satellite_constellation1.m
% Show satellite constellation
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/static/";

%% Read RINEX navigation and observation files
gnav = gt.Gnav(datapath+"base.nav");
gobs = gt.Gobs(datapath+"rover.obs");

%% Plot satellite constellation
% RINEX header position is used for receiver position in default
gobs.plotSky(gnav);

%% Plot satellite constellation using gt.Gsat
gsat = gt.Gsat(gobs,gnav);

% Set receiver position
gsat.setRcvPos(gobs.pos);

% Skyplot for only GPS at first epoch
gsat.plotSky(1, gsat.sys==gt.C.SYS_GPS);