/**
 * @file ionppp.c
 * @brief Compute ionospheric pierce point (ipp) position and slant factor
 * @author Taro Suzuki
 * @note Wrapper for "ionppp" in rtkcmn.c
 * @note Change input unit from radian to degree
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 5

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, j, m, nsat, nllhs;
    double llh[3], azel[2], re, hion, fs, posp[3];
    double *fss, *latp, *lonp, *hp, *llhs, *azs, *els;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 3);   /* llh */
    mxCheckSameSize(argin[1], argin[2]); /* az,el */
    mxCheckScalar(argin[3]);             /* re */
    mxCheckScalar(argin[4]);             /* hion */

    /* inputs */
    llhs = (double *)mxGetPr(argin[0]);
    nllhs = (int)mxGetM(argin[0]);
    azs = (double *)mxGetPr(argin[1]);
    nsat = (int)mxGetN(argin[1]);
    m = (int)mxGetM(argin[1]);
    els = (double *)mxGetPr(argin[2]);
    re = (double)mxGetScalar(argin[3]);
    hion = (double)mxGetScalar(argin[4]);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    fss = mxGetPr(argout[0]);
    argout[1] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    latp = mxGetPr(argout[1]);
    argout[2] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    lonp = mxGetPr(argout[2]);
    argout[3] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    hp = mxGetPr(argout[3]);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
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
            fs = ionppp(llh, azel, re, hion, posp);
            fss[i + m * j] = fs;
            latp[i + m * j] = posp[0] * R2D;
            lonp[i + m * j] = posp[1] * R2D;
            hp[i + m * j] = posp[2];
        }
    }
}
