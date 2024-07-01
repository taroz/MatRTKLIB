/**
 * @file satpos.c
 * @brief Compute satellite position, velocity and clock
 * @author Taro Suzuki
 * @note Wrapper for "satpos" in ephemeris.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 4

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    nav_t nav = {0};
    gtime_t t;
    char satstr[32], errmsg[512];
    int i, j, m, nsat, svh, ephopt;
    double ep[6], *eps, *sats, rs[6], dts[2], var;
    double *x, *y, *z, *vx, *vy, *vz, *dtss, *ddtss, *vars, *svhs;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6); /* epochs*/
    mxCheckSizeOfRows(argin[1], 1);    /* sats */
    mxCheckScalar(argin[3]);           /* ephopt */

    /* inputs */
    eps = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    sats = (double *)mxGetPr(argin[1]);
    nsat = (int)mxGetN(argin[1]);
    nav = mxnav2nav(argin[2]);
    ephopt = (int)mxGetScalar(argin[3]);

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
        ep[0] = eps[i + m * 0];
        ep[1] = eps[i + m * 1];
        ep[2] = eps[i + m * 2];
        ep[3] = eps[i + m * 3];
        ep[4] = eps[i + m * 4];
        ep[5] = eps[i + m * 5];
        t = epoch2time(ep);

        for (j = 0; j < nsat; j++) {
            /* satellite clock bias by broadcast ephemeris */
            if (!satpos(t, t, (int)sats[j], ephopt, &nav, rs, dts, &var, &svh)) {
                satno2id((int)sats[j], satstr);
                sprintf(errmsg, "no ephemeris %s sat=%s", time_str(t, 3), satstr);
                mexWarnMsgTxt(errmsg);
                continue;
            }
            x[i + m * j] = rs[0];
            y[i + m * j] = rs[1];
            z[i + m * j] = rs[2];
            vx[i + m * j] = rs[3];
            vy[i + m * j] = rs[4];
            vz[i + m * j] = rs[5];
            dtss[i + m * j] = dts[0] * CLIGHT;
            ddtss[i + m * j] = dts[1] * CLIGHT;
            vars[i + m * j] = var;
            svhs[i + m * j] = (double)svh;
        }
    }
    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
    if (nav.erp.n > 0) free(nav.erp.data);
}
