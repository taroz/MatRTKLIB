/**
 * @file llh2enu.c
 * @brief Transform (lat,lon,ellipsoidal height) to local tangential coordinate
 * @author Taro Suzuki
 * @note Output transformation matrix
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    const mwSize dims[3] = {3, 3, 0};
    int i, j, m;
    double l[3], x[3], e[3], o[3], Et[9], orgxyz[3], *orgllh, *llh, *enu, *E;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 3);     /* llh */
    mxCheckSizeOfArgument(argin[1], 1, 3); /* orgllh */

    /* inputs */
    llh = (double *)mxGetPr(argin[0]);
    orgllh = (double *)mxGetPr(argin[1]);
    m = (int)mxGetM(argin[0]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, 3, mxREAL);
    argout[1] = mxCreateDoubleMatrix(3, 3, mxREAL);
    enu = mxGetPr(argout[0]);
    E = mxGetPr(argout[1]);

    o[0] = D2R * orgllh[0];
    o[1] = D2R * orgllh[1];
    o[2] = orgllh[2];

    pos2ecef(o, orgxyz);
    xyz2enu(o, Et);
    transpose_mw(Et, dims, E); /* transpose, ecef -> enu */

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        l[0] = llh[i + m * 0] * D2R;
        l[1] = llh[i + m * 1] * D2R;
        l[2] = llh[i + m * 2];
        pos2ecef(l, x);
        x[0] -= orgxyz[0];
        x[1] -= orgxyz[1];
        x[2] -= orgxyz[2];
        ecef2enu(o, x, e);
        enu[i + m * 0] = e[0];
        enu[i + m * 1] = e[1];
        enu[i + m * 2] = e[2];
    }
}
