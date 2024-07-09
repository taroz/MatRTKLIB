%% estimate_position_spp1_step_by_step.m
% Step by step example of single point positioning
% Author: Taro Suzuki

clear; close all; clc;
addpath ../
datapath = "./data/static/"; % Static data

%% Read RINEX observation and navigation file
nav = gt.Gnav(datapath+"base.nav");
obs = gt.Gobs(datapath+"rover.obs");

% Select only GPS
obs = obs.selectSat(obs.sys==gt.C.SYS_GPS);

%% Position reference
llhref = readmatrix(datapath+"rover_position.txt");

%% Select observations for position computation
SNR_TH = 30; % SNR threshold (dBHz)
EL_TH = 10; % Elevation angle threshold (deg)
obs.maskP(obs.L1.S<SNR_TH);

%% Initials
nx = 3+1; % Position in ECEF and receiver clock [x,y,z,dtr]'
x = zeros(nx,1); % Initial position is center of the Earth
xlog = zeros(obs.n,nx); % For logging solution

%% Point positioning
for i=1:obs.n
    obsc = obs.selectTime(i); % Current observation
    sat = gt.Gsat(obsc,nav); % Compute satellite position

    % Repeat until convergence
    for iter = 1:10
        sat.setRcvPos(gt.Gpos(x(1:3)',"xyz")); % Set current receiver position
        obsc = obsc.residuals(sat); % Compute pseudorange residuals at current position

        % resP = obs.P-(rng-dts+ion+trp)-dtr-tgd
        resP = obsc.L1.resPc-x(4)-nav.getTGD(sat.sat);

        idx = ~isnan(resP) & sat.el>EL_TH; % Index not NaN
        nobs = nnz(idx); % Number of current observation

        % Simple elevation angle dependent weight model
        varP90 = 0.5^2;
        w = 1./(varP90./sind(sat.el(idx))); 
        sys = obsc.sys(idx);

        % Design matrix
        H = zeros(nobs,nx);
        H(:,1) = -sat.ex(idx)'; % LOS vector in ECEF X
        H(:,2) = -sat.ey(idx)'; % LOS vector in ECEF Y
        H(:,3) = -sat.ez(idx)'; % LOS vector in ECEF Z
        H(:,4) = 1.0;           % Reciever clock
        
        % Weighted least square
        % (y-H*x)'*diag(w)*(y-H*x)
        y = resP(idx)';
        dx = lscov(H,y,w); % position/clock error
        
        % Solution correction
        x = x+dx;

        % Exit loop after convergence 
        if norm(dx)<1e-3
            break;
        end
    end
    xlog(i,:) = x';
    fprintf("i=%d iter:%d\n",i,iter);
end

%% Plot positioning error
posest = gt.Gpos(xlog(:,1:3),'xyz');
posest.setOrg(llhref,"llh");
posest.plot