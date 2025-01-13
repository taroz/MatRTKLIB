# MatRTKLIB
**MatRKTLIB** provides a MATLAB wrapper for [RTKLIB](https://github.com/tomojitakasu/RTKLIB), an open source GNSS data processing library, and also provides various processes required for actual GNSS analysis and research in its own MATLAB classes. Originally maintained for my own research, I have made it open source.

## Updates
### January 13, 2025
The backend has been changed to [MALIB](https://github.com/JAXA-SNU/MALIB), the successor to [RTKLIB](https://github.com/tomojitakasu/RTKLIB/tree/rtklib_2.4.3). If you have cloned the repository before, please run `git submodule update`.

# Features
- Incorporates RTKLIB as a submodule and provides MATLAB wrappers for almost all RTKLIB functions
  - Calling functions of RTKLIB on MATLAB is `rtklib.****`
  - Support for vector inputs/outputs for almost all functions
  - Any updates to RTKLIB (new satellites, RINEX version support, etc.) can be reflected immediately
  - RTKLIB porting progress is [here](./src/)

- Provides original GNSS classes (**GT: GNSS Tools**) using RTKLIB
  - To create a GNSS Tools object in MATLAB, use `gt.****`
  - Provides for reading, editing, visualization, analysis, and export of RINEX files and positioning solutions
  - See [GT directory](./+gt) for more information on GT class types

- Provides a very wide variety of specific examples commonly used in GNSS analysis. For example
  - Step-by-step implementation of stand-alone and RTK positioning (`estimate_position_spp1_step_by_step.m`, `estimate_position_rtk_step_by_step.m`)
  - Removal of specific satellite observations from RINEX files (`edit_rinex_observation4.m`)
  - Computing double-difference pseudoranges and carrier phase residuals (`compute_double_difference.m`)
  - Error analysis with a kinematic positioning reference (`evaluate_position_error.m`)
  - See [examples](./examples) for more details

# Demo
![](https://github.com/taroz/Misc/blob/master/data/MatRTKLIB/demo.gif?raw=true)

# Installation
If you do not want to compile **MatRTKLIB** yourself, you can download a pre-compiled package:

```shell
git clone https://github.com/taroz/MatRTKLIB.git
```

To install **MatRTKLIB**, simply add its folder path to your MATLAB path list in MATLAB command window:

```matlab
addpath('/path/to/MatRTKLIB');
```

# Compile
Pre-compiled mex files are created in the following environments.
- MATLAB 2024a
- OS: Windows 11, Compiler: Microsoft Visual Studio 2022
- OS: Ubuntu 20.04, Compiler: GCC
- OS: macOS (Sequoia 15.2, Apple M4), Compiler: Xcode 16.2 (Clang)

For 32-bit systems, you will need to recompile it yourself.
When compiling, clone including submodules.

```shell
git clone --recursive https://github.com/taroz/MatRTKLIB.git
```

Or, if you have already cloned

```shell
git submodule update --init --recursive
```

The compilation procedure is as follows.
1. In MATLAB, enter `mex -setup` to see if compiler is configured
2. Run `compile.m`

Note: If you are syncing directories via OneDrive or Dropbox, the compilation may fail. 
If this happens, please pause the synchronization.

# Citation
Under review...