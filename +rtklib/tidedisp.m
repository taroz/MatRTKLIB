% TIDEDISP Compute displacements by earth tides
%  dr = TIDEDISP(epoch, rr, opt)
%  dr = TIDEDISP(epoch, rr, opt, erp)
%  dr = TIDEDISP(epoch, rr, opt, erp, odisp)
%
% Inputs: 
%    epoch : Mx6, calendar day/time in GPST
%                {year, month, day, hour, minute, second}
%    rr    : Mx3, site position in ECEF coordinate (m)
%    opt   : 1x1, options (or of the followings)
%                      1: solid earth tide
%                      2: ocean tide loading
%                      4: pole tide
%                      8: elimate permanent deformation
%    erp   : 1x1, earth rotation parameter struct
%    odisp : 6x11, ocean tide loading parameters (for opt = 2)
% 
% Outputs:
%    dr    : Mx3, displacement by earth tides in ECEF (m)
%
% Author: 
%    Taro Suzuki
