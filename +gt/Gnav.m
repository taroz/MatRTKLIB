classdef Gnav < handle
    % Gnav: GNSS RINEX navigation data class
    %
    % Gnav Declaration:
    % obj = Gnav(file)
    %   file      : 1x1, RINEX navigation file
    %               (wind-card * can be used to extract all navigation files)
    %
    % obj = Gnav(navstr)
    %   navstr    : 1x1, RTKLIB navigation struct
    %
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
    %
    % Gnav Methods:
    %   setNavFile(file):
    %   setNavStruct(navstr):
    %   readSP3(file):
    %   readCLK(file):
    %   readERP(file):
    %   readSatPCV(file, time):
    %   readDCB(file):
    %   navstr = struct():
    %   getTGD(sat):
    %   help()
    %
    %     Author: Taro Suzuki

    properties
        eph, geph, peph, pclk, erp, pcv, dcb, utc, ion;
    end
    methods
        %% constractor
        function obj = Gnav(varargin)
            if nargin==1 && (ischar(varargin{1}) || isStringScalar(varargin{1}))
                obj.setNavFile(char(varargin{1})); % file
            elseif nargin==1 && isstruct(varargin{1})
                obj.setNavStruct(varargin{1}); % nav struct
            else
                error('Wrong input arguments');
            end
        end

        %% set navigation data from RINEX file
        function setNavFile(obj, file)
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            paths = rtklib.expath(file);
            for path = paths
                try
                    if ~exist('navstr','var')
                        navstr = rtklib.readrnxnav(path{:});
                    else
                        navstr = rtklib.readrnxnav(path{:}, navstr);
                    end
                catch
                end
            end

            obj.setNavStruct(navstr);
        end
        %% set navigation data from navigation struct
        function setNavStruct(obj, navstr)
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
        end

        %% read precise ephemeris
        function readSP3(obj, file)
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            navstr = rtklib.readsp3(file, obj.struct());
            obj.setNavStruct(navstr);
        end

        %% read precise clock
        function readCLK(obj, file)
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            navstr = rtklib.readrnxc(file, obj.struct());
            obj.setNavStruct(navstr);
        end

        %% read earth rotation parameter
        function readERP(obj, file)
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            obj.erp = rtklib.readerp(file);
        end

        %% read satellite antenna PCV
        function readSatPCV(obj, file, time)
            arguments
                obj gt.Gnav
                file (1,:) char
                time gt.Gtime
            end
            navstr = rtklib.readsap(file, time.ep(1,:), obj.struct());
            obj.setNavStruct(navstr);
        end

        %% set satellite DCB
        function readDCB(obj, file)
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            navstr = rtklib.readdcb(file, obj.struct());
            obj.setNavStruct(navstr);
        end

        %% output observation file
        function outNav(obj, file)
            arguments
                obj gt.Gnav
                file (1,:) char
            end
            navstr = obj.struct();
            rtklib.outrnxnav(file, navstr);
        end

        %% convert to struct
        function navstr = struct(obj)
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
            doc gt.Gnav
        end
    end
end