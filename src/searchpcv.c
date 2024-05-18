/**
 * @file searchpcv.c
 * @brief Search antenna parameter
 * @author Taro Suzuki
 * @note Wrapper for "searchpcv" in rtkcmn.c
 */

#include "mex_utility.h"

#define NIN 4

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    pcv_t *pcvs_pcv, pcv0 = {0}, *pcv;
    pcvs_t pcvs = {0};
    gtime_t time;
    int sat, n;
    char type[MAXANT];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckScalar(argin[0]);               /* sat */
    mxCheckChar(argin[1]);                 /* antenna type */
    mxCheckSizeOfArgument(argin[2], 1, 6); /* epoch */

    /* pcvs */
    n = mxGetSize(argin[3]);
    if (!(pcvs_pcv = (pcv_t *)malloc(n * sizeof(pcv_t)))) {
        mexErrMsgTxt("searchpcv: memory allocation error");
    }

    /* input */
    sat = (int)mxGetScalar(argin[0]);
    mxGetString(argin[1], type, sizeof(type));
    time = epoch2time(mxGetPr(argin[2]));
    mxpcv2pcv(argin[3], n, pcvs_pcv);
    
    /* set pcvs_t */
    pcvs.n = pcvs.nmax = n;
    pcvs.pcv = pcvs_pcv;

    /* call RTKLIB function */
    pcv = searchpcv(sat, type, time, &pcvs);

    /* output */
    argout[0] = pcv2mxpcv(pcv ? pcv : &pcv0, 1);

    free(pcvs_pcv);
}
