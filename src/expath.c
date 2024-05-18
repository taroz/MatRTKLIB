/**
 * @file expath.c
 * @brief Expand file path with wild-card (*) in file
 * @author Taro Suzuki
 * @note Wrapper for "expath" in rtkcmn.c
 */

#include "mex_utility.h"

#define NIN 1

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, n, nmax = 10;
    char path[512];
    char **paths = (char **)malloc(nmax*sizeof(char *));
    for (i = 0; i < nmax; i++) {
        paths[i] = (char *)malloc(512 * sizeof(char));
    }

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckChar(argin[0]); /* file path */

    /* input */
    mxGetString(argin[0], path, 512);
    //mexPrintf("%s\n",path);

    /* call RTKLIB function */
    n = expath(path, paths, nmax);

    /* outputs */
    argout[0] = mxCreateCellMatrix(1, n);

    for (i = 0; i < n; i++) {
        mxSetCell(argout[0], i, mxCreateString(paths[i]));
    }

    free(paths);
}