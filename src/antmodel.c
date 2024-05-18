/**
 * @file antmodel.c
 * @brief Compute antenna offset by antenna phase center parameters
 * @author Taro Suzuki
 * @note Wrapper for "antmodel" in rtkcmn.c
 */

#include "mex_utility.h"

#define NIN 6

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    pcv_t pcv = {0};
    int i, j, m, nsat, opt, freqidx;
    double *del, *azs, *els, *dant, azel[2], dantfreq[NFREQ];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfArgument(argin[0], 1, 1); /* pcv */
    mxCheckSizeOfArgument(argin[1], 1, 3); /* del */
    mxCheckSameSize(argin[2], argin[3]);   /* az,el */
    mxCheckScalar(argin[4]);               /* opt */
    mxCheckScalar(argin[5]);               /* freqidx */

    /* input */
    mxpcv2pcv(argin[0], 1, &pcv);
    del = (double *)mxGetPr(argin[1]);
    azs = (double *)mxGetPr(argin[2]);
    m = (int)mxGetM(argin[2]);
    nsat = (int)mxGetN(argin[2]);
    els = (double *)mxGetPr(argin[3]);
    opt = (int)mxGetScalar(argin[4]);
    freqidx = (int)mxGetScalar(argin[5]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    dant = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        for (j = 0; j < nsat; j++) {
            azel[0] = azs[i + m * j] * D2R;
            azel[1] = els[i + m * j] * D2R;
            antmodel(&pcv, del, azel, opt, &dantfreq);
            dant[i + m * j] = dantfreq[freqidx];
        }
    }
}
