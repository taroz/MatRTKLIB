classdef Gobs < handle
    % Gobs: GNSS RINEX observation data class
    % ---------------------------------------------------------------------
    % Gobs Declaration:
    % gobs = Gobs();  Create empty gt.Gobs object
    %
    % gobs = Gobs(file);  Create gt.Gobs object from RINEX file
    %   file      : 1x1, RINEX observation file
    %
    % gobs = Gobs(obsstr);  Create gt.Gobs object from observation struct
    %   obsstr    : 1x1, RTKLIB observation struct
    % ---------------------------------------------------------------------
    % Gobs Properties:
    %   n         : 1x1, Number of epochs
    %   nsat      : 1x1, Number of satellites
    %   sat       : 1x(obj.nsat), Satellite number (Compliant RTKLIB)
    %   prn       : 1x(obj.nsat), Satellite PRN/slot number
    %   sys       : 1x(obj.nsat), Satellite system (SYS_GPS, SYS_GLO, ...)
    %   satstr    : 1x(obj.nsat), Satellite ID cell array ('Gnn','Rnn','Enn','Jnn','Cnn','Inn' or 'nnn')
    %   time      : 1x1, Observation time, gt.Gtime object
    %   dt        : 1x1, Observation time interval (s)
    %   pos       : 1x1, Position in RINEX header, gt.Gpos object
    %   glofcn    : 1x(obj.nsat), Frequency channel number for GLONASS
    %   L1        : 1x1, L1 observation struct
    %     .P      : (obj.n)x(obj.nsat), Pseudorange (m)
    %     .L      : (obj.n)x(obj.nsat), Carrier phase (cycle)
    %     .D      : (obj.n)x(obj.nsat), Doppler (Hz)
    %     .S      : (obj.n)x(obj.nsat), SNR (dB-Hz)
    %     .I      : (obj.n)x(obj.nsat), LLI flag
    %     .ctype  : 1x(obj.nsat), Observation code cell array {'1C', '1P', '1P',...}
    %     .freq   : 1x(obj.nsat), Carrier frequency (Hz)
    %     .lam    : 1x(obj.nsat), Wavelength (m)
    %   L2        : 1x1, L2 observation struct
    %   L5        : 1x1, L5 observation struct
    %   L6        : 1x1, L6 observation struct
    %   L7        : 1x1, L7 observation struct
    %   L8        : 1x1, L8 observation struct
    %   L9        : 1x1, L9 observation struct
    %  (Lwl)      : 1x1, Wide-lane linear combination struct
    %  (Lml)      : 1x1, Middle-lane linear combination struct
    %  (Lewl)     : 1x1, Extra wide-lane linear combination struct
    %  (Lif)      : 1x1, Ionosphere-free linear combination struct
    % ---------------------------------------------------------------------
    % Gobs Methods:
    %   setObsFile(file);              Set observation from RINEX file
    %   setObsStruct(obsstr);          Set observation from observation struct
    %   setFrequency();                Set carrier frequency and wavelength
    %   setFrequencyFromNav(nav);      Set carrier frequency and wavelength from navigation
    %   outObs(file);                  Output RINEX observation file
    %   insert(idx, gobs);             Insert gt.Gobs object
    %   append(gobs);                  Append of gt.Gobs object
    %   maskP(mask, [freq]);           Apply mask to pseudorange observations
    %   maskD(mask, [freq]);           Apply mask to Doppler observations
    %   maskL(mask, [freq]);           Apply mask to carrier phase observations
    %   mask(mask, [freq]);            Apply mask to observations
    %   maskLLI(mask);                 Apply mask to carrier phase from LLI flag
    %   gobs = eliminateNaN();         Eliminate satellites whose observations are all NaN
    %   gobs = copy();                 Copy object
    %   gobs = select(tidx, sidx);     Select observation from time/satellite index
    %   gobs = selectSat(sidx);        Select observation from satellite index
    %   gobs = selectTime(tidx);       Select observation from time index
    %   gobs = selectTimeSpan(ts, te); Select observation from time span
    %   obsstr = struct([tidx], [sidx]); Convert from gt.Gobs object to observation struct
    %   gobs = fixedInterval([dt]);    Resampling observation at fixed interval
    %   gobs = interp(gtime, [method]); Interpolating observation at gtime
    %   [gobsc, gobsrefc] = commonObs(gobsref); Extract common observations with reference observation
    %   [gobsc, gobsrefc] = commonSat(gobsref); Extract common satellite with reference observation
    %   [gobsc, gobsrefc] = commonTime(gobsref);Extract common time with reference observation
    %   gobs = sameObs(gobsref);       Same satellite and time as reference observation
    %   gobs = sameSat(gobsref);       Same satellite as reference observation
    %   gobs = sameTime(gobsref);      Same time as reference observation
    %   gobs = linearCombination();    Compute linear combination of observations
    %   gobs = residuals(gsat);        Compute observation residuals
    %   gobsSD = singleDifference(gobs); Compute single-difference observations
    %   gobsDD = doubleDifference(gobs); Compute double-difference observations
    %   plot([freq], [sidx]);          Plot received observations and SNR
    %   plotNSat([freq], [snrth], [sidx]); Plot received number of satellites
    %   plotSky(nav, [sidx]);          Plot satellite constellation
    %   help();                        Show help
    % ---------------------------------------------------------------------
    % Gobs Overloads:
    %   gobsSD =  obj - gobs;          Compute single-difference observations
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki
    %
    properties
        n      % Number of epochs
        nsat   % Number of satellites
        sat    % Satellite number (Compliant RTKLIB)
        prn    % Satellite PRN number/slot number
        sys    % Satellite system (SYS_GPS, SYS_GLO, ...)
        satstr % Satellite id cell array
        time   % Observation time, gt.Gtime object
        dt     % Observation time interval (s)
        pos    % Position in RINEX header, gt.Gpos object
        glofcn % Frequency channel number for GLONASS
        L1     % L1 observation struct {P, L, D, S, I, ctype, freq, lam}
        L2     % L2 observation struct
        L5     % L5 observation struct
        L6     % L6 observation struct
        L7     % L7 observation struct
        L8     % L8 observation struct
        L9     % L9 observation struct
        Lwl    % Wide-lane linear combination struct
        Lml    % Middle-lane linear combination struct
        Lewl   % Extra wide-lane linear combination struct
        Lif    % Ionosphere-free linear combination struct
    end
    properties(Access=private)
        FTYPE = ["L1","L2","L5","L6","L7","L8","L9","Lwl","Lml","Lewl","Lif"];
    end
    methods
        %% constructor
        function obj = Gobs(varargin)
            if nargin==0 % generate empty object
                obj.n = 0;
                obj.nsat = 0;
            elseif nargin==1 && (ischar(varargin{1}) || isStringScalar(varargin{1}))
                obj.setObsFile(char(varargin{1})); % file
            elseif nargin==1 && isstruct(varargin{1})
                obj.setObsStruct(varargin{1}); % obs struct
            else
                error('Wrong input arguments');
            end
        end
        %% setObsFile
        function setObsFile(obj, file)
            % setObsFile: Set observation from RINEX file
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setObsFile(file)
            %
            % Input: ------------------------------------------------------
            %   file : 1x1, RINEX observation file
            %
            arguments
                obj gt.Gobs
                file (1,:) char
            end
            try
                [obs, basepos, fcn] = rtklib.readrnxobs(obj.absPath(file));
            catch
                error('Wrong RINEX observation file: %s',file);
            end

            % pos
            if ~all(basepos==[0,0,0])
                obj.pos = gt.Gpos(basepos,'xyz');
            end
            % glofcn
            idxglo = obs.sys==gt.C.SYS_GLO;
            fcn(fcn==0) = NaN;
            obj.glofcn = NaN(1,obs.nsat);
            obj.glofcn(idxglo) = fcn(obs.prn(idxglo))-8;

            obj.setObsStruct(obs);
        end
        %% setObsStruct
        function setObsStruct(obj, obsstr)
            % setObsStruct: Set observation from observation struct
            % -------------------------------------------------------------
            % The observation struct is the output of the RTKLIB wrapper
            % function.
            %
            % Usage: ------------------------------------------------------
            %   obj.setObsStruct(obsstr)
            %
            % Input: ------------------------------------------------------
            %   obsstr : 1x1, Observation struct
            %
            arguments
                obj gt.Gobs
                obsstr (1,1) struct
            end
            ep = obsstr.ep;
            obj.n = size(obsstr.ep,1);
            obj.nsat = size(obsstr.sat,2);
            obj.sat = obsstr.sat;
            [sys_, obj.prn] = rtklib.satsys(obj.sat);
            obj.sys = gt.C.SYS(sys_);
            obj.satstr = rtklib.satno2id(obj.sat);
            obj.time = gt.Gtime(ep);
            obj.dt = obj.time.estInterval();
            for f = obj.FTYPE
                if isfield(obsstr,f)
                    obj.(f) = obsstr.(f);
                end
            end
            if isempty(obj.glofcn)
                obj.glofcn = NaN(1,obj.nsat);
            end
            if ~all(isnan(obj.glofcn))
                obj.setFrequency();
            end
        end
        %% setFrequency
        function setFrequency(obj)
            % setFrequency: Set carrier frequency and wavelength
            % -------------------------------------------------------------
            % Carrier frequency is determined from the type of observation.
            % For GLONASS, the carrier frequency is determined from the
            % frequency channel number (FCN) in the RINEX header.
            %
            % If the RINEX header does not contain an FCN, the GLONASS
            % frequency is not set.
            %
            % Usage: ------------------------------------------------------
            %   obj.setFrequency()
            %
            arguments
                obj gt.Gobs
            end
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    code = rtklib.obs2code(obj.(f).ctype);
                    obj.(f).freq = rtklib.code2freq(double(obj.sys), code, obj.glofcn);
                    obj.(f).freq(obj.(f).freq==0) = NaN;
                    obj.(f).lam = gt.C.CLIGHT./obj.(f).freq;
                end
            end
        end
        %% setFrequencyFromNav
        function setFrequencyFromNav(obj, nav)
            % setFrequencyFromNav: Set carrier frequency and wavelength from navigation
            % -------------------------------------------------------------
            % Carrier frequency is determined from the type of observeation.
            % For GLONASS, the carrier frequency is determined from the
            % frequency channel number (FCN) in the navigation data.
            %
            % Usage: ------------------------------------------------------
            %   obj.setObsStruct(nav)
            %
            % Input: ------------------------------------------------------
            %   nav : 1x1, Navigation struct or gt.Gnav object
            %
            arguments
                obj gt.Gobs
                nav (1,1)
            end
            if ~isstruct(nav)
                if isa(nav, 'gt.Gnav')
                    nav = nav.struct();
                else
                    error('Input must be nav struct of gt.Gnav');
                end
            end
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    if isfield(obj.(f),"ctype")
                        code = rtklib.obs2code(obj.(f).ctype);
                        obj.(f).freq = rtklib.sat2freq(obj.sat,code,nav);
                        obj.(f).freq(obj.(f).freq==0) = NaN;
                        obj.(f).lam = gt.C.CLIGHT./obj.(f).freq;
                    end
                end
            end
        end
        %% outObs
        function outObs(obj, file)
            % outObs: Output RINEX observation file
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.outObs(file)
            %
            % Input: ------------------------------------------------------
            %   file : Output RINEX observation file name
            %
            arguments
                obj gt.Gobs
                file (1,:) char
            end
            obsstr = obj.struct();

            fcn = zeros(1,32);
            xyz = zeros(1,3);

            % GLONASS FCN for RINEX header
            if ~any(isnan(obj.glofcn))
                sysglo = obj.sys==gt.C.SYS_GLO;
                fcn(obj.prn(sysglo)) = obj.glofcn(sysglo)+8;
            end
            if ~isempty(obj.pos)
                xyz = obj.pos.xyz;
            end
            rtklib.outrnxobs(obj.absPath(file), obsstr, xyz, fcn);
        end
        %% insert
        function insert(obj, idx, gobs)
            % insert: Insert gt.Gobs object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.insert(idx, gobs)
            %
            % Input: ------------------------------------------------------
            %   idx : 1x1, Integer index to insert data
            %   gobs: 1x1, gt.Gobs object
            %
            arguments
                obj gt.Gobs
                idx (1,1) {mustBeInteger}
                gobs gt.Gobs
            end
            if idx<=0 || idx>obj.n
                error('Index is out of range');
            end
            obsstr.n = obj.n+gobs.n;
            obsstr.sat = unique([obj.sat, gobs.sat]);
            obsstr.nsat = length(obsstr.sat);
            [obsstr.sys, obsstr.prn] = rtklib.satsys(obsstr.sat);
            obsstr.satstr = rtklib.satno2id(obsstr.sat);
            obsstr.ep = obj.insertdata(obj.time.ep, idx, gobs.time.ep);
            obsstr.tow = obj.insertdata(obj.time.tow, idx, gobs.time.tow);
            obsstr.week = obj.insertdata(obj.time.week, idx, gobs.time.week);
            [~,sidx1] = intersect(obsstr.sat, obj.sat);
            [~,sidx2] = intersect(obsstr.sat, gobs.sat);
            tidx1 = [1:(idx-1) (idx+gobs.n):(idx+gobs.n+obj.n)];
            tidx2 = idx:(idx+gobs.n-1);
            for f = obj.FTYPE
                if ~isempty(obj.(f)) || ~isempty(gobs.(f))
                    obsstr.(f) = obj.initFreqStruct(f,obsstr.n,obsstr.nsat);
                    if ~isempty(obj.(f))
                        obsstr.(f) = obj.setFreqStruct(obsstr.(f),obj.(f),tidx1,1:obj.n,sidx1,1:obj.nsat);
                    end
                    if ~isempty(gobs.(f))
                        obsstr.(f) = obj.setFreqStruct(obsstr.(f),gobs.(f),tidx2,1:gobs.n,sidx2,1:gobs.nsat);
                    end
                end
            end
            obj.setObsStruct(obsstr);
        end
        %% append
        function append(obj, gobs)
            % append: Append gt.Gobs object
            % -------------------------------------------------------------
            % Add gt.Gobs object.
            % obj.n will be obj.n+gobs.n
            %
            % Usage: ------------------------------------------------------
            %   obj.append(gobs)
            %
            % Input: ------------------------------------------------------
            %   gobs : 1x1, gt.Gobs object
            %
            arguments
                obj gt.Gobs
                gobs gt.Gobs
            end
            obsstr.n = obj.n+gobs.n;
            obsstr.sat = unique([obj.sat, gobs.sat]);
            obsstr.nsat = length(obsstr.sat);
            [obsstr.sys, obsstr.prn] = rtklib.satsys(obsstr.sat);
            obsstr.satstr = rtklib.satno2id(obsstr.sat);
            obsstr.ep = [obj.time.ep; gobs.time.ep];
            obsstr.tow = [obj.time.tow; gobs.time.tow];
            obsstr.week = [obj.time.week; gobs.time.week];
            [~,sidx1] = intersect(obsstr.sat, obj.sat);
            [~,sidx2] = intersect(obsstr.sat, gobs.sat);
            for f = obj.FTYPE
                if ~isempty(obj.(f)) || ~isempty(gobs.(f))
                    obsstr.(f) = obj.initFreqStruct(f,obsstr.n,obsstr.nsat);
                    if ~isempty(obj.(f))
                        obsstr.(f) = obj.setFreqStruct(obsstr.(f),obj.(f),1:obj.n,1:obj.n,sidx1,1:obj.nsat);
                    end
                    if ~isempty(gobs.(f))
                        obsstr.(f) = obj.setFreqStruct(obsstr.(f),gobs.(f),(obj.n+1):obsstr.n,1:gobs.n,sidx2,1:gobs.nsat);
                    end
                end
            end
            % merge glofcn
            glofcn_ = obj.glofcn;
            obj.glofcn = NaN(1,obsstr.nsat);
            obj.glofcn(sidx1) = glofcn_;
            obj.glofcn(sidx2) = gobs.glofcn;

            obj.setObsStruct(obsstr);
        end
        %% maskP
        function maskP(obj, mask, freq)
            % maskP: Apply mask to pseudorange observations
            % -------------------------------------------------------------
            % Mask size must be [obj.n, obj.nsat].
            % The masked observations will be NaN.
            %
            % Usage: ------------------------------------------------------
            %   obj.maskP(mask, [freq])
            %
            % Input: ------------------------------------------------------
            %   mask : (obj.n)x(obj.nsat), Logical index array to mask
            %  [freq] : String array of frequency types to mask (e.g. "L1")
            %          (optional) Default: obj.FTYPE (all frequencies)
            %
            arguments
                obj gt.Gobs
                mask logical
                freq string {mustBeMember(freq,["L1","L2","L5","L6","L7","L8","L9","Lwl","Lml","Lewl","Lif","ALL"])} = "ALL"
            end
            if size(mask,1)~=obj.n || size(mask,2)~=obj.nsat
                error('mask array size does not match');
            end
            if freq=="ALL"
                freq = obj.FTYPE;
            end
            for f = freq
                if ~isempty(obj.(f))
                    if isfield(obj.(f),'P')
                        obj.(f).P(mask) = NaN;
                    end
                    if isfield(obj.(f),'resP')
                        obj.(f).resP(mask) = NaN;
                        obj.(f).resPc(mask) = NaN;
                    end
                    if isfield(obj.(f),'Pd')
                        obj.(f).Pd(mask) = NaN;
                        if isfield(obj.(f),'resPd')
                            obj.(f).resPd(mask) = NaN;
                        end
                    end
                    if isfield(obj.(f),'Pdd')
                        obj.(f).Pdd(mask) = NaN;
                        if isfield(obj.(f),'resPdd')
                            obj.(f).resPdd(mask) = NaN;
                        end
                    end
                end
            end
        end
        %% maskD
        function maskD(obj, mask, freq)
            % maskD: Apply mask to Doppler observations
            % -------------------------------------------------------------
            % Mask size must be [obj.n, obj.nsat].
            % The masked observations will be NaN.
            %
            % Usage: ------------------------------------------------------
            %   obj.maskD(mask, [freq])
            %
            % Input: ------------------------------------------------------
            %   mask : (obj.n)x(obj.nsat), Logical index array to mask
            %  [freq] : String array of frequency types to mask (e.g. "L1")
            %          (optional) Default: obj.FTYPE (all frequencies)
            %
            arguments
                obj gt.Gobs
                mask logical
                freq string {mustBeMember(freq,["L1","L2","L5","L6","L7","L8","L9","Lwl","Lml","Lewl","Lif","ALL"])} = "ALL"
            end
            if size(mask,1)~=obj.n || size(mask,2)~=obj.nsat
                error('mask array size does not match');
            end
            if freq=="ALL"
                freq = obj.FTYPE;
            end
            for f = freq
                if ~isempty(obj.(f))
                    if isfield(obj.(f),'D')
                        obj.(f).D(mask) = NaN;
                    end
                    if isfield(obj.(f),'resD')
                        obj.(f).resD(mask) = NaN;
                        obj.(f).resDc(mask) = NaN;
                    end
                    if isfield(obj.(f),'Dd')
                        obj.(f).Dd(mask) = NaN;
                        if isfield(obj.(f),'resDd')
                            obj.(f).resDd(mask) = NaN;
                        end
                    end
                end
            end
        end
        %% maskL
        function maskL(obj, mask, freq)
            % maskL: Apply mask to carrier phase observations
            % -------------------------------------------------------------
            % Mask size must be [obj.n, obj.nsat].
            % The masked observations will be NaN.
            %
            % Usage: ------------------------------------------------------
            %   obj.maskL(mask, [freq])
            %
            % Input: ------------------------------------------------------
            %   mask : (obj.n)x(obj.nsat), Logical index array to mask
            %  [freq] : String array of frequency types to mask (e.g. "L1")
            %          (optional) Default: obj.FTYPE (all frequencies)
            %
            arguments
                obj gt.Gobs
                mask logical
                freq string {mustBeMember(freq,["L1","L2","L5","L6","L7","L8","L9","Lwl","Lml","Lewl","Lif","ALL"])} = "ALL"
            end
            if size(mask,1)~=obj.n || size(mask,2)~=obj.nsat
                error('mask array size does not match');
            end
            if freq=="ALL"
                freq = obj.FTYPE;
            end
            for f = freq
                if ~isempty(obj.(f))
                    if isfield(obj.(f),'L')
                        obj.(f).L(mask) = NaN;
                    end
                    if isfield(obj.(f),'resL')
                        obj.(f).resL(mask) = NaN;
                        obj.(f).resLc(mask) = NaN;
                    end
                    if isfield(obj.(f),'Ld')
                        obj.(f).Ld(mask) = NaN;
                        if isfield(obj.(f),'resLd')
                            obj.(f).resLd(mask) = NaN;
                        end
                    end
                    if isfield(obj.(f),'Ldd')
                        obj.(f).Ldd(mask) = NaN;
                        if isfield(obj.(f),'resLdd')
                            obj.(f).resLdd(mask) = NaN;
                        end
                    end
                end
            end
        end
        %% mask
        function mask(obj, mask, freq)
            % mask: Apply mask to observations
            % -------------------------------------------------------------
            % Apply mask to pseudorange, Doppler, and carrier phase.
            % Mask size must be [obj.n, obj.nsat].
            % The masked observations will be NaN.
            %
            % Usage: ------------------------------------------------------
            %   obj.mask(mask, [freq])
            %
            % Input: ------------------------------------------------------
            %   mask : (obj.n)x(obj.nsat), Logical index array to mask
            %  [freq] : String array of frequency types to mask (e.g. "L1")
            %          (optional) Default: obj.FTYPE (all frequencies)
            %
            arguments
                obj gt.Gobs
                mask logical
                freq string {mustBeMember(freq,["L1","L2","L5","L6","L7","L8","L9","Lwl","Lml","Lewl","Lif","ALL"])} = "ALL"
            end
            if size(mask,1)~=obj.n || size(mask,2)~=obj.nsat
                error('mask array size does not match the observations');
            end
            obj.maskP(mask,freq);
            obj.maskL(mask,freq);
            obj.maskD(mask,freq);
        end
        %% maskLLI
        function maskLLI(obj)
            % maskLLI: Apply mask to carrier phase from LLI flag
            % -------------------------------------------------------------
            % Carrier phase observations for cycle slip and half-cycle slip
            % will be NaN.
            %
            % Usage: ------------------------------------------------------
            %   obj.maskLLI()
            %
            arguments
                obj gt.Gobs
            end
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    mask = obj.(f).I>=1; % 1:cycle slip, 2or3:half-cycle slip
                    obj.maskL(mask,f);
                end
            end
        end
        %% eliminateNaN
        function gobs = eliminateNaN(obj)
            % eliminateNaN: Eliminate satellites whose observations are all NaN
            % -------------------------------------------------------------
            % If all pseudorange observations are NaN, eliminate the satellite.
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.eliminateNaN()
            %
            % Output: -----------------------------------------------------
            %   gobs: 1x1, gt.Gobs object with satellites eliminated
            %
            arguments
                obj gt.Gobs
            end
            sidx = false(size(obj.sat));
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    sidx = sidx | any(~isnan(obj.(f).P));
                end
            end
            gobs = obj.selectSat(sidx);
        end
        %% copy
        function gobs = copy(obj)
            % copy: Copy object
            % -------------------------------------------------------------
            % MATLAB handle class is used, so if you want to create a
            % different object, you need to use the copy method.
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.copy()
            %
            % Output: -----------------------------------------------------
            %   gobs: 1x1, Copied gt.Gobs object
            %
            arguments
                obj gt.Gobs
            end
            gobs = obj.select(1:obj.n,1:obj.nsat);
        end
        %% select
        function gobs = select(obj, tidx, sidx)
            % select: Select observation from time/satellite index
            % -------------------------------------------------------------
            % Select observation from time/satellite index and return a new object.
            % The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.select(tidx, sidx)
            %
            % Input: ------------------------------------------------------
            %   tidx : Logical or numeric index to select time
            %   sidx : Logical or numeric index to select satellite
            %
            % Output: -----------------------------------------------------
            %   gobs : 1x1, Selected gt.Gobs object
            %
            arguments
                obj gt.Gobs
                tidx {mustBeInteger, mustBeVector}
                sidx {mustBeInteger, mustBeVector}
            end
            if ~any(tidx)
                warning('Selected time index is empty');
                gobs = gt.Gobs();
                return
            end
            if ~any(sidx)
                warning('Selected satellite index is empty');
                gobs = gt.Gobs();
                return
            end
            obsstr = obj.struct(tidx, sidx);
            gobs = gt.Gobs(obsstr);

            gobs.pos = obj.pos;
            gobs.glofcn = obj.glofcn(sidx);
            obj.copyFrequency(gobs,1:gobs.nsat,sidx);
            obj.copyAdditinalObservation(gobs,1:gobs.n,tidx,1:gobs.nsat,sidx);
        end
        %% selectSat
        function gobs = selectSat(obj, sidx)
            % selectSat: Select observation from satellite index
            % -------------------------------------------------------------
            % Select observation from satellite index and return a new object.
            % The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.selectSat(sidx)
            %
            % Input: ------------------------------------------------------
            %   sidx : Logical or numeric index to select satellite
            %
            % Output: -----------------------------------------------------
            %   gobs : 1x1, Selected gt.Gobs object
            %
            arguments
                obj gt.Gobs
                sidx {mustBeInteger, mustBeVector}
            end
            gobs = obj.select(1:obj.n, sidx);
        end
        %% selectTime
        function gobs = selectTime(obj, tidx)
            % selectTime: Select observation from time index
            % -------------------------------------------------------------
            % Select observation from time index and return a new object.
            % The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.selectTime(tidx)
            %
            % Input: ------------------------------------------------------
            %   tidx : Logical or numeric index to select time
            %
            % Output: -----------------------------------------------------
            %   gobs: 1x1, Selected gt.Gobs object
            %
            arguments
                obj gt.Gobs
                tidx {mustBeInteger, mustBeVector}
            end
            gobs = obj.select(tidx, 1:obj.nsat);
        end
        %% selectTimeSpan
        function gobs = selectTimeSpan(obj, ts, te)
            % selectTimeSpan: Select observation from time span
            % -------------------------------------------------------------
            % Select observation from the time span and return a new object.
            % The time span is start and end time represented by gt.Gtime.
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.selectTimeSpan(ts, te)
            %
            % Input: ------------------------------------------------------
            %   ts  : 1x1, gt.Gtime, Start time
            %   te  : 1x1, gt.Gtime, End time
            %
            % Output: -----------------------------------------------------
            %   gobs: 1x1, Selected gt.Gobs object
            %
            arguments
                obj gt.Gobs
                ts gt.Gtime
                te gt.Gtime
            end
            tr = obj.roundDateTime(obj.time.t, obj.dt);
            tsr = obj.roundDateTime(ts.t, obj.dt);
            ter = obj.roundDateTime(te.t, obj.dt);
            tidx = tr>=tsr & tr<=ter;
            gobs = obj.selectTime(tidx);
        end
        %% struct
        function obsstr = struct(obj, tidx, sidx)
            % struct: Convert from gt.Gobs object to observation struct
            % -------------------------------------------------------------
            % The input to the RTKLIB wrapper function must be a structure.
            % The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   obsstr = obj.struct([tidx], [sidx][)
            %
            % Input: ------------------------------------------------------
            %  [tidx]: Logical or numeric to select time (optional)
            %          Default: tidx = 1:obj.n
            %  [sidx]: Logical or numeric index to select satellite (optional)
            %          Default: sidx = 1:obj.nsat
            %
            % Output: -----------------------------------------------------
            %   obsstr: 1x1, Observation struct (for interface to RTKLIB)
            %
            arguments
                obj gt.Gobs
                tidx {mustBeInteger, mustBeVector} = 1:obj.n
                sidx {mustBeInteger, mustBeVector} = 1:obj.nsat
            end
            obsstr.sat = obj.sat(sidx);
            obsstr.prn = obj.prn(sidx);
            obsstr.sys = double(obj.sys(sidx));
            obsstr.satstr = obj.satstr(sidx);
            obsstr.ep = obj.time.ep(tidx,:);
            obsstr.tow = obj.time.tow(tidx);
            obsstr.week = obj.time.week(tidx);
            obsstr.n = size(obsstr.ep,1);
            obsstr.nsat = size(obsstr.sat,2);
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    obsstr.(f) = obj.selectFreqStruct(obj.(f), tidx, sidx);
                end
            end
        end
        %% interp
        function gobs = interp(obj, gtime, method)
            % interp: Interpolating observation at gtime
            % -------------------------------------------------------------
            % Interpolate observation at the query point and return a
            % new object.
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.interp(gtime, [method])
            %
            % Input: ------------------------------------------------------
            %   gtime : Query points, gt.Gtime object
            %   method: Interpolation method (optional)
            %           Default: method = "linear"
            %
            % Output: -----------------------------------------------------
            %   gobs: 1x1, Interpolated gt.Gobs object
            %
            arguments
                obj gt.Gobs
                gtime gt.Gtime
                method (1,:) char {mustBeMember(method,{'linear','spline','makima'})} = 'linear'
            end
            if min(obj.time.t)>min(gtime.t) || max(obj.time.t)<max(gtime.t)
                error("Query point is out of range (extrapolation)")
            end
            obsstr.n = gtime.n;
            obsstr.nsat = obj.nsat;
            obsstr.sat = obj.sat;
            obsstr.prn = obj.prn;
            obsstr.sys = double(obj.sys);
            obsstr.satstr = obj.satstr;
            obsstr.ep = gtime.ep;
            obsstr.tow = gtime.tow;
            obsstr.week = gtime.week;

            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    obsstr.(f) = obj.initFreqStruct(f,obsstr.n,obsstr.nsat);
                    obsstr.(f) = obj.setFreqStructInterp(obsstr.(f),gtime.t,obj.(f),obj.time.t,method);
                end
            end
            gobs = gt.Gobs(obsstr);
            gobs.pos = obj.pos;
            gobs.glofcn = obj.glofcn;
        end
        %% fixedInterval
        function gobs = fixedInterval(obj, dt)
            % fixedInterval: Resampling observation at fixed interval
            % -------------------------------------------------------------
            % The time interval of the observed value will be constant at
            % the specified second.
            %
            % If the time interval of the original observation is not
            % constant, NaN is inserted into the observation at that time.
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.fixedInterval([dt])
            %
            % Input: ------------------------------------------------------
            %  [dt] : 1x1, double, Time interval for resampling (s)
            %        (optional) Default: dt = obj.dt
            %
            % Output: -----------------------------------------------------
            %   gobs: 1x1, Resampled gt.Gobs object
            %
            arguments
                obj gt.Gobs
                dt (1,1) double = 0
            end
            if dt==0; dt = obj.dt; end
            tr = obj.roundDateTime(obj.time.t, obj.dt);
            tfixr = obj.roundDateTime((tr(1):seconds(dt):tr(end))', dt);
            nfix = length(tfixr);
            tfix = NaT(nfix,1,"TimeZone","UTC");
            [~, idx1,idx2] = intersect(tfixr,tr);
            tfix(idx1) = obj.time.t(idx2);
            tfix = fillmissing(tfix,'linear');
            gtfix = gt.Gtime(tfix);

            obsstr.n = nfix;
            obsstr.nsat = obj.nsat;
            obsstr.sat = obj.sat;
            obsstr.prn = obj.prn;
            obsstr.sys = double(obj.sys);
            obsstr.satstr = obj.satstr;
            obsstr.ep = gtfix.ep;
            obsstr.tow = gtfix.tow;
            obsstr.week = gtfix.week;

            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    obsstr.(f) = obj.initFreqStruct(f,obsstr.n,obsstr.nsat);
                    obsstr.(f) = obj.setFreqStruct(obsstr.(f),obj.(f),idx1,idx2,1:obj.nsat,1:obj.nsat);
                end
            end
            gobs = gt.Gobs(obsstr);
            gobs.pos = obj.pos;
            gobs.glofcn = obj.glofcn;
        end
        %% commonObs
        function [gobsc, gobsrefc] = commonObs(obj, gobsref)
            % commonObs: Extract common observation with reference observation
            % -------------------------------------------------------------
            % Extract the common time and satellite observations between
            % the reference gt.Gobs object and the current object.
            %
            % Output new gt.Gobs object and reference gt.Gobs object.
            %
            % gobsc.time = obsrefc.time
            % gobsc.sat = obsrefc.sat
            %
            % Usage: ------------------------------------------------------
            %   [gobsc, gobsrefc] = obj.commonObs(gobsref)
            %
            % Input: ------------------------------------------------------
            %   gobsref : 1x1, Reference gt.Gobs object
            %
            % Output: -----------------------------------------------------
            %   gobsc   : 1x1, New gt.Gobs object
            %   gobsrefc: 1x1, New reference gt.Gobs object
            %
            arguments
                obj gt.Gobs
                gobsref gt.Gobs
            end
            [gobsc, gobsrefc] = obj.commonSat(gobsref);
            [gobsc, gobsrefc] = gobsc.commonTime(gobsrefc);
        end
        %% commonSat
        function [gobsc, gobsrefc] = commonSat(obj, gobsref)
            % commonSat: Extract common satellite with reference observation
            % -------------------------------------------------------------
            % Extract the common satellites between the reference gt.Gobs
            % object and the current object.
            %
            % Output new gt.Gobs object and reference gt.Gobs object.
            %
            % gobsc.sat = obsrefc.sat
            %
            % Usage: ------------------------------------------------------
            %   [gobsc, gobsrefc] = obj.commonObs(gobsref)
            %
            % Input: ------------------------------------------------------
            %   gobsref : 1x1, Reference gt.Gobs object
            %
            % Output: -----------------------------------------------------
            %   gobsc   : 1x1, New gt.Gobs object
            %   gobsrefc: 1x1, New reference gt.Gobs object
            %
            arguments
                obj gt.Gobs
                gobsref gt.Gobs
            end
            [~,sidx1,sidx2] = intersect(obj.sat,gobsref.sat);
            gobsc = obj.selectSat(sidx1);
            gobsrefc = gobsref.selectSat(sidx2);
        end
        %% commonTime
        function [gobsc, gobsrefc] = commonTime(obj, gobsref)
            % commonTime: Extract common time with reference observation
            % -------------------------------------------------------------
            % Extract the common time between the reference gt.Gobs object
            % and the current object.
            %
            % Output new gt.Gobs object and reference gt.Gobs object.
            %
            % gobsc.time = gobsrefc.time
            %
            % Usage: ------------------------------------------------------
            %   [gobsc, gobsrefc] = obj.commonObs(gobsref)
            %
            % Input: ------------------------------------------------------
            %   gobsref : 1x1, Reference gt.Gobs object
            %
            % Output: -----------------------------------------------------
            %   gobsc   : 1x1, New gt.Gobs object
            %   gobsrefc: 1x1, New reference gt.Gobs object
            %
            arguments
                obj gt.Gobs
                gobsref gt.Gobs
            end
            t = obj.roundDateTime(obj.time.t, obj.dt);
            tref = obj.roundDateTime(gobsref.time.t, gobsref.dt);
            [~,tidx1,tidx2] = intersect(t,tref);
            gobsc = obj.selectTime(tidx1);
            gobsrefc = gobsref.selectTime(tidx2);
        end
        %% sameObs
        function gobs = sameObs(obj, gobsref)
            % sameObs: Same satellite and time as reference observation
            % -------------------------------------------------------------
            % Create an gt.Gobs object whose time and satellite are
            % consistent with the reference gt.Gobs object.
            %
            % gobs.time = gobsref.time
            % gobs.sat = gobsref.sat
            %
            % If the time or satellite of the reference observation is not
            % included in the current observation, NaN is inserted into the
            % observations.
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.sameObs(gobsref)
            %
            % Input: ------------------------------------------------------
            %   gobsref : 1x1, Reference gt.Gobs object
            %
            % Output: -----------------------------------------------------
            %   gobs : 1x1, New gt.Gobs object
            %
            arguments
                obj gt.Gobs
                gobsref gt.Gobs
            end
            gobs = obj.sameSat(gobsref);
            gobs = gobs.sameTime(gobsref);
        end
        %% sameSat
        function gobs = sameSat(obj, gobsref)
            % sameSat: Same satellite as reference observation
            % -------------------------------------------------------------
            % Create an gt.Gobs object whose satellite are consistent with
            % the reference gt.Gobs object.
            %
            % gobs.sat = gobsref.sat
            %
            % If the satellite of the reference observation is not
            % in the current observation, NaN is inserted into the
            % observations.
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.sameSat(gobsref)
            %
            % Input: ------------------------------------------------------
            %   gobsref : 1x1, Reference gt.Gobs object
            %
            % Output: -----------------------------------------------------
            %   gobs : 1x1, New gt.Gobs object
            %
            arguments
                obj gt.Gobs
                gobsref gt.Gobs
            end
            [~,sidx1,sidx2] = intersect(gobsref.sat,obj.sat);
            obsstr.n = obj.n;
            obsstr.nsat = gobsref.nsat;
            obsstr.sat = gobsref.sat;
            obsstr.ep = obj.time.ep;

            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    obsstr.(f) = obj.initFreqStruct(f,obsstr.n,obsstr.nsat);
                    obsstr.(f) = obj.setFreqStruct(obsstr.(f),obj.(f),1:obj.n,1:obj.n,sidx1,sidx2);
                end
            end
            gobs = gt.Gobs(obsstr);
            gobs.pos = obj.pos;
            gobs.glofcn = gobsref.glofcn;
            obj.copyAdditinalObservation(gobs,1:gobs.n,1:gobs.n,sidx1,sidx2);
        end
        %% sameTime
        function gobs = sameTime(obj, gobsref)
            % sameTime: Same time as reference observation
            % -------------------------------------------------------------
            % Create an gt.Gobs object whose time are consistent with
            % the reference gt.Gobs object.
            %
            % gobs.time = gobsref.time
            %
            % If the time of the reference observation is not
            % in the current observation, NaN is inserted into the
            % observations.
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.sameTime(gobsref)
            %
            % Input: ------------------------------------------------------
            %   gobsref : 1x1, Reference gt.Gobs object
            %
            % Output: -----------------------------------------------------
            %   gobs : 1x1, New gt.Gobs object
            %
            arguments
                obj gt.Gobs
                gobsref gt.Gobs
            end
            t = obj.roundDateTime(obj.time.t, obj.dt);
            tref = obj.roundDateTime(gobsref.time.t, gobsref.dt);

            [~,tidx1,tidx2] = intersect(tref,t);
            obsstr.n = gobsref.n;
            obsstr.nsat = obj.nsat;
            obsstr.sat = obj.sat;

            ep_ = gobsref.time.ep;
            ep_(tidx1,:) = obj.time.ep(tidx2,:);
            obsstr.ep = ep_;

            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    obsstr.(f) = obj.initFreqStruct(f,obsstr.n,obsstr.nsat);
                    obsstr.(f) = obj.setFreqStruct(obsstr.(f),obj.(f),tidx1,tidx2,1:obj.nsat,1:obj.nsat);
                end
            end
            gobs = gt.Gobs(obsstr);
            gobs.pos = obj.pos;
            gobs.glofcn = gobsref.glofcn;
            obj.copyAdditinalObservation(gobs,tidx1,tidx2,1:gobs.nsat,1:gobs.nsat);
        end
        %% linearCombination
        function gobs = linearCombination(obj)
            % linearCombination: Compute linear combination of observations
            % -------------------------------------------------------------
            % Compute following linear combination of observations
            % Lwl : Wide-lane carrier phase
            % Lml : Middle-lane carrier phase
            % Lewl: Extra wide-lane carrier phase
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.linearCombination()
            %
            % Output: -----------------------------------------------------
            %   gobs : 1x1, New gt.Gobs object
            %
            arguments
                obj gt.Gobs
            end
            gobs = obj.copy();

            % middle-lane (L1-L5)
            if ~isempty(obj.L1) && ~isempty(obj.L5)
                gobs.Lml.freq = obj.L1.freq-obj.L5.freq;
                gobs.Lml.lam = gt.C.CLIGHT./gobs.Lml.freq;
                gobs.Lml.L = obj.L1.L-obj.L5.L; % (cycle)
            end
            % wide-lane (L1-L2)
            if ~isempty(obj.L1) && ~isempty(obj.L2)
                gobs.Lwl.freq = obj.L1.freq-obj.L2.freq;
                gobs.Lwl.lam = gt.C.CLIGHT./gobs.Lwl.freq;
                gobs.Lwl.L = obj.L1.L-obj.L2.L; % (cycle)
            end
            % extra wide-lane (L2-L5)
            if ~isempty(obj.L2) && ~isempty(obj.L5)
                gobs.Lewl.freq = obj.L2.freq-obj.L5.freq;
                gobs.Lewl.lam = gt.C.CLIGHT./gobs.Lewl.freq;
                gobs.Lewl.L = obj.L2.L-obj.L5.L; % (cycle)
            end
            % ToDo: other combinations
        end
        %% residuals
        function gobs = residuals(obj, gsat)
            % residuals: Compute observation residuals
            % -------------------------------------------------------------
            % Compute pseudorange, carrier phase, doppler residuals.
            %
            % resP,resD,resL:
            %   Corrects geometric distance/rate and satellite clock/drift
            %
            % resPc,resLc:
            %   Corrects troposphere and ionosphere errors in addition to
            %   the above
            %
            % Usage: ------------------------------------------------------
            %   gobs = obj.residuals(gsat)
            %
            % Input: ------------------------------------------------------
            %   gsat : 1x1, gt.Gsat object
            %
            % Output: -----------------------------------------------------
            %   gobs: 1x1, new gt.Gobs object
            %
            arguments
                obj gt.Gobs
                gsat gt.Gsat
            end
            if obj.nsat ~= gsat.nsat
                error('obj.nsat and gsat.nsat must be the same')
            end
            if obj.n ~= gsat.n
                error('obj.n and gsat.n must be the same')
            end
            if isempty(gsat.pos) & isempty(gsat.vel)
                error('Call gsat.setRcvPos(gpos) or gsat.setRcvVel(gvel)) first to set the receiver position/velocity');
            end
            gobs = obj.copy();
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    if ~isempty(gsat.pos)
                        if isfield(gobs.(f),"P"); gobs.(f).resP = gobs.(f).P-(gsat.rng-gsat.dts); end % pseudorange residuals (m)
                        if isfield(gobs.(f),"L"); gobs.(f).resL = gobs.(f).L.*gobs.(f).lam-(gsat.rng-gsat.dts); end % carrier phase residuals (m)
                    end
                    if ~isempty(gsat.vel)
                        if isfield(gobs.(f),"D"); gobs.(f).resD = -gobs.(f).D.*gobs.(f).lam-(gsat.rate-gsat.ddts); end % doppler residuals (m/s)
                    end
                    if isprop(gsat,"ion"+f)
                        if ~isempty(gsat.("ion"+f))
                            if ~isempty(gsat.pos)
                                if isfield(gobs.(f),"P"); gobs.(f).resPc = gobs.(f).P-(gsat.rng-gsat.dts+gsat.("ion"+f)+gsat.trp); end % pseudorange residuals (m)
                                if isfield(gobs.(f),"L"); gobs.(f).resLc = gobs.(f).L.*gobs.(f).lam-(gsat.rng-gsat.dts-gsat.("ion"+f)+gsat.trp); end % carrier phase residuals (m)
                            end
                        end
                    end
                end
            end
        end
        %% singleDifference
        function gobsSD = singleDifference(obj, gobsref)
            % singleDifference: Compute single-difference observations
            % -------------------------------------------------------------
            % Compute single-difference observation (difference between
            % reference station).
            %
            % Pd,Ld,Dd,resPd,resDd,resLd: Single-difference observations
            %
            % The time and satellite of the reference station's observation
            % must match the object.
            %
            % Usage: ------------------------------------------------------
            %   gobsSD = obj.singleDifference(gobsref)
            %
            % Input: ------------------------------------------------------
            %   gobsref : 1x1, gt.Gobs object of reference station
            %
            % Output: -----------------------------------------------------
            %   gobsSD: 1x1, gt.Gobs object
            %
            arguments
                obj gt.Gobs
                gobsref gt.Gobs
            end
            if obj.nsat ~= gobsref.nsat
                error('obj.nsat and gobs.nsat must be the same')
            end
            if obj.n ~= gobsref.n
                error('obj.n and gobs.n must be the same')
            end
            gobsSD = obj.copy();
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    if isfield(obj.(f),"P") && isfield(gobsref.(f),"P"); gobsSD.(f).Pd = obj.(f).P-gobsref.(f).P; end % (m)
                    if isfield(obj.(f),"L") && isfield(gobsref.(f),"L"); gobsSD.(f).Ld = obj.(f).L-gobsref.(f).L; end % (m)
                    if isfield(obj.(f),"D") && isfield(gobsref.(f),"D"); gobsSD.(f).Dd = obj.(f).D-gobsref.(f).D; end % (m/s)
                    if isfield(obj.(f),"resP") && isfield(gobsref.(f),"resP"); gobsSD.(f).resPd = obj.(f).resP-gobsref.(f).resP; end % (m)
                    if isfield(obj.(f),"resL") && isfield(gobsref.(f),"resL"); gobsSD.(f).resLd = obj.(f).resL-gobsref.(f).resL; end % (m)
                    if isfield(obj.(f),"resD") && isfield(gobsref.(f),"resD"); gobsSD.(f).resDd = obj.(f).resD-gobsref.(f).resD; end % (m/s)
                end
            end
        end
        %% doubleDifference
        function gobsDD = doubleDifference(obj, refsatidx)
            % doubleDifference: Compute double-difference observations
            % -------------------------------------------------------------
            % Compute double-difference observation (difference between
            % reference station and satellite).
            %
            % Pd,Ld,Dd,resPd,resDd,resLd: Double-difference observations
            %
            % Usage: ------------------------------------------------------
            %   gobsDD = obj.doubleDifference(refsatidx)
            %
            % Input: ------------------------------------------------------
            %   refsatidx : 1x(obj.nsat), Index of reference satellite
            %
            % Output: -----------------------------------------------------
            %   gobsSD: 1x1, gt.Gobs object
            %
            arguments
                obj gt.Gobs
                refsatidx {mustBeInteger, mustBeVector}
            end
            if length(refsatidx) ~= obj.nsat
                error('Size of refidx must be obj.nsat')
            end
            sidx = unique(refsatidx);
            gobsDD = obj.copy();
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    if isfield(obj.(f),"Pd"); gobsDD.(f).Pdd = obj.(f).Pd-obj.(f).Pd(:,refsatidx); ...
                            gobsDD.(f).Pdd(:,sidx) = NaN; end % (m)
                    if isfield(obj.(f),"Ld"); gobsDD.(f).Ldd = obj.(f).Ld-obj.(f).Ld(:,refsatidx); ...
                            gobsDD.(f).Ldd(:,sidx) = NaN; end % (m)
                    if isfield(obj.(f),"resPd"); gobsDD.(f).resPdd = obj.(f).resPd-obj.(f).resPd(:,refsatidx); ...
                            gobsDD.(f).resPdd(:,sidx) = NaN; end % (m)
                    if isfield(obj.(f),"resLd"); gobsDD.(f).resLdd = obj.(f).resLd-obj.(f).resLd(:,refsatidx); ...
                            gobsDD.(f).resLdd(:,sidx) = NaN; end % (m)
                end
            end
        end
        %% plot
        function plot(obj, freq, sidx)
            % plot: Plot received observations and SNR
            % -------------------------------------------------------------
            % Plot received observations and SNR
            %
            % Usage: ------------------------------------------------------
            %   obj.plot([freq], [sidx])
            %
            % Input: ------------------------------------------------------
            %  [freq]: Frequency band to plot (optional) Default: 'L1'
            %  [sidx]: Logical or numeric index to select satellite (optional)
            %          Default: sidx = 1:obj.nsat
            %
            arguments
                obj gt.Gobs
                freq string {mustBeMember(freq,["L1","L2","L5","L6","L7","L8","L9","Lwl","Lml","Lewl","Lif"])} = "L1"
                sidx {mustBeInteger, mustBeVector} = 1:obj.nsat
            end
            gobs = obj.selectSat(sidx);
            if isempty(gobs.(freq))
                warning([freq ': No observations'])
            else
                f = figure;
                f.Position(4) = 1.2*f.Position(4);
                y = gobs.nsat:-1:1;
                for i=1:gobs.nsat
                    scatter(gobs.time.t,y(i)*ones(gobs.n,1),[],gobs.(freq).S(:,i),'filled');
                    hold on;
                end
                grid on;
                xlim([gobs.time.t(1) gobs.time.t(end)]);
                ylim([0 gobs.nsat+1]);

                yticks(1:gobs.nsat)
                yticklabels(fliplr(gobs.satstr));
                c = colorbar(gca,'northoutside');
                c.Label.String = freq+" SNR (dB-Hz)";
                drawnow
            end
        end
        %% plotNSat
        function plotNSat(obj, freq, snrth, sidx)
            % plotNSat: Plot received number of satellites
            % -------------------------------------------------------------
            % Plot the time transition of number of satellites whose SNR
            % are above a specified threshold.
            %
            % Usage: ------------------------------------------------------
            %   obj.plotNSat([freq], [snrth], [sidx])
            %
            % Input: ------------------------------------------------------
            %  [freq] : Frequency band to plot (default: 'L1')
            %  [snrth]: 1x1, SNR threshold (default: 0.0 dB-Hz)
            %  [sidx] : Logical or numeric index to select satellite (optional)
            %           Default: sidx = 1:obj.nsat
            %
            arguments
                obj gt.Gobs
                freq string {mustBeMember(freq,["L1","L2","L5","L6","L7","L8","L9","Lwl","Lml","Lewl","Lif"])} = "L1"
                snrth (1,1) double = 0.0
                sidx {mustBeInteger, mustBeVector} = 1:obj.nsat
            end
            gobs = obj.selectSat(sidx);
            if isempty(gobs.(freq))
                warning([freq ': No observations'])
            else
                figure;
                satsyss = unique(gobs.sys);
                col = gt.C.C_SYS(satsyss,:);
                for i=1:length(satsyss)
                    isys = gobs.sys==satsyss(i);
                    nsys(:,i) = sum(gobs.(freq).S(:,isys)>snrth,2);
                end
                area(gobs.time.t,nsys);
                grid on;
                set(gca,'ColorOrder',col);
                legend(string(gt.C.SYSNAME(double(satsyss))));
                xlim([gobs.time.t(1) gobs.time.t(end)]);
                title("Number of "+freq+" observations (CNR threhould "+num2str(snrth)+" dB-Hz)");
                drawnow
            end
        end
        %% plotSky
        function plotSky(obj, gnav, tidx, sidx)
            % plotSky: Plot satellite constellation
            % -------------------------------------------------------------
            % Display satellite constellation display.
            % The receiver location uses the antenna location in the RINEX
            % header.
            %
            % Usage: ------------------------------------------------------
            %   obj.plotSky(gnav, [tidx], [sidx])
            %
            % Input: ------------------------------------------------------
            %   gnav : 1x1, gt.Gnav object
            %  [tidx]: Logical or numeric to select time (optional)
            %          Default: tidx = 1:obj.n
            %  [sidx]: Logical or numeric index to select satellite (optional)
            %          Default: sidx = 1:obj.nsat
            %
            arguments
                obj gt.Gobs
                gnav gt.Gnav
                tidx {mustBeInteger, mustBeVector} = 1:obj.n
                sidx {mustBeInteger, mustBeVector} = 1:obj.nsat
            end
            if isempty(obj.pos)
                error('Apploximated position in RINEX Header is empty');
            end
            gobs = obj.select(tidx, sidx);
            gsat = gt.Gsat(gobs, gnav);
            gsat.setRcvPos(obj.pos);
            gsat.plotSky;
        end
        %% help
        function help(~)
            % help: Show help
            doc gt.Gobs
        end
        %% overload
        function gobsSD = minus(obj, gobs)
            % minus: Compute single difference
            % -------------------------------------------------------------
            % You can calculate single diffenrece only running obj - gobs.
            % This object and gobs object must be same size.
            %
            % Usage: ------------------------------------------------------
            %   gobsSD = obj - gobs
            %
            % Output: -----------------------------------------------------
            %   gobsSD: 1x1, gt.Gobs object with single difference
            %
            arguments
                obj gt.Gobs
                gobs gt.Gobs
            end
            gobsSD = obj.singleDifference(gobs);
        end
    end
    %% Private functions
    methods(Access=private)
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
        %% Select LLI
        function Isel = selectLLI(~,I,tidx,sidx)
            I(isnan(I)) = 0;

            I1 = I==1 | I==3;
            I2 = I==2 | I==3;

            I1sum = cumsum(I1);
            I1sum_sel = I1sum(tidx,sidx);
            [n_sel,nsat_sel] = size(I1sum_sel);
            if n_sel>1
                I1sel = [zeros(1,nsat_sel);diff(I1sum_sel,1)];
                I1sel(I1sel>=1) = 1;
            else
                I1sel = I1sum_sel;
                I1sel(I1sel>=1) = 1;
            end
            I2sel = 2*I2(tidx,sidx);

            Isel = I1sel+I2sel;
        end
        %% Interpolate LLI
        function Ii = interpLLI(obj,t,I,ti)
            Ii = zeros(size(ti,1),size(I,2));
            tidx = interp1(t,1:length(t),ti,"previous");
            [tidx_unique, idx] = unique(tidx);
            Isel = obj.selectLLI(I,tidx_unique,1:size(I,2));
            Ii(idx,:) = Isel;
        end
        %% Select observation
        function Fsel = selectFreqStruct(obj,F,tidx,sidx)
            if isfield(F,"P"); Fsel.P = F.P(tidx,sidx); end
            if isfield(F,"L"); Fsel.L = F.L(tidx,sidx); end
            if isfield(F,"D"); Fsel.D = F.D(tidx,sidx); end
            if isfield(F,"S"); Fsel.S = F.S(tidx,sidx); end
            if isfield(F,"I"); Fsel.I = obj.selectLLI(F.I,tidx,sidx); end
            if isfield(F,"ctype"); Fsel.ctype = F.ctype(sidx); end
            if isfield(F,'freq'); Fsel.freq = F.freq(sidx);end
            if isfield(F,'lam'); Fsel.lam = F.lam(sidx); end
        end
        %% Initialize observation
        function Fini = initFreqStruct(obj,f,n,nsat)
            if isfield(obj.(f),"P"); Fini.P = NaN(n,nsat); end
            if isfield(obj.(f),"L"); Fini.L = NaN(n,nsat); end
            if isfield(obj.(f),"D"); Fini.D = NaN(n,nsat); end
            if isfield(obj.(f),"S"); Fini.S = NaN(n,nsat); end
            if isfield(obj.(f),"I"); Fini.I = NaN(n,nsat); end
            if isfield(obj.(f),"ctype"); Fini.ctype = repmat({''},1,nsat); end
            if isfield(obj.(f),'freq'); Fini.freq = NaN(1,nsat); end
            if isfield(obj.(f),'lam'); Fini.lam = NaN(1,nsat); end
        end
        %% Set observation
        function Fset = setFreqStruct(obj,Fset,F,tidx1,tidx2,sidx1,sidx2)
            if isfield(F,"P"); Fset.P(tidx1,sidx1) = F.P(tidx2,sidx2); end
            if isfield(F,"L"); Fset.L(tidx1,sidx1) = F.L(tidx2,sidx2); end
            if isfield(F,"D"); Fset.D(tidx1,sidx1) = F.D(tidx2,sidx2); end
            if isfield(F,"S"); Fset.S(tidx1,sidx1) = F.S(tidx2,sidx2); end
            if isfield(F,"I"); Fset.I(tidx1,sidx1) = obj.selectLLI(F.I,tidx2,sidx2); end
            if isfield(F,"ctype"); Fset.ctype(sidx1) = F.ctype(sidx2); end
            if isfield(F,'freq'); Fset.freq(sidx1) = F.freq(sidx2); end
            if isfield(F,'lam'); Fset.lam(sidx1) = F.lam(sidx2); end
        end
        %% Set interpolated observation
        function Fset = setFreqStructInterp(obj,Fset,tset,F,t,method)
            if isfield(F,"P"); Fset.P = interp1(t,F.P,tset,method); end
            if isfield(F,"L"); Fset.L = interp1(t,F.L,tset,method); end
            if isfield(F,"D"); Fset.D = interp1(t,F.D,tset,method); end
            if isfield(F,"S"); Fset.S = interp1(t,F.S,tset,method); end
            if isfield(F,"I"); Fset.I = obj.interpLLI(t,F.I,tset); end
            if isfield(F,"ctype"); Fset.ctype = F.ctype; end
            if isfield(F,'freq'); Fset.freq = F.freq; end
            if isfield(F,'lam'); Fset.lam = F.lam; end
        end
        %% Copy frequency and wavelength
        function copyFrequency(obj,dst,sidx1,sidx2)
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    if isfield(f,'freq')
                        dst.(f).freq(sidx1) = obj.(f).freq(sidx2);
                        dst.(f).lam(sidx1) = obj.(f).lam(sidx2);
                    end
                end
            end
        end
        %% Copy frequency struct
        function copyAdditinalObservation(obj,dst,tidx1,tidx2,sidx1,sidx2)
            for f = obj.FTYPE
                if ~isempty(obj.(f))
                    if isfield(obj.(f),'resP'); dst.(f).resP(tidx1,sidx1) = obj.(f).resP(tidx2,sidx2); end
                    if isfield(obj.(f),'resL'); dst.(f).resL(tidx1,sidx1) = obj.(f).resL(tidx2,sidx2); end
                    if isfield(obj.(f),'resD'); dst.(f).resD(tidx1,sidx1) = obj.(f).resD(tidx2,sidx2); end
                    if isfield(obj.(f),'resPc'); dst.(f).resPc(tidx1,sidx1) = obj.(f).resPc(tidx2,sidx2); end
                    if isfield(obj.(f),'resLc'); dst.(f).resLc(tidx1,sidx1) = obj.(f).resLc(tidx2,sidx2); end
                    if isfield(obj.(f),'Pd'); dst.(f).Pd(tidx1,sidx1) = obj.(f).Pd(tidx2,sidx2); end
                    if isfield(obj.(f),'Ld'); dst.(f).Ld(tidx1,sidx1) = obj.(f).Ld(tidx2,sidx2); end
                    if isfield(obj.(f),'Dd'); dst.(f).Dd(tidx1,sidx1) = obj.(f).Dd(tidx2,sidx2); end
                    if isfield(obj.(f),'resPd'); dst.(f).resPd(tidx1,sidx1) = obj.(f).resPd(tidx2,sidx2); end
                    if isfield(obj.(f),'resLd'); dst.(f).resLd(tidx1,sidx1) = obj.(f).resLd(tidx2,sidx2); end
                    if isfield(obj.(f),'resDd'); dst.(f).resDd(tidx1,sidx1) = obj.(f).resDd(tidx2,sidx2); end
                    if isfield(obj.(f),'Pdd'); dst.(f).Pdd(tidx1,sidx1) = obj.(f).Pdd(tidx2,sidx2); end
                    if isfield(obj.(f),'Ldd'); dst.(f).Ldd(tidx1,sidx1) = obj.(f).Ldd(tidx2,sidx2); end
                    if isfield(obj.(f),'resPdd'); dst.(f).resPdd(tidx1,sidx1) = obj.(f).resPdd(tidx2,sidx2); end
                    if isfield(obj.(f),'resLdd'); dst.(f).resLdd(tidx1,sidx1) = obj.(f).resLdd(tidx2,sidx2); end
                end
            end
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