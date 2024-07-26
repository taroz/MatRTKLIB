classdef Gnav < handle
    % Gnav: GNSS RINEX navigation data class
    % ---------------------------------------------------------------------
    % Gnav Declaration:
    % gnav = Gnav(file);  Create gt.Gnav object from RINEX
    %   file      : 1x1, RINEX navigation file
    %               (wind-card * can be used to extract all navigation files)
    %
    % gnav = Gnav(navstr);  Create gt.Gnav object from navigation struct
    %   navstr    : 1x1, RTKLIB navigation struct
    % ---------------------------------------------------------------------
    % Gnav Properties:
    %   eph       : Nx1, GPS/QZS/GAL/BDS/IRN ephemeris struct array:
    %   geph      : NGx1, GLONASS ephemeris struct array
    %   peph      : NEx1, Precise ephemeris struct array (from .sp3 file)
    %   pclk      : NCx1, Precise clock struct array (from .clk file)
    %   erp       : 1x1, Earth rotation parameter struct (from .erp file)
    %   pcv       : (MAXSAT)x1, Satellite antenna PCV struct array (from .erp file)
    %   dcb       : (MAXSAT)x3, satellite DCB (0:P1-P2, 1:P1-C1, 2:P2-C2) (m)
    %   utc       : 1x1, UTC time parameters
    %     .???    : 1x8 or 1x9 or 1x8, ??? = gps or glo or gal or qzs or cmp irn or sbs
    %   ion       : 1x8 or 1x4, ionosphere model parameter
    %     .???    : ??? = gps or gal or qzs or cmp or irn
    % ---------------------------------------------------------------------
    % Gnav Methods:
    %   setNavFile(file);        Set navigation data from RINEX file
    %   setNavStruct(navstr);    Set navigation data from navigation struct
    %   readSP3(file);           Read precise ephemeris
    %   readCLK(file);           Read precise RIENX clock
    %   readERP(file);           Read earth rotation parameter
    %   readSatPCV(file, gtime); Read satellite antenna PCV
    %   readDCB(file);           Read satellite antenna DCB
    %   outNav(file);            Output RINEX navigation file
    %   gnav = copy();           Copy object
    %   navstr = struct();       Convert to navigation struct
    %   [tgd, vtgd] = getTGD(sat); Get TGD value for specified satellite
    %   help();                  Show help
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki
    %
    properties
        eph  % GPS/QZS/GAL/BDS/IRN ephemeris
        geph % GLONASS ephemeris
        peph % Precise ephemeris
        pclk % Precise clock
        erp  % Earth rotation parameter
        pcv  % Satellite antenna PCV
        dcb  % satellite DCB (0:P1-P2, 1:P1-C1, 2:P2-C2) (m)
        utc  % UTC time parameters
        ion  % Ionosphere model parameter
    end
    methods
        %% constructor
        function obj = Gnav(varargin)
            if nargin==1 && (ischar(varargin{1}) || isStringScalar(varargin{1}))
                obj.setNavFile(char(varargin{1})); % file
            elseif nargin==1 && isstruct(varargin{1})
                obj.setNavStruct(varargin{1}); % nav struct
            else
                error('Wrong input arguments');
            end
        end
        %% setNavFile
        function setNavFile(obj, file)
            % setNavFile: Set navigation data from RINEX file
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setNavFile(file)
            %
            % Input: ------------------------------------------------------
            %   file : 1x1, RINEX navigation file
            %
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            paths = rtklib.expath(obj.absPath(file));
            for path = paths
                try
                    if ~exist('navstr','var')
                        navstr = rtklib.readrnxnav(obj.absPath(path{:}));
                    else
                        navstr = rtklib.readrnxnav(obj.absPath(path{:}), navstr);
                    end
                catch
                end
            end
            if ~exist('navstr','var')
                error('Wrong RINEX navigation file: %s',obj.absPath(file));
            end

            obj.setNavStruct(navstr);
        end
        %% setNavStruct
        function setNavStruct(obj, navstr)
            % setNavStruct: Set navigation data from navigation struct
            % -------------------------------------------------------------
            % The navigation struct is the output of the RTKLIB wrapper
            % function.
            %
            % Usage: ------------------------------------------------------
            %   obj.setNavStruct(navstr)
            %
            % Input: ------------------------------------------------------
            %   navstr : 1x1, Navigation struct
            %
            arguments
                obj gt.Gnav
                navstr (1,1) struct
            end
            obj.eph = navstr.eph;
            obj.geph = navstr.geph;
            obj.peph = navstr.peph;
            obj.pclk = navstr.pclk;
            obj.erp = navstr.erp;
            obj.pcv = navstr.pcvs;
            obj.utc.gps = navstr.utc_gps;
            obj.utc.glo = navstr.utc_glo;
            obj.utc.gal = navstr.utc_gal;
            obj.utc.qzs = navstr.utc_qzs;
            obj.utc.cmp = navstr.utc_cmp;
            obj.utc.irn = navstr.utc_irn;
            obj.utc.sbs = navstr.utc_sbs;
            obj.ion.gps = navstr.ion_gps;
            obj.ion.gal = navstr.ion_gal;
            obj.ion.qzs = navstr.ion_qzs;
            obj.ion.cmp = navstr.ion_cmp;
            obj.ion.irn = navstr.ion_irn;
            obj.dcb = navstr.cbias;
            
            % eliminateDuplicated ephemeris
            obj.eliminateDuplicate();
        end
        %% readSP3
        function readSP3(obj, file)
            % readSP3: Read precise ephemeris(.SP3)
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.readSP3(file)
            %
            % Input: ------------------------------------------------------
            %   file : 1x1, Precise ephemeris(.SP3)  file
            %
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            navstr = rtklib.readsp3(obj.absPath(file), obj.struct());
            obj.setNavStruct(navstr);
        end
        %% readCLK
        function readCLK(obj, file)
            % readCLK: Read precise RINEX clock
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.readCLK(file)
            %
            % Input: ------------------------------------------------------
            %   file : 1x1, precise RINEX clock file
            %
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            navstr = rtklib.readrnxc(obj.absPath(file), obj.struct());
            obj.setNavStruct(navstr);
        end
        %% readERP
        function readERP(obj, file)
            % readERP: Read ERP (Earth Rotation Parameter)
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.readERP(file)
            %
            % Input: ------------------------------------------------------
            %   file : 1x1, ERP file
            %
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            obj.erp = rtklib.readerp(obj.absPath(file));
        end
        %% readSatPCV
        function readSatPCV(obj, file, gtime)
            % readSatPCV: Read satellite antenna PCV
            % -------------------------------------------------------------
            % Read satellite PCV (Phase Center Variation) file.
            %
            % Usage: ------------------------------------------------------
            %   obj.readSatPCV(file, gtime)
            %
            % Input: ------------------------------------------------------
            %   file  : 1x1, Satellite antenna PCV file
            %   gtime : 1x1, gt.Gtime, Observation time
            %
            arguments
                obj gt.Gnav
                file (1,:) char
                gtime gt.Gtime
            end
            navstr = rtklib.readsap(obj.absPath(file), gtime.ep(1,:), obj.struct());
            obj.setNavStruct(navstr);
        end
        %% readDCB
        function readDCB(obj, file)
            % readDCB:  Read satellite antenna DCB
            % -------------------------------------------------------------
            % Read DCB file and calculate DCB correction value.
            %
            % Usage: ------------------------------------------------------
            %   obj.readDCB(file)
            %
            % Input: ------------------------------------------------------
            %   file : 1x1, Satellite antenna DCB file name
            %
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            navstr = rtklib.readdcb(obj.absPath(file), obj.struct());
            obj.setNavStruct(navstr);
        end
        %% outNav
        function outNav(obj, file)
            % outNav: Output RINEX navigation file
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.outNav(file)
            %
            % Input: ------------------------------------------------------
            %   file : 1x1, Output RINEX navigation file name
            %
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            navstr = obj.struct();
            rtklib.outrnxnav(file, navstr);
        end
        %% copy
        function gnav = copy(obj)
            % copy: Copy object
            % -------------------------------------------------------------
            % MATLAB handle class is used, so if you want to create a
            % different instance, you need to use the copy method.
            %
            % Usage: ------------------------------------------------------
            %   gnav = obj.copy()
            %
            % Output: -----------------------------------------------------
            %   gnav : 1x1, Copied gt.Gnav object
            %
            arguments
                obj gt.Gnav
            end
            gnav = gt.Gnav(obj.struct());
        end
        %% struct
        function navstr = struct(obj)
            % struct: Convert to navigation struct
            % -------------------------------------------------------------
            % The input to the RTKLIB wrapper function must be a structure.
            %
            % Usage: ------------------------------------------------------
            %   obj.struct()
            %
            % Output: -----------------------------------------------------
            %   navstr: 1x1, Navigation struct (for interface to RTKLIB)
            %
            arguments
                obj gt.Gnav
            end
            navstr.eph = obj.eph;
            navstr.geph = obj.geph;
            navstr.peph = obj.peph;
            navstr.pclk = obj.pclk;
            navstr.erp = obj.erp;
            navstr.pcvs = obj.pcv;
            navstr.cbias = obj.dcb;
            navstr.utc_gps = obj.utc.gps;
            navstr.utc_glo = obj.utc.glo;
            navstr.utc_gal = obj.utc.gal;
            navstr.utc_qzs = obj.utc.qzs;
            navstr.utc_cmp = obj.utc.cmp;
            navstr.utc_irn = obj.utc.irn;
            navstr.utc_sbs = obj.utc.sbs;
            navstr.ion_gps = obj.ion.gps;
            navstr.ion_gal = obj.ion.gal;
            navstr.ion_qzs = obj.ion.qzs;
            navstr.ion_cmp = obj.ion.cmp;
            navstr.ion_irn = obj.ion.irn;
        end
        %% getTGD
        function [tgd, vtgd] = getTGD(obj, sat)
            % getTGD: Get TGD value for specified satellite
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [tgd, vtgd] = getTGD(sat)
            %
            % Input: ------------------------------------------------------
            %   sat : 1xN, satellite number vector
            %
            % Output: -----------------------------------------------------
            %   tgd : 1xN, TGD (Time Group Delay) value (m)
            %   vtgd: 1xN, TGD variance (constant) (m^2)
            %
            arguments
                obj gt.Gnav
                sat (1,:) {mustBeInteger, mustBeVector}
            end
            nsat = length(sat);
            sys = rtklib.satsys(sat);
            t = struct2table(obj.eph);

            % ToDo: support code type input
            tgd = zeros(1, nsat);
            for i=1:nsat
                if sys(i)==gt.C.SYS_GPS||sys(i)==gt.C.SYS_QZS||sys(i)==gt.C.SYS_GAL||sys(i)==gt.C.SYS_CMP
                    idx = find(t.sat==sat(i), 1);
                    if ~isempty(idx); tgd(i) = gt.C.CLIGHT*t.tgd(idx,1); end
                end
            end
            ERR_CBIAS = 0.3; % code bias error std (m)
            vtgd = ERR_CBIAS^2*ones(1,nsat);
        end
        %% help
        function help(~)
            % help: Show help
            doc gt.Gnav
        end
    end
    %% Private functions
    methods(Access=private)
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
        %% Eliminate duplicated ephemeris
        function eliminateDuplicate(obj)
            % GPS
            teph = struct2table(obj.eph);
            uniquesat = unique(teph.sat);
            idxeliminate = [];
            for i=1:length(uniquesat)
                sys = rtklib.satsys(uniquesat(i));
                % GPS
                if sys==gt.C.SYS_GPS
                    idx = find(teph.sat==uniquesat(i));
                    tephsat = teph(idx,:);
                    [~,idxsort] = sortrows(tephsat,"ttr");
                    toc = gt.Gtime(tephsat.toc(idxsort,:));
                    idxduplicate = abs(diff(toc.t))<seconds(60);
                    idxeliminate = [idxeliminate; idx(idxsort(idxduplicate))];
                end
                % ToDo: check other systems
            end
            obj.eph(idxeliminate) = [];
        end
    end
end