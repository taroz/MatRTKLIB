classdef Gsol < handle
    % Gsol: GNSS solution class
    %
    % Gsol Declaration:
    % obj = Gsol(file)
    %   file   : 1x1, RTKLIB solution file (???.pos)
    %
    % obj = Gsol(solstr)
    %   sol    : 1x1, RTKLIB solution struct
    %
    % obj = Gsol(time, pos)
    %   time   : 1x1, Time, gt.Gtime class
    %   pos    : 1x1, Position, gt.Gpos class
    %
    % Gsol Properties:
    %   n      : 1x1, Number of epochs
    %   time   : 1x1, Time, gt.Gtime class
    %   pos    : 1x1, Position, gt.Gpos class
    %   vel    : 1x1, Velocity, gt.Gvel class
    %   pcov   : 1x1, Position covariance, gt.Gcov class
    %   vcov   : 1x1, Velocity covariance, gt.Gcov class
    %   dtr    : (obj.n)x6, Receiver clock bias to time systems (s)
    %   ns     : (obj.n)x1, Number of valid satellites
    %   stat   : (obj.n)x1, solution status (SOLQ_???)
    %   age    : (obj.n)x1, Age of differential (s)
    %   ratio  : (obj.n)x1, AR ratio factor for valiation
    %   dt     : 1x1, solution time interval (s)
    %   perr   : 1x1, Position error, gt.Gerr class
    %   verr   : 1x1, Velocity error, gt.Gerr class
    %
    % Gsol Methods:
    %   setSolFile(file) : Set soltion from file
    %   setSolStruct(solstr) : Set soltion from solution struct
    %   setSolTimePos(time, pos) : Set soltion from Gtime and Gpos
    %   setOrg(pos, type) : Set coordinate orgin
    %   outSol(file, [gopt]) : Output solution file
    %   append(gsol) : Append solution object
    %   difference(gobj) : Solution object difference
    %   gsol = select(idx) : Select from index
    %   gsol = selectTimeSpan(ts, te, [dt]) : Select from time
    %   sol = struct([idx]) : Convert to struct
    %   gsol = fixedInterval(dt) : Fixed interval
    %   [gsol,gsolref] = common(gsolref) : Compute Common time
    %   [gpos, gcov] = mean([stat],[idx]) : Compute the position and covariance
    %   [mllh, sdenu] = meanLLH([stat],[idx]) : Compute the mean and standard deviation of LLH position 
    %   [mxyz, sdxyz] = meanXYZ([stat],[idx]) : Compute the mean and standard deviation of XYZ position 
    %   [menu, sdenu] = meanENU([stat],[idx]) : Compute the mean and standard deviation of ENU position 
    %   nstat = solStatCount([stat]) : Solution status count
    %   rstat = solStatRate([stat]) : Solution status rate
    %   plot([stat],[idx]) : Plot ENU position
    %   plotAll([stat],[idx]) : Plot All
    %   help()
    %
    % Author: Taro Suzuki

    properties
        n % Number of epochs
        time % Time, gt.Gtime class
        pos % Position, gt.Gpos class
        vel % Velocity, gt.Gvel class
        pcov % Position covariance, gt.Gcov class
        vcov % Velocity covariance, gt.Gcov class
        dtr % Receiver clock bias to time systems (s)
        ns % Number of valid satellites
        stat % solution status (SOLQ_???)
        age % ge of differential (s)
        ratio % AR ratio factor for valiation
        thres % threshold
        dt % solution time interval (s)
        perr % Position error, gt.Gerr class
        verr % Velocity error, gt.Gerr class
    end
    methods
        %% constractor
        function obj = Gsol(varargin)
            if nargin==1 && (ischar(varargin{1}) || isStringScalar(varargin{1}))
                obj.setSolFile(char(varargin{1})); % file
            elseif nargin==1 && isstruct(varargin{1})
                obj.setSolStruct(varargin{1}); % sol struct
            elseif nargin==2
                obj.setSolTimePos(varargin{1}, varargin{2});
            else
                error('Wrong input arguments');
            end
        end

        %% set soltion from file
        function setSolFile(obj, file)
            % setSolFile: Set soltion from file
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setSolFile(file)
            %
            % Input: ------------------------------------------------------
            %   file  : RTKLIB solution file
            %
            arguments
                obj gt.Gsol
                file (1,:) char
            end
            [sol, sol.rb] = rtklib.readsol(file);

            % reference position
            if all(sol.rb == [0,0,0])
                sol.rb = [];
            end
            obj.setSolStruct(sol);
        end

        %% set soltion from solution struct
        function setSolStruct(obj, solstr)
            % setSolStruct: Set soltion from solution struct
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setSolStruct(solstr)
            %
            % Input: ------------------------------------------------------
            %   solstr  : RTKLIB solution struct
            %
            arguments
                obj gt.Gsol
                solstr struct
            end
            if ~all(solstr.type == solstr.type(1))
                error('Solution formatting is inconsistent');
            end
            obj.n = solstr.n;
            obj.time = gt.Gtime(solstr.ep);
            obj.time.round(3);
            obj.dt = obj.time.estInterval();
            obj.dtr = solstr.dtr;
            obj.ns = solstr.ns;
            obj.stat = gt.C.SOLQ(solstr.stat);
            obj.age = solstr.age;
            obj.ratio = solstr.ratio;
            obj.thres = solstr.thres;
            
            if ~isfield(solstr, 'rb')
                solstr.rb = [];
            end
            if ~isempty(solstr.rb)
                if all(solstr.rb == [0,0,0])
                    solstr.rb = [];
                end
            end
            solstr.rr(solstr.stat==0,:) = NaN;

            if solstr.type(1) == 0 % ECEF
                obj.pos = gt.Gpos(solstr.rr(:,1:3), 'xyz');
                obj.pcov = gt.Gcov(solstr.qr, 'xyz');
                if any(solstr.rr(:,4:6), 'all')
                    obj.vel = gt.Gvel(solstr.rr(:,4:6), 'xyz');
                    obj.vcov = gt.Gcov(solstr.qv, 'xyz');
                end
                if ~isempty(solstr.rb); obj.setOrg(solstr.rb, 'xyz'); end
            else % enu
                obj.pos = gt.Gpos(solstr.rr(:,1:3), 'enu');
                obj.pcov = gt.Gcov(solstr.qr, 'enu');
                if any(solstr.rr(:,4:6), 'all')
                    obj.vel = gt.Gvel(solstr.rr(:,4:6), 'enu');
                    obj.vcov = gt.Gcov(solstr.qv, 'enu');
                end
                if ~isempty(solstr.rb); obj.setOrg(solstr.rb, 'xyz'); end
            end
        end

        %% set soltion from Gtime and Gpos
        function setSolTimePos(obj, time, pos)
            % setSolTimePos: Set soltion from Gtime and Gpos
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setSolTimePos(time, pos)
            %
            % Input: ------------------------------------------------------
            %   time : Time, gt.Gtime class
            %   pos  :  Position, gt.Gpos class
            %
            arguments
                obj gt.Gsol
                time gt.Gtime
                pos gt.Gpos
            end
            if time.n ~= pos.n
                error('Time and pos must be same size');
            end
            if isempty(pos.xyz)
                error('pos.xyz must be set to a value');
            end
            solstr.n = time.n;
            solstr.rb = pos.orgxyz;
            solstr.ep = time.ep;
            solstr.rr = [pos.xyz zeros(solstr.n,3)];
            solstr.qr = zeros(solstr.n,6);
            solstr.qv = zeros(solstr.n,6);
            solstr.dtr = zeros(solstr.n,6);
            solstr.type = zeros(solstr.n,1);
            solstr.stat = ones(solstr.n,1);
            solstr.ns = ones(solstr.n,1);
            solstr.age = zeros(solstr.n,1);
            solstr.ratio = zeros(solstr.n,1);
            solstr.thres = zeros(solstr.n,1);

            obj.setSolStruct(solstr);
        end

        %% set coordinate orgin
        function setOrg(obj, org, orgtype)
            % setOrg: Set coordinate orgin
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setOrg(org, orgtype)
            %
            % Input: ------------------------------------------------------
            %   org : Coordinate origin
            %   orgtype : Coordinate type: 'llh' or 'xyz'
            %
            arguments
                obj gt.Gsol
                org (1,3) double
                orgtype (1,:) char {mustBeMember(orgtype,{'llh','xyz'})}
            end
            obj.pos.setOrg(org, orgtype);
            obj.pcov.setOrg(org, orgtype);
            if ~isempty(obj.vel)
                obj.vel.setOrg(org, orgtype);
                obj.vcov.setOrg(org, orgtype);
            end
        end

        %% output solution file
        function outSol(obj, file, gopt)
            % outSol: Output solution file
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.outSol(file, gopt)
            %
            % Input: ------------------------------------------------------
            %   file : RTKLIB solution file
            %   gopt : optional, Output option
            %
            arguments
                obj gt.Gsol
                file (1,:) char
                gopt = []
            end
            solstr = obj.struct();
            if isempty(solstr.rb)
                solstr.rb = [0 0 0];
            end
            if ~isempty(gopt)
                if ~isa(gopt, 'gt.Gopt')
                    error('gt.Gopt must be input')
                end
                rtklib.outsol(file, solstr, gopt.struct);
            else
                rtklib.outsol(file, solstr);
            end
        end

        %% append
        function append(obj, gsol)
            % append: Append solution object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.append(gsol)
            %
            % Input: ------------------------------------------------------
            %   gsol  : GNSS solution object
            %
            arguments
                obj gt.Gsol
                gsol gt.Gsol
            end
            solstr1 = obj.struct();
            solstr2 = gsol.struct();
            solstr.n = solstr1.n+solstr2.n;
            solstr.rb = solstr1.rb;
            solstr.ep = [solstr1.ep; solstr2.ep];
            solstr.rr = [solstr1.xyz; solstr2.xyz];
            solstr.qr = [solstr1.qr; solstr2.qr];
            solstr.qv = [solstr1.qv; solstr2.qv];
            solstr.dtr = [solstr1.dtr; solstr2.dtr];
            solstr.type = [solstr1.type; solstr2.type];
            solstr.stat = [solstr1.stat; solstr2.stat];
            solstr.ns = [solstr1.ns; solstr2.ns];
            solstr.age = [solstr1.age; solstr2.age];
            solstr.ratio = [solstr1.ratio; solstr2.ratio];
            solstr.thres = [solstr1.thres; solstr2.thres];

            obj.setSolStruct(solstr);
        end

        %% difference
        function difference(obj, gobj)
            % difference: Solution object difference
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.difference(gsol)
            %
            % Input: ------------------------------------------------------
            %   gsol : GNSS solution object
            %
            arguments
                obj gt.Gsol
                gobj
            end
            switch class(gobj)
                case 'gt.Gpos'
                    obj.perr = obj.pos-gobj;
                case 'gt.Gvel'
                    obj.verr = obj.vel-gobj;
                case 'gt.Gsol'
                    if ~isempty(obj.pos) && ~isempty(gobj.pos)
                        obj.perr = obj.pos-gobj.pos;
                    end
                    if ~isempty(obj.vel) && ~isempty(gobj.vel)
                        obj.verr = obj.vel-gobj.vel;
                    end
                otherwise
                    error('gt.Gpos or gt.Gvel or gt.Gsol must be input')
            end
        end

        %% copy
        function gsol = copy(obj)
            % copy: Copy object
            % -------------------------------------------------------------
            % MATLAB handle class is used, so if you want to create a
            % different instance, you need to use the copy method.
            %
            % Usage: ------------------------------------------------------
            %   gsol = obj.copy()
            %
            % Output: ------------------------------------------------------
            %   gsol : 1x1, Copied object
            %
            arguments
                obj gt.Gsol
            end
            gsol = obj.select(1:obj.n);
        end

        %% select from index
        function gsol = select(obj, idx)
            % select: Select from index
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.select(idx)
            %
            % Input: ------------------------------------------------------
            %   idx  : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   gsol : GNSS solution object
            %
            arguments
                obj gt.Gsol
                idx {mustBeInteger, mustBeVector}
            end
            if ~any(idx)
                error('Selected index is empty');
            end
            solstr = obj.struct(idx);
            gsol = gt.Gsol(solstr);

            if ~isempty(obj.perr)
                gsol.perr = obj.perr.select(idx);
            end
            if ~isempty(obj.verr)
                gsol.verr = obj.verr.select(idx);
            end
        end

        %% select from time
        function gsol = selectTimeSpan(obj, ts, te)
            % selectTimeSpan: Select from time
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.selectTimeSpan(ts, te)
            %
            % Input: ------------------------------------------------------
            %   ts  : Start time (datenum or gt.Gtime)
            %   te  : End time (datenum or gt.Gtime)
            %
            % Output: ------------------------------------------------------
            %   gsol : GNSS solution object
            %
            arguments
                obj gt.Gsol
                ts gt.Gtime
                te gt.Gtime
            end
            tr = obj.roundDateTime(obj.time.t,2);
            tsr = obj.roundDateTime(ts.t,2);
            ter = obj.roundDateTime(te.t,2);

            idx = tr>=tsr & tr<=ter;
            gsol = obj.select(idx);
        end

        %% convert to struct
        function solstr = struct(obj, idx)
            % solstr: Convert to struct
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.solstr(idx)
            %
            % Input: ------------------------------------------------------
            %   idx : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   solstr :  RTKLIB solution struct
            %
            arguments
                obj gt.Gsol
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.pos.xyz)
                pos_ = obj.pos.enu;
                pcov_ = obj.pcov.enu;
                type_ = ones(obj.n,1); % type (0:xyz-ecef,1:enu-baseline)
                if ~isempty(obj.vel)
                    vel_ = obj.vel.enu;
                    vcov_ = obj.vcov.enu;
                end
            else
                pos_ = obj.pos.xyz;
                pcov_ = obj.pcov.xyz;
                type_ = zeros(obj.n,1); % type (0:xyz-ecef,1:enu-baseline)
                if ~isempty(obj.vel)
                    vel_ = obj.vel.xyz;
                    vcov_ = obj.vcov.xyz;
                end
            end
            solstr.rb = obj.pos.orgxyz;
            solstr.ep = obj.time.ep(idx,:);
            solstr.n = size(solstr.ep,1);
            if ~isempty(obj.vel)
                solstr.rr = [pos_(idx,:) vel_(idx,:)];
                solstr.qv = vcov_(idx,:);
            else
                solstr.rr = [pos_(idx,:) zeros(solstr.n,3)];
                solstr.qv = zeros(solstr.n,6);
            end
            solstr.qr = pcov_(idx,:);
            solstr.type = type_(idx);
            solstr.dtr = obj.dtr(idx,:);
            solstr.stat = double(obj.stat(idx,:));
            solstr.ns = obj.ns(idx,:);
            solstr.age = obj.age(idx,:);
            solstr.ratio = obj.ratio(idx,:);
            solstr.thres = obj.thres(idx,:);
        end

        %% fixed interval
        function gsol = fixedInterval(obj, dt)
            % fixedInterval: Fixed interval
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.fixedInterval(idx)
            %
            % Input: ------------------------------------------------------
            %   dt : solution time interval
            %
            % Output: ------------------------------------------------------
            %   gsol : GNSS solution object
            %
            arguments
                obj gt.Gsol
                dt (1,1) double = 0
            end
            if dt==0; dt = obj.dt; end
            if isempty(obj.pos.xyz)
                type = 1; % 0:xyz-ecef,1:enu-baseline
            else
                type = 0; % 0:xyz-ecef,1:enu-baseline
            end

            tr = obj.roundDateTime(obj.time.t,2);
            tfixr = obj.roundDateTime((tr(1):seconds(dt):tr(end))',2);
            nfix = length(tfixr);
            tfix = NaT(nfix,1);
            [~, idx1,idx2] = intersect(tfixr,tr);
            tfix(idx1) = obj.time.t(idx2);
            tfix = fillmissing(tfix,'linear');
            gtfix = gt.Gtime(tfix);

            solstr = obj.struct();

            solstrfix.n = nfix;
            solstrfix.ep = gtfix.ep;
            solstrfix.rb = obj.pos.orgxyz;

            solstrfix.rr = NaN(nfix,6);
            solstrfix.qr = NaN(nfix,6);
            solstrfix.qv = NaN(nfix,6);
            solstrfix.dtr = NaN(nfix,6);
            solstrfix.type = type*ones(nfix,1);
            solstrfix.stat = zeros(nfix,1);
            solstrfix.ns = NaN(nfix,1);
            solstrfix.age = NaN(nfix,1);
            solstrfix.ratio = NaN(nfix,1);
            solstrfix.thres = zeros(nfix,1);

            solstrfix.rr(idx1,:) = solstr.rr(idx2,:);
            solstrfix.qr(idx1,:) = solstr.qr(idx2,:);
            solstrfix.qv(idx1,:) = solstr.qv(idx2,:);
            solstrfix.dtr(idx1,:) = solstr.dtr(idx2,:);
            solstrfix.type(idx1) = solstr.type(idx2,:);
            solstrfix.stat(idx1) = solstr.stat(idx2,:);
            solstrfix.ns(idx1) = solstr.ns(idx2,:);
            solstrfix.age(idx1) = solstr.age(idx2,:);
            solstrfix.ratio(idx1) = solstr.ratio(idx2,:);
            solstrfix.thres(idx1) = solstr.thres(idx2,:);

            gsol = gt.Gsol(solstrfix);
        end

        %% common time
        function [gsol,gsolref] = common(obj,gsolref)
            % common: Compute Common time
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.common(gsolref)
            %
            % Input: ------------------------------------------------------
            %   gsolref : GNSS solution reference object
            %
            % Output: ------------------------------------------------------
            %   gsol : GNSS solution object
            %   gsolref : GNSS solution reference object 
            %
            arguments
                obj gt.Gsol
                gsolref gt.Gsol
            end
            t = obj.roundDateTime(obj.time.t,2);
            tref = obj.roundDateTime(gsolref.time.t,2);
            [~,tind,tindref] = intersect(t,tref);
            gsol = obj.select(tind);
            gsolref = gsolref.select(tindref);
        end

        %% mean calculation
        function [gpos, gcov] = mean(obj, stat, idx)
            % mean: Compute the position and covariance
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.mean(stat, idx)
            %
            % Input: ------------------------------------------------------
            %   stat : solution status
            %   idx : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   gpos : GNSS position
            %   gcov : GNSS position covariance 
            %
            arguments
                obj gt.Gsol
                stat (1,1) {mustBeInteger} = 0
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.pos.llh)
                error('pos.llh must be set to a value');
            end
            gsol = obj.select(idx);
            if stat==0
                idxstat = true(gsol.n,1);
            else
                idxstat = gsol.stat==stat;
            end
            [gpos, gcov] = gsol.pos.mean(idxstat);
        end
        function [mllh, sdenu] = meanLLH(obj, stat, idx)
            % meanLLH: Compute the mean and standard deviation of LLH position 
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.meanLLH(stat, idx)
            %
            % Input: ------------------------------------------------------
            %   stat : solution status
            %   idx : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   mllh : Mean of LLH positio
            %   sdenu : Standard deviation of LLH positon
            %
            arguments
                obj gt.Gsol
                stat (1,1) {mustBeInteger} = 0
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.pos.llh)
                error('pos.llh must be set to a value');
            end
            gsol = obj.select(idx);
            if stat==0
                idxstat = true(gsol.n,1);
            else
                idxstat = gsol.stat==stat;
            end
            [mllh, sdenu] = gsol.pos.meanLLH(idxstat);
        end
        function [mxyz, sdxyz] = meanXYZ(obj, stat, idx)
            % meanXYZ: Compute the mean and standard deviation of XYZ position
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.meanXYZ(stat, idx)
            %
            % Input: ------------------------------------------------------
            %   stat : solution status 
            %   idx : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   mxyz : Mean of XYZ positio
            %   sdxyz : Standard deviation of XYZ positon
            %
            arguments
                obj gt.Gsol
                stat (1,1) {mustBeInteger} = 0
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.pos.xyz)
                error('pos.xyz must be set to a value');
            end
            gsol = obj.select(idx);
            if stat==0
                idxstat = true(gsol.n,1);
            else
                idxstat = gsol.stat==stat;
            end
            [mxyz, sdxyz] = gsol.pos.meanXYZ(idxstat);
        end
        function [menu, sdenu] = meanENU(obj, stat, idx)
            % meanENU: Compute the mean and standard deviation of ENU position
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.meanENU(stat, idx)
            %
            % Input: ------------------------------------------------------
            %   stat : solution status 
            %   idx : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   menu : Mean of ENU position
            %   sdenu : Standard deviation of ENU positon
            %
            arguments
                obj gt.Gsol
                stat (1,1) {mustBeInteger} = 0
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.pos.enu)
                error('pos.enu must be set to a value');
            end
            gsol = obj.select(idx);
            if stat==0
                idxstat = true(gsol.n,1);
            else
                idxstat = gsol.stat==stat;
            end
            [menu, sdenu] = gsol.pos.meanENU(idxstat);
        end
        
        %% solution status count
        function nstat = solStatCount(obj, stat)
            % solStatCount: Solution status count
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.solStatCount(stat)
            %
            % Input: ------------------------------------------------------
            %   stat : solution status 
            %
            % Output: ------------------------------------------------------
            %   nstat : solution status count
            %
            arguments
                obj gt.Gsol
                stat (1,:) = 1:7
            end
            for i=1:length(stat)
                nstat(1,i) = nnz(obj.stat==double(stat(i)));
            end
        end

        %% solution status rate
        function rstat = solStatRate(obj, stat)
            % solStatRate: Solution status rate
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.solStatRate(stat)
            %
            % Input: ------------------------------------------------------
            %   stat : solution status 
            %
            % Output: ------------------------------------------------------
            %   rstat : 
            %
            arguments
                obj gt.Gsol
                stat (1,:) = 1:7
            end
            nstat = obj.solStatCount(stat);
            rstat = 100*nstat/obj.n;
        end

        %% plot
        function plot(obj, stat, idx)
            % plot: Plot ENU position
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot(stat, idx)
            %
            % Input: ------------------------------------------------------
            %   stat : solution status
            %   idx : Logical or numeric index to select
            %
            arguments
                obj gt.Gsol
                stat (1,1) {mustBeInteger} = 0
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            gsol = obj.select(idx);
            if ~isempty(gsol.pos.enu)
                enu_ = gsol.pos.enu;
            else
                % first position is origin
                orgllh_ = gsol.pos.llh(find(gsol.stat>0,1),:);
                enu_ = rtklib.llh2enu(gsol.pos.llh, orgllh_);
            end
            if stat==0
                idxstat = true(gsol.n,1);
            else
                idxstat = gsol.stat==stat;
            end
            figure;
            tiledlayout(3,1,'TileSpacing','Compact');
            nexttile(1, [2 1]);
            obj.plotSolStat(enu_(idxstat,1), enu_(idxstat,2), gsol.stat(idxstat), 1);
            xlabel('East (m)');
            ylabel('North (m)');
            grid on; axis equal;
            nexttile;
            obj.plotSolStat(gsol.time.t(idxstat), enu_(idxstat,3), gsol.stat(idxstat), 0);
            grid on;
            ylabel('Up (m)');
            drawnow
        end
        function plotAll(obj, idx)
            % plotAll: Plot All
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotAll(idx)
            %
            % Input: ------------------------------------------------------
            %   idx : Logical or numeric index to select
            %
            arguments
                obj gt.Gsol
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            gsol = obj.select(idx);
            if ~isempty(gsol.pos.enu)
                enu_ = gsol.pos.enu;
            else
                % first position is origin
                orgllh_ = gsol.pos.llh(find(gsol.stat>0,1),:);
                enu_ = rtklib.llh2enu(gsol.pos.llh, orgllh_);
            end

            f = figure;
            f.Position(2) = f.Position(2)-f.Position(4);
            f.Position(4) = 2*f.Position(4);
            tiledlayout(6,1,'TileSpacing','Compact');
            nexttile(1, [2 1]);
            obj.plotSolStat(enu_(:,1), enu_(:,2), gsol.stat, 1);
            xlabel('East (m)');
            ylabel('North (m)');
            grid on; axis equal;
            a1 = nexttile;
            obj.plotSolStat(gsol.time.t, enu_(:,3), gsol.stat, 0);
            ylabel('Up (m)');
            grid on;
            a2 = nexttile;
            obj.plotSolStat(gsol.time.t, gsol.ns, gsol.stat, 0);
            ylabel('Number of satellites');
            grid on;
            a3 = nexttile;
            obj.plotSolStat(gsol.time.t, gsol.ratio, gsol.stat, 0);
            if ~all(gsol.thres==0)
                plot(gsol.time.t, gsol.thres, 'r-', 'LineWidth', 2);
            end
            ylabel('AR ratio factor');
            grid on;
            a4 = nexttile;
            obj.plotSolStat(gsol.time.t, gsol.age, gsol.stat, 0);
            ylabel('Age (s)');
            grid on;

            linkaxes([a1 a2 a3 a4],'x');
            drawnow
        end


        %% help
        function help(~)
            doc gt.Gsol
        end
    end

    %% private functions
    methods (Access = private)
        % round datetime
        function dtr = roundDateTime(~, dt, dec)

            dtr = dateshift(dt,'start','minute') + seconds(round(second(dt),dec));
        end
            % roundDateTime: Round datetime to the nearest specified decimal place
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   dtr = obj.roundDateTime(dt, dec)
            %
            % Input: ------------------------------------------------------
            %   dt  : Solution time interval
            %   dec : Decimal place to round to
            %
            % Output: -----------------------------------------------------
            %   dtr : Rounded datetime object
            %
        function plotSolStat(~, x, y, stat, lflag)
            % plotSolStat: Round datetime to the nearest specified decimal place
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   dtr = obj.plotSolStat(dt, dec)
            %
            % Input: ------------------------------------------------------
            %  x     : x-component of the selected data points 
            %  y     : y-component of the selected data points 
            %  stat  : Solution status data
            %  lflag : Logical flag to indicate whether to display legend
            %
            plot(x, y, '-', 'Color', gt.C.C_LINE);
            grid on; hold on;
            p = [];
            l = {};
            uniquestat = flipud(unique(stat));
            uniquestat(uniquestat==0) = [];
            for i=1:length(uniquestat)
                idx = stat==uniquestat(i);
                p_ = plot(x(idx), y(idx), '.', 'MarkerSize', 10, 'Color', gt.C.C_SOL(uniquestat(i),:));
                p = [p, p_];
                l = [l, string(gt.C.SOLQNAME(double(uniquestat(i))))];
            end
            if lflag
                legend(p, l);
            end
        end
    end
end