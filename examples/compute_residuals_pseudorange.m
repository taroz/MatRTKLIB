%% compute_residuals_pseudorange.m
% Compute pseudorange residuals
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/kinematic/";

%% Read RINEX observation/navigation file
obs = gt.Gobs(datapath+"base.obs"); % static data
nav = gt.Gnav(datapath+"base.nav");

%% Compute residuals
% Compute satellite position
sat = gt.Gsat(obs, nav);

% Set receiver true position
sat.setRcvPos(obs.pos);

% Elevation mask (15 degree)
obs.mask(sat.el<15);

% Compute residuals
obs = obs.residuals(sat);

%% Plot residuals
% obs.resPc = obs.P-(sat.rng+sat.dts+sat.trp+sat.ion)
% Receiver clock error remains
figure;
plot(obs.L1.resPc);
grid on;
title("Psedudorange residuals (with receiver clock error)");
xlabel("Epochs");
ylabel("Pseudorange residuals (m)");
legend(obs.satstr,"Location","eastoutside");

%% Compute receiver clock error
% Average the residuals for each satellite system
% Because of the existence of inter-satellite system bias
meanall = @(x) mean(x,2,'omitnan');
g = findgroups(obs.sys);
rcvclk = splitapply(meanall, obs.L1.resPc, g);

% plot pseduorange residuals
figure;
plot(obs.L1.resPc-rcvclk(:,g));
grid on;
title("Psedudorange residuals");
xlabel("Epochs");
ylabel("Pseudorange residuals (m)");
legend(obs.satstr,"Location","eastoutside");