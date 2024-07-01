/**
 * @file enu2xyz.c
 * @brief Transform local tangential coordinate to ECEF coordinate
 * @author Taro Suzuki
 * @note Output transformation matrix
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, j, m;
    double e[3], x[3], o[3], oxyz[3], *orgllh, *xyz, *enu, *E;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 3);     /* enu */
    mxCheckSizeOfArgument(argin[1], 1, 3); /* orgllh */

    /* inputs */
    enu = (double *)mxGetPr(argin[0]);
    orgllh = (double *)mxGetPr(argin[1]);
    m = (int)mxGetM(argin[0]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, 3, mxREAL);
    argout[1] = mxCreateDoubleMatrix(3, 3, mxREAL);
    xyz = mxGetPr(argout[0]);
    E = mxGetPr(argout[1]);

    o[0] = D2R * orgllh[0];
    o[1] = D2R * orgllh[1];
    o[2] = orgllh[2];

    pos2ecef(o, oxyz);
    xyz2enu(o, E); /* enu -> ecef */

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        e[0] = enu[i + m * 0];
        e[1] = enu[i + m * 1];
        e[2] = enu[i + m * 2];
        enu2ecef(o, e, x);
        xyz[i + m * 0] = x[0] + oxyz[0];
        xyz[i + m * 1] = x[1] + oxyz[1];
        xyz[i + m * 2] = x[2] + oxyz[2];
    }
}
