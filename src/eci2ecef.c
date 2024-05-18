/**
 * @file eci2ecef.c
 * @brief Compute eci to ECEF transformation matrix
 * @author Taro Suzuki
 * @note Wrapper for "eci2ecef" in rtkcmn.c
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, nepoch;
    mwSize dims[3] = {3, 3, 0};
    double *U, Ut[9], utcep[6], *utcepoch, *erpv, *gmst;
    gtime_t tutc;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);     /* time in utc */
    mxCheckSizeOfArgument(argin[1], 1, 4); /* erp values */

    /* inputs */
    utcepoch = (double *)mxGetPr(argin[0]);
    nepoch = (int)mxGetM(argin[0]);
    erpv = (double *)mxGetPr(argin[1]);

    /* output */
    if (nepoch == 1) {
        argout[0] = mxCreateDoubleMatrix(3, 3, mxREAL);
    } else {
        dims[2] = nepoch;
        argout[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
    }
    argout[1] = mxCreateDoubleMatrix(nepoch, 1, mxREAL);
    U = mxGetPr(argout[0]);
    gmst = mxGetPr(argout[1]);

    /* call RTKLIB function */
    if (nepoch == 1) {
        tutc = epoch2time(utcepoch);
        eci2ecef(tutc, erpv, Ut, gmst);
        transpose_mw(Ut, dims, U);
    } else {
        for (i = 0; i < nepoch; i++) {
            utcep[0] = utcepoch[i + nepoch * 0];
            utcep[1] = utcepoch[i + nepoch * 1];
            utcep[2] = utcepoch[i + nepoch * 2];
            utcep[3] = utcepoch[i + nepoch * 3];
            utcep[4] = utcepoch[i + nepoch * 4];
            utcep[5] = utcepoch[i + nepoch * 5];
            tutc = epoch2time(utcep);
            eci2ecef(tutc, erpv, Ut, &gmst[i]);
            transpose_mw(Ut, dims, &U[3 * 3 * i]);
        }
    }
}
