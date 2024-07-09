%% plot_satellite_constellation2.m
% Show satellite elevation and azimuth angles
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
basepath = "./data/static/";

%% Read RINEX navigation and observation files
gnav = gt.Gnav(basepath+"base.nav");
gobs = gt.Gobs(basepath+"rover.obs");

%% Compute satellite position
gsat = gt.Gsat(gobs,gnav);

% Set receiver position
gsat.setRcvPos(gobs.pos);

%% Plot satellite elevation and azimuth
% GPS satellite index
idxgps = gsat.sys==gt.C.SYS_GPS; 

% Plot GPS elevation/azimuth
tiledlayout(2,1)

% Elevation
ax1 = nexttile;
plot(gsat.time.t,gsat.el(:,idxgps),"LineWidth",2);
ylabel("Elevation angle (deg)")
grid on;

% Azimuth
ax2 = nexttile;
plot(gsat.time.t,gsat.az(:,idxgps),"LineWidth",2);
ylabel("Azimuth angle (deg)")
grid on

% Show satellite name
lg = legend(gsat.satstr(idxgps));
lg.Layout.Tile = "East";
linkaxes([ax1 ax2],"x");
