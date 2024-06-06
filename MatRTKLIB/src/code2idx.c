/**
 * @file mex_code2idx.c
 * @brief Convert system and obs code to frequency index
 * @author Taro Suzuki
 * @note Wrapper for "code2idx" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, m, n;
    double *sys, *code, *idx;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSameSize(argin[0], argin[1]); /* sys,code */

    /* inputs */
    sys = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    n = (int)mxGetN(argin[0]);
    code = (double *)mxGetPr(argin[1]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    idx = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m * n; i++) {
        idx[i] = (double)code2idx((int)sys[i], (uint8_t)code[i]);
    }
}
