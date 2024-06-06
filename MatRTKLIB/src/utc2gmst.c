/**
 * @file utc2gmst.c
 * @brief Convert utc to gmst (Greenwich mean sidereal time)
 * @author Taro Suzuki
 * @note Wrapper for "utc2gmst" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, nepoch;
    double ep[6], *epoch, ut1_utc, *gmst;
    gtime_t time;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6); /* epochs */
    mxCheckScalar(argin[1]);           /* ut1_utc */

    /* inputs */
    epoch = (double *)mxGetPr(argin[0]);
    nepoch = (int)mxGetM(argin[0]);
    ut1_utc = (double)mxGetScalar(argin[1]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(nepoch, 1, mxREAL);
    gmst = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < nepoch; i++) {
        ep[0] = epoch[i + nepoch * 0];
        ep[1] = epoch[i + nepoch * 1];
        ep[2] = epoch[i + nepoch * 2];
        ep[3] = epoch[i + nepoch * 3];
        ep[4] = epoch[i + nepoch * 4];
        ep[5] = epoch[i + nepoch * 5];
        time = epoch2time(ep);
        gmst[i] = utc2gmst(time, ut1_utc);
    }
}
