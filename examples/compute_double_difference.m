%% compute_double_difference.m
% Compute double-differenced GNSS observation
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/static/";

%% Rover and base position
% Read position from text file
posrllh = readmatrix(datapath+"rover_position.txt");
posbllh = readmatrix(datapath+"base_position.txt");

posr = gt.Gpos(posrllh,"llh");
posb = gt.Gpos(posbllh,"llh");

%% Read RINEX observation/navigation file
obsr = gt.Gobs(datapath+"rover.obs");
obsb = gt.Gobs(datapath+"base.obs");
nav = gt.Gnav(datapath+"base.nav");

%% Mask observation
obsr.mask(obsr.L1.S<35);

%% Synchronize the satellites and time of the two observations
% Satellite and time of the two observations do not match
fprintf('Before commonObs\n');
fprintf('Rover: Nepoch=%d Nsat=%d dt=%.1f\n',obsr.n,obsr.nsat,obsr.dt);
fprintf('Base : Nepoch=%d Nsat=%d dt=%.1f\n',obsb.n,obsb.nsat,obsb.dt);

[obsr2,obsb2] = obsr.commonObs(obsb);

% Satellite and time of the two observations are the same
fprintf('After commonObs\n');
fprintf('Rover: Nepoch=%d Nsat=%d dt=%.1f\n',obsr2.n,obsr2.nsat,obsr2.dt);
fprintf('Base : Nepoch=%d Nsat=%d dt=%.1f\n',obsb2.n,obsb2.nsat,obsb2.dt);

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

%% Plot double-differenced residuals
% DD pseudorange residuals
figure;
plot(obsrb.L1.resPdd);
grid on;
title("DD psedudorange residuals");
xlabel("Epochs");
ylabel("DD pseudorange residuals (m)");
legend(obsrb.satstr,"Location","eastoutside");

% DD carrier phase residuals
resLdd = obsrb.L1.resLdd./obsrb.L1.lam; % m->cycle

% Fractional part of DD carrier phase residuals
f_resLdd = (resLdd-round(resLdd)).*obsrb.L1.lam;

figure;
plot(f_resLdd);
grid on;
title("DD carrier phase residuals");
xlabel("Epochs");
ylabel("DD carrier phase residuals (m)");
legend(obsrb.satstr,"Location","eastoutside");
