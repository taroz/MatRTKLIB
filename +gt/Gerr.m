classdef Gerr < handle
    % Gerr: GNSS position/velocity/acceleration error class
    %
    % Gerr Declaration:
    % obj = Gerr('errtype', err, 'coordtype', [orgpos], ['orgtype'])
    %   errtype  : Error type: 'position' or 'velocity' or 'acceleration'
    %   err      : Nx3, position/velocity/acceleration error vector
    %   coordtype: Coordinate type: 'xyz' or 'enu'
    %   [orgpos] : 1x3, Coordinate origin position vector
    %                [latitude(deg), longitude(deg), ellipsoidal height(m)] or
    %                [ECEF x(m), ECEF y(m), ECEF z(m)]
    %   [orgtype]: 1x1, Coordinate type: 'llh' or 'xyz'
    %
    % Gerr Properties:
    %   type    : 'position' or 'velocity' or 'acceleration'
    %   n       : 1x1, Number of epochs
    %   xyz     : (obj.n)x3, ECEF position/velocity/acceleration error
    %   enu     : (obj.n)x3, Local ENU position/velocity/acceleration error
    %   orgllh  : 1x3, Coordinate origin (deg, deg, m)
    %   orgxyz  : 1x3, Coordinate origin in ECEF (m, m, m)
    %   d2      : (obj.n)x1, Horizontal (2D) error
    %   d3      : (obj.n)x1, 3D error
    %
    % Gerr Methods:
    %   setErr(err, type):Set error
    %   setOrg(pos, postype):Set coordinate orgin
    %   append(gerr):Append another Gerr object to the current object
    %   addOffset(offset, [coordtype]):Add an offset to the ENU or XYZ data
    %   gerr = select([idx]): Select time from index
    %   [mxyz, sdxyz] = meanXYZ([idx]): Calculate mean and standard deviation of XYZ data
    %   [menu, sdenu] = meanENU([idx]):Calculate mean and standard deviation of ENU data
    %   [m2d, sd2d] = mean2D([idx]):Calculate mean and standard deviation of 2D data
    %   [m3d, sd3d] = mean3D([idx]):Calculate mean and standard deviation of 3D data
    %   rxyz = rmsXYZ([idx]):Calculate root mean square of XYZ data
    %   renu = rmsENU([idx]):Calculate root mean square of ENU data
    %   r2d = rms2D([idx]):Calculate root mean square of 2D data
    %   r3d = rms3D([idx]):Calculate root mean square of 3D data
    %   p2d = ptile2D([p],[idx]):Calculates the specified percentiles of the 2D error data
    %   p3d = ptile3D([p],[idx]):Calculates the specified percentiles of the 3D error data
    %   cep = cep([idx]):Calculates the Circular Error Probable
    %   sep = sep([idx]):Calculates the Spherical Error Probable
    %   x = x([idx]):Accesses the x-component of the XYZ data
    %   y = y([idx]):Accesses the y-component of the XYZ data
    %   z = z([idx]):Accesses the z-component of the XYZ data
    %   east = east([idx]):Accesses the east-component of the ENU data
    %   north = north([idx]):Accesses the north-component of the ENU data
    %   up = up([idx])Accesses the up-component of the ENU data
    %   plot([idx]):plot the ENU error data
    %   plotENU([idx]):plot the ENU error data
    %   plotXYZ([idx]):plot the XYZ error data
    %   plot2D([idx]):plot the 2D error data
    %   plot3D([idx]):plot the 3D error data
    %   plotCDF2D([idx]):Plot the Cumulative Distribution Function of 2D error data
    %   plotCDF3D([idx]):Plot the Cumulative Distribution Function of 3D error data
    %   help()
    %
    % Author: Taro Suzuki

    properties
        type % 'position' or 'velocity' or 'acceleration'
        n % Number of epochs
        xyz % ECEF position/velocity/acceleration error
        enu % Local ENU position/velocity/acceleration error
        orgllh % Coordinate origin (deg, deg, m)
        orgxyz % Coordinate origin in ECEF (m, m, m)
        d2 % Horizontal (2D) error
        d3 % 3D error
    end
    properties (Access = private)
        unit
    end
    methods
        %% constractor
        function obj = Gerr(errtype, err, coordtype, org, orgtype)
            arguments
                errtype (1,:) char {mustBeMember(errtype,{'position', 'velocity', 'acceleration'})}
                err (:,3) double
                coordtype (1,:) char {mustBeMember(coordtype,{'xyz','enu'})}
                org (1,3) double = [0, 0, 0]
                orgtype (1,:) char {mustBeMember(orgtype,{'llh','xyz'})} = 'llh'
            end
            obj.type = errtype;
            switch errtype
                case 'position'
                    obj.unit = '(m)';
                case 'velocity'
                    obj.unit = '(m/s)';
                case 'acceleration'
                    obj.unit = '(m/s^2)';
            end
            if nargin>=3; obj.setErr(err, coordtype); end
            if nargin==5; obj.setOrg(org, orgtype); end
        end

        %% set error
        function setErr(obj, err, coordtype)
            % setErr: Set error
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setErr(err, coordtype)
            %
            % Input: ------------------------------------------------------
            %   err : Nx3, position/velocity/acceleration error vector
            %   coordtype : Coordinate type: 'xyz' or 'enu'
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

        %% append
        function append(obj, gerr)
            % append: Append another Gerr object to the current object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.append(gerr)
            %
            % Input: ------------------------------------------------------
            %   gerr : Another Gerr object to append to the current object
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
            % addOffset: Add an offset to the ENU or XYZ data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.addOffset(offset, coordtype)
            %
            % Input: ------------------------------------------------------
            %   offset : Array representing the offset to be added
            %   coordtype : Coordinate type: 'xyz' or 'enu'
            %
            arguments
                obj gt.Gerr
                offset (1,3) double
                coordtype (1,:) char {mustBeMember(coordtype,{'enu','xyz'})} = 'enu'
            end
            switch coordtype
                case 'enu'
                    if isempty(obj.enu)
                        error('enu must be set to a value');
                    end
                    obj.setErr(obj.enu + offset, 'enu');
                case 'xyz'
                    if isempty(obj.xyz)
                        error('xyz must be set to a value');
                    end
                    obj.setErr(obj.xyz + offset, 'xyz');
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
            % Output: ------------------------------------------------------
            %   gerr : 1x1, Copied object
            %
            arguments
                obj gt.Gerr
            end
            gerr = obj.select(1:obj.n);
        end

        %% select from index
        function gerr = select(obj, idx)
            % select: Select time from index
            % -------------------------------------------------------------
            % Select time from the index and return a new object.
            % The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   gerr = obj.select([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx]  : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
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

        %% mean calculation
        function [mxyz, sdxyz] = meanXYZ(obj, idx)
            % meanXYZ: Calculate mean and standard deviation of XYZ data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [mxyz, sdxyz] = obj.meanXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   mxyz :  Mean of XYZ position
            %   sdxyz : Standard deviation of XYZ position
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
        function [menu, sdenu] = meanENU(obj, idx)
            % meanENU: Calculate mean and standard deviation of ENU data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [menu, sdenu] = obj.meanENU([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   menu :  Mean of ENU position
            %   sdenu : Standard deviation of ENU position
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
        function [m2d, sd2d] = mean2D(obj, idx)
            % mean2D: Calculate mean and standard deviation of 2D data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [m2d, sd2d] = obj.mean2D([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   m2d :  Mean of 2D position
            %   sd2d : Standard deviation of 2D position
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
        function [m3d, sd3d] = mean3D(obj, idx)
            % mean3D: Calculate mean and standard deviation of 3D data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   [m3d, sd3d] = obj.mean3D([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   m3d :  Mean of 3D position
            %   sd3d : Standard deviation of 3D position
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            m3d = mean(obj.d3(idx), 1, 'omitnan');
            sd3d = std(obj.d3(idx), 0, 1, 'omitnan');
        end
        
        %% rms calculation
        function rxyz = rmsXYZ(obj, idx)
            % rmsXYZ: Calculate root mean square of XYZ data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   rxyz = obj.rmsXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   rxyz :  rms of XYZ Coordinate
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
        function renu = rmsENU(obj, idx)
            % rmsENU: Calculate root mean square of ENU data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   renu = obj.rmsENU([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   renu :  rms of ENU Coordinate
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
        function r2d = rms2D(obj, idx)
            % rms2D: Calculate root mean square of 2D data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   r2d = obj.rms2D([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   r2d :  rms of 2D position
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
        function r3d = rms3D(obj, idx)
            % rms3D: Calculate root mean square of 3D data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   r3d = obj.rms3D([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   r3d :   rms of 3D position
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            r3d = rms(obj.d3(idx), 1, 'omitnan');
        end

        %% percentile error
        function p2d = ptile2D(obj, p, idx)
            % ptile2D: Calculates the specified percentiles of the 2D error data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   p2d = obj.ptile2D([p], [idx])
            %
            % Input: ------------------------------------------------------
            %   [p] : Array of percentiles to calculate
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   p2d : Calculated percentiles of the 2D error data
            %
            arguments
                obj gt.Gerr
                p (1,:) double {mustBeVector} = 95
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.d2)
                error('enu must be set to a value');
            end
            p2d = prctile(obj.d2(idx), p, 1);
        end
        function p3d = ptile3D(obj, p, idx)
            % ptile3D: Calculates the specified percentiles of the 3D error data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   p3d = obj.ptile3D([p], [idx])
            %
            % Input: ------------------------------------------------------
            %   [p] : Array of percentiles to calculate
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   p3d : Calculated percentiles of the 3D error data
            %
            arguments
                obj gt.Gerr
                p (1,:) double {mustBeVector} = 95
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            p3d = prctile(obj.d3(idx), p, 1);
        end
        function cep = cep(obj, idx)
            % cep: Calculates the Circular Error Probable
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   cep = obj.cep([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   cep : Circular Error Probable  
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            cep = obj.ptile2D(obj.d2(idx), 50);
        end
         function sep = sep(obj, idx)
            % sep: Calculates the Spherical Error Probable
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   sep = obj.sep([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   sep :  Spherical Error Probable 
            %
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            sep = obj.ptile3D(obj.d3(idx), 50);
        end
        
        %% access
        function x = x(obj, idx)
            % x: Accesses the x-component of the XYZ data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   x = obj.x([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   x :  x-component of the selected data points 
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
        function y = y(obj, idx)
            % y: Accesses the y-component of the XYZ data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   y = obj.y([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   y : y-component of the selected data points   
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
        function z = z(obj, idx)
            % z: Accesses the z-component of the XYZ data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   z = obj.z([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   z :  z-component of the selected data points  
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
        function east = east(obj, idx)
            % east: Accesses the east-component of the ENU data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   east = obj.east([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   east : east-component of the selected data points  
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
        function north = north(obj, idx)
            % north: Accesses the north-component of the ENU data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   north = obj.north([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   north :  north-component of the selected data points 
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
        function up = up(obj, idx)
            % up: Accesses the up-component of the ENU data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   up = obj.up([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            % Output: ------------------------------------------------------
            %   up :   up-component of the selected data points 
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
            % plot: plot the ENU error data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
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
        function plotENU(obj, idx)
            % plotENU: Plot the ENU error data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotENU([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
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
        function plotXYZ(obj, idx)
            % plotXYZ: Plot the XYZ error data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
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
        function plot2D(obj, idx)
            % plot2D: Plot the 2D error data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot2D([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
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
        function plot3D(obj, idx)
            % plot3D: Plot the 3D error data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plot3D([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
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
        function plotCDF2D(obj, idx)
            % plotCDF2D: Plot the Cumulative Distribution Function of 2D
            %            error data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotCDF2D([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            arguments
                obj gt.Gsol
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.d2)
                error('enu must be set to a value');
            end
            figure;
            y = 0:100;
            x = obj.ptile2D(y,idx);
            
            figure;
            plot(x,y,',-');
            grid on;
            xlabel(['Horizontal ' obj.type ' error ' obj.unit]);
            ylabel('Probability (%)');
            drawnow
        end

        function plotCDF3D(obj, idx)
            % plotCDF3D: Plot the Cumulative Distribution Function of 3D
            %            error data
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.plotCDF3D([idx])
            %
            % Input: ------------------------------------------------------
            %   [idx] : Logical or numeric index to select
            %
            arguments
                obj gt.Gsol
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            figure;
            y = 0:100;
            x = obj.ptile3D(y,idx);
            
            figure;
            plot(x,y,',-');
            grid on;
            xlabel(['3D ' obj.type ' error ' obj.unit]);
            ylabel('Probability (%)');
            drawnow
        end
    end
end