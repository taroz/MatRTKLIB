% SAT2FREQ Convert satellite and obs code to frequency
%  freq = SAT2FREQ(sat, code, nav)
%
% Inputs: 
%    sat  : 1xN, satellite number defined in RTKLIB
%    code : 1xN, obs code (CODE_???)
%    nav  : 1x1, navigation data struct
%
% Outputs:
%    freq : 1xN, carrier frequency (Hz) (0.0: error)
%
% Author: 
%    Taro Suzuki
