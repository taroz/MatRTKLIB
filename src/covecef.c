/**
 * @file covecef.c
 * @brief Transform local tangential coordinate "covariance" to ECEF coordinate
 * @author Taro Suzuki
 * @note Wrapper for "covecef" in rtkcmn.c
 * @note Change input unit from radian to degree
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i;
    const mwSize *dims, dims2d[3] = {3, 3, 0};
    double o[3], Peceft[9], *orgllh, *Pecef, *Qenu, *Qenut;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfArgument(argin[0], 3, 3); /* Qenu */
    mxCheckSizeOfArgument(argin[1], 1, 3); /* orgllh */

    /* inputs */
    Qenu = (double *)mxGetPr(argin[0]);
    orgllh = (double *)mxGetPr(argin[1]);
    dims = mxGetDimensions(argin[0]);
    Qenut = transpose_mw_malloc(Qenu, dims);

    /* output */
    if (dims[2] == 0) {
        argout[0] = mxCreateDoubleMatrix(3, 3, mxREAL);
    } else {
        argout[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
    }
    Pecef = mxGetPr(argout[0]);

    o[0] = D2R * orgllh[0];
    o[1] = D2R * orgllh[1];
    o[2] = orgllh[2];

    /* call RTKLIB function */
    if (dims[2] == 0) {
        covecef(o, Qenut, Peceft);
        transpose_mw(Peceft, dims2d, Pecef);
    } else {
        for (i = 0; i < dims[2]; i++) {
            covecef(o, &Qenut[3 * 3 * i], Peceft);
            transpose_mw(Peceft, dims2d, &Pecef[3 * 3 * i]);
        }
    }
    free(Qenut);
}
