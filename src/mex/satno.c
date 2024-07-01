/**
 * @file satno.c
 * @brief Convert satellite system+prn/slot number to satellite number
 * @author Taro Suzuki
 * @note Wrapper for "satno" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, ino, m, n;
    double *sys, *prn, *no;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSameSize(argin[0], argin[1]); /* sys,prn */

    /* inputs */
    sys = (double *)mxGetPr(argin[0]);
    prn = (double *)mxGetPr(argin[1]);
    m = (int)mxGetM(argin[0]);
    n = (int)mxGetN(argin[0]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    no = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m * n; i++) {
        ino = satno((int)sys[i], (int)prn[i]);
        no[i] = (double)ino;
    }
}
