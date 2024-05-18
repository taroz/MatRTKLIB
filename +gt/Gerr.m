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
    %   setErr(err, type):
    %   setOrg(pos, postype):
    %   append(gerr):
    %   addOffset(offset, [coordtype]):
    %   gerr = select([idx]):
    %   [mxyz, sdxyz] = meanXYZ([idx]):
    %   [menu, sdenu] = meanENU([idx]):
    %   [m2d, sd2d] = mean2D([idx]):
    %   [m3d, sd3d] = mean3D([idx]):
    %   rxyz = rmsXYZ([idx]):
    %   renu = rmsENU([idx]):
    %   r2d = rms2D([idx]):
    %   r3d = rms3D([idx]):
    %   p2d = ptile2D([p],[idx]):
    %   p3d = ptile3D([p],[idx]):
    %   cep = cep([idx]):
    %   sep = sep([idx]):
    %   x = x([idx]):
    %   y = y([idx]):
    %   z = z([idx]):
    %   east = east([idx]):
    %   north = north([idx]):
    %   up = up([idx])
    %   plot([idx]):
    %   plotENU([idx]):
    %   plotXYZ([idx]):
    %   plot2D([idx]):
    %   plot3D([idx]):
    %   plotCDF2D([idx]):
    %   plotCDF3D([idx]):
    %   help()
    %
    % Author: Taro Suzuki

    properties
        type, n, xyz, enu, orgllh, orgxyz, d2, d3;
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
            arguments
                obj gt.Gerr
            end
            gerr = obj.select(1:obj.n);
        end

        %% select from index
        function gerr = select(obj, idx)
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
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            m3d = mean(obj.d3(idx), 1, 'omitnan');
            sd3d = std(obj.d3(idx), 0, 1, 'omitnan');
        end
        
        %% rms calculation
        function rxyz = rmsXYZ(obj, idx)
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
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            r3d = rms(obj.d3(idx), 1, 'omitnan');
        end

        %% percentile error
        function p2d = ptile2D(obj, p, idx)
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
            arguments
                obj gt.Gerr
                p (1,:) double {mustBeVector} = 95
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            p3d = prctile(obj.d3(idx), p, 1);
        end
        function cep = cep(obj, idx)
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            cep = obj.ptile2D(obj.d2(idx), 50);
        end
         function sep = sep(obj, idx)
            arguments
                obj gt.Gerr
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            sep = obj.ptile3D(obj.d3(idx), 50);
        end
        
        %% access
        function x = x(obj, idx)
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