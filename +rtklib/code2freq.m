% CODE2FREQ Convert system and obs code to carrier frequency
%  freq = CODE2FREQ(sys, code)
%  freq = CODE2FREQ(sys, code, fcn)
% 
% Inputs:
%    sys   : 1xN, satellite system (SYS_???)
%    code  : 1xN, obs code (CODE_???)
%    fcb   : 1xN, frequency channel number for GLONASS
%
% Outputs:
%    freq  : 1xN, carrier frequency (Hz) (0.0: error)
%
% Author: 
%    Taro Suzuki