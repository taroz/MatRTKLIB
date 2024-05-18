/**
 * @file enu2llh.c
 * @brief Transform local tangential coordinate to (lat,lon,ellipsoidal height)
 * @author Taro Suzuki
 * @note Input unit from radian to degree
 * @note Output transformation matrix
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, j, m;
    double e[3], x[3], l[3], o[3], orgxyz[3], *orgllh, *llh, *enu, *E;

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
    llh = mxGetPr(argout[0]);
    E = mxGetPr(argout[1]);

    o[0] = D2R * orgllh[0];
    o[1] = D2R * orgllh[1];
    o[2] = orgllh[2];

    pos2ecef(o, orgxyz);
    xyz2enu(o, E); /* enu -> ecef */

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        e[0] = enu[i + m * 0];
        e[1] = enu[i + m * 1];
        e[2] = enu[i + m * 2];
        if (mxIsNaN(e[0]) || mxIsNaN(e[1]) || mxIsNaN(e[2])) {
            llh[i + m * 0] = llh[i + m * 1] = llh[i + m * 2] = mxGetNaN();
            continue;
        }
        enu2ecef(o, e, x);
        x[0] += orgxyz[0];
        x[1] += orgxyz[1];
        x[2] += orgxyz[2];
        ecef2pos(x, l);
        llh[i + m * 0] = l[0] * R2D;
        llh[i + m * 1] = l[1] * R2D;
        llh[i + m * 2] = l[2];
    }
}
