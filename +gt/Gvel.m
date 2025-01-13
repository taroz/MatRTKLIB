classdef Gvel < handle
    % Gvel: GNSS velocity class
    % ---------------------------------------------------------------------
    % Gvel Declaration:
    % gvel = Gvel();  Create empty gt.Gvel object
    %
    % gvel = Gvel(vel, 'type', [orgpos], ['orgtype']);
    %                            Create gt.Gerr object from velocity vector
    %   vel     : Mx3, Velocity vector
    %               [ECEF x(m/s), ECEF y(m/s), ECEF z(m/s)] or
    %               [east(m/s), north(m/s), up(m/s)]
    %   veltype : Coordinate type: 'xyz' or 'enu'
    %  [orgpos] : 1x3, Coordinate origin position vector
    %               [latitude(deg), longitude(deg), ellipsoidal height(m)] or
    %               [ECEF x(m), ECEF y(m), ECEF z(m)]
    %  [orgtype]: 1x1, Coordinate type: 'llh' or 'xyz'
    % ---------------------------------------------------------------------
    % Gvel Properties:
    %   n       : 1x1, Number of epochs
    %   xyz     :(obj.n)x3, ECEF velocity (m/s, m/s, m/s)
    %   enu     :(obj.n)x3, Local ENU velocity (m/s, m/s, m/s)
    %   orgllh  : 1x3, Coordinate origin (deg, deg, m)
    %   orgxyz  : 1x3, Coordinate origin in ECEF (m, m, m)
    %   v2      :(obj.n)x1, 2D (horizontal) velocity (m/s)
    %   v3      :(obj.n)x1, 3D velocity (m/s)
    % ---------------------------------------------------------------------
    % Gvel Methods:
    %   setVel(vel, veltype);        Set velocity
    %   setOrg(pos, postype);        Set coordinate origin
    %   setOrgGpos(gpos);            Set coordinate origin by gt.Gpos
    %   insert(idx, gvel);           Insert gt.Gvel object
    %   append(gvel);                Append gt.Gvel object
    %   addOffset(offset, [coordtype]); Add offset to velocity data
    %   gerr = difference(gvel);     Compute difference between two gt.Gvel objects
    %   gpos = integral(dt, [idx]);  Cumulative integral
    %   gvel = copy();               Copy object
    %   gvel = select([idx]);        Select velocity from index
    %   gvel = interp(x, xi, [method]); Interpolating velocity
    %   [gvel, gcov] = mean([idx]):  Compute mean and variance of velocity
    %   [mxyz, sdxyz] = meanXYZ([idx]); Compute mean and standard deviation of ECEF velocity
    %   [menu, sdenu] = meanENU([idx]); Compute mean and standard deviation of ENU velocity
    %   [m2d, sd2d] = mean2D([idx]); Compute mean and standard deviation of 2D velocity
    %   [m3d, sd3d] = mean3D([idx]); Compute mean and standard deviation of 3D velocity
    %   x = x([idx]);                Get X-component of ECEF velocity
    %   y = y([idx]);                Get Y-component of ECEF velocity
    %   z = z([idx]);                Get Z-component of ECEF velocity
    %   east = east([idx]);          Get East-component of ENU velocity
    %   north = north([idx]);        Get North-component of ENU velocity
    %   up = up([idx]);              Get Up-component of ENU velocity
    %   plot([idx]);                 Plot ENU velocity
    %   plotXYZ([idx]);              Plot ECEF velocity
    %   plot2D([idx]);               Plot 2D velocity
    %   plot3D([idx]);               Plot 3D velocity
    %   help();                      Show help
    % ---------------------------------------------------------------------
    % Gvel Overloads:
    %   gerr = obj - gvel;           Compute difference between two gt.Gvel objects
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki
    %
    properties
        n      % Number of epochs
        xyz    % ECEF velocity (m/s, m/s, m/s)
        enu    % Local ENU velocity (m/s, m/s, m/s)
        orgllh % Coordinate origin (deg, deg, m)
        orgxyz % Coordinate origin in ECEF (m, m, m)
        v2     % 2D (horizontal) velocity (m/s)
        v3     % 3D velocity (m/s)
    end
    methods
        %% constructor
        function obj = Gvel(varargin)
            if nargin==0; obj.n = 0; end % generate empty object
            if nargin>=2; obj.setVel(varargin{1}, varargin{2}); end
            if nargin==4; obj.setOrg(varargin{3}, varargin{4}); end
        end
        %% setVel
        function setVel(obj, vel, veltype)
            % setVel: Set velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setVel(vel, veltype)
            %
            % Input: ------------------------------------------------------
            %   vel    : Mx3, Velocity vector
            %   veltype: 1x1, Coordinate type: 'xyz' or 'enu'
            %
            arguments
                obj gt.Gvel
                vel (:,3) double
                veltype (1,:) char {mustBeMember(veltype,{'xyz','enu'})}
            end
            obj.n = size(vel,1);
            switch veltype
                case 'xyz'
                    obj.xyz = vel;
                    if ~isempty(obj.orgllh); obj.enu = rtklib.ecef2enu(obj.xyz, obj.orgllh); end
                case 'enu'
                    obj.enu = vel;
                    if ~isempty(obj.orgllh); obj.xyz = rtklib.enu2ecef(obj.enu, obj.orgllh); end
            end
            if ~isempty(obj.enu)
                obj.v2 = vecnorm(obj.enu(:,1:2), 2, 2);
                obj.v3 = vecnorm(obj.enu, 2, 2);
            else
                obj.v3 = vecnorm(obj.xyz, 2, 2);
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
            %   org    : 1x3, Coordinate origin
            %   orgtype: 1x1, Coordinate type: 'llh' or 'xyz'
            %
            arguments
                obj gt.Gvel
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
            obj.v2 = vecnorm(obj.enu(:,1:2), 2, 2);
            obj.v3 = vecnorm(obj.enu, 2, 2);
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
                obj gt.Gvel
                gpos gt.Gpos
            end
            if isempty(gpos.llh)
                error("gpos.llh is empty");
            end
            obj.setOrg(gpos.llh(1,:),"llh");
        end
        %% insert
        function insert(obj, idx, gvel)
            % insert: Insert gt.Gvel object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.insert(idx, gvel)
            %
            % Input: ------------------------------------------------------
            %   idx : 1x1, Integer index to insert
            %   gvel: 1x1, gt.Gvel object
            %
            arguments
                obj gt.Gvel
                idx (1,1) {mustBeInteger}
                gvel gt.Gvel
            end
            if idx<=0 || idx>obj.n
                error('Index is out of range');
            end
            if ~isempty(obj.xyz) && ~isempty(gvel.xyz)
                obj.setVel(obj.insertdata(obj.xyz, idx, gvel.xyz), 'xyz');
            else
                obj.setVel(obj.insertdata(obj.enu, idx, gvel.enu), 'enu');
            end
        end
        %% append
        function append(obj, gvel)
            % append: Append gt.Gvel object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.append(gvel)
            %
            % Input: ------------------------------------------------------
            %   gvel: 1x1, gt.Gvel object
            %
            arguments
                obj gt.Gvel
                gvel gt.Gvel
            end
            if ~isempty(obj.xyz)
                obj.setVel([obj.xyz; gvel.xyz], 'xyz');
            else
                obj.setVel([obj.enu; gvel.enu], 'enu');
            end
        end
        %% addOffset
        function addOffset(obj, offset, coordtype)
            % addOffset: Add offset to velocity data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.addOffset(offset, [coordtype[)
            %
            % Input: ------------------------------------------------------
            %   offset    : Mx3 or 1x3, Velocity offset
            %  [coordtype]: 1x1, Coordinate type: 'xyz' or 'enu' (optional)
            %                    Default: coordtype = 'enu'
            %
            arguments
                obj gt.Gvel
                offset (:,3) double
                coordtype (1,:) char {mustBeMember(coordtype,{'enu','xyz'})} = 'enu'
            end
            if size(offset,1)~=obj.n && size(offset,1)~=1
                error("Size of offset must be obj.n or 1");
            end
            switch coordtype
                case 'enu'
                    if isempty(obj.enu)
                        error('enu must be set to a value');
                    end
                    obj.setVel(obj.enu + offset, 'enu');
                case 'xyz'
                    if isempty(obj.xyz)
                        error('xyz must be set to a value');
                    end
                    obj.setVel(obj.xyz + offset, 'xyz');
            end
        end
        %% difference
        function gerr = difference(obj, gvel)
            % difference : Compute difference between two gt.Gvel objects
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.difference(gvel)
            %
            % Input: ------------------------------------------------------
            %   gvel: 1x1, gt.Gvel object
            %
            % Output: -----------------------------------------------------
            %   gerr: 1x1, gt.Gerr object
            %
            arguments
                obj gt.Gvel
                gvel gt.Gvel
            end
            if obj.n ~= gvel.n && gvel.n ~= 1
                error('Size of gvel must be obj.n or 1')
            end
            if ~isempty(obj.xyz) && ~isempty(gvel.xyz)
                gerr = gt.Gerr('velocity', obj.xyz - gvel.xyz, 'xyz');
                if ~isempty(obj.orgllh); gerr.setOrg(obj.orgllh, 'llh'); end
            elseif ~isempty(obj.enu) && ~isempty(gvel.enu)
                gerr = gt.Gerr('velocity', obj.enu - gvel.enu, 'enu');
                if ~isempty(obj.orgllh); gerr.setOrg(obj.orgllh, 'llh'); end
            else
                error('two gt.Gvel must have both xyz or enu')
            end
        end
        %% integral
        function gpos = integral(obj, dt, idx)
            % integral: Cumulative integral
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.integral(dt, [idx])
            %
            % Input: ------------------------------------------------------
            %   dt  : 1x1, Time step (s)
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   gpos : 1x1, gt.Gpos object
            %
            arguments
                obj gt.Gvel
                dt (1,1) double
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if ~isempty(obj.xyz)
                xyz_ = cumtrapz(dt*obj.xyz(idx,:));
                gpos = gt.Gpos(xyz_, 'xyz');
            else
                enu_ = cumtrapz(dt*obj.enu(idx,:));
                gpos = gt.Gpos(enu_, 'enu');
            end
            if ~isempty(obj.orgllh); gpos.setOrg(obj.orgllh, 'llh'); end
        end
        %% copy
        function gvel = copy(obj)
            % copy: Copy object
            % -------------------------------------------------------------
            % MATLAB handle class is used, so if you want to create a
            % different object, you need to use the copy method.
            %
            % Usage: ------------------------------------------------------
            %   gvel = obj.copy()
            %
            % Output: -----------------------------------------------------
            %   gvel: 1x1, Copied gt.Gvel object
            %
            arguments
                obj gt.Gvel
            end
            gvel = obj.select(1:obj.n);
        end
        %% select
        function gvel = select(obj, idx)
            % select : Select velocity from index
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   gvel = obj.select(idx)
            %
            % Input: ------------------------------------------------------
            %  idx : Logical or numeric index to select
            %
            % Output: -----------------------------------------------------
            %   gvel : 1x1, Selected gt.Gvel object
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector}
            end
            if ~any(idx)
                error('Selected index is empty');
            end
            if ~isempty(obj.xyz)
                gvel = gt.Gvel(obj.xyz(idx,:), 'xyz');
            else
                gvel = gt.Gvel(obj.enu(idx,:), 'enu');
            end
            if ~isempty(obj.orgllh); gvel.setOrg(obj.orgllh, 'llh'); end
        end
        %% interp
        function gvel = interp(obj, x, xi, method)
            % interp: Interpolating velocity
            % -------------------------------------------------------------
            % Interpolate the velovity data at the query point and return a
            % new object.
            %
            % Usage: ------------------------------------------------------
            %   gvel = obj.interp(x, xi, [method])
            %
            % Input: ------------------------------------------------------
            %   x     : Sample points
            %   xi    : Query points
            %   method: Interpolation method (optional)
            %           Default: method = "linear"
            %
            % Output: -----------------------------------------------------
            %   gvel: 1x1, Interpolated gt.Gvel object
            %
            arguments
                obj gt.Gvel
                x {mustBeVector}
                xi {mustBeVector}
                method (1,:) char {mustBeMember(method,{'linear','spline','makima'})} = 'linear'
            end
            if length(x)~=obj.n
                error('Size of x must be obj.n');
            end
            if min(x)>min(xi) || max(x)<max(xi)
                error("Query point is out of range (extrapolation)")
            end
            if ~isempty(obj.xyz)
                gvel = gt.Gvel(interp1(x, obj.xyz, xi, method), "xyz");
            else
                gvel = gt.Gvel(interp1(x, obj.enu, xi, method), "enu");
            end
            if ~isempty(obj.orgllh); gvel.setOrg(obj.orgllh, 'llh'); end
        end
        %% mean
        function [gvel, gcov] = mean(obj, idx)
            % mean: Compute mean and variance of velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [gvel, gcov] = obj.mean([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx]: Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   gvel : 1x1, gt.Gvel object with mean velocity
            %   gcov : 1x1, gt.Gcov object
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if ~isempty(obj.enu)
                menu = obj.meanENU(idx);
                gvel = gt.Gvel(menu, 'enu');
            else
                mxyz = obj.meanXYZ(idx);
                gvel = gt.Gvel(mxyz, 'xyz');
            end
            if ~isempty(obj.orgllh)
                gvel.setOrg(obj.orgllh,'llh');
            end
            gcov = gt.Gcov(obj);
        end
        %% meanXYZ
        function [mxyz, sdxyz] = meanXYZ(obj, idx)
            % meanXYZ: Compute mean and standard deviation of ECEF velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [mxyz, sdxyz] = obj.meanXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   mxyz : Mx3, Mean of ECEF velocities (m/s)
            %   sdxyz: 1x3, Standard deviation of ECEF velocities (m/s)
            %
            arguments
                obj gt.Gvel
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
            % meanENU: Compute mean and standard deviation of ENU velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.meanENU([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   menu : Mx3, Mean of ENU velocities
            %   sdenu: 1x3, Standard deviation of ENU velocity
            %
            arguments
                obj gt.Gvel
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
            % mean2D: Compute mean and standard deviation of 2D velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.mean2D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   m2d  : Mx1, Mean of 2D (horizontal) velocities
            %   sd2d : 1x1, Standard deviation of 2D (horizontal) velocities
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.v2)
                error('enu must be set to a value');
            end
            m2d = mean(obj.v2(idx), 1, 'omitnan');
            sd2d = std(obj.v2(idx), 0, 1, 'omitnan');
        end
        %% mean3D
        function [m3d, sd3d] = mean3D(obj, idx)
            % mean3D : Compute mean and standard deviation of 3D velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.mean3D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   m3d  : Mx1, Mean of 3D velocities
            %   sd3d : 1x1, Standard deviation of 3D velocities
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            m3d = mean(obj.v3(idx), 1, 'omitnan');
            sd3d = std(obj.v3(idx), 0, 1, 'omitnan');
        end
        %% x
        function x = x(obj, idx)
            % x : Get X-component of ECEF velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.x([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   x :  Mx1, X-component of ECEF velocity
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            x = obj.xyz(idx,1);
        end
        %% y
        function y = y(obj, idx)
            % y : Get Y-component of ECEF velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.y([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   y :  Mx1, Y-component of ECEF velocity
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            y = obj.xyz(idx,2);
        end
        %% z
        function z = z(obj, idx)
            % z : Get Z-component of ECEF velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.z([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   z :  Mx1, Z-component of ECEF velocity
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            z = obj.xyz(idx,3);
        end
        %% east
        function east = east(obj, idx)
            % east : Get East-component of ENU velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.east([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   east :  Mx1, East-component of ENU velocity
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            east = obj.enu(idx,1);
        end
        %% north
        function north = north(obj, idx)
            % north : Get North-component of ENU velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.north([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   north : Mx1, North-component of ENU velocity
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            north = obj.enu(idx,2);
        end
        %% up
        function up = up(obj, idx)
            % up : Get Up-component of ENU velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.up([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   up :  Mx1, Up-component of ENU velocity
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            up = obj.enu(idx,3);
        end
        %% plot
        function plot(obj, idx)
            % plot : Plot ENU velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            figure;
            tiledlayout(3,1,'TileSpacing','Compact');
            nexttile;
            plot(obj.enu(idx, 1), '.-');
            ylabel('East (m/s)');
            grid on;
            nexttile;
            plot(obj.enu(idx, 2), '.-');
            ylabel('North (m/s)');
            grid on;
            nexttile;
            plot(obj.enu(idx, 3), '.-');
            ylabel('Up (m/s)');
            grid on;
        end
        %% plotXYZ
        function plotXYZ(obj, idx)
            % plotXYZ : Plot ECEF velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('enu must be set to a value');
            end
            figure;
            tiledlayout(3,1,'TileSpacing','Compact');
            a1 = nexttile;
            plot(obj.xyz(idx, 1), '.-');
            ylabel('X (m/s)');
            grid on;
            a2 = nexttile;
            plot(obj.xyz(idx, 2), '.-');
            ylabel('Y (m/s)');
            grid on;
            a3 = nexttile;
            plot(obj.xyz(idx, 3), '.-');
            ylabel('Z (m/s)');
            grid on;

            linkaxes([a1 a2 a3],'x');
            drawnow
        end
        %% plot2D
        function plot2D(obj, idx)
            % plot2D : Plot 2D velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot2D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.v2)
                error('enu must be set to a value');
            end
            figure;
            plot(obj.v2(idx), '.-');
            ylabel('Horizontal velocity (m/s)');
            grid on;
            drawnow
        end
        %% plot3D
        function plot3D(obj, idx)
            % plot3D : Plot 3D velocity
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot3D([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx] : Logical or numeric index to select (optional)
            %          Default: idx = 1:obj.n
            %
            arguments
                obj gt.Gvel
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            figure;
            plot(obj.v3(idx), '.-');
            ylabel('3D velocity (m/s)');
            grid on;
            drawnow
        end
        %% help
        function help(~)
            % help: Show help
            doc gt.Gvel
        end
        %% overload
        function gerr = minus(obj, gvel)
            % minus: Subtract two Gvel objects
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj-gvel
            %
            % Input: ------------------------------------------------------
            %   gvel : gt.Gvel object
            %
            % Output: -----------------------------------------------------
            %   gerr : gt.Gerr object
            %
            gerr = obj.difference(gvel);
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