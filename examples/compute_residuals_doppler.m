%% compute_residuals_doppler.m
% Compute Doppler residuals
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Read RINEX observation/navigation file
obs = gt.Gobs(datapath+"base.obs"); % Static data
nav = gt.Gnav(datapath+"base.nav");

%% Compute residuals
% Compute satellite velocity
sat = gt.Gsat(obs, nav); % Compute satellite position

% Set receiver true position/velocity (base station is static)
sat.setRcvPosVel(obs.pos, gt.Gvel([0 0 0],"xyz"));

% Elevation mask (15 degree)
obs.mask(sat.el<15);

% Compute residuals
obs = obs.residuals(sat);

%% Plot residuals
% obs.resD = -obs.D-(sat.rate+sat.ddts)
% Receiver clock drift remains
figure;
plot(obs.L1.resD);
grid on;
title("Doppler residuals (with receiver clock drift)");
xlabel("Epochs");
ylabel("Doppler residuals (m/s)");
legend(obs.satstr,"Location","eastoutside");

%% Compute receiver clock drift
% Average the residuals to estimate receiver clock drift
% Time variation of inter-satellite system bias is negligible
rcvdclk = mean(obs.L1.resD, 2, "omitnan");

figure;
plot(obs.L1.resD-rcvdclk);
grid on;
title("Doppler residuals (m/s)");
xlabel("Epochs");
ylabel("Pseudorange residuals (m/s)");
legend(obs.satstr,"Location","eastoutside");