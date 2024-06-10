% ANTMODEL_S Compute satellite antenna offset by antenna phase center parameters
%  dant = ANTMODEL_S(pcvs, sat, nadir, freqidx)
%
% Inputs: 
%    pcvs    : MAXSATx1, array of PCV struct
%    sat     : 1xN, satellite number defined in RTKLIB
%    nadir   : MxN, nadir angle for satellite (deg)
%    freqidx : 1x1, frequency index
%
% Outputs:
%    dant    : MxN, range offsets for specified frequency (m)
%
% Notes:
%            freq idx   0     1     2     3     4 
%           --------------------------------------
%            GPS       L1    L2    L5     -     - 
%            GLONASS   G1    G2    G3     -     -  (G1=G1,G1a,G2=G2,G2a)
%            Galileo   E1    E5b   E5a   E6   E5ab
%            QZSS      L1    L2    L5    L6     - 
%            SBAS      L1     -    L5     -     -
%            BDS       B1    B2    B2a   B3   B2ab (B1=B1I,B1C,B2=B2I,B2b)
%            NavIC     L5     S     -     -     - 
% 
% Author: 
%    Taro Suzuki