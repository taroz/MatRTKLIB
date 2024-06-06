/**
 * @file gpst2utc.c
 * @brief Convert GPST epoch to UTC epoch
 * @author Taro Suzuki
 * @note Wrapper for "gpst2utc" in rtkcmn.c
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
    mxCheckNumberOfArguments(nargin, NIN); /* epochs */
    mxCheckSizeOfColumns(argin[0], 6);

    /* inputs */
    epoch = (double *)mxGetPr(argin[0]);
    nepoch = (int)mxGetM(argin[0]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(nepoch, 6, mxREAL);
    utcepoch = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < nepoch; i++) {
        ep[0] = epoch[i + nepoch * 0];
        ep[1] = epoch[i + nepoch * 1];
        ep[2] = epoch[i + nepoch * 2];
        ep[3] = epoch[i + nepoch * 3];
        ep[4] = epoch[i + nepoch * 4];
        ep[5] = epoch[i + nepoch * 5];
        time = epoch2time(ep);
        time = gpst2utc(time);
        time2epoch(time, ep);
        utcepoch[i + nepoch * 0] = ep[0];
        utcepoch[i + nepoch * 1] = ep[1];
        utcepoch[i + nepoch * 2] = ep[2];
        utcepoch[i + nepoch * 3] = ep[3];
        utcepoch[i + nepoch * 4] = ep[4];
        utcepoch[i + nepoch * 5] = ep[5];
    }
}
