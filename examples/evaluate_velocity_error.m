clc; clear; close all;
addpath ../
datapath = "./data/kinematic/";

%% Read RINEX observation and navigation file
gnav = gt.Gnav(datapath+"base.nav");
gobs = gt.Gobs(datapath+"base.obs");

%% Load RTKLIB config file
gopt = gt.Gopt(datapath+"spp.conf");

%% Single point positioning
[gsol, gstat] = gt.Gfun.pntpos(gobs, gnav, gopt);

%% Velocity error
orgxyz = gsol.pos.xyz(1,:); % First position is origin
gsol.setOrg(orgxyz,"xyz")
vxyzref = zeros(gobs.n,3);
err = gsol.vel-gt.Gvel(vxyzref,"xyz",orgxyz,"xyz");

%% Display error statistics
err.rms2D
err.rms3D

%% Plot velocity error
err.setOrg(gobs.pos.llh,"llh");
err.plot
err.plotENU