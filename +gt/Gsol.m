classdef Gsol < handle
    % Gsol: GNSS solution class
    % ---------------------------------------------------------------------
    % Gsol Declaration:
    % gsol = Gsol();  Create empty gt.Gsol object
    %
    % gsol = Gsol(file);  Create gt.Gsol object from RTKLIB solution file
    %   file   : 1x1, RTKLIB solution file (???.pos)
    %
    % gsol = Gsol(solstr);  Create gt.Gsol object from solution struct
    %   sol    : 1x1, RTKLIB solution struct
    %
    % gsol = Gsol(time, pos, [stat]);  Create gt.Gsol object from time and position
    %   time   : 1x1, Time, gt.Gtime object
    %   pos    : 1x1, Position, gt.Gpos object
    %  [stat]  : 1x1, Solution status (optional)
    % ---------------------------------------------------------------------
    % Gsol Properties:
    %   n      : 1x1, Number of epochs
    %   time   : 1x1, Time, gt.Gtime object
    %   pos    : 1x1, Position, gt.Gpos object
    %   vel    : 1x1, Velocity, gt.Gvel object
    %   pcov   : 1x1, Position covariance, gt.Gcov object
    %   vcov   : 1x1, Velocity covariance, gt.Gcov object
    %   dtr    : (obj.n)x6, Receiver clock bias to time systems (s)
    %   ns     : (obj.n)x1, Number of valid satellites
    %   stat   : (obj.n)x1, Solution status (SOLQ_???)
    %   age    : (obj.n)x1, Age of differential (s)
    %   ratio  : (obj.n)x1, AR ratio factor for validation
    %   dt     : 1x1, Solution time interval (s)
    % ---------------------------------------------------------------------
    % Gsol Methods:
    %   setSolFile(file);              Set solution from file
    %   setSolStruct(solstr);          Set solution from solution struct
    %   setSolTimePos(gtime, gpos, [stat]); Set solution from gt.Gtime and gt.Gpos objects
    %   setOrg(pos, type);             Set coordinate origin
    %   setOrgGpos(gpos);              Set coordinate origin by gt.Gpos
    %   outSol(file, [gopt]);          Output solution file
    %   insert(idx, gsol);             Insert gt.Gsol object
    %   append(gsol);                  Append gt.Gsol object
    %   [perr, verr] = difference(gobj); Compute position/velocity errors
    %   gsol = copy();                 Copy object
    %   gsol = select(idx);            Select solution from index
    %   gsol = selectTimeSpan(ts, te); Select solution from time span
    %   sol = struct([idx]);           Convert from gt.Gsol object to solution struct
    %   gsol = fixedInterval([dt]);    Resampling solution at fixed interval
    %   [gsol, gsolref] = commoSol(gsolref);   Extract common time with reference solution
    %   gsol = obj.sameSol(gsolref);           Same time as reference solution
    %   gsol = obj.sameTime(gtimeref);         Same time as reference time
    %   gsol = interp(gtime, [method]);        Interpolating solution at gtime
    %   [gpos, gcov] = mean([stat],[idx]);     Compute the position and covariance
    %   [mllh, sdenu] = meanLLH([stat],[idx]); Compute mean geodetic position and standard deviation
    %   [mxyz, sdxyz] = meanXYZ([stat],[idx]); Compute mean ECEF position and standard deviation
    %   [menu, sdenu] = meanENU([stat],[idx]); Compute mean ENU position and standard deviation
    %   nstat = statCount([stat]);  Count solution status
    %   rstat = statRate([stat]);   Compute solution status rate
    %   str = fixRateStr();         Ambiguity fixed rate string
    %   showFixRate();              Show ambiguity fixed rate
    %   outKML(file, [open], [lw], [lc], [ps], [pc], [idx], [alt]); Output Google Earth KML file
    %   plot([stat],[idx]);            Plot solution position
    %   plotAll([stat],[idx]);         Plot all solution
    %   plotMap([stat],[idx]);         Plot solution to map
    %   plotSatMap([stat],[idx]);      Plot solution to satellite map
    %   help();                        Show help
    % ---------------------------------------------------------------------
    % Gsol Overloads:
    %   [perr, verr] =  obj - gobj;    Compute position/velocity errors
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki
    %
    properties
        n     % Number of epochs
        time  % Time, gt.Gtime object
        pos   % Position, gt.Gpos object
        vel   % Velocity, gt.Gvel object
        pcov  % Position covariance, gt.Gcov object
        vcov  % Velocity covariance, gt.Gcov object
        dtr   % Receiver clock bias to time systems (s)
        ns    % Number of valid satellites
        stat  % Solution status (SOLQ_???)
        age   % Age of differential (s)
        ratio % AR ratio factor for valiation
        thres % threshold
        dt    % Solution time interval (s)
    end
    methods
        %% constructor
        function obj = Gsol(varargin)
            if nargin==0 % generate empty object
                obj.n = 0;
            elseif nargin==1 && (ischar(varargin{1}) || isStringScalar(varargin{1}))
                obj.setSolFile(char(varargin{1})); % file
            elseif nargin==1 && isstruct(varargin{1})
                obj.setSolStruct(varargin{1}); % sol struct
            elseif nargin==2
                obj.setSolTimePos(varargin{1}, varargin{2});
            elseif nargin==3
                obj.setSolTimePos(varargin{1}, varargin{2}, varargin{3});
            else
                error('Wrong input arguments');
            end
        end
        %% setSolFile
        function setSolFile(obj, file)
            % setSolFile: Set solution from file
            % -------------------------------------------------------------
            % Read the .pos file of RTKLIB.
            %
            % Usage: ------------------------------------------------------
            %   obj.setSolFile(file)
            %
            % Input: ------------------------------------------------------
            %   file  : RTKLIB solution file (???.pos)
            %
            arguments
                obj gt.Gsol
                file (1,:) char
            end
            [sol, sol.rb] = rtklib.readsol(obj.absPath(file));

            % reference position
            if all(sol.rb == [0,0,0])
                sol.rb = [];
            end
            obj.setSolStruct(sol);
        end
        %% setSolStruct
        function setSolStruct(obj, solstr)
            % setSolStruct: Set solution from solution struct
            % -------------------------------------------------------------
            % Set objects from RTKLIB's solution structure.
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
        %% setSolTimePos
        function setSolTimePos(obj, gtime, gpos, stat)
            % setSolTimePos: Set solution from gt.Gtime and gt.Gpos objects
            % -------------------------------------------------------------
            % gtime and gpos must be the same size.
            %
            % Usage: ------------------------------------------------------
            %   obj.setSolTimePos(time, pos, [stat])
            %
            % Input: ------------------------------------------------------
            %   gtime : Time, gt.Gtime object
            %   gpos  : Position, gt.Gpos object
            %   stat  : Solution status (optional) Default: gt.C.SOLQ_FIX
            %
            arguments
                obj gt.Gsol
                gtime gt.Gtime
                gpos gt.Gpos
                stat = gt.C.SOLQ_FIX
            end
            if gtime.n ~= gpos.n
                error('Time and pos must be same size');
            end
            if isempty(gpos.xyz)
                error('pos.xyz must be set to a value');
            end
            if isscalar(stat)
                stat = stat*ones(gtime.n,1);
            end
            solstr.n = gtime.n;
            solstr.rb = gpos.orgxyz;
            solstr.ep = gtime.ep;
            solstr.rr = [gpos.xyz zeros(solstr.n,3)];
            solstr.qr = zeros(solstr.n,6);
            solstr.qv = zeros(solstr.n,6);
            solstr.dtr = zeros(solstr.n,6);
            solstr.type = zeros(solstr.n,1);
            solstr.stat = stat;
            solstr.ns = ones(solstr.n,1);
            solstr.age = zeros(solstr.n,1);
            solstr.ratio = zeros(solstr.n,1);
            solstr.thres = zeros(solstr.n,1);

            obj.setSolStruct(solstr);
        end
        %% setOrg
        function setOrg(obj, org, orgtype)
            % setOrg: Set coordinate orgin
            % -------------------------------------------------------------
            % Geodetic and ECEF position can be set as the origin.
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
        %% setOrgGpos
        function setOrgGpos(obj, gpos)
            % setOrgGpos: Set coordinate origin by gt.Gpos
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setOrgGpos(gpos)
            %
            % Input: ------------------------------------------------------
            %   gpos : 1x1, gt.Gpos, Coordinate origin position
            %
            arguments
                obj gt.Gsol
                gpos gt.Gpos
            end
            if isempty(gpos.llh)
                error("gpos.llh is empty");
            end
            obj.setOrg(gpos.llh(1,:),"llh");
        end
        %% outSol
        function outSol(obj, file, gopt)
            % outSol: Output solution file
            % -------------------------------------------------------------
            % Output RTKLIB solution file (???.pos).
            %
            % If an process option structure is input, output RTKLIB process
            % options in the solution file header.
            %
            % Usage: ------------------------------------------------------
            %   obj.outSol(file, [gopt])
            %
            % Input: ------------------------------------------------------
            %   file : Output solution file name (???.pos)
            %  [gopt] : RTKLIB process option object (optional)
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
                rtklib.outsol(obj.absPath(file), solstr, gopt.struct);
            else
                rtklib.outsol(obj.absPath(file), solstr);
            end
        end
        %% insert
        function insert(obj, idx, gsol)
            % insert: Insert gt.Gsol object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.insert(idx, gsol)
            %
            % Input: ------------------------------------------------------
            %   idx : 1x1, Integer index to insert data
            %   gsol: 1x1, gt.Gsol object
            %
            arguments
                obj gt.Gsol
                idx (1,1) {mustBeInteger}
                gsol gt.Gsol
            end
            if idx<=0 || idx>obj.n
                error('Index is out of range');
            end
            solstr1 = obj.struct();
            solstr2 = gsol.struct();
            solstr.n = solstr1.n+solstr2.n;
            solstr.rb = obj.insertdata(solstr1.rb, idx, solstr2.rb);
            solstr.ep = obj.insertdata(solstr1.ep, idx, solstr2.ep);
            solstr.rr = obj.insertdata(solstr1.xyz, idx, solstr2.xyz);
            solstr.qr = obj.insertdata(solstr1.qr, idx, solstr2.qr);
            solstr.qv = obj.insertdata(solstr1.qv, idx, solstr2.qv);
            solstr.dtr = obj.insertdata(solstr1.dtr, idx, solstr2.dtr);
            solstr.type = obj.insertdata(solstr1.type, idx, solstr2.type);
            solstr.stat = obj.insertdata(solstr1.stat, idx, solstr2.stat);
            solstr.ns = obj.insertdata(solstr1.ns, idx, solstr2.ns);
            solstr.age = obj.insertdata(solstr1.age, idx, solstr2.age);
            solstr.ratio = obj.insertdata(solstr1.ratio, idx, solstr2.ratio);
            solstr.thres = obj.insertdata(solstr1.thres, idx, solstr2.thres);

            obj.setSolStruct(solstr);
        end
        %% append
        function append(obj, gsol)
            % append: Append gt.Gsol object
            % -------------------------------------------------------------
            % Add gt.Gsol object.
            % obj.n will be obj.n+gsol.n
            %
            % Usage: ------------------------------------------------------
            %   obj.append(gsol)
            %
            % Input: ------------------------------------------------------
            %   gsol : 1x1, gt.Gsol object
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
        function [perr, verr] = difference(obj, gobj)
            % difference: Compute position/velocity errors
            % -------------------------------------------------------------
            % Compute the difference between two gt.Gsol objects and
            % compute the position and velocity error.
            %
            % The size of the input must be the same as the size of this
            % object.
            %
            % Usage: ------------------------------------------------------
            %   [perr, verr] = obj.difference(gobj)
            %
            % Input: ------------------------------------------------------
            %   gobj : gt.Gsol or gt.Gpos or gt.Gvel object
            %
            % Output: -----------------------------------------------------
            %   perr : 1x1, Position error, gt.Gerr object
            %   verr : 1x1, Velocity error, gt.Gerr object
            %
            arguments
                obj gt.Gsol
                gobj
            end
            verr = gt.Gerr();
            switch class(gobj)
                case 'gt.Gpos'
                    perr = obj.pos-gobj;
                case 'gt.Gvel'
                    if ~isempty(obj.vel)
                        verr = obj.vel-gobj;
                    end
                case 'gt.Gsol'
                    perr = obj.pos-gobj.pos;
                    if ~isempty(obj.vel) && ~isempty(gobj.vel)
                        verr = obj.vel-gobj.vel;
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
            % Output: -----------------------------------------------------
            %   gsol : 1x1, Copied gt.Gsol object
            %
            arguments
                obj gt.Gsol
            end
            gsol = obj.select(1:obj.n);
        end
        %% select
        function gsol = select(obj, idx)
            % select: Select solution from index
            % -------------------------------------------------------------
            % Select solution from index and return a new object.
            % The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   obj.select(idx)
            %
            % Input: ------------------------------------------------------
            %   idx  : Logical or numeric index to select
            %
            % Output: -----------------------------------------------------
            %   gsol : 1x1, Selected gt.Gsol object
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
        end
        %% selectTimeSpan
        function gsol = selectTimeSpan(obj, ts, te)
            % selectTimeSpan: Select solution from time span
            % -------------------------------------------------------------
            % Select solution from the time span and return a new object.
            % The time span is start and end time represented by gt.Gtime.
            %
            % Usage: ------------------------------------------------------
            %   obj.selectTimeSpan(ts, te)
            %
            % Input: ------------------------------------------------------
            %   ts  : Start time (gt.Gtime)
            %   te  : End time (gt.Gtime)
            %
            % Output: -----------------------------------------------------
            %   gsol : 1x1, Selected gt.Gsol object
            %
            arguments
                obj gt.Gsol
                ts gt.Gtime
                te gt.Gtime
            end
            tr = obj.roundDateTime(obj.time.t, obj.dt);
            tsr = obj.roundDateTime(ts.t, obj.dt);
            ter = obj.roundDateTime(te.t, obj.dt);

            idx = tr>=tsr & tr<=ter;
            gsol = obj.select(idx);
        end
        %% struct
        function solstr = struct(obj, idx)
            % solstr: Convert from gt.Gsol object to solution struct
            % -------------------------------------------------------------
            % The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   obj.struct([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
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
        %% fixedInterval
        function gsol = fixedInterval(obj, dt)
            % fixedInterval: Resampling solution at fixed interval
            % -------------------------------------------------------------
            % The time interval of the solution will be constant at the
            % specified second.
            %
            % If the time interval of the original solution is not constant,
            % NaN is inserted into the solution at that time.
            %
            % Usage: ------------------------------------------------------
            %   obj.fixedInterval([dt])
            %
            % Input: ------------------------------------------------------
            %  [dt]  : 1x1, double, Time interval for resampling (s)
            %        (optional) Default: dt = obj.dt
            %
            % Output: -----------------------------------------------------
            %   gsol : 1x1, Resampled gt.Gsol object
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

            tr = obj.roundDateTime(obj.time.t,obj.dt);
            tfixr = obj.roundDateTime((tr(1):seconds(dt):tr(end))',dt);
            nfix = length(tfixr);
            tfix = NaT(nfix,1,"TimeZone","UTC");
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
        %% commonSol
        function [gsolc, gsolrefc] = commonSol(obj, gsolref)
            % common: Extract common time with reference solution
            % -------------------------------------------------------------
            % Extract the common time between the reference gt.Gsol object
            % and the current object.
            %
            % Output new gt.Gsol object and reference gt.Gsol object.
            %
            % gsolc.time = gsolrefc.time
            %
            % Usage: ------------------------------------------------------
            %   obj.common(gsolref)
            %
            % Input: ------------------------------------------------------
            %   gsolref : 1x1, Reference gt.Gsol object
            %
            % Output: -----------------------------------------------------
            %   gsolc    : 1x1, New gt.Gsol object
            %   gsolrefc : 1x1, New reference gt.Gsol object
            %
            arguments
                obj gt.Gsol
                gsolref gt.Gsol
            end
            t = obj.roundDateTime(obj.time.t, obj.dt);
            tref = obj.roundDateTime(gsolref.time.t, gsolref.dt);
            [~,tind,tindref] = intersect(t, tref);
            gsolc = obj.select(tind);
            gsolrefc = gsolref.select(tindref);
        end
        %% sameSol
        function gsolref = sameSol(obj, gsolref)
            % same: Same time as reference solution
            % -------------------------------------------------------------
            % Create an gt.Gsol object whose time are consistent with
            % the reference gt.Gsol object.
            %
            % gsol.time = gsolref.time
            %
            % If the time of the reference solution is not in the current
            % solution, NaN is inserted into the solution.
            %
            % Usage: ------------------------------------------------------
            %   gsol = obj.sameSol(gsolref)
            %
            % Input: ------------------------------------------------------
            %   gsolref : 1x1, Reference gt.Gsol object
            %
            % Output: -----------------------------------------------------
            %   gsol : 1x1, New gt.Gsol object
            %
            arguments
                obj gt.Gsol
                gsolref gt.Gsol
            end
            if isempty(obj.pos.xyz)
                type = 1; % 0:xyz-ecef,1:enu-baseline
            else
                type = 0; % 0:xyz-ecef,1:enu-baseline
            end
            solstr_ = obj.struct;
            n_ = gsolref.n;
            solstr.n = n_;

            t = obj.roundDateTime(obj.time.t, obj.dt);
            tref = obj.roundDateTime(gsolref.time, gsolref.dt);

            [~,idx1,idx2] = intersect(tref,t);

            ep_ = gsolref.time.ep;
            ep_(idx1,:) = obj.time.ep(idx2,:);
            solstr.ep = ep_;

            solstr.rb = obj.pos.orgxyz;

            solstr.rr = NaN(n_,6);
            solstr.qr = NaN(n_,6);
            solstr.qv = NaN(n_,6);
            solstr.dtr = NaN(n_,6);
            solstr.type = type*ones(n_,1);
            solstr.stat = zeros(n_,1);
            solstr.ns = NaN(n_,1);
            solstr.age = NaN(n_,1);
            solstr.ratio = NaN(n_,1);
            solstr.thres = zeros(n_,1);

            solstr.rr(idx1,:) = solstr_.rr(idx2,:);
            solstr.qr(idx1,:) = solstr_.qr(idx2,:);
            solstr.qv(idx1,:) = solstr_.qv(idx2,:);
            solstr.dtr(idx1,:) = solstr_.dtr(idx2,:);
            solstr.type(idx1) = solstr_.type(idx2,:);
            solstr.stat(idx1) = solstr_.stat(idx2,:);
            solstr.ns(idx1) = solstr_.ns(idx2,:);
            solstr.age(idx1) = solstr_.age(idx2,:);
            solstr.ratio(idx1) = solstr_.ratio(idx2,:);
            solstr.thres(idx1) = solstr_.thres(idx2,:);

            gsolref = gt.Gsol(solstr);
        end
        %% sameTime
        function gsol = sameTime(obj, gtimeref)
            % same: Same time as reference time
            % -------------------------------------------------------------
            % Create an gt.Gsol object whose time are consistent with
            % the reference gt.Gtime object.
            %
            % gsol.time = gtimeref
            %
            % If the time of the reference time is not in the current
            % solution, NaN is inserted into the solution.
            %
            % Usage: ------------------------------------------------------
            %   gsol = obj.sameTime(gtimeref)
            %
            % Input: ------------------------------------------------------
            %   gtimeref : 1x1, Reference gt.Gtime object
            %
            % Output: -----------------------------------------------------
            %   gsol : 1x1, New gt.Gsol object
            %
            arguments
                obj gt.Gsol
                gtimeref gt.Gtime
            end
            if isempty(obj.pos.xyz)
                type = 1; % 0:xyz-ecef,1:enu-baseline
            else
                type = 0; % 0:xyz-ecef,1:enu-baseline
            end

            solstr_ = obj.struct;
            n_ = gtimeref.n;
            solstr.n = n_;

            t = obj.roundDateTime(obj.time.t, obj.dt);
            tref = obj.roundDateTime(gtimeref.t, gtimeref.estInterval());

            [~,idx1,idx2] = intersect(tref,t);

            ep_ = gtimeref.ep;
            ep_(idx1,:) = obj.time.ep(idx2,:);
            solstr.ep = ep_;

            solstr.rb = obj.pos.orgxyz;

            solstr.rr = NaN(n_,6);
            solstr.qr = NaN(n_,6);
            solstr.qv = NaN(n_,6);
            solstr.dtr = NaN(n_,6);
            solstr.type = type*ones(n_,1);
            solstr.stat = zeros(n_,1);
            solstr.ns = NaN(n_,1);
            solstr.age = NaN(n_,1);
            solstr.ratio = NaN(n_,1);
            solstr.thres = zeros(n_,1);

            solstr.rr(idx1,:) = solstr_.rr(idx2,:);
            solstr.qr(idx1,:) = solstr_.qr(idx2,:);
            solstr.qv(idx1,:) = solstr_.qv(idx2,:);
            solstr.dtr(idx1,:) = solstr_.dtr(idx2,:);
            solstr.type(idx1) = solstr_.type(idx2,:);
            solstr.stat(idx1) = solstr_.stat(idx2,:);
            solstr.ns(idx1) = solstr_.ns(idx2,:);
            solstr.age(idx1) = solstr_.age(idx2,:);
            solstr.ratio(idx1) = solstr_.ratio(idx2,:);
            solstr.thres(idx1) = solstr_.thres(idx2,:);

            gsol = gt.Gsol(solstr);
        end
        %% interp
        function gsol = interp(obj, gtime, method)
            % interp: Interpolating solution at gtime
            % -------------------------------------------------------------
            % Interpolate observation at the query point and return a
            % new object.
            %
            % Usage: ------------------------------------------------------
            %   gsol = obj.interp(gtime, [method])
            %
            % Input: ------------------------------------------------------
            %   gtime : Query points, gt.Gtime object
            %   method: Interpolation method (optional)
            %           Default: method = "linear"
            %
            % Output: -----------------------------------------------------
            %   gsol: 1x1, Interpolated gt.Gsol object
            %
            arguments
                obj gt.Gsol
                gtime gt.Gtime
                method (1,:) char {mustBeMember(method,{'linear','spline','makima'})} = 'linear'
            end
            if min(obj.time.t)>min(gtime.t) || max(obj.time.t)<max(gtime.t)
                error("Query point is out of range (extrapolation)")
            end
            gsol = gt.Gsol();
            gsol.n = gtime.n;
            gsol.time = obj.time.interp(obj.time.t, gtime.t, method);
            gsol.pos = obj.pos.interp(obj.time.t, gtime.t, method);
            if ~isempty(obj.vel); gsol.vel = obj.vel.interp(obj.time.t, gtime.t, method); end
            gsol.pcov = obj.pcov.interp(obj.time.t, gtime.t, method);
            if ~isempty(obj.vcov); gsol.vcov = obj.vcov.interp(obj.time.t, gtime.t, method); end
            gsol.dtr = interp1(obj.time.t, obj.dtr, gtime.t, method);
            gsol.ns = round(interp1(obj.time.t, obj.ns, gtime.t, method));
            gsol.stat = gt.C.SOLQ(round(interp1(obj.time.t, double(obj.stat), gtime.t, method)));
            gsol.age = interp1(obj.time.t, obj.age, gtime.t, method);
            gsol.ratio = interp1(obj.time.t, obj.ratio, gtime.t, method);
            gsol.thres = interp1(obj.time.t, obj.thres, gtime.t, method);
            gsol.dt = obj.time.estInterval();
        end
        %% mean
        function [gpos, gcov] = mean(obj, stat, idx)
            % mean: Compute mean position and covariance
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.mean([stat], [idx])
            %
            % Input: ------------------------------------------------------
            %  [stat]: Solution status to compute mean position (optional)
            %          0:ALL, SOLQ_XXX, Default: stat = 0
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   gpos : 1x1, gt.Gpos object with mean position
            %   gcov : 1x1, gt.Gcov object
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
        %% meanLLH
        function [mllh, sdenu] = meanLLH(obj, stat, idx)
            % meanLLH: Compute mean geodetic position and standard deviation
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.meanLLH([stat], [idx])
            %
            % Input: ------------------------------------------------------
            %  [stat]: Solution status to compute mean position (optional)
            %          0:ALL, SOLQ_XXX, Default: stat = 0
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   mllh  : 1x3, Mean geodetic position
            %   sdenu : 1x3, Standard deviation of ENU position
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
        %% meanXYZ
        function [mxyz, sdxyz] = meanXYZ(obj, stat, idx)
            % meanXYZ: Compute mean ECEF position and standard deviation
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.meanXYZ([stat], [idx])
            %
            % Input: ------------------------------------------------------
            %  [stat]: Solution status to compute mean position (optional)
            %          0:ALL, SOLQ_XXX, Default: stat = 0
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   mxyz  : 1x3, Mean ECEF position
            %   sdxyz : 1x3, Standard deviation of ECEF position
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
        %% meanENU
        function [menu, sdenu] = meanENU(obj, stat, idx)
            % meanENU: Compute mean ENU position and standard deviation
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.meanENU([stat], [idx])
            %
            % Input: ------------------------------------------------------
            %  [stat]: Solution status to compute mean position (optional)
            %          0:ALL, SOLQ_XXX, Default: stat = 0
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   menu  : 1x3, Mean ENU position
            %   sdenu : 1x3, Standard deviation of ENU position
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
        %% statCount
        function nstat = statCount(obj, stat)
            % statCount: Count solution status
            % -------------------------------------------------------------
            % The order of solution status (SOLQ_???) is as follows:
            % [FIX, FLOAT, SBAS, DGPS, SINGLE, PPP, DR]
            %
            % Usage: ------------------------------------------------------
            %   obj.statCount([stat])
            %
            % Input: ------------------------------------------------------
            %  [stat] : Solution status (optional)
            %           SOLQ_XXX, Default: All solution status
            %
            % Output: -----------------------------------------------------
            %   nstat : 1x7, Solution status count
            %
            arguments
                obj gt.Gsol
                stat (1,:) = 1:7
            end
            for i=1:length(stat)
                nstat(1,i) = nnz(obj.stat==double(stat(i)));
            end
        end
        %% statRate
        function rstat = statRate(obj, stat)
            % statRate: Compute solution status rate
            % -------------------------------------------------------------
            % The order of solution status (SOLQ_???) is as follows:
            % [FIX, FLOAT, SBAS, DGPS, SINGLE, PPP, DR]][
            %
            % Usage: ------------------------------------------------------
            %   obj.statRate([stat])
            %
            % Input: ------------------------------------------------------
            %  [stat] : Solution status (optional)
            %           SOLQ_XXX, Default: All solution status
            %
            % Output: -----------------------------------------------------
            %   rstat : 1x7, Solution status rate (%)
            %
            arguments
                obj gt.Gsol
                stat (1,:) = 1:7
            end
            nstat = obj.statCount(stat);
            rstat = 100*nstat/obj.n;
        end
        %% statRateStr
        function str = statRateStr(obj)
            % statRateStr: Solution status rate string
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   str = obj.statRateStr()
            %
            % Output: -----------------------------------------------------
            %   str : String, (Fix: %.1f% (%d/%d),...)
            %
            arguments
                obj gt.Gsol
            end
            name = string(gt.C.SOLQNAME(double(unique(obj.stat))));
            rate = obj.statRate(unique(obj.stat));
            count = obj.statCount(unique(obj.stat));
            str = "";
            for i=1:length(name)
                if i>=2
                    str = str+", ";
                end
                str = str+sprintf("%s:%.1f%% (%d/%d)",name(i),rate(i),count(i),obj.n);
            end
        end
        %% showStatRate
        function showStatRate(obj)
            % showStatRate: Show status rate
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.showStatRate()
            %
            arguments
                obj gt.Gsol
            end
            disp(obj.statRateStr);
        end
        %% fixRateStr
        function str = fixRateStr(obj)
            % fixRateStr: Ambiguity fixed rate string
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   str = obj.fixRateStr()
            %
            % Output: -----------------------------------------------------
            %   str : String, (Fixed rate: %.1f% (%d/%d))
            %
            arguments
                obj gt.Gsol
            end
            nfix = obj.statCount(gt.C.SOLQ_FIX);
            rfix = obj.statRate(gt.C.SOLQ_FIX);
            str = sprintf("Fixed rate: %.1f%% (%d/%d)",rfix,nfix,obj.n);
        end
        %% showFixRate
        function showFixRate(obj)
            % showFixRate: Show ambiguity fixed rate
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.showFixRate()
            %
            arguments
                obj gt.Gsol
            end
            disp(obj.fixRateStr);
        end
        %% outKML
        function outKML(obj, file, open, lw, lc, ps, pc, idx, alt)
            % outKML: Output Google Earth KML file
            % -------------------------------------------------------------
            % Output Google Earth KML file. If Google Earth is installed,
            % it will automatically open the KML file by default.
            %
            % Usage: ------------------------------------------------------
            %   obj.outKML(file, [open], [lw], [lc], [ps], [pc], [idx], [alt])
            %
            % Input: ------------------------------------------------------
            %   file:  Output KML file name (???.kml)
            %  [open]: 1x1, Open KML file (optional) (0:off,1:on)
            %          Default: off
            %  [lw]:   1x1, Line width (0: No line) (optional) Default: 1.0
            %  [lc]:   Line Color, MATLAB Style, e.g. "r" or [1 0 0]
            %          (optional) Default: "w"
            %  [ps]:   1x1, Point size (0: No point) (optional) Default: 0.5
            %  [pc]:   Point Color, MATLAB Style (0: Solution status)
            %          e.g. "r" or [1 0 0] (optional) Default: 0
            %  [idx]:  Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %  [alt]:  1x1, Output altitude (optional)
            %          (0:off,1:elipsoidal,2:geodetic) Default: off
            %
            arguments
                obj gt.Gsol
                file (1,:) char
                open (1,1) = 0
                lw (1,1) = 1.0
                lc = "w"
                ps (1,1) = 0.5
                pc = 0
                idx {mustBeInteger, mustBeVector} = 1:obj.n
                alt (1,1) = 0
            end
            if obj.n==0
                error('No data to output');
            end
            if isempty(obj.pos.llh)
                error('llh must be set to a value');
            end
            gsol = obj.select(idx);
            gsol = gsol.select(~isnan(gsol.pos.llh(:,1)));
            kmlstr = "";
            kmlstr = kmlstr+"<?xml version=\""1.0\"" encoding=\""UTF-8\""?>\n";
            kmlstr = kmlstr+"<kml xmlns=\""http://earth.google.com/kml/2.1\"">\n";
            kmlstr = kmlstr+"<Document>\n";

            if lw ~= 0
                kmlstr = kmlstr+gsol.kmltrack(lc, lw, alt);
            end
            if ps ~= 0
                kmlstr = kmlstr+gsol.kmlpoint(pc, ps, alt);
            end
            kmlstr = kmlstr+"</Document>\n";
            kmlstr = kmlstr+"</kml>\n";

            fid = fopen(file,"wt");
            fprintf(fid, kmlstr);
            fclose(fid);

            if open
                system(obj.absPath(file));
            end
        end
        %% plot
        function plot(obj, stat, idx)
            % plot: Plot solution position
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot([stat], [idx])
            %
            % Input: ------------------------------------------------------
            %  [stat]: Solution status to plot (optional)
            %          0:ALL, SOLQ_XXX, Default: stat = 0
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
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
                idxstat = 1:gsol.n;
            else
                idxstat = find(gsol.stat==stat);
            end
            figure;
            tiledlayout(3,1,'TileSpacing','Compact');
            nexttile(1, [2 1]);
            obj.plotSolStat(enu_(idxstat,1), enu_(idxstat,2), gsol.stat(idxstat), 1);
            xlabel('East (m)');
            ylabel('North (m)');
            grid on; axis equal;
            title(obj.statRateStr);
            nexttile;
            obj.plotSolStat(gsol.time.t(idxstat), enu_(idxstat,3), gsol.stat(idxstat), 0);
            xlim([gsol.time.t(idxstat(1)) gsol.time.t(idxstat(end))]);
            grid on;
            ylabel('Up (m)');
            drawnow
        end
        %% plotAll
        function plotAll(obj, idx)
            % plotAll: Plot all solution
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotAll([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
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
        %% plotMap
        function plotMap(obj, stat, idx)
            % plotMap: Plot solution to map
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotMap([stat], [idx])
            %
            % Input: ------------------------------------------------------
            %  [stat]: Solution status to plot (optional)
            %          0:ALL, SOLQ_XXX, Default: stat = 0
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gsol
                stat (1,1) {mustBeInteger} = 0
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.pos.llh)
                error('llh must be set to a value');
            end
            gsol = obj.select(idx);
            if stat==0
                idxstat = true(gsol.n,1);
            else
                idxstat = gsol.stat==stat;
            end
            figure;
            geoplot(obj.pos.lat(idxstat),obj.pos.lon(idxstat),"color",[0.2 0.2 0.2]);
            hold on;
            idxstat = idxstat & gsol.stat~=0;
            geoscatter(obj.pos.lat(idxstat),obj.pos.lon(idxstat),20,gt.C.C_SOL(obj.stat(idxstat),:),"filled");
            drawnow
        end
        %% plotSatMap
        function plotSatMap(obj, stat, idx)
            % plotSatMap: Plot solution to satellite map
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotSatMap([stat], [idx])
            %
            % Input: ------------------------------------------------------
            %  [stat]: Solution status to plot (optional)
            %          0:ALL, SOLQ_XXX, Default: stat = 0
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gsol
                stat (1,1) {mustBeInteger} = 0
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            obj.plotMap(stat, idx);
            geobasemap("satellite");
        end
        %% help
        function help(~)
            % help: Show help
            doc gt.Gsol
        end
        %% overload
        function [perr, verr] = minus(obj, gobj)
            % minus: Subtract two Gsol objects
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [perr, verr] = obj-gobj
            %
            % Input: ------------------------------------------------------
            %   gsol : gt.Gsol/gt.Gpos/gt.Gvel object
            %
            % Output: -----------------------------------------------------
            %   perr : Position error, gt.Gerr object
            %   verr : Velocity error, gt.Gerr object
            %
            [perr, verr] = obj.difference(gobj);
        end
    end
    %% private functions
    methods (Access = private)
        %% Insert data
        function c = insertdata(~,a,idx,b)
            c = [a(1:size(a,1)<idx,:); b; a(1:size(a,1)>=idx,:)];
        end
        %% Round datetime
        function tr = roundDateTime(~, t, dt)
            pt = posixtime(t);
            pt = round(pt/dt)*dt;
            tr = datetime(pt, "ConvertFrom", "posixtime", "TimeZone", "UTC");
        end
        %% Plot with solution status
        function plotSolStat(~, x, y, stat, lflag)
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
        %% Output KML track
        function kmlstr = kmltrack(obj, linecol, linewidth, outalt)
            linecol = validatecolor(linecol);

            kmlstr = "";
            kmlstr = kmlstr+"<Placemark>\n";
            kmlstr = kmlstr+"<name>Rover Track</name>\n";
            kmlstr = kmlstr+"<Style>\n";
            kmlstr = kmlstr+"<LineStyle>\n";
            kmlstr = kmlstr+sprintf("<color>%s</color>\n",obj.col2hex(linecol));
            kmlstr = kmlstr+sprintf("<width>%d</width>\n",linewidth);
            kmlstr = kmlstr+"</LineStyle>\n";
            kmlstr = kmlstr+"</Style>\n";
            kmlstr = kmlstr+"<LineString>\n";
            if outalt>0; kmlstr = kmlstr+"<altitudeMode>absolute</altitudeMode>\n"; end
            kmlstr = kmlstr+"<coordinates>\n";
            for i=1:obj.n
                if outalt==0
                    alt = 0.0;
                elseif outalt==1
                    alt = obj.pos.h(i);
                elseif outalt==2
                    alt =obj.pos.orthometric(i);
                end
                kmlstr = kmlstr+sprintf("%13.9f,%12.9f,%5.3f\n",obj.pos.lon(i),obj.pos.lat(i),alt);
            end
            kmlstr = kmlstr+"</coordinates>\n";
            kmlstr = kmlstr+"</LineString>\n";
            kmlstr = kmlstr+"</Placemark>\n";
        end
        %% Output KML point
        function kmlstr = kmlpoint(obj, pointcol, pointsize, outalt)
            icon = "http://maps.google.com/mapfiles/kml/pal2/icon18.png";
            kmlstr = "";

            if pointcol == 0
                for i=1:7
                    kmlstr = kmlstr+sprintf("<Style id=""P%d"">\n",i);
                    kmlstr = kmlstr+"<IconStyle>\n";
                    kmlstr = kmlstr+sprintf("<color>%s</color>\n",obj.col2hex(gt.C.C_SOL(i,:)));
                    kmlstr = kmlstr+sprintf("<scale>%.1f</scale>\n",pointsize);
                    kmlstr = kmlstr+sprintf("<Icon><href>%s</href></Icon>\n",icon);
                    kmlstr = kmlstr+"</IconStyle>\n";
                    kmlstr = kmlstr+"</Style>\n";
                end
            else
                pointcol = validatecolor(pointcol);
                kmlstr = kmlstr+"<Style id=""P1"">\n";
                kmlstr = kmlstr+"<IconStyle>\n";
                kmlstr = kmlstr+sprintf("<color>%s</color>\n",obj.col2hex(pointcol));
                kmlstr = kmlstr+sprintf("<scale>%.1f</scale>\n",pointsize);
                kmlstr = kmlstr+sprintf("<Icon><href>%s</href></Icon>\n",icon);
                kmlstr = kmlstr+"</IconStyle>\n";
                kmlstr = kmlstr+"</Style>\n";
            end

            kmlstr = kmlstr+"<Folder>\n";
            kmlstr = kmlstr+"<name>Position</name>\n";
            for i=1:obj.n
                kmlstr = kmlstr+"<Placemark>\n";
                if pointcol == 0
                    kmlstr = kmlstr+sprintf("<styleUrl>#P%d</styleUrl>\n",obj.stat(i));
                else
                    kmlstr = kmlstr+"<styleUrl>#P1</styleUrl>\n";
                end
                kmlstr = kmlstr+"<Point>\n";
                if outalt>0
                    kmlstr = kmlstr+"<extrude>1</extrude>\n";
                    kmlstr = kmlstr+"<altitudeMode>absolute</altitudeMode>\n";
                end
                if outalt==0
                    alt = 0.0;
                elseif outalt==1
                    alt = obj.pos.h(i);
                elseif outalt==2
                    alt =obj.pos.orthometric(i);
                end
                kmlstr = kmlstr+sprintf("<coordinates>%13.9f,%12.9f,%5.3f</coordinates>\n",obj.pos.lon(i),obj.pos.lat(i),alt);
                kmlstr = kmlstr+"</Point>\n";
                kmlstr = kmlstr+"</Placemark>\n";
            end

            kmlstr = kmlstr+"</Folder>\n";
        end
        %% Convert color vector to KML color string
        function chex = col2hex(~,c)
            arguments
                ~
                c (:,3)
            end
            nc = size(c,1);
            ckml = round(255*fliplr(c)); % order is BGR
            hs = reshape(string(dec2hex(ckml,2)),nc,3);
            chex = char("FF"+hs(:,1)+hs(:,2)+hs(:,3));
        end
        %% Convert from relative path to absolute path
        function apath = absPath(~, rpath)
            if isstring(rpath)
                rpath = char(rpath);
            end
            [dirname, filename, ext] = fileparts(rpath);
            [status, pathinfo] = fileattrib(dirname);
            if status==1
                apath = fullfile(pathinfo.Name, strcat([filename, ext]));
            else
                error('Directory does not exist: %s',dirname);
            end
        end
    end
end