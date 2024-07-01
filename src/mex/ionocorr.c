/**
 * @file ionocorr.c
 * @brief Compute ionospheric correction
 * @author Taro Suzuki
 * @note Wrapper for "ionocorr" in rtkcmn.c
 * @note Change input unit from radian to degree
 * @note Add frequency compensation
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 6

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    nav_t nav = {0};
    gtime_t time;
    int i, j, m, nsat, nllhs, ionoopt;
    double ep[6], llh[3], azel[2], ion, var;
    double *eps, *ionparm, *llhs, *ions, *vars, *azs, *els, *frqs;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);      /* epoch */
    mxCheckSizeOfColumns(argin[2], 3);      /* llh */
    mxCheckSameRows(argin[0], argin[3]);    /* epoch,az */
    mxCheckSameSize(argin[3], argin[4]);    /* az,el */
    mxCheckScalar(argin[5]);                /* ionoopt */
    mxCheckSameColumns(argin[4], argin[6]); /* frequency */

    /* inputs */
    eps = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    nav = mxnav2nav(argin[1]);
    llhs = (double *)mxGetPr(argin[2]);
    nllhs = (int)mxGetM(argin[2]);
    azs = (double *)mxGetPr(argin[3]);
    nsat = (int)mxGetN(argin[3]);
    els = (double *)mxGetPr(argin[4]);
    ionoopt = (int)mxGetScalar(argin[5]);
    frqs = (double *)mxGetPr(argin[6]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    ions = mxGetPr(argout[0]);
    mxSetNaN(ions, m * nsat);
    argout[1] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    vars = mxGetPr(argout[1]);
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

        if (nllhs == 1) {
            llh[0] = llhs[0] * D2R;
            llh[1] = llhs[1] * D2R;
            llh[2] = llhs[2];
        } else {
            llh[0] = llhs[i + m * 0] * D2R;
            llh[1] = llhs[i + m * 1] * D2R;
            llh[2] = llhs[i + m * 2];
        }

        for (j = 0; j < nsat; j++) {
            azel[0] = azs[i + m * j] * D2R;
            azel[1] = els[i + m * j] * D2R;
            ionocorr(time, &nav, 0, llh, azel, ionoopt, &ion, &var);

            /* frequency compensation */
            ion *= SQR(FREQ1 / frqs[j]);
            var *= SQR(FREQ1 / frqs[j]);

            ions[i + m * j] = ion;
        }
    }

    if (nav.n > 0) free(nav.eph);
    if (nav.ng > 0) free(nav.geph);
    if (nav.ne > 0) free(nav.peph);
    if (nav.nc > 0) free(nav.pclk);
}
