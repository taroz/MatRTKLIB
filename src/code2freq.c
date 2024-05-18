/**
 * @file mex_code2freq.c
 * @brief Convert system and obs code to carrier frequency
 * @author Taro Suzuki
 * @note Wrapper for "code2freq" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, m, n;
    double *sys, *code, *frq, *dfcn;
    char msg[512];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckDouble(argin[0]);             /* sys */
    mxCheckDouble(argin[1]);             /* code */
    mxCheckSameSize(argin[0], argin[1]); /* sys,code */
    if (nargin == 3) {
        mxCheckDouble(argin[2]);             /* fcn */
        mxCheckSameSize(argin[1], argin[2]); /* code,fcn*/
    }

    /* inputs */
    sys = (double *)mxGetPr(argin[0]);
    m = (int)mxGetM(argin[0]);
    n = (int)mxGetN(argin[0]);
    code = (double *)mxGetPr(argin[1]);
    if (nargin == 3) {
        dfcn = (double *)mxGetPr(argin[2]);
    }

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    frq = mxGetPr(argout[0]);

    /* call RTKLIB function */
    for (i = 0; i < m * n; i++) {
        if (nargin == 3) {
            if ((int)sys[i]==SYS_GLO && ((int)dfcn[i]<-7 || (int)dfcn[i]>6)) {
                sprintf(msg, "Wrong GLONASS FCN: %d", (int)dfcn[i]);
                mexWarnMsgTxt(msg);
            }
            frq[i] = code2freq((int)sys[i], (uint8_t)code[i], (int)dfcn[i]);
        } else {
            frq[i] = code2freq((int)sys[i], (uint8_t)code[i], 0);
        }
    }
}
