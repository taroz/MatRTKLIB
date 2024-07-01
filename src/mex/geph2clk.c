/**
 * @file geph2clk.c
 * @brief Compute satellite clock bias with glonass ephemeris
 * @author Taro Suzuki
 * @note Wrapper for "geph2clk" in ephemeris.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    geph_t geph = {0};
    gtime_t time;
    int i, m;
    double ep[6], *eps, *dtss;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6); /* epochs*/

    /* inputs */
    eps = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    mxgeph2geph(argin[1], 1, &geph);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, 1, mxREAL);
    dtss = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        ep[0] = eps[i + m * 0];
        ep[1] = eps[i + m * 1];
        ep[2] = eps[i + m * 2];
        ep[3] = eps[i + m * 3];
        ep[4] = eps[i + m * 4];
        ep[5] = eps[i + m * 5];
        time = epoch2time(ep);

        dtss[i] = geph2clk(time, &geph);
    }
}
