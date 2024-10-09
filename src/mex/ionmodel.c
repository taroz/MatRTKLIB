/**
 * @file ionmodel.c
 * @brief Compute ionospheric delay by broadcast ionosphere model (klobuchar model)
 * @author Taro Suzuki
 * @note Wrapper for "ionmodel" in rtkcmn.c
 * @note Change input unit from radian to degree
 * @note Add ionospheric delay variance to output
 * @note Add frequency compensation
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 6

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    gtime_t time;
    int i, j, m, nsat, neps, nllhs;
    double ep[6], llh[3], azel[2], ion, var;
    double *eps, *ionparm, *llhs, *ions, *vars, *azs, *els, *frqs;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);      /* epoch */
    mxCheckSizeOfArgument(argin[1], 1, 8);  /* ionparam */
    mxCheckSizeOfColumns(argin[2], 3);      /* llh */
    mxCheckSameSize(argin[3], argin[4]);    /* az,el */
    mxCheckSameColumns(argin[4], argin[5]); /* frequency */

    /* inputs */
    eps = (double *)mxGetPr(argin[0]);
    neps = (int)mxGetM(argin[0]);
    ionparm = (double *)mxGetPr(argin[1]);
    llhs = (double *)mxGetPr(argin[2]);
    nllhs = (int)mxGetM(argin[2]);
    azs = (double *)mxGetPr(argin[3]);
    nsat = (int)mxGetN(argin[3]);
    els = (double *)mxGetPr(argin[4]);
    frqs = (double *)mxGetPr(argin[5]);

    if (neps != 1 && nllhs != 1 && neps != nllhs) {
		mexErrMsgTxt("Either the number of epochs or the number of received positions must be 1 or the same");
	}
    m = neps>=nllhs?neps:nllhs;
    //mexPrintf("m=%d nsat=%d neps=%d nllhs=%d\n", m, nsat, neps, nllhs);

    /* outputs */
    argout[0] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    ions = mxGetPr(argout[0]);
    mxSetNaN(ions, m * nsat);
    argout[1] = mxCreateDoubleMatrix(m, nsat, mxREAL);
    vars = mxGetPr(argout[1]);
    mxSetNaN(vars, m * nsat);

    // mexPrintf("ion_parm:%.10f %.10f %.10f %.10f\n", 
	// ionparm[0], ionparm[1], ionparm[2], ionparm[3]);

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
            ion = ionmodel(time, ionparm, llh, azel);
            var = SQR(ion * ERR_BRDCI);

            /* frequency compensation */
            ion *= SQR(FREQ1 / frqs[j]);
            var *= SQR(FREQ1 / frqs[j]);

            ions[i + m * j] = ion;
        }
    }
}
