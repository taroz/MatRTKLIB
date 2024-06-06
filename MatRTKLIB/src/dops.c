/**
 * @file dops.c
 * @brief Compute DOP (dilution of precision) from azimuth and elevation
 * @author Taro Suzuki
 * @note Wrapper for "dops" in rtkcmn.c
 * @note Change input unit from radian to degree *
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 3

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, j, m, nsat;
    double azel[MAXSAT * 2] = {0};
    double elmin, dop[4], *azs, *els, *dopout;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSameSize(argin[0], argin[1]); /* az,el */
    mxCheckScalar(argin[2]);             /* elmin */

    /* inputs */
    azs = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    els = (double *)mxGetPr(argin[1]);
    nsat = (int)mxGetN(argin[1]);
    elmin = (double)mxGetScalar(argin[2]) * D2R;

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, 4, mxREAL);
    dopout = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        for (j = 0; j < nsat; j++) {
            azel[2 * j] = azs[i + m * j] * D2R;
            azel[2 * j + 1] = els[i + m * j] * D2R;
        }
        dops(nsat, azel, elmin, dop);
        if (dop[0] == 0) {
            dopout[i + m * 0] = dopout[i + m * 1] = dopout[i + m * 2] =
                dopout[i + m * 3] = mxGetNaN();
            continue;
        } else {
            dopout[i + m * 0] = dop[0];
            dopout[i + m * 1] = dop[1];
            dopout[i + m * 2] = dop[2];
            dopout[i + m * 3] = dop[3];
        }
    }
}
