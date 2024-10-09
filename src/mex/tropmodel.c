/**
 * @file tropmodel.c
 * @brief Compute tropospheric delay by standard atmosphere and saastamoinen model
 * @author Taro Suzuki
 * @note Wrapper for "tropmodel" in rtkcmn.c
 * @note Change input unit from radian to degree
 * @note Add tropospheric delay variance to output
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 4

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    gtime_t time;
    int i, j, m, nsat, neps, nllhs;
    double ep[6], llh[3], azel[2], *eps, *llhs, *azs, *els, *trps, *vars;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);   /* epoch */
    mxCheckSizeOfColumns(argin[1], 3);   /* llh */
    mxCheckSameSize(argin[2], argin[3]); /* az,el */

    /* inputs */
    eps = (double *)mxGetPr(argin[0]);
    neps = (int)mxGetM(argin[0]);
    llhs = (double *)mxGetPr(argin[1]);
    nllhs = (int)mxGetM(argin[1]);
    azs = (double *)mxGetPr(argin[2]);
    nsat = (int)mxGetN(argin[2]);
    els = (double *)mxGetPr(argin[3]);

    if (neps != 1 && nllhs != 1 && neps != nllhs) {
		mexErrMsgTxt("Either the number of epochs or the number of received positions must be 1 or the same");
	}
    m = neps>=nllhs?neps:nllhs;
    //mexPrintf("m=%d nsat=%d neps=%d nllhs=%d\n", m, nsat, neps, nllhs);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    trps = mxGetPr(argout[0]);
    mxSetNaN(trps, m * nsat);
    argout[1] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    vars = mxGetPr(argout[1]);
    mxSetNaN(vars, m * nsat);

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        if (neps == 1) {
	        ep[0] = eps[0];
	        ep[1] = eps[1];
	        ep[2] = eps[2];
	        ep[3] = eps[3];
	        ep[4] = eps[4];
	        ep[5] = eps[5];
        } else {
	        ep[0] = eps[i + m * 0];
	        ep[1] = eps[i + m * 1];
	        ep[2] = eps[i + m * 2];
	        ep[3] = eps[i + m * 3];
	        ep[4] = eps[i + m * 4];
	        ep[5] = eps[i + m * 5];
        }
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
            trps[i + m * j] = tropmodel(time, llh, azel, REL_HUMI);
            vars[i + m * j] = SQR(ERR_SAAS / (sin(azel[1]) + 0.1));
        }
    }
}
