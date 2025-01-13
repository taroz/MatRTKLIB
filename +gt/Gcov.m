classdef Gcov < handle
    % Gcov: GNSS position/velocity covariance class
    % ---------------------------------------------------------------------
    % Gcov Declaration:
    % gcov = Gcov();  Create empty gt.Gcov object
    %
    % gcov = Gcov(cov, 'type', [orgpos], ['orgtype']);
    %                           Create gt.Gcov object from covariance vector
    %   cov      : Mx6, vector of elements of covariance
    %                  [c_xx, c_yy, c_zz, c_xy, c_yz, c_zx] or
    %                  [c_ee,c_nn,c_uu,c_en,c_nu,c_ue] or
    %              3x3xM, covariance matrix
    %   type     : 1x1, Coordinate type: 'xyz' or 'enu'
    %  [orgpos]  : 1x3, Coordinate origin [option] 1x3 or 3x1 position vector
    %  [orgtype] : 1x1, Position type [option]: 'llh' or 'xyz'
    %
    % gcov = Gcov(gpos);  Create gt.Gcov object from position
    %   gpos   : 1x1, gt.Gpos
    %
    % gcov = Gcov(gvel);  Create gt.Gcov object from velocity
    %   gvel   : 1x1, gt.Gvel
    %
    % gcov = Gcov(gerr);  Create gt.Gcov object from error
    %   gerr   : 1x1, gt.Gerr
    % ---------------------------------------------------------------------
    % Gcov Properties:
    %   n       : 1x1, Number of epochs
    %   xyz     :(obj.n)x6, Vector of elements of covariance in ECEF
    %   enu     :(obj.n)x6, Vector of elements of covariance in ENU
    %   orgllh  : 1x3, Coordinate origin (deg, deg, m)
    %   orgxyz  : 1x3, Coordinate origin in ECEF (m, m, m)
    % ---------------------------------------------------------------------
    % Methods:
    %   setGpos(gpos);        Set gt.Gpos object and calculate variance
    %   setGvel(gvel);        Set gt.Gvel object and calculate variance
    %   setGerr(gerr);        Set gt.Gerr object and calculate variance
    %   setCovVec(cov, type); Set covariance vector
    %   setCov(cov, type);    Set covariance matrix
    %   setOrg(pos, type);    Set coordinate origin and update covariance matrix
    %   setOrgGpos(gpos);     Set coordinate origin by gt.Gpos
    %   insert(idx, gvel);    Insert gt.Gcov object
    %   append(gcov);         Append gt.Gcov object
    %   gcov = copy();        Copy object
    %   gcov = select(idx);   Select object from index
    %   gcov = interp(x, xi, [method]); Interpolating covariance data
    %   cov = covXYZ([idx]);  Convert to 3x3 covariance matrix in ECEF coordinate
    %   cov = covENU([idx]);  Convert to 3x3 covariance matrix in ENU coordinate
    %   var = varXYZ([idx]);  Compute variance in ECEF coordinate
    %   var = varENU([idx]);  Compute variance in ENU coordinate
    %   sd = sdXYZ([idx]);    Compute standard deviation in ECEF coordinate
    %   sd = sdENU([idx]);    Compute standard deviation in ENU coordinate
    %   plot([idx]);          Plot standard deviation in ENU coordinate
    %   plotXYZ([idx]);       Plot standard deviation in ECEF coordinate
    %   help();               Show help
    % ---------------------------------------------------------------------
    % Author: Taro Suzuki
    %
    properties
        n      % Number of epochs
        xyz    % Vector of elements of covariance in ECEF (RTKLIB order)
        enu    % Vector of elements of covariance in ENU (RTKLIB order)
        orgllh % Coordinate origin (deg, deg, m)
        orgxyz % Coordinate origin in ECEF (m, m, m)
    end
    methods
        %% constructor
        function obj = Gcov(varargin)
            if nargin==0 % generate empty object
                obj.n = 0;
            elseif nargin == 1
                if isa(varargin{1},'gt.Gpos')
                    obj.setGpos(varargin{1});
                elseif isa(varargin{1},'gt.Gvel')
                    obj.setGvel(varargin{1});
                elseif isa(varargin{1},'gt.Gerr')
                    obj.setGerr(varargin{1});
                else
                    error('Wrong input arguments');
                end
            elseif nargin>=2 % cov, covtype, org, orgtype
                if size(varargin{1}, 2) == 6
                    obj.setCovVec(varargin{1}, varargin{2});
                elseif size(varargin{1}, 1) == 3 && size(varargin{1}, 2) == 3
                    obj.setCov(varargin{1}, varargin{2});
                else
                    error('Wrong input arguments');
                end
            end
            if nargin==4; obj.setOrg(varargin{3}, varargin{4}); end
        end
        %% setGpos
        function setGpos(obj, gpos)
            % setGpos: Set gt.Gpos object and calculate variance
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setGpos(gpos)
            %
            % Input: ------------------------------------------------------
            %   gpos: 1x1, gt.Gpos object
            %
            arguments
                obj gt.Gcov
                gpos gt.Gpos
            end
            obj.n = 1;
            if ~isempty(gpos.enu)
                obj.enu = [var(gpos.enu, 'omitnan') 0 0 0];
            else
                obj.xyz = [var(gpos.xyz, 'omitnan') 0 0 0];
            end
            if ~isempty(gpos.orgllh)
                obj.setOrg(gpos.orgllh, 'llh');
            end
        end
        %% setGvel
        function setGvel(obj, gvel)
            % setGvel: Set gt.gvel object and calculate variance
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setGvel(gvel)
            %
            % Input: ------------------------------------------------------
            %   gvel: 1x1, gt.Gvel object
            %
            arguments
                obj gt.Gcov
                gvel gt.Gvel
            end
            obj.n = 1;
            if ~isempty(gvel.enu)
                obj.enu = [var(gvel.enu, 'omitnan') 0 0 0];
            else
                obj.xyz = [var(gvel.xyz, 'omitnan') 0 0 0];
            end
            if ~isempty(gvel.orgllh)
                obj.setOrg(gvel.orgllh, 'llh');
            end
        end
        %% setGerr
        function setGerr(obj, gerr)
            % setGerr: Set gt.Gerr object and calculate variance
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setGerr(gerr)
            %
            % Input: ------------------------------------------------------
            %   gerr: 1x1, gt.Gerr object
            %
            arguments
                obj gt.Gcov
                gerr gt.Gerr
            end
            obj.n = 1;
            if ~isempty(gerr.enu)
                obj.enu = [var(gerr.enu, 'omitnan') 0 0 0];
            else
                obj.xyz = [var(gerr.xyz, 'omitnan') 0 0 0];
            end
            if ~isempty(gerr.orgllh)
                obj.setOrg(gerr.orgllh, 'llh');
            end
        end
        %% setCovVec
        function setCovVec(obj, cov, covtype)
            % setCovVec: Set covariance vector
            % -------------------------------------------------------------
            % C
            % Usage: ------------------------------------------------------
            %   obj.setCovVec(cov, covtype)
            %
            % Input: ------------------------------------------------------
            %   cov    : Mx6, vector of elements of covariance
            %   covtype: 1x1, Coordinate type 'xyz' or 'enu'
            %
            arguments
                obj gt.Gcov
                cov (:,6) double
                covtype (1,:) char {mustBeMember(covtype,{'xyz','enu'})}
            end
            obj.n = size(cov,1);
            switch covtype
                case 'xyz'
                    obj.xyz = cov;
                    if ~isempty(obj.orgllh); obj.enu = rtklib.covenusol(obj.xyz, obj.orgllh); end
                case 'enu'
                    obj.enu = cov;
                    if ~isempty(obj.orgllh); obj.xyz = rtklib.covecefsol(obj.enu, obj.orgllh); end
            end
        end
        %% setCov
        function setCov(obj, cov, covtype)
            % setCov: Set covariance matrix
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setCov(cov, covtype)
            %
            % Input: ------------------------------------------------------
            %   cov    : 3x3xM, vector of elements of covariance
            %   covtype: 1x1, Coordinate type 'xyz' or 'enu'
            %
            arguments
                obj gt.Gcov
                cov (3,3,:) double
                covtype (1,:) char {mustBeMember(covtype,{'xyz','enu'})}
            end
            obj.n = size(cov,3);
            switch covtype
                case 'xyz'
                    obj.xyz = obj.mat2vec(cov);
                    if ~isempty(obj.orgllh); obj.enu = rtklib.covenusol(obj.xyz, obj.orgllh); end
                case 'enu'
                    obj.enu = obj.mat2vec(cov);
                    if ~isempty(obj.orgllh); obj.xyz = rtklib.covecefsol(obj.enu, obj.orgllh); end
            end
        end
        %% setOrg
        function setOrg(obj, org, orgtype)
            % setOrg: Set coordinate origin and update covariance matrix
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.setOrg(org, orgtype)
            %
            % Input: ------------------------------------------------------
            %   org    : 1x3, coordinate origin position
            %   orgtype: 1x1, Position type 'xyz' or 'enu'
            %
            arguments
                obj gt.Gcov
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
                obj.enu = rtklib.covenusol(obj.xyz, obj.orgllh);
            elseif ~isempty(obj.enu)
                obj.xyz = rtklib.covecefsol(obj.enu, obj.orgllh);
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
                obj gt.Gcov
                gpos gt.Gpos
            end
            if isempty(gpos.llh)
                error("gpos.llh is empty");
            end
            obj.setOrg(gpos.llh(1,:),"llh");
        end
        %% insert
        function insert(obj, idx, gcov)
            % insert: Insert gt.Gcov object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.insert(idx, gcov)
            %
            % Input: ------------------------------------------------------
            %   idx : 1x1, Integer index to insert
            %   gvel: 1x1, gt.Gvel object
            %
            arguments
                obj gt.Gvel
                idx (1,1) {mustBeInteger}
                gcov gt.Gcov
            end
            if idx<=0 || idx>obj.n
                error('Index is out of range');
            end
            if ~isempty(obj.xyz) && ~isempty(gcov.xyz)
                obj.setCovVec(obj.insertdata(obj.xyz, idx, gcov.xyz), 'xyz');
            else
                obj.setCovVec(obj.insertdata(obj.enu, idx, gcov.enu), 'enu');
            end
        end
        %% append
        function append(obj, gcov)
            % append: Append gt.Gcov object
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   obj.append(gcov)
            %
            % Input: ------------------------------------------------------
            %   gcov: 1x1, gt.Gcov object
            %
            arguments
                obj gt.Gcov
                gcov gt.Gcov
            end
            if ~isempty(obj.xyz)
                obj.setCovVec([obj.xyz; gcov.xyz], 'xyz');
            else
                obj.setCovVec([obj.enu; gcov.enu], 'enu');
            end
        end
        %% copy
        function gcov = copy(obj)
            % copy: Copy object
            % -------------------------------------------------------------
            % MATLAB handle class is used, so if you want to create a
            % different object, you need to use the copy method.
            %
            % Usage: ------------------------------------------------------
            %   gcov = obj.copy()
            %
            % Output: -----------------------------------------------------
            %   gcov: 1x1, Copied gt.Gcov object
            %
            arguments
                obj gt.Gcov
            end
            gcov = obj.select(1:obj.n);
        end
        %% select
        function gcov = select(obj, idx)
            % select: Select object from index
            % -------------------------------------------------------------
            % Select covariance data from the index and return a new object.
            % The index may be a logical or numeric index.
            %
            % Usage: ------------------------------------------------------
            %   gpos = obj.select(idx)
            %
            % Input: ------------------------------------------------------
            %   idx: Logical or numeric index to select
            %
            % Output: -----------------------------------------------------
            %   gcov: 1x1, gt.Gcov object
            %
            arguments
                obj gt.Gcov
                idx {mustBeInteger, mustBeVector}
            end
            if ~any(idx)
                error('Selected index is empty');
            end
            if ~isempty(obj.xyz)
                gcov = gt.Gcov(obj.xyz(idx,:), 'xyz');
            else
                gcov = gt.Gcov(obj.enu(idx,:), 'enu');
            end
            if ~isempty(obj.orgllh); gcov.setOrg(obj.orgllh, 'llh'); end
        end
        function gcov = interp(obj, x, xi, method)
            % interp: Interpolating covariance data
            % -------------------------------------------------------------
            % Interpolate the covariance data at the query point and return a
            % new object.
            %
            % Usage: ------------------------------------------------------
            %   gcov = obj.interp(x, xi, [method])
            %
            % Input: ------------------------------------------------------
            %   x     : Sample points
            %   xi    : Query points
            %   method: Interpolation method (optional)
            %           Default: method = "linear"
            %
            % Output: -----------------------------------------------------
            %   gcov: 1x1, Interpolated gt.Gcov object
            %
            arguments
                obj gt.Gcov
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
                gcov = gt.Gcov(interp1(x, obj.xyz, xi, method), "xyz");
            else
                gcov = gt.Gcov(interp1(x, obj.enu, xi, method), "enu");
            end
            if ~isempty(obj.orgllh); gcov.setOrg(obj.orgllh, 'llh'); end
        end
        %% covXYZ
        function cov = covXYZ(obj, idx)
            % covXYZ: Convert to 3x3 covariance matrix in ECEF coordinate
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   cov = obj.covXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   cov : 3x3xM, Covariance matrix in ECEF coordinate
            %
            arguments
                obj gt.Gcov
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            cov = obj.vec2matrix(obj.xyz(idx,:));
        end
        %% covENU
        function cov = covENU(obj, idx)
            % covENU: Convert to 3x3 covariance matrix in ENU coordinate
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   cov = obj.covENU([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: ----------------------------------------------------
            %   cov : 3x3xM, Covariance matrix in ENU coordinate
            %
            arguments
                obj gt.Gcov
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            cov = obj.vec2matrix(obj.enu(idx,:));
        end
        %% varXYZ
        function var = varXYZ(obj, idx)
            % varXYZ: Compute variance in ECEF coordinate
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   var = obj.varXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   var : Mx3, Variance in ECEF coorinate
            %
            arguments
                obj gt.Gcov
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            var = obj.xyz(idx,1:3);
        end
        %% varENU
        function var = varENU(obj, idx)
            % varENU: Compute variance in ENU coordinate
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   var = obj.varENU([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   var : Mx3, Varinance in ENU coorinate
            %
            arguments
                obj gt.Gcov
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            var = obj.enu(idx,1:3);
        end
        %% sdXYZ
        function sd = sdXYZ(obj, idx)
            % sdXYZ: Compute standard deviation in ECEF coordinate
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   sd = obj.sdXYZ([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   sd : Mx3, Standard deviation in ECEF coordinate
            %
            arguments
                obj gt.Gcov
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            sd = sqrt(obj.xyz(idx,1:3));
        end
        %% sdENU
        function sd = sdENU(obj, idx)
            % sdENU: Compute standard deviation in ENU coordinate
            % -------------------------------------------------------------
            %
            % Usage: ------------------------------------------------------
            %   sd = obj.sdENU([idx])
            %
            % Input: ------------------------------------------------------
            %  [idx]: Logical or numeric index to select (optional)
            %         Default: idx = 1:obj.n
            %
            % Output: -----------------------------------------------------
            %   sd : Mx3, Standard deviation in ENU coordinate
            %
            arguments
                obj gt.Gcov
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            sd = sqrt(obj.enu(idx,1:3));
        end
        %% plot
        function plot(obj, idx)
            % plot: Plot standard deviation in ENU coordinate
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
                obj gt.Gcov
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.enu)
                error('enu must be set to a value');
            end
            sdenu = obj.sdENU(idx);
            figure;
            plot(sdenu(:, 1), '.-');
            grid on; hold on;
            plot(sdenu(:, 2), '.-');
            plot(sdenu(:, 3), '.-');
            ylabel('SD (m)');
            legend('SD East', 'SD North', 'SD up')
            drawnow
        end
        %% plotXYZ
        function plotXYZ(obj, idx)
            % plotXYZ: Plot standard deviation in ECEF coordinate
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
                obj gt.Gcov
                idx {mustBeInteger, mustBeVector} = 1:obj.n
            end
            if isempty(obj.xyz)
                error('xyz must be set to a value');
            end
            sdxyz = obj.sdXYZ(idx);
            figure;
            plot(sdxyz(:, 1), '.-');
            grid on; hold on;
            plot(sdxyz(:, 2), '.-');
            plot(sdxyz(:, 3), '.-');
            ylabel('SD (m)');
            legend('SD ECEF-X', 'SD ECEF-Y', 'SD ECEF-Z')
            drawnow
        end
        %% help
        function help(~)
            % help: Show help
            doc gt.Gcov
        end
    end
    %% private functions
    methods (Access = private)
        %% Insert data
        function c = insertdata(~,a,idx,b)
            c = [a(1:size(a,1)<idx,:); b; a(1:size(a,1)>=idx,:)];
        end
        %% convert vector to matrix
        function mat = vec2matrix(~, vec)
            arguments
                ~
                vec (:,6) double
            end
            r3 = @(x) reshape(x,1,1,[]);
            mat = [r3(vec(:,1)), r3(vec(:,4)), r3(vec(:,6));
                r3(vec(:,4)), r3(vec(:,2)), r3(vec(:,5));
                r3(vec(:,6)), r3(vec(:,5)), r3(vec(:,3))];
        end
        %% convert matrix to vector
        function vec = mat2vec(~,mat)
            arguments
                ~
                mat (3,3,:) double
            end
            r1 = @(x) reshape(x,[],1);
            vec = [r1(mat(1,1,:)), r1(mat(2,2,:)), r1(mat(3,3,:)),...
                r1(mat(1,2,:)), r1(mat(2,3,:)), r1(mat(3,1,:))];
        end
    end
end