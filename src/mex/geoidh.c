/**
 * @file geoidh.c
 * @brief Get geoid height from geoid model
 * @author Taro Suzuki
 * @note Wrapper for "geoidh" in geoid.c
 * @note Change input unit from radian to degree
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    char file[512], errmsg[512];
    double *lat, *lon, *geoh, pos[2];
    int i, m, n, model;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSameSize(argin[0], argin[1]); /* lat,lon */
    if (nargin == 3) mexErrMsgTxt("geoid type and file path are required");
    if (nargin == 4) {
        mxCheckScalar(argin[2]); /* Geoid type */
        mxCheckChar(argin[3]);   /* Geoid file */
    }
    /* input */
    lat = (double *)mxGetPr(argin[0]);
    lon = (double *)mxGetPr(argin[1]);
    m = (int)mxGetM(argin[0]);
    n = (int)mxGetN(argin[0]);
    if (nargin == 4) {
        model = (int)mxGetScalar(argin[2]);
        mxGetString(argin[3], file, sizeof(file));
    }

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    geoh = mxGetPr(argout[0]);

    /* call RTKLIB function */
    if (nargin == 4) {
        if (!opengeoid(model, file)) {
            sprintf(errmsg, "geoid model file open error: %s",file);
            mexErrMsgTxt(errmsg);
        }
    }
    for (i = 0; i < m * n; i++) {
        pos[0] = lat[i] * D2R;
        pos[1] = lon[i] * D2R;
        geoh[i] = geoidh(pos);
    }
    if (nargin == 4) closegeoid();
}
