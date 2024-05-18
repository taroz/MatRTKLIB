% READPCV Read antenna parameters
%  pcvs = READPCV(file)
%
% Inputs: 
%    file  : 1x1, antenna parameter file (antex)
%
% Outputs:
%    pcvs  : 1x1, pcvs data struct
%
% Notes:
%    file with the externsion .atx or .ATX is recognized as antex
%    file except for antex is recognized ngs antenna parameters
%    only support non-azimuth-depedent parameters
%
% Author: 
%    Taro Suzuki
