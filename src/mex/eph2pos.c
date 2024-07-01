/**
 * @file eph2pos.c
 * @brief Compute satellite position and clock bias with broadcast ephemeris
 * (gps, galileo, qzss)
 * @author Taro Suzuki
 * @note Wrapper for "eph2pos" in ephemeris.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    eph_t eph = {0};
    gtime_t time;
    int i, m;
    double ep[6], *eps, rs[3];
    double *rss, *dtss, *vars;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6); /* epochs*/

    /* inputs */
    eps = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    mxeph2eph(argin[1], 1, &eph);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, 3, mxREAL);
    rss = mxGetPr(argout[0]);
    mxSetNaN(rss, m * 3);
    argout[1] = mxCreateDoubleMatrix(m, 1, mxREAL);
    dtss = mxGetPr(argout[1]);
    mxSetNaN(dtss, m);
    argout[2] = mxCreateDoubleMatrix(m, 1, mxREAL);
    vars = mxGetPr(argout[2]);
    mxSetNaN(vars, m);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        ep[0] = eps[i + m * 0];
        ep[1] = eps[i + m * 1];
        ep[2] = eps[i + m * 2];
        ep[3] = eps[i + m * 3];
        ep[4] = eps[i + m * 4];
        ep[5] = eps[i + m * 5];
        time = epoch2time(ep);

        eph2pos(time, &eph, rs, &dtss[i], &vars[i]);

        rss[i + m * 0] = rs[0];
        rss[i + m * 1] = rs[1];
        rss[i + m * 2] = rs[2];
    }
}
