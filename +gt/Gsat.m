classdef Gsat < handle
    % Gsat: GNSS satellite related data class
    % ---------------------------------------------------------------------
    % Gsat Declaration:
    % gsat = Gsat();  Create empty gt.Gsat object
    %
    % gsat = Gsat(gobs, gnav, [ephopt]);  Create gt.Gsat object from
    %                                     observation and navigation
    %   gobs      : 1x1, gt.Gobs object, GNSS observation
    %   gnav      : 1x1, gt.Gnav object, GNSS navigation
    %  [ephopt]   : 1x1, Ephemeris option (gt.C.EPHOPT_???) (optional)
    %                    Default: ephopt = gt.C.EPHOPT_BRDC
    %
    % gsat = Gsat(gtime, sat, gnav, [ephopt]);  Create gt.Gsat object from
    %                                           time, sat, and navigation
    %   gtime     : 1x1, gt.Gtime object, time
    %   sat       : 1xN, Satellite number (Compliant RTKLIB)
    %   gnav      : 1x1, gt.Gnav object, GNSS navigation
    %  [ephopt]   : 1x1, Ephemeris option (gt.C.EPHOPT_???) (optional)
    %                    Default: ephopt = gt.C.EPHOPT_BRDC
    % ---------------------------------------------------------------------
    % Gsat Properties:
    %   n         : 1x1, Number of epochs
    %   nsat      : 1x1, Number of satellites
    %   sat       : 1x(obj.nsat), Satellite number (Compliant RTKLIB)
    %   prn       : 1x(obj.nsat), Satellite prn/slot number
    %   sys       : 1x(obj.nsat), Satellite system (SYS_GPS, SYS_GLO, ...)
    %   satstr    : 1x(obj.nsat), Satellite ID cell array ('Gnn','Rnn','Enn','Jnn','Cnn','Inn' or 'nnn')
    %   time      : 1x1, Time, gt.Gtime object
    %   x         : (obj.n)x(obj.nsat), Satellite position in ECEF X (m)
    %   y         : (obj.n)x(obj.nsat), Satellite position in ECEF Y (m)
    %   z         : (obj.n)x(obj.nsat), Satellite position in ECEF Z (m)
    %   vx        : (obj.n)x(obj.nsat), Satellite position in ECEF X (m/s)
    %   vy        : (obj.n)x(obj.nsat), Satellite position in ECEF Y (m/s)
    %   vz        : (obj.n)x(obj.nsat), Satellite position in ECEF Z (m/s)
    %   dts       : (obj.n)x(obj.nsat), Satellite clock bias (m)
    %   ddts      : (obj.n)x(obj.nsat), Satellite clock drift (m/s)
    %   var       : (obj.n)x(obj.nsat), Satellite position and clock error variance (m^2)
    %   svh       : (obj.n)x(obj.nsat), Satellite health flag
    %   pos       : 1x1, Receiver position, gt.Gpos object
    %   vel       : 1x1, Receiver velocity, gt.Gvel object
    %   rng       : (obj.n)x(obj.nsat), Geometric distance (m)
    %   rate      : (obj.n)x(obj.nsat), Range rate (m/s)
    %   ex        : (obj.n)x(obj.nsat), Line-of-sight vector in ECEF X (m)
    %   ey        : (obj.n)x(obj.nsat), Line-of-sight vector in ECEF Y (m)
    %   ez        : (obj.n)x(obj.nsat), Line-of-sight vector in ECEF Z (m)
    %   az        : (obj.n)x(obj.nsat), Satellite azimuth angle (deg)
    %   el        : (obj.n)x(obj.nsat), Satellite elevation angle (deg)
    %   trp       : (obj.n)x(obj.nsat), Tropospheric delay (m)
    %   ionL1     : (obj.n)x(obj.nsat), Ionospheric delay at L1 frequency (m)
    %   ionL2     : (obj.n)x(obj.nsat), Ionospheric delay at L2 frequency (m)
    %   ionL5     : (obj.n)x(obj.nsat), Ionospheric delay at L5 frequency (m)
    %   ionL6     : (obj.n)x(obj.nsat), Ionospheric delay at L6 frequency (m)
    %   ionL7     : (obj.n)x(obj.nsat), Ionospheric delay at L7 frequency (m)
    %   ionL8     : (obj.n)x(obj.nsat), Ionospheric delay at L8 frequency (m)
    %   ionL9     : (obj.n)x(obj.nsat), Ionospheric delay at L9 frequency (m)
    % ---------------------------------------------------------------------
    % Gsat Methods:
    %   setSatObs(gobs, gnav, ephopt);    Set satellite data at observation time
    %   setSat(gtime, sat, gnav, ephopt); Set satellite data at input time
    %   setRcvPos(gpos);                  Set receiver position and compute satellite data
    %   setRcvVel(gvel);                  Set receiver velocity and compute satellite data
    %   setRcvPosVel(gpos, gvel);         Set receiver position/velocity and compute satellite data
    %   gsat = copy();                    Copy object
    %   gsat = select(obj, tidx, sidx);   Select satellite data from time/satellite index
    %   gsat = selectSat(sidx);           Select satellite data from satellite index
    %   gsat = selectTime(tidx);          Select satellite data from time index
    %   gsat = selectTimeSpan(ts, te);    Select satellite data from time span
    %   [refidx,Dinv] = referenceSat([tidx]); Compute reference satellite
    %   plotSky([tidx], [sidx]);          Plot satellite constellation
    %   help();                           Show help
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki
    %
    properties
        n      % Number of epochs
        nsat   % Number of satellites
        sat    % Satellite number (Compliant RTKLIB)
        prn    % Satellite prn/slot number
        sys    % Satellite system (SYS_GPS, SYS_GLO, ...)
        satstr % Satellite id cell array
        time   % Time, gt.Gtime object
        x      % Satellite position in ECEF X (m)
        y      % Satellite position in ECEF Y (m)
        z      % Satellite position in ECEF Z (m)
        vx     % Satellite position in ECEF X (m/s)
        vy     % Satellite position in ECEF Y (m/s)
        vz     % Satellite position in ECEF Z (m/s)
        dts    % Satellite clock bias (m)
        ddts   % Satellite clock drift (m/s)
        var    % Satellite position and clock error variance (m^2)
        svh    % Satellite health flag
        pos    % Receiver position, gt.Gpos object
        vel    % Satellite velocity, gt.Gvel object
        rng    % Geometric distance (m)
        rate   % Range rate (m/s)
        ex     % Line-of-sight vector in ECEF X (m)
        ey     % Line-of-sight vector in ECEF Y (m)
        ez     % Line-of-sight vector in ECEF Z (m)
        az     % Satellite azimuth angle (deg)
        el;    % Satellite elevation angle (deg)
        trp;   % Tropospheric delay (m)
        ionL1; % Ionospheric delay at L1 frequency (m)
        ionL2; % Ionospheric delay at L2 frequency (m)
        ionL5; % Ionospheric delay at L5 frequency (m)
        ionL6; % Ionospheric delay at L6 frequency (m)
        ionL7; % Ionospheric delay at L7 frequency (m)
        ionL8; % Ionospheric delay at L8 frequency (m)
        ionL9; % Ionospheric delay at L9 frequency (m)
    end
    properties(Access=private)
        obs,nav;
        FTYPE = ["L1","L2","L5","L6","L7","L8","L9"];
    end
    methods
        %% constructor
        function obj = Gsat(varargin)
            if nargin==0
                % generate empty object
                obj.n = 0;
                obj.nsat = 0;
            elseif nargin==2
                obj.setSatObs(varargin{1},varargin{2}); % call rtklib.satposs
            elseif nargin==3 && isa(varargin{1}, 'gt.Gobs')
                obj.setSatObs(varargin{1},varargin{2},varargin{3}); % call rtklib.satposs
            elseif nargin==3 && size(varargin{1},2)==6
                obj.setSat(varargin{1},varargin{2},varargin{3}); % call rtklib.satpos
            elseif nargin==4 && isa(varargin{1}, 'gt.Gobs')
                obj.setSatObs(varargin{1},varargin{2},varargin{3},varargin{4}); % call rtklib.satposs
            elseif nargin==4 && isa(varargin{1}, 'gt.Gtime')
                obj.setSat(varargin{1},varargin{2},varargin{3},varargin{4}); % call rtklib.satpos
            else
                error('Wrong input arguments');
            end
        end
        %% setSatObs
        function setSatObs(obj, gobs, gnav, ephopt, clk)
            % setSatObs: Set satellite data at observation time
            % -------------------------------------------------------------
            % Compute satellite position/velocity and satellite clock at
            % observation time. Includes correction of signal propagation
            % time from L1 pseudorange.
            %
            % Call rtklib.satposs to compute satellite data.
            %
            % Usage: ------------------------------------------------------
            %   obj.setSatObs(gobs, gnav, ephopt)
            %
            % Input: ------------------------------------------------------
            %   gobs : 1x1, gt.Gobs, GNSS observation object
            %   gnav : 1x1, gt.Gnav, GNSS navigation data object
            %   ephopt : 1×1 : Ephemeris option to compute satellite position
            %                (optional) Default: ephopt = gt.C.EPHOPT_BRDC
            %
            arguments
                obj gt.Gsat
                gobs gt.Gobs
                gnav gt.Gnav
                ephopt (1,1) = gt.C.EPHOPT_BRDC
                clk (:,1) = zeros(gobs.n, 1)
            end
            if isenum(ephopt)
                ephopt = double(ephopt);
            end
            obsstr = gobs.struct;
            for f = obj.FTYPE
                if isfield(obsstr,f)
                    obsstr.(f).P = obsstr.(f).P-clk;
                end
            end
            [obj.x,obj.y,obj.z,obj.vx,obj.vy,obj.vz,obj.dts,obj.ddts,obj.var,obj.svh] ...
                = rtklib.satposs(obsstr, gnav.struct, ephopt);
            
            % mask unhealthy satellite
            idx = obj.svh~=0;
            idx(:,gobs.sys==gt.C.SYS_QZS) = false; % ToDo: Fix QZSS health
            obj.x(idx) = NaN;
            obj.y(idx) = NaN;
            obj.z(idx) = NaN;
            obj.vx(idx) = NaN;
            obj.vy(idx) = NaN;
            obj.vz(idx) = NaN;
            obj.dts(idx) = NaN;
            obj.ddts(idx) = NaN;
            obj.var(idx) = NaN;

            obj.n = gobs.n;
            obj.nsat = gobs.nsat;
            obj.sat = gobs.sat;
            obj.prn = gobs.prn;
            obj.sys = gobs.sys;
            obj.satstr = gobs.satstr;
            obj.time = gobs.time;
            obj.obs = gobs;
            obj.nav = gnav;
        end
        %% setSat
        function setSat(obj, gtime, sat, gnav, ephopt)
            % setSat: Set satellite data at input time
            % -------------------------------------------------------------
            % Compute satellite position/velocity and satellite clock at
            % input time.
            %
            % Call rtklib.satpos to compute satellite data.
            %
            % Usage: ------------------------------------------------------
            %   obj.setSat(gtime, sat, gnav, ephopt)
            %
            % Input: ------------------------------------------------------
            %   gtime: 1x1, gt.Gtime, Time to compute satellite data
            %   sat  : 1xN, Satellite number (Compliant RTKLIB)
            %   gnav : 1x1, gt.Gnav, GNSS navigation data object
            %   ephopt : 1×1 : Ephemeris option to compute satellite position
            %                  (optional) Default: ephopt = gt.C.EPHOPT_BRDC
            %
            arguments
                obj gt.Gsat
                gtime gt.Gtime
                sat (1,:) {mustBeInteger, mustBeVector}
                gnav gt.Gnav
                ephopt (1,1) = gt.C.EPHOPT_BRDC
            end
            if isenum(ephopt)
                ephopt = double(ephopt);
            end
            [obj.x,obj.y,obj.z,obj.vx,obj.vy,obj.vz,obj.dts,obj.ddts,obj.var,obj.svh] ...
                = rtklib.satpos(gtime.ep, sat, gnav.struct, ephopt);
            obj.n = gtime.n;
            obj.nsat = length(sat);
            obj.sat = sat;
            [sys_, obj.prn] = rtklib.satsys(obj.sat);
            obj.sys = gt.C.SYS(sys_);
            obj.satstr = rtklib.satno2id(obj.sat);
            obj.time = gtime;
            obj.nav = gnav;
        end
        %% setRcvPos
        function setRcvPos(obj, gpos)
            % setRcvPos: Set receiver position and compute satellite data
            % -------------------------------------------------------------
            % Compute line-of-sight vector, geometric distance, ionospheric
            % and tropospheric delays, satellite elevation and azimuth angles.
            %
            % Usage: ------------------------------------------------------
            %   obj.setRcvPos(gpos)
            %
            % Input: ------------------------------------------------------
            %   gpos : 1x1, gt.Gpos, Receiver position
            %
            arguments
                obj gt.Gsat
                gpos gt.Gpos
            end
            if gpos.n ~= obj.n && gpos.n ~= 1
                error('The size of gpos is equal to the size of obj.n or 1');
            end
            obj.pos = gpos;

            % ex,ey,ez,rng,az,el
            [obj.rng, obj.ex, obj.ey, obj.ez] ...
                = rtklib.geodist(obj.x, obj.y, obj.z, gpos.xyz);
            [obj.az, obj.el] = rtklib.satazel(gpos.llh, obj.ex, obj.ey, obj.ez);

            % trop,iono
            obj.trp = rtklib.tropmodel(obj.obs.time.ep,gpos.llh,obj.az,obj.el);
            if ~isfield(obj.obs.L1,"freq")
                obj.obs.setFrequencyFromNav(obj.nav);
            end
            for f = obj.FTYPE
                if ~isempty(obj.obs.(f))
                    obj.("ion"+f) = rtklib.ionmodel(obj.obs.time.ep,obj.nav.ion.gps,gpos.llh,obj.az,obj.el,obj.obs.(f).freq);
                end
            end
        end
        %% setRcvVel
        function setRcvVel(obj, gvel)
            % setRcvVel: Set receiver velocity and compute satellite data
            % -------------------------------------------------------------
            % Compute range rate between satellite and receiver.
            %
            % Usage: ------------------------------------------------------
            %   obj.setRcvVel(gvel)
            %
            % Input: ------------------------------------------------------
            %   gvel : 1x1, gt.Gvel, Receiver velocity
            %
            arguments
                obj gt.Gsat
                gvel gt.Gvel
            end
            if gvel.n ~= obj.n && gvel.n ~= 1
                error('The size of gvel is equal to the size of obj.n or 1');
            end
            if isempty(obj.pos)
                error('setRcvPos must be called first');
            end
            obj.vel = gvel;

            % range rate
            vsrx = obj.vx-obj.vel.xyz(:,1);
            vsry = obj.vy-obj.vel.xyz(:,2);
            vsrz = obj.vz-obj.vel.xyz(:,3);

            % relative velocity + sagnac effect
            obj.rate = vsrx.*obj.ex+vsry.*obj.ey+vsrz.*obj.ez+...
                gt.C.OMGE/gt.C.CLIGHT*(obj.vy.*obj.pos.xyz(:,1)+obj.y.*gvel.xyz(:,1)-obj.vx.*obj.pos.xyz(:,2)-obj.x.*gvel.xyz(:,2));
        end
        %% setRcvPosVel
        function setRcvPosVel(obj, gpos, gvel)
            % setRcvPosVel: Set receiver position/velocity and compute satellite data
            % -------------------------------------------------------------
            % Call setRcvPos() and setRcvVel() simultaneously.
            %
            % Usage: ------------------------------------------------------
            %   obj.setRcvPosVel(gpos, gvel)
            %
            % Input: ------------------------------------------------------
            %   gpos : 1x1, gt.Gpos, Receiver position
            %   gvel : 1x1, gt.Gvel, Receiver velocity
            %
            arguments
                obj gt.Gsat
                gpos gt.Gpos
                gvel gt.Gvel
            end
            obj.setRcvPos(gpos);
            obj.setRcvVel(gvel);
        end
        %% copy
        function gsat = copy(obj)
            % copy: Copy object
            % -------------------------------------------------------------
            % MATLAB handle class is used, so if you want to create a
            % different instance, you need to use the copy method.
            %
            % Usage: ------------------------------------------------------
            %   gtime = obj.copy()
            %
            % Output: -----------------------------------------------------
            %   gsat : 1x1, Copied gt.Gsat object
            %
            arguments
                obj gt.Gsat
            end
            gsat = obj.select(1:obj.n,1:obj.nsat);
        end
        %% select
        function gsat = select(obj, tidx, sidx)
            % select: Select satellite data from time/satellite index
            % -------------------------------------------------------------
            % Select satellite data from time/satellite index and return a
            % new object. The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   obj.select(tidx, sidx)
            %
            % Input: ------------------------------------------------------
            %   tidx : Logical or numeric index to select time
            %   sidx : Logical or numeric index to select satellite
            %
            % Output: -----------------------------------------------------
            %   gsat : 1x1, Selected gt.Gsat object
            %
            arguments
                obj gt.Gsat
                tidx {mustBeInteger, mustBeVector}
                sidx {mustBeInteger, mustBeVector}
            end
            if ~any(tidx)
                error('Selected time index is empty');
            end
            if ~any(sidx)
                error('Selected satellite index is empty');
            end
            gsat = gt.Gsat();
            gsat.time = obj.time.select(tidx);
            gsat.n = gsat.time.n;
            gsat.sat = obj.sat(sidx);
            gsat.prn = obj.prn(sidx);
            gsat.sys = obj.sys(sidx);
            gsat.satstr = obj.satstr(sidx);
            gsat.nsat = length(obj.sat);

            gsat.x = obj.x(tidx, sidx);
            gsat.y = obj.y(tidx, sidx);
            gsat.z = obj.z(tidx, sidx);
            gsat.vx = obj.vx(tidx, sidx);
            gsat.vy = obj.vy(tidx, sidx);
            gsat.vz = obj.vz(tidx, sidx);
            gsat.dts = obj.dts(tidx, sidx);
            gsat.ddts = obj.ddts(tidx, sidx);
            gsat.var = obj.var(tidx, sidx);
            gsat.svh = obj.svh(tidx, sidx);
            % receiver position
            if ~isempty(obj.pos)
                gsat.pos = obj.pos;
                gsat.rng = obj.rng(tidx, sidx);
                gsat.ex = obj.ex(tidx, sidx);
                gsat.ey = obj.ey(tidx, sidx);
                gsat.ez = obj.ez(tidx, sidx);
                gsat.az = obj.az(tidx, sidx);
                gsat.el = obj.el(tidx, sidx);
            end
            % receiver velocity
            if ~isempty(obj.vel)
                gsat.vel = obj.vel;
                gsat.rate = obj.rate(tidx, sidx);
            end
            if ~isempty(obj.obs)
                gsat.obs = obj.obs.select(tidx, sidx);
            end
            if ~isempty(obj.nav)
                gsat.nav = obj.nav;
            end
        end
        %% selectSat
        function gsat = selectSat(obj, sidx)
            % selectSat: Select satellite data from satellite index
            % -------------------------------------------------------------
            % Select satellite data from satellite index and return a
            % new object. The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   obj.selectSat(sidx)
            %
            % Input: ------------------------------------------------------
            %   sidx : Logical or numeric index to select satellite
            %
            % Output: -----------------------------------------------------
            %   gsat : 1x1, Selected gt.Gsat object
            %
            arguments
                obj gt.Gsat
                sidx {mustBeInteger, mustBeVector}
            end
            gsat = obj.select(1:obj.n, sidx);
        end
        %% selectTime
        function gsat = selectTime(obj, tidx)
            % selectTime: Select satellite data from time index
            % -------------------------------------------------------------
            % Select satellite data from time index and return a
            % new object. The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %    obj.selectTime(tidx)
            %
            % Input: ------------------------------------------------------
            %   tidx : Logical or numeric index to select time
            %
            % Output: -----------------------------------------------------
            %   gsat : 1x1, Selected gt.Gsat object
            %
            arguments
                obj gt.Gsat
                tidx {mustBeInteger, mustBeVector}
            end
            gsat = obj.select(tidx, 1:obj.nsat);
        end
        %% selectTimeSpan
        function gsat = selectTimeSpan(obj, ts, te)
            % selectTimeSpan: Select satellite data from time span
            % -------------------------------------------------------------
            % Select satellite data from the time span and return a new object.
            % The time span is start and end time represented by gt.Gtime.
            %
            % Usage: ------------------------------------------------------
            %    obj.selectTimeSpan(ts, te)
            %
            % Input: ------------------------------------------------------
            %   ts : 1x1, gt.Gtime, Start time
            %   te : 1x1, gt.Gtime, End time
            %
            % Output: -----------------------------------------------------
            %   gsat : 1x1, Selected gt.Gsat object
            %
            arguments
                obj gt.Gsat
                ts gt.Gtime
                te gt.Gtime
            end
            dt = obj.time.estInterval();
            tr = obj.roundDateTime(obj.time.t, dt);
            tsr = obj.roundDateTime(ts.t, dt);
            ter = obj.roundDateTime(te.t, dt);
            tidx = tr>=tsr & tr<=ter;
            gsat = obj.selectTime(tidx);
        end
        %% referenceSat
        function [refidx,Dinv] = referenceSat(obj, tidx)
            % referenceSat: Compute reference satellite
            % -------------------------------------------------------------
            % Compute reference satellites for double difference.
            %
            % Computation of the satellite with the highest elevation angle
            % for each satellite system.
            %
            % Usage: ------------------------------------------------------
            %   obj.referenceSat([tidx])
            % Input: ------------------------------------------------------
            %  [tidx]: Logical or numeric to select time (optional)
            %          Default: tidx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   refidx : 1x(obj.nsat), Reference satellite index
            %   Dinv : (obj.nsat)x(obj.nsat), Double-difference to
            %           single-difference conversion matrix
            %
            arguments
                obj gt.Gsat
                tidx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.pos)
                error('Call obj.setRcvPos(gpos) first to set the receiver position');
            end
            nsys_prev = 0;
            Dinv = [];
            g = findgroups(obj.sys);
            for gu=unique(g)
                nsys = nnz(g==gu);
                elref = mean(obj.el(tidx,:),1,"omitmissing");
                elref(g~=gu) = 0;
                if any(elref)
                    [~, satidx] = max(elref);
                    Dgu = eye(nsys);
                    Dgu(:,satidx-nsys_prev) = -1;
                    Dgu(satidx-nsys_prev,:) = -1;
                    Dinv = blkdiag(Dinv,inv(Dgu));
                    refsatidx(gu) = satidx;
                else
                    refsatidx(gu) = nsys_prev+1;
                    Dinv = blkdiag(Dinv,eye(nsys));
                end
                nsys_prev = nsys_prev+nsys;
            end
            refidx = refsatidx(g);
        end
        %% plotSky (using navigation toolbox)
        % function plotSky(obj)
        %     if isempty(obj.pos)
        %         error('Call obj.setRcvPos(gpos) first to set the receiver position');
        %     end
        %
        %     uniquesys = unique(obj.sys);
        %     col = gt.C.C_SYS(uniquesys,:);
        %     satsys = categorical(obj.sys);
        %     fig = figure;
        %     sp = skyplot(obj.az(idx,:),obj.el(idx,:),obj.satstr,'GroupData',satsys);
        %     set(gca,'ColorOrder',col)
        %     set(gca,'LabelFontSize',10)
        %     legend(string(gt.C.SYSNAME(uniquesys)),'Location','WestOutside','FontSize',10);
        %
        %     txt = uicontrol(fig,'Style','text','Position',[40 40 100 40]);
        %     txt.String = string(obj.time.t(obj.n),'yyyy-MM-dd HH:mm:ss.S');
        %
        %     sld = uicontrol(fig,'Style','slider','Position',[40 80 100 20]);
        %     sld.Callback = @(src,event)obj.update_azel(sld,txt,sp);
        %     sld.Value = obj.n;
        %     sld.Min = 1;
        %     sld.Max = obj.n;
        %     sld.SliderStep = [1 10]/obj.n;
        % end
        %% plotSky
        function plotSky(obj, tidx, sidx)
            % plotSky: Plot satellite constellation
            % -------------------------------------------------------------
            % Display satellite constellation.
            % The receiver position must be set by calling setRcvPos first.
            %
            % Usage: ------------------------------------------------------
            %   obj.plotSky(tidx, sidx)
            %
            % Input: ------------------------------------------------------
            %  [tidx]: Logical or numeric to select time (optional)
            %          Default: tidx = 1:obj.n
            %  [sidx]: Logical or numeric index to select satellite (optional)
            %          Default: sidx = 1:obj.nsat
            %
            arguments
                obj gt.Gsat
                tidx {mustBeInteger, mustBeVector} = 1:obj.n
                sidx {mustBeInteger, mustBeVector} = 1:obj.nsat
            end
            if isempty(obj.pos)
                error('Call obj.setRcvPos(gpos) first to set the receiver position');
            end
            gsat = obj.select(tidx, sidx);

            uniquesys = unique(gsat.sys);
            col = gt.C.C_SYS(uniquesys,:);

            tippp = [dataTipTextRow('Satellite','');
                dataTipTextRow('Azimuth','ThetaData');
                dataTipTextRow('Elevation','RData')];
            tipps = [dataTipTextRow('Satellite','ColorVariable');
                dataTipTextRow('Azimuth','ThetaData');
                dataTipTextRow('Elevation','RData')];

            fig = figure;
            for i=1:length(uniquesys)
                isat = gsat.sys==uniquesys(i);
                az_ = gsat.az(:,isat)/180*pi;
                el_ = gsat.el(:,isat);
                satstr_ = gsat.satstr(isat);
                if gsat.n > 1
                    pp = polarplot(az_,el_,'Color',col(i,:),'linewidth',1);
                else
                    pp = polarplot(az_,el_,'.','Color',col(i,:),'MarkerSize',0.1);
                end
                hold on;
                for j=1:length(pp)
                    pp(j).DataTipTemplate.DataTipRows = tippp;
                    pp(j).DataTipTemplate.DataTipRows(1).Label = satstr_{j};
                end
                ps(i) = polarscatter(az_(1,:),el_(1,:),'filled','SizeData',150,'MarkerEdgeColor',col(i,:),'MarkerFaceColor',col(i,:),'MarkerFaceAlpha',0.5);
                ps(i).ColorVariable = satstr_;
                ps(i).DataTipTemplate.DataTipRows = tipps;
                tx{i} = text(az_(1,:),el_(1,:)-10,satstr_,'Color',col(i,:),'FontSize',10,'HorizontalAlignment','center');
            end
            ax = gca;
            ax.RLim = [0 90];
            ax.RDir = 'reverse';
            ax.ThetaDir = 'clockwise';
            ax.ThetaZeroLocation = 'top';
            ax.RAxisLocation = 270;
            ax.ThetaTickLabel(1) = {'N'};
            ax.ThetaTickLabel(4) = {'E'};
            ax.ThetaTickLabel(7) = {'S'};
            ax.ThetaTickLabel(10) = {'W'};
            ax.RTickLabel = {'0°','20°','40°','60°','80°'};
            legend(ps, string(gt.C.SYSNAME(double(uniquesys))),'Location','WestOutside','FontSize',10);

            % text and slidar control
            if gsat.n > 1
                txt = uicontrol(fig,'Style','text','Position',[40 40 100 40]);
                txt.String = string(gsat.time.t(1),'yyyy-MM-dd HH:mm:ss.S');
                sld = uicontrol(fig,'Style','slider','Position',[40 80 100 20]);
                sld.Callback = @(src,event)gsat.update_azel(sld,txt,ps,uniquesys);
                sld.Value = 1;
                sld.Min = 1;
                sld.Max = gsat.n;
                sld.SliderStep = [1 10]/gsat.n;
            end
        end
        %% help
        function help(~)
            % help: Show help
            doc gt.Gsat
        end
    end
    %% Private functions
    methods(Access=private)
        %% Update azimuth and elevation for skyplot (using navigation toolbox)
        % function update_azel(obj, sld, txt, sp)
        %     idx = uint32(sld.Value);
        %     set(sp,AzimuthData=obj.az(1:idx,:), ElevationData=obj.el(1:idx,:));
        %     txt.String = string(obj.time.t(idx),'yyyy-MM-dd HH:mm:ss.S');
        % end
        %% Update azimuth and elevation for skyplot
        function update_azel(obj, sld, txt, ps, uniquesys)
            idx = uint32(sld.Value);
            txt.String = string(obj.time.t(idx),'yyyy-MM-dd HH:mm:ss.S');
            for i=1:length(ps)
                isat = obj.sys==uniquesys(i);
                az_ = obj.az(:,isat)/180*pi;
                el_ = obj.el(:,isat);
                ps(i).ThetaData = az_(idx,:);
                ps(i).RData = el_(idx,:);
            end
        end
        %% Round datetime
        function tr = roundDateTime(~, t, dt)
            pt = posixtime(t);
            pt = round(pt/dt)*dt;
            tr = datetime(pt, "ConvertFrom", "posixtime", "TimeZone", "UTC");
        end
    end
end