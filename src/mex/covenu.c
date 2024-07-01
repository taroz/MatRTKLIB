/**
 * @file covenu.c
 * @brief Transform ECEF "covariance" to local tangential coordinate
 * @author Taro Suzuki
 * @note Wrapper for "covenu" in rtkcmn.c
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
    double o[3], Qenut[9], *orgllh, *Pecef, *Peceft, *Qenu;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfArgument(argin[0], 3, 3); /* Pecef */
    mxCheckSizeOfArgument(argin[1], 1, 3); /* orgllh */

    /* inputs */
    Pecef = (double *)mxGetPr(argin[0]);
    orgllh = (double *)mxGetPr(argin[1]);
    dims = mxGetDimensions(argin[0]);
    Peceft = transpose_mw_malloc(Pecef, dims);

    /* output */
    if (dims[2] == 0) {
        argout[0] = mxCreateDoubleMatrix(3, 3, mxREAL);
    } else {
        argout[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
    }
    Qenu = mxGetPr(argout[0]);

    o[0] = D2R * orgllh[0];
    o[1] = D2R * orgllh[1];
    o[2] = orgllh[2];

    /* call RTKLIB function */
    if (dims[2] == 0) {
        covenu(o, &Peceft[0], Qenut);
        transpose_mw(Qenut, dims2d, Qenu);
    } else {
        for (i = 0; i < dims[2]; i++) {
            covenu(o, &Peceft[3 * 3 * i], Qenut);
            transpose_mw(Qenut, dims2d, &Qenu[3 * 3 * i]);
        }
    }
    free(Peceft);
}
