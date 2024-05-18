/**
 * @file satantoff.c
 * @brief Compute satellite antenna phase center offset in ECEF coordinate
 * @author Taro Suzuki
 * @note Wrapper for "satantoff" in preceph.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 6

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    nav_t nav = {0};
    gtime_t time;
    int i, j, m, nsat;
    double ep[6], rs[3], *eps, *sats, *rsxs, *rsys, *rszs;
    double *dx, *dy, *dz, dant[3];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);      /* epochs */
    mxCheckSameRows(argin[0], argin[1]);     /* epochs,rsxs */
    mxCheckSameSize(argin[1], argin[2]);    /* rsxs,rsys */
    mxCheckSameSize(argin[2], argin[3]);    /* rsys,rszs */
    mxCheckSameColumns(argin[3], argin[4]); /* rszs,sats */
    mxCheckSizeOfRows(argin[4], 1);         /* sats */

    /* inputs */
    eps = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    rsxs = (double *)mxGetPr(argin[1]);
    rsys = (double *)mxGetPr(argin[2]);
    rszs = (double *)mxGetPr(argin[3]);
    sats = (double *)mxGetPr(argin[4]);
    nsat = (int)mxGetN(argin[4]);
    nav = mxnav2nav(argin[5]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    dx = mxGetPr(argout[0]);
    mxSetNaN(dx, m * nsat);
    argout[1] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    dy = mxGetPr(argout[1]);
    mxSetNaN(dy, m * nsat);
    argout[2] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    dz = mxGetPr(argout[2]);
    mxSetNaN(dz, m * nsat);

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
            if (mxIsNaN(rsxs[i + m * j])) continue;

            /* satellite position */
            rs[0] = rsxs[i + m * j];
            rs[1] = rsys[i + m * j];
            rs[2] = rszs[i + m * j];

            /* compute satellite antenna phase center offset */
            satantoff(time, rs, (int)sats[j], &nav, dant);
            dx[i + m * j] = dant[0];
            dy[i + m * j] = dant[1];
            dz[i + m * j] = dant[2];
        }
    }
    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
}
