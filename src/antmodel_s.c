/**
 * @file antmodel_s.c
 * @brief Compute satellite antenna phase center parameters
 * @author Taro Suzuki
 * @note Wrapper for "antmodel_s" in rtkcmn.c
 */

#include "mex_utility.h"

#define NIN 4

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    pcv_t pcvs[MAXSAT] = {{0}};
    int i, j, m, nsat, freqidx;
    double *sat, *nadir, *dant, azel[2], dantfreq[NFREQ];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfArgument(argin[0], MAXSAT, 1); /* pcv */
    mxCheckSameColumns(argin[1], argin[2]);     /* sat,nadir */
    mxCheckScalar(argin[3]);                    /* freqidx */

    /* input */
    mxpcv2pcv(argin[0], MAXSAT, pcvs);
    sat = (double *)mxGetPr(argin[1]);
    nsat = (int)mxGetN(argin[1]);
    nadir = (double *)mxGetPr(argin[2]);
    m = (int)mxGetM(argin[2]);
    freqidx = (int)mxGetScalar(argin[3]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    dant = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        for (j = 0; j < nsat; j++) {
            antmodel_s(&pcvs[(int)sat[j] - 1], nadir[i + m * j] * D2R,
                       &dantfreq);
            dant[i + m * j] = dantfreq[freqidx];
        }
    }
}
