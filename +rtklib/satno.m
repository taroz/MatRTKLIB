% SATNO Convert satellite system+prn/slot number to satellite number
%  sat = SATNO(sys, prn)
%
% Inputs: 
%    sys   : 1xN, satellite system (SYS_GPS, SYS_GLO, ...)
%    prn   : 1xN, satellite prn/slot number
%
% Outputs:
%    sat   : 1xN, satellite number (0:error) defined in RTKLIB
%
% Author: 
%    Taro Suzuki
