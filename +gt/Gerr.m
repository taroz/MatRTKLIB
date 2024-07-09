classdef Gerr < handle
    % Gerr: GNSS position/velocity/acceleration error class
    % ---------------------------------------------------------------------
    % Gerr Declaration:
    % gerr = Gerr();  Create empty gt.Gerr object
    %
    % gerr = Gerr('errtype', err, 'coordtype', [orgpos], ['orgtype']);
    %                              Create gt.Gerr object from error vector
    %   errtype  : 1x1, Error type: 'position' or 'velocity' or 'acceleration'
    %   err      : Mx3, position/velocity/acceleration error vector
    %   coordtype: 1x1, Coordinate type: 'xyz' or 'enu'
    %  [orgpos]  : 1x3, Coordinate origin position vector
    %                [latitude(deg), longitude(deg), ellipsoidal height(m)] or
    %                [ECEF x(m), ECEF y(m), ECEF z(m)]
    %  [orgtype] : 1x1, Coordinate type: 'llh' or 'xyz'
    % ---------------------------------------------------------------------
    % Gerr Properties:
    %   type    : 'position' or 'velocity' or 'acceleration'
    %   n       : 1x1, Number of epochs
    %   xyz     : (obj.n)x3, ECEF position/velocity/acceleration error
    %   enu     : (obj.n)x3, Local ENU position/velocity/acceleration error
    %   orgllh  : 1x3, Coordinate origin (deg, deg, m)
    %   orgxyz  : 1x3, Coordinate origin in ECEF (m, m, m)
    %   d2      : (obj.n)x1, Horizontal (2D) error
    %   d3      : (obj.n)x1, 3D error
    % ---------------------------------------------------------------------
    % Gerr Methods:
    %   setErr(err, type);            Set error
    %   setOrg(pos, postype);         Set coordinate origin
    %   setOrgGpos(gpos);             Set coordinate origin by gt.Gpos
    %   insert(idx, gerr);            Insert gt.Gerr object
    %   append(gerr);                 Append gt.Gerr object
    %   addOffset(offset, [coordtype]); Add offset to error
    %   gerr = copy();                Copy object
    %   gerr = select([idx]);         Select time from index
    %   [gerr, gcov] = mean([idx]);   Compute mean error and covariance
    %   [mxyz, sdxyz] = meanXYZ([idx]); Compute mean and standard deviation of ECEF error
    %   [menu, sdenu] = meanENU([idx]); Compute mean and standard deviation of ENU error
    %   [m2d, sd2d] = mean2D([idx]);  Compute mean and standard deviation of 2D error
    %   [m3d, sd3d] = mean3D([idx]);  Compute mean and standard deviation of 3D error
    %   rxyz = rmsXYZ([idx]);         Compute root mean square of ECEF error
    %   renu = rmsENU([idx]);         Compute root mean square of ENU error
    %   r2d = rms2D([idx]);           Compute root mean square of 2D error
    %   r3d = rms3D([idx]);           Compute root mean square of 3D error
    %   p2d = ptile2D([p],[idx]);     Compute the specified percentiles of 2D error
    %   p3d = ptile3D([p],[idx]);     Compute the specified percentiles of 3D error
    %   cep = cep([idx]);             Compute the Circular Error Probable
    %   sep = sep([idx]);             Compute the Spherical Error Probable
    %   x = x([idx]);                 Get X-component of ECEF error
    %   y = y([idx]);                 Get Y-component of ECEF error
    %   z = z([idx]);                 Get Z-component of ECEF error
    %   east = east([idx]);           Get East-component of ENU error
    %   north = north([idx]);         Get North-component of ENU error
    %   up = up([idx]);               Get Up-component of ENU error
    %   plot([idx]);                  Plot horizontal and vertical error
    %   plotENU([idx]);               Plot ENU error
    %   plotXYZ([idx]);               Plot ECEF error
    %   plot2D([idx]);                Plot 2D error
    %   plot3D([idx]);                Plot 3D error
    %   plotCDF2D([idx]);             Plot Cumulative Distribution Function of 2D error
    %   plotCDF3D([idx]);             Plot Cumulative Distribution Function of 3D error
    %   help();                       Show help
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki
    %
    properties
        type   % 'position' or 'velocity' or 'acceleration'
        n      % Number of epochs
        xyz    % ECEF position/velocity/acceleration error
        enu    % Local ENU position/velocity/acceleration error
        orgllh % Coordinate origin (deg, deg, m)
        orgxyz % Coordinate origin in ECEF (m, m, m)
        d2     % 2D (horizontal) error
        d3     % 3D error
    end
    properties (Access = private)
        unit   % unit of error
    end
    methods
        %% constructor
        function obj = Gerr(varargin)            
            if nargin==0 % generate empty object
                obj.n = 0;
            elseif nargin>1
                obj.type = varargin{1};
                switch varargin{1}
                    case 'position'
                        obj.unit = '(m)';
                    case 'velocity'
                        obj.unit = '(m/s)';
                    case 'acceleration'
                        obj.unit = '(m/s^2)';
                    otherwise
                        error('errtype must be position or velocity or acceleration');
                end
            end
            if nargin>=3; obj.setErr(varargin{2}, varargin{3}); end
            if nargin==5; obj.setOrg(varargin{4}, varargin{5}); end
        end
        %% setErr
        function setErr(obj, err, coordtype)
            % setErr: Set error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setErr(err, coordtype)
            %
            % Input: ------------------------------------------------------
            %   err       : Mx3, position/velocity/acceleration error vector
            %   coordtype : 1x1, Coordinate type: 'xyz' or 'enu'
            %
            arguments
                obj gt.Gerr
                err (:,3) double
                coordtype (1,:) char {mustBeMember(coordtype,{'xyz','enu'})}
            end
            obj.n = size(err,1);
            switch coordtype
                case 'xyz'
                    obj.xyz = err;
                    if ~isempty(obj.orgllh); obj.enu = rtklib.ecef2enu(obj.xyz, obj.orgllh); end
                case 'enu'
                    obj.enu = err;
                    if ~isempty(obj.orgllh); obj.xyz = rtklib.enu2ecef(obj.enu, obj.orgllh); end
            end
            if ~isempty(obj.enu)
                obj.d2 = vecnorm(obj.enu(:,1:2), 2, 2);
                obj.d3 = vecnorm(obj.enu, 2, 2);
            else
                obj.d3 = vecnorm(obj.xyz, 2, 2);
            end
        end
        %% setOrg
        function setOrg(obj, org, orgtype)
            % setOrg: Set coordinate origin
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setOrg(org, orgtype)
            %
            % Input: ------------------------------------------------------
            %   org     : 1x3, Coordinate origin position
            %   orgtype : 1x1, Coordinate type: 'llh' or 'xyz'
            %
            arguments
                obj gt.Gerr
                org (1,3) double
                orgtype (1,:) char {mustBeMember(orgtype,{'llh','xyz'})}
            end
            switch orgtype
                case 'llh'
                    obj.orgllh = org;
                    obj.orgxyz = rtklib.llh2xyz(org);
                case 'xyz'
                    obj.orgxyz = org;
                    obj.orgllh = rtklib.xyz2llh(org);
            end
            if ~isempty(obj.xyz)
                obj.enu = rtklib.ecef2enu(obj.xyz, obj.orgllh);
            elseif ~isempty(obj.enu)
                obj.xyz = rtklib.enu2ecef(obj.enu, obj.orgllh);
            end
            obj.d2 = vecnorm(obj.enu(:,1:2), 2, 2);
            obj.d3 = vecnorm(obj.enu, 2, 2);
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
                obj gt.Gerr
                gpos gt.Gpos
            end
            if isempty(gpos.llh)
                error("gpos.llh is empty");
            end
            obj.setOrg(gpos.llh(1,:),"llh");
        end
        %% insert
        function insert(obj, idx, gerr)
            % insert: Insert gt.Gerr object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.insert(idx, gerr)
            %
            % Input: ------------------------------------------------------
            %   idx : 1x1, Integer index to insert
            %   gvel: 1x1, gt.Gerr object
            %
            arguments
                obj gt.Gvel
                idx (1,1) {mustBeInteger}
                gerr gt.Gcov
            end
            if idx<=0 || idx>obj.n
                error('Index is out of range');
            end
            if ~isempty(obj.xyz) && ~isempty(gerr.xyz)
                obj.setErr(obj.insertdata(obj.xyz, idx, gerr.xyz), 'xyz');
            else
                obj.setErr(obj.insertdata(obj.enu, idx, gerr.enu), 'enu');
            end
        end
        %% append
        function append(obj, gerr)
            % append: Append gt.Gerr object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.append(gerr)
            %
            % Input: ------------------------------------------------------
            %   gerr : 1x1, gt.Gerr object
            %
            arguments
                obj gt.Gerr
                gerr gt.Gerr
            end
            if strcmp(obj.type, gerr.type)
                if ~isempty(obj.xyz)
                    obj.setErr([obj.xyz; gerr.xyz], 'xyz');
                else
                    obj.setErr([obj.enu; gerr.enu], 'enu');
                end
            else
                error('error type must be equal');
            end
        end
        %% addOffset
        function addOffset(obj, offset, coordtype)
            % addOffset: Add offset to error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.addOffset(offset, coordtype)
            %
            % Input: ------------------------------------------------------
            %   offset    : Mx3 or 1x3, Position offset
            %  [coordtype]: 1x1, Coordinate type 'enu' or 'xyz' (optional)
            %               Default 'enu'
            %
            arguments
                obj gt.Gerr
                offset (:,3) double
                coordtype (1,:) char {mustBeMember(coordtype,{'enu','xyz'})} = 'enu'
            end
            if size(offset,1)~=obj.n || size(offset,1)~=1
                error("Size of offset must be obj.n or 1");
            end
            switch coordtype
                case 'enu'
                    if isempty(obj.enu)
                        error('enu must be set to a value');
                    end
                    obj.setErr(obj.enu+offset, 'enu');
                case 'xyz'
                    if isempty(obj.xyz)
                        error('xyz must be set to a value');
                    end
                    obj.setErr(obj.xyz+offset, 'xyz');
            end
        end
        %% copy
        function gerr = copy(obj)
            % copy: Copy object
            % -------------------------------------------------------------
            % MATLAB handle class is used, so if you want to create a
            % different instance, you need to use the copy method.
            %
            % Usage: ------------------------------------------------------
            %   gerr = obj.copy()
            %
            % Output: -----------------------------------------------------
            %   gerr : 1x1, Copied gt.Gerr object
            %
            arguments
                obj gt.Gerr
            end
            gerr = obj.select(1:obj.n);
        end
        %% select
        function gerr = select(obj, idx)
            % select: Select time from index
            % -------------------------------------------------------------
            % Select error from the index and return a new object.
            % The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   gerr = obj.select([idx])
            %
            % Input: ------------------------------------------------------
            %   idx : Logical or numeric index to select
            %
            % Output: -----------------------------------------------------
            %   gerr: 1x1, Selected object
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector}
            end
            if ~any(idx)
                error('Selected index is empty');
            end
            if ~isempty(obj.xyz)
                gerr = gt.Gerr(obj.type, obj.xyz(idx,:), 'xyz');
            else
                gerr = gt.Gerr(obj.type, obj.enu(idx,:), 'enu');
            end
            if ~isempty(obj.orgllh); gerr.setOrg(obj.orgllh, 'llh'); end
        end
        %% mean
        function [gerr, gcov] = mean(obj, idx)
            % mean: Compute mean error and covariance
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %  [gerr, gcov] = obj.mean([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   gerr: 1x1, gt.Gerr object with mean error
            %   gcov: 1x1, gt.Gcov object
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if ~isempty(obj.enu)
                menu = obj.meanENU(idx);
                gerr = gt.Gerr(menu, 'enu');
            else
                mxyz = obj.meanXYZ(idx);
                gerr = gt.Gerr(mxyz, 'xyz');
            end
            if ~isempty(obj.orgllh)
                gerr.setOrg(obj.orgllh,'llh');
            end
            gcov = gt.Gcov(obj);
        end
        %% meanXYZ
        function [mxyz, sdxyz] = meanXYZ(obj, idx)
            % meanXYZ: Compute mean and standard deviation of ECEF error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %  [mxyz, sdxyz] = obj.meanXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   mxyz  : 1x3, Mean of ECEF error
            %   sdxyz : 1x3, Standard deviation of ECEF error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            mxyz = mean(obj.xyz(idx,:), 1, 'omitnan');
            sdxyz = std(obj.xyz(idx,:), 0, 1, 'omitnan');
        end
        %% meanENU
        function [menu, sdenu] = meanENU(obj, idx)
            % meanENU: Compute mean and standard deviation of ENU error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [menu, sdenu] = obj.meanENU([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   menu  : 1x3, Mean of ENU error
            %   sdenu : 1x3, Standard deviation of ENU error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            menu = mean(obj.enu(idx,:), 1, 'omitnan');
            sdenu = std(obj.enu(idx,:), 0, 1, 'omitnan');
        end
        %% mean2D
        function [m2d, sd2d] = mean2D(obj, idx)
            % mean2D: Compute mean and standard deviation of 2D error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [m2d, sd2d] = obj.mean2D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   m2d  : 1x1, Mean of 2D (horizontal) error
            %   sd2d : 1x1, Standard deviation of 2D error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.d2)
                error('enu must be set to a value');
            end
            m2d = mean(obj.d2(idx), 1, 'omitnan');
            sd2d = std(obj.d2(idx), 0, 1, 'omitnan');
        end
        %% mean3D
        function [m3d, sd3d] = mean3D(obj, idx)
            % mean3D: Compute mean and standard deviation of 3D error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [m3d, sd3d] = obj.mean3D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   m3d  : 1x1, Mean of 3D error
            %   sd3d : 1x1, Standard deviation of 3D error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            m3d = mean(obj.d3(idx), 1, 'omitnan');
            sd3d = std(obj.d3(idx), 0, 1, 'omitnan');
        end
        %% rmsXYZ
        function rxyz = rmsXYZ(obj, idx)
            % rmsXYZ: Compute root mean square of ECEF error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   rxyz = obj.rmsXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   rxyz : RMS of ECEF error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            rxyz = rms(obj.xyz(idx,:), 1, 'omitnan');
        end
        %% rmsENU
        function renu = rmsENU(obj, idx)
            % rmsENU: Compute root mean square of ENU error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   renu = obj.rmsENU([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   renu :  RMS of ENU error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            renu = rms(obj.enu(idx,:), 1, 'omitnan');
        end
        %% rms2D
        function r2d = rms2D(obj, idx)
            % rms2D: Compute root mean square of 2D error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   r2d = obj.rms2D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   r2d :  RMS of 2D error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.d2)
                error('enu must be set to a value');
            end
            r2d = rms(obj.d2(idx), 1, 'omitnan');
        end
        %% rms3D
        function r3d = rms3D(obj, idx)
            % rms3D: Compute root mean square of 3D error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   r3d = obj.rms3D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   r3d :   RMS of 3D error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            r3d = rms(obj.d3(idx), 1, 'omitnan');
        end
        %% ptile2D
        function p2d = ptile2D(obj, p, idx)
            % ptile2D: Compute specified percentiles of 2D error
            % -------------------------------------------------------------
            % If error contains NaN, NaN is also counted in percentile error.
            % If you want to calculate the percentile error excluding NaN, 
            % input the index excluding NaN into the function.
            %
            % Usage: ------------------------------------------------------
            %   p2d = obj.ptile2D([p], [idx])
            %
            % Input: ------------------------------------------------------
            %  [p]  : Array of percentiles to calculate (%) (optional)
            %         Default: p = 95
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   p2d : Computed percentiles of 2D error
            %
            arguments
                obj gt.Gerr
                p (1,:) double {mustBeVector} = 95
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.d2)
                error('enu must be set to a value');
            end
            d2_ = obj.d2(idx);
            d2_(isnan(d2_)) = Inf;
            p2d = prctile(d2_, p, 1);
            p2d(p2d==Inf) = NaN;
        end
        %% ptile3D
        function p3d = ptile3D(obj, p, idx)
            % ptile3D: Compute specified percentiles of 3D error
            % -------------------------------------------------------------
            % If error contains NaN, NaN is also counted in percentile error.
            % If you want to calculate the percentile error excluding NaN, 
            % input the index excluding NaN into the function.
            %
            % Usage: ------------------------------------------------------
            %   p3d = obj.ptile3D([p], [idx])
            %
            % Input: ------------------------------------------------------
            %  [p]  : Array of percentiles to calculate (%) (optional)
            %         Default: p = 95
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   p3d : Computed percentiles of the 3D error
            %
            arguments
                obj gt.Gerr
                p (1,:) double {mustBeVector} = 95
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            d3_ = obj.d3(idx);
            d3_(isnan(d3_)) = Inf;
            p3d = prctile(d3_, p, 1);
            p3d(p3d==Inf) = NaN;
        end
        %% cep
        function cep = cep(obj, idx)
            % cep: Compute the Circular Error Probable
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   cep = obj.cep([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   cep : Circular Error Probable
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            cep = obj.ptile2D(obj.d2(idx), 50);
        end
        %% sep
        function sep = sep(obj, idx)
            % sep: Compute the Spherical Error Probable
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   sep = obj.sep([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   sep :  Spherical Error Probable
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            sep = obj.ptile3D(obj.d3(idx), 50);
        end
        %% x
        function x = x(obj, idx)
            % x: Get X-component of ECEF error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   x = obj.x([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   x :  X-component of ECEF error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            x = obj.xyz(idx,1);
        end
        %% y
        function y = y(obj, idx)
            % y: Get Y-component of ECEF error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   y = obj.y([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   y : Y-component of ECEF error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            y = obj.xyz(idx,2);
        end
        %% z
        function z = z(obj, idx)
            % z: Get Z-component of ECEF error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   z = obj.z([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   z :  Z-component of ECEF error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            z = obj.xyz(idx,3);
        end
        %% east
        function east = east(obj, idx)
            % east: Get East-component of ENU error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   east = obj.east([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   east : East-component of ENU error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            east = obj.enu(idx,1);
        end
        %% north
        function north = north(obj, idx)
            % north: Get North-component of ENU error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   north = obj.north([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   north : North-component of ENU error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            north = obj.enu(idx,2);
        end
        %% up
        function up = up(obj, idx)
            % up: Get Up-component of ENU error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   up = obj.up([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   up :  Up-component of ENU error
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            up = obj.enu(idx,3);
        end
        %% plot
        function plot(obj, idx)
            % plot: Plot horizontal and vertical error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            figure;
            tiledlayout(3,1,'TileSpacing','Compact');
            nexttile(1, [2 1]);
            plot(obj.enu(idx,1), obj.enu(idx,2), '.-');
            xlabel(['East ' obj.type ' error ' obj.unit]);
            ylabel(['North ' obj.type ' error ' obj.unit]);
            grid on; axis equal;
            nexttile;
            plot(obj.enu(idx,3),'.-');
            grid on;
            ylabel('Up (m)');
            drawnow
        end
        %% plotENU
        function plotENU(obj, idx)
            % plotENU: Plot ENU error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotENU([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            figure;
            plot(obj.enu(idx, 1), '.-');
            grid on; hold on;
            plot(obj.enu(idx, 2), '.-');
            plot(obj.enu(idx, 3), '.-');
            legend({['East ' obj.type ' error ' obj.unit],...
                ['North ' obj.type ' error ' obj.unit],...
                ['Up ' obj.type ' error ' obj.unit]});
            drawnow
        end
        %% plotXYZ
        function plotXYZ(obj, idx)
            % plotXYZ: Plot ECEF error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('enu must be set to a value');
            end
            figure;
            plot(obj.xyz(idx, 1), '.-');
            grid on; hold on;
            plot(obj.xyz(idx, 2), '.-');
            plot(obj.xyz(idx, 3), '.-');
            legend({['X ' obj.type ' error ' obj.unit],...
                ['Y ' obj.type ' error ' obj.unit],...
                ['Z ' obj.type ' error ' obj.unit]});
            drawnow
        end
        %% plot2D
        function plot2D(obj, idx)
            % plot2D: Plot 2D error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot2D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.d2)
                error('enu must be set to a value');
            end
            figure;
            plot(obj.d2(idx), '.-');
            ylabel(['Horizontal ' obj.type ' error ' obj.unit]);
            grid on;
            drawnow
        end
        %% plot3D
        function plot3D(obj, idx)
            % plot3D: Plot 3D error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot3D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            figure;
            plot(obj.d3(idx), '.-');
            ylabel(['3D ' obj.type ' error ' obj.unit]);
            grid on;
            drawnow
        end
        %% plotCDF2D
        function plotCDF2D(obj, idx)
            % plotCDF2D: Plot Cumulative Distribution Function of 2D error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotCDF2D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.d2)
                error('enu must be set to a value');
            end
            y = 0:100;
            x = obj.ptile2D(y,idx);

            figure;
            plot(x,y,'-');
            grid on;
            xlabel(['Horizontal ' obj.type ' error ' obj.unit]);
            ylabel('Probability (%)');
            drawnow
        end
        %% plotCDF3D
        function plotCDF3D(obj, idx)
            % plotCDF3D: Plot Cumulative Distribution Function of 3D error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotCDF3D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            y = 0:100;
            x = obj.ptile3D(y,idx);

            figure;
            plot(x,y,'-');
            grid on;
            xlabel(['3D ' obj.type ' error ' obj.unit]);
            ylabel('Probability (%)');
            drawnow
        end
        %% help
        function help(~)
            % help: Show help
            doc gt.Gcov
        end
    end
    %% Private functions
    methods(Access=private)
        %% Insert data
        function c = insertdata(~,a,idx,b)
            c = [a(1:size(a,1)<idx,:); b; a(1:size(a,1)>=idx,:)];
        end
    end
end