/**
 * @file peph2pos.c
 * @brief Compute satellite position/clock with precise ephemeris/clock
 * @author Taro Suzuki
 * @note Wrapper for "peph2pos" in preeph.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 4

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    nav_t nav = {0};
    gtime_t time;
    int i, j, m, nsat, opt;
    double ep[6], *eps, *sats, rs[6], dts[2], var;
    double *x, *y, *z, *vx, *vy, *vz, *dtss, *ddtss, *vars;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6); /* epochs*/
    mxCheckSizeOfRows(argin[1], 1);    /* sats */
    mxCheckScalar(argin[3]);           /* opt */

    /* inputs */
    eps = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    sats = (double *)mxGetPr(argin[1]);
    nsat = (int)mxGetN(argin[1]);
    nav = mxnav2nav(argin[2]);
    opt = (int)mxGetScalar(argin[3]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    x = mxGetPr(argout[0]);
    mxSetNaN(x, m * nsat);
    argout[1] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    y = mxGetPr(argout[1]);
    mxSetNaN(y, m * nsat);
    argout[2] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    z = mxGetPr(argout[2]);
    mxSetNaN(z, m * nsat);
    argout[3] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    vx = mxGetPr(argout[3]);
    mxSetNaN(vx, m * nsat);
    argout[4] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    vy = mxGetPr(argout[4]);
    mxSetNaN(vy, m * nsat);
    argout[5] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    vz = mxGetPr(argout[5]);
    mxSetNaN(vz, m * nsat);
    argout[6] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    dtss = mxGetPr(argout[6]);
    mxSetNaN(dtss, m * nsat);
    argout[7] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    ddtss = mxGetPr(argout[7]);
    mxSetNaN(ddtss, m * nsat);
    argout[8] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    vars = mxGetPr(argout[8]);
    mxSetNaN(vars, m * nsat);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        ep[0] = eps[i + m * 0];
        ep[1] = eps[i + m * 1];
        ep[2] = eps[i + m * 2];
        ep[3] = eps[i + m * 3];
        ep[4] = eps[i + m * 4];
        ep[5] = eps[i + m * 5];
        time = epoch2time(ep);

        for (j = 0; j < nsat; j++) {
            /* satellite position/clock by precise ephemeris/clock */
            if (!peph2pos(time, (int)sats[j], &nav, opt, rs, dts, &var)) {
                mexPrintf("no precise ephemeris %s sat=%2d\n",
                          time_str(time, 3), (int)sats[j]);
                continue;
            }

            x[i + m * j] = rs[0];
            y[i + m * j] = rs[1];
            z[i + m * j] = rs[2];
            vx[i + m * j] = rs[3];
            vy[i + m * j] = rs[4];
            vz[i + m * j] = rs[5];
            dtss[i + m * j] = dts[0];
            ddtss[i + m * j] = dts[1];
            vars[i + m * j] = var;
        }
    }
    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
}
