clear; clc; close all;
addpath ..\
basepath = ".\data\";

%% Read RINEX navigation and observation files
gnav = gt.Gnav(basepath+"base.nav");
gobs = gt.Gobs(basepath+"rover_1Hz.obs");

%% Compute satellite position
gsat = gt.Gsat(gobs,gnav);

% Set receiver position
gsat.setRcvPos(gobs.pos);

%% Plot satellite constellation
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

lg = legend(gsat.satstr(idxgps));
lg.Layout.Tile = "East";
linkaxes([ax1 ax2],"x");
