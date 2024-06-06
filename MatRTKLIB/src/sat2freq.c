/**
 * @file sat2freq.c
 * @brief Convert satellite and obs code to frequency
 * @author Taro Suzuki
 * @note Wrapper for "sat2freq" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 3

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    nav_t nav = {0};
    int i, m, n;
    double *sat, *frq, *code;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSameSize(argin[0], argin[1]); /* sat,code */

    /* inputs */
    sat = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    n = (int)mxGetN(argin[0]);
    code = (double *)mxGetPr(argin[1]);
    nav = mxnav2nav(argin[2]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    frq = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m * n; i++) {
        frq[i] = sat2freq((int)sat[i], (uint8_t)code[i], &nav);
    }

    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
}
