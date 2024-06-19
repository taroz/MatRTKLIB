clear; clc; close all;
addpath ..\
datapath = ".\data\static\";

%% Read RINEX navigation and observation files
gnav = gt.Gnav(datapath+"base.nav");
gobs = gt.Gobs(datapath+"rover_1Hz.obs");

%% Plot satellite constellation
% RINEX header position is used for receiver position in default
gobs.plotSky(gnav);

%% Plot satellite constellation using gt.Gsat
gsat = gt.Gsat(gobs,gnav);

% Set receiver position
gsat.setRcvPos(gobs.pos);

% Skyplot for only GPS at first epoch
gsat.plotSky(1, gsat.sys==gt.C.SYS_GPS);