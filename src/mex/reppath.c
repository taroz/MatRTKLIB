/**
 * @file reppath.c
 * @brief Replace keywords in file path
 * @author Taro Suzuki
 * @note Wrapper for "reppath" in rtkcmn.c
 * @note Input interface changed from original
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    char path[512], rpath[512];
    double *epoch;
    gtime_t time;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]);
    if (nargin==2) mxCheckSizeOfArgument(argin[1], 1, 6); /* epoch */

    /* input */
    mxGetString(argin[0], path, sizeof(path)); /* path */
    if (nargin==2){
        epoch = (double *)mxGetPr(argin[1]);
        time = epoch2time(epoch);
    } else {
        time = utc2gpst(timeget());
    }
    /* call RTKLIB function */
    reppath(path, rpath, time, "", "");

    /* outputs */
    argout[0] = mxCreateString(rpath);
}
