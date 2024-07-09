%% estimate_velocity_doppler_step_by_step.m
% Step by step example of velocity estimation by Doppler
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/static/";

%% Read RINEX observation and navigation file
nav = gt.Gnav(datapath+"base.nav");
obs = gt.Gobs(datapath+"rover.obs");

%% Initial position/velocity
posini = obs.pos; % Approximate position
velini = gt.Gvel(zeros(obs.n,3),"xyz"); % Initial velocity is set to zero

%% Select observations for position computation
SNR_TH = 30; % SNR threshold (dBHz)
mask = obs.L1.S<SNR_TH;
obs.maskD(mask);

%% Compute Doppler residuals
sat = gt.Gsat(obs,nav);
sat.setRcvPosVel(posini,velini);
obs = obs.residuals(sat);

%% Velocity estimation
xlog = zeros(obs.n,4); % For logging solution

for i=1:obs.n
    x = [velini.xyz(i,:) 0]'; % [vx vy vz ddtr]'
    
    % resD = obs.D-(rate-ddts)-ddtr
    resD = obs.L1.resD(i,:)-x(4);
    
    idx = ~isnan(resD); % Index not NaN
    nobs = nnz(idx); % Number of current observation

    % Simple elevation angle dependent weight model
    varD90 = 0.1^2; % (m/s)^2
    w = 1./(varD90./sind(sat.el(i,idx))); 

    % Design matrix
    H = zeros(nobs,4);
    H(:,1) = -sat.ex(i,idx)'; % LOS vector in ECEF X
    H(:,2) = -sat.ey(i,idx)'; % LOS vector in ECEF Y
    H(:,3) = -sat.ez(i,idx)'; % LOS vector in ECEF Z
    H(:,4) = 1.0;             % Reciever clock drift
    
    % Weighted least square
    % (y-H*x)'*diag(w)*(y-H*x)
    y = resD(idx)';
    dx = lscov(H,y,w);  % Velocity/clock drift error
    
    % Solution correction
    x = x+dx;

    xlog(i,:) = x';
    fprintf("i=%d\n",i);
end

%% Plot positioning error
velest = gt.Gvel(xlog(:,1:3),"xyz",obs.pos.xyz,"xyz");
err = velest-gt.Gvel([0 0 0],"xyz",obs.pos.xyz,"xyz");
err.plot
disp("RMS ENU velocity error (m)");
err.rmsENU