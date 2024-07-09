%% compute_float_ambiguity.m
% Compute double-differenced float carrier phase ambiguity
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/static/";

%% Rover and base position
% Read position from text file
posrllh = readmatrix(datapath+"rover_position.txt");
posbllh = readmatrix(datapath+"base_position.txt");
posr = gt.Gpos(posrllh,"llh"); % True position, ambiguity must be integer
posb = gt.Gpos(posbllh,"llh");

%% Read RINEX observation/navigation file
obsr = gt.Gobs(datapath+"rover.obs");
obsb = gt.Gobs(datapath+"base.obs");
nav = gt.Gnav(datapath+"base.nav");

obsr = obsr.selectSat(obsr.sys==gt.C.SYS_GPS);
%% Middle/Widelane carrier phase
% Set frequency
obsr.setFrequencyFromNav(nav);
obsb.setFrequencyFromNav(nav);

% Compute linear combination
obsr = obsr.linearCombination;
obsb = obsb.linearCombination;

%% Mask observation
obsr.mask(obsr.L1.S<35);

%% Synchronize the satellites and time of the two observations
[obsr2,obsb2] = obsr.commonObs(obsb);

%% Compute residuals (Compensate geometric distance)
satr = gt.Gsat(obsr2, nav); % Compute satellite position
satr.setRcvPos(posr); % Set receiver position
obsr2 = obsr2.residuals(satr); % Compute residuals

satb = gt.Gsat(obsb2, nav); % Compute satellite position
satb.setRcvPos(posb); % Set receiver position
obsb2 = obsb2.residuals(satb); % Compute residuals

%% Single difference (rover-base)
obsrb = obsr2-obsb2;

%% Double difference
% Reference satellite (higest elevation angle)
refsatidx = satb.referenceSat();

% Double difference
obsrb = obsrb.doubleDifference(refsatidx);

%% Plot L1 DD ambiguitay
resLdd = obsrb.L1.resLdd./obsrb.L1.lam; % m->cycle

% The ambiguity of the carrier phase at the correct position should be an integer
figure;
plot(resLdd,'.-');
grid on;
title("Float DD L1 carrier phase ambiguity");
xlabel("Epochs");
ylabel("DD L1 carrier phase ambiguity (cycle)");
legend(obsrb.satstr,"Location","eastoutside");

%% Plot widelane DD ambiguitay
% DD widelane carrier phase residuals (wave length = 0.8m)
resLwldd = obsrb.Lwl.resLdd./obsrb.Lwl.lam; % m->cycle

figure;
plot(resLwldd,'.-');
grid on;
title("Float DD widelane carrier phase ambiguity");
xlabel("Epochs");
ylabel("DD widelane carrier phase ambiguity (cycle)");
legend(obsrb.satstr,"Location","eastoutside");
