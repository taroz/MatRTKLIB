/**
 * @file sunmoonpos.c
 * @brief Get sun and moon position in ECEF
 * @author Taro Suzuki
 * @note Wrapper for "sunmoonpos" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, j, nepoch;
    double rsun_, rmoon_, ep[6];
    double *erpv, *utcepoch, *rsun, *rmoon, *gmst;
    gtime_t utc;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);     /* utcepoch */
    mxCheckSizeOfArgument(argin[1], 1, 4); /* erpv */

    /* inputs */
    utcepoch = (double *)mxGetPr(argin[0]);
    nepoch = (int)mxGetM(argin[0]);
    erpv = (double *)mxGetPr(argin[1]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(nepoch, 3, mxREAL);
    rsun = mxGetPr(argout[0]);
    argout[1] = mxCreateDoubleMatrix(nepoch, 3, mxREAL);
    rmoon = mxGetPr(argout[1]);
    argout[1] = mxCreateDoubleMatrix(nepoch, 1, mxREAL);
    gmst = mxGetPr(argout[1]);

    /* call RTKLIB function */
    for (i = 0; i < nepoch; i++) {
        ep[0] = utcepoch[i + nepoch * 0];
        ep[1] = utcepoch[i + nepoch * 1];
        ep[2] = utcepoch[i + nepoch * 2];
        ep[3] = utcepoch[i + nepoch * 3];
        ep[4] = utcepoch[i + nepoch * 4];
        ep[5] = utcepoch[i + nepoch * 5];
        utc = epoch2time(ep);
        sunmoonpos(utc, erpv, &rsun_, &rmoon_, &gmst[i]);
        for (j = 0; j < 3; j++) {
            rsun[i + nepoch * j] = rsun_;
            rmoon[i + nepoch * j] = rmoon_;
        }
    }
}
