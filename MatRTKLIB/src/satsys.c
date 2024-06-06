/**
 * @file satid2no.c
 * @brief Convert satellite number to satellite system
 * @author Taro Suzuki
 * @note Wrapper for "satsys" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, isys, iprn, m, n;
    double *sat, *sys, *prn;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);

    /* input */
    sat = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    n = (int)mxGetN(argin[0]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    sys = mxGetPr(argout[0]);
    argout[1] = mxCreateDoubleMatrix(m, n, mxREAL);
    prn = mxGetPr(argout[1]);

    /* call RTKLIB function */
    for (i = 0; i < m * n; i++) {
        isys = satsys((int)sat[i], &iprn);
        sys[i] = (double)isys;
        prn[i] = (double)iprn;
    }
}
