/**
 * @file satposs.c
 * @brief Compute satellite position, velocity and clock
 * @author Taro Suzuki
 * @note Wrapper for "satposs" in ephemeris.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 3

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    nav_t nav = {0};
    obsd_t *obs, *obss;
    int i, j, m, nsat, svh[MAXSAT], ephopt, sats[MAXSAT];
    double rs[6 * MAXSAT], dts[2 * MAXSAT], var[MAXSAT];
    double *x, *y, *z, *vx, *vy, *vz, *dtss, *ddtss, *vars, *svhs;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckScalar(argin[2]); /* ephopt */

    /* inputs */
    obss = mxobs2obs_all(argin[0], 1, &m, &nsat, sats);
    nav = mxnav2nav(argin[1]);
    ephopt = (int)mxGetScalar(argin[2]);

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
    argout[9] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    svhs = mxGetPr(argout[9]);
    mxSetNaN(svhs, m * nsat);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        obs = &obss[nsat * i];
        satposs(obs->time, obs, nsat, &nav, ephopt, rs, dts, var, svh);

        for (j = 0; j < nsat; j++) {
            if (norm(&rs[j * 6], 3) > 0.0) {
                x[i + m * j] = rs[0 + j * 6];
                y[i + m * j] = rs[1 + j * 6];
                z[i + m * j] = rs[2 + j * 6];
                vx[i + m * j] = rs[3 + j * 6];
                vy[i + m * j] = rs[4 + j * 6];
                vz[i + m * j] = rs[5 + j * 6];
                dtss[i + m * j] = dts[0 + j * 2] * CLIGHT;
                ddtss[i + m * j] = dts[1 + j * 2] * CLIGHT;
                vars[i + m * j] = var[j];
                svhs[i + m * j] = (double)svh[j];
            }
        }
    }
    free(obss);
    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
    if (nav.erp.n > 0) free(nav.erp.data);
}
