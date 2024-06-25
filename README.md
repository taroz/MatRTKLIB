# MatRTKLIB
**MatRKTLIB** provides a MATLAB wrapper for [RTKLIB](https://github.com/tomojitakasu/RTKLIB), an open source GNSS data processing library, and also provides various processes required for actual GNSS analysis and research in its own MATLAB classes. Originally maintained for my own research, I have made it open source.

# Feautures
- Incorporates RTKLIB as a submodule and provides MATLAB wrappers for almost all RTKLIB functions
  - Calling functions of RTKLIB on MATLAB is `rtklib.****`
  - Support for vector inputs for almost all functions
  - Any updates to RTKLIB (new satellites, RINEX version support, etc.) can be reflected immediately

- Provides original GNSS classes (**gt: GNSS Tools**) using RTKLIB
  - To create a GNSS Tools object in MATLAB, use `gt.****`
  - Provides for reading, editing, visualization, analysis, and export of RINEX files and positioning solutions

- Provides a very wide variety of specific examples commonly used in GNSS analysis. For example
  - Step-by-step implementation of stand-alone and RTK positioning (`estimate_position_spp1_step_by_step.m`, `estimate_position_rtk_step_by_step.m`)
  - Removal of specific satellite observations from RINEX files (`edit_rinex_observation4.m`)
  - Computing double-difference pseudoranges and carrier phase residuals (`compute_double_difference.m`)
  - Error analysis with a kinematic positioning reference (`evaluate_position_error.m`)
  - See [examples](./examples) for more details.

# Demo
![](https://github.com/taroz/Misc/blob/master/data/MatRTKLIB/demo.gif?raw=true)

# Installation
If you do not want to compile **MatRTKLIB** yourself, you can download a pre-compiled package:

```git clone https://github.com/taroz/MatRTKLIB.git```

To install **MatRTKLIB**, simply add its folder path to your MATLAB path list in MATLAB comand window:

```addpath('/path/to/MatRTKLIB');```

# Compile
Pre-compiled mex files are created in the following environments.
- MATLAB 2024a
- OS: Windows 11, Compiler: Microsoft Visual Studio 2022
- OS: Ubuntu 20.04, Compiler: GCC

For 32-bit systems, you will need to recompile it yourself.
When compiling, clone including submodules.

```git clone --recursive https://github.com/taroz/MatRTKLIB.git```

Or, if you have already cloned

```git submodule update --init --recursive```

The compilation procedure is as follows.
1. In MATLAB, enter `mex -setup` to see if compiler is configured
2. Run `compile.m`

Note: If you are syncing directories via OneDrive or Dropbox, the compilation may fail. 
If this happens, please pause the synchronization.

# Citation
TBD