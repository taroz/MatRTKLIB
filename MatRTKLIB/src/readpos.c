/**
 * @file readpos.c
 * @brief Read positions from station position file
 * @author Taro Suzuki
 * @note Wrapper for "readpos in rinex.c
 */

#include "mex_utility.h"

#define NIN 2

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i;
    char file[512], station[512];
    double *pos, posrad[3];

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]); /* station position file */
    mxCheckChar(argin[1]); /* station */

    /* input */
    mxGetString(argin[0], file, sizeof(file));
    mxGetString(argin[1], station, sizeof(station));

    /* output */
    argout[0] = mxCreateDoubleMatrix(1, 3, mxREAL);
    pos = mxGetPr(argout[0]);

    /* call RTKLIB function */
    readpos(file, station, &posrad);
    for (i=0; i<3; i++) pos[i] = posrad[i];
}
