/**
 * @file utc2gpst.c
 * @brief Convert UTC epoch to GPST epoch
 * @author Taro Suzuki
 * @note Wrapper for "utc2gpst" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, nepoch;
    double ep[6], *epoch, *utcepoch;
    gtime_t time;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);

    /* inputs */
    utcepoch = (double *)mxGetPr(argin[0]);
    nepoch = (int)mxGetM(argin[0]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(nepoch, 6, mxREAL);
    epoch = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < nepoch; i++) {
        ep[0] = utcepoch[i + nepoch * 0];
        ep[1] = utcepoch[i + nepoch * 1];
        ep[2] = utcepoch[i + nepoch * 2];
        ep[3] = utcepoch[i + nepoch * 3];
        ep[4] = utcepoch[i + nepoch * 4];
        ep[5] = utcepoch[i + nepoch * 5];
        time = epoch2time(ep);
        time = utc2gpst(time);
        time2epoch(time, ep);
        epoch[i + nepoch * 0] = ep[0];
        epoch[i + nepoch * 1] = ep[1];
        epoch[i + nepoch * 2] = ep[2];
        epoch[i + nepoch * 3] = ep[3];
        epoch[i + nepoch * 4] = ep[4];
        epoch[i + nepoch * 5] = ep[5];
    }
}
