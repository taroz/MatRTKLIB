/**
 * @file covenusol.c
 * @brief Transform ECEF "covariance" to local tangential coordinate
 * @author Taro Suzuki
 * @note Wrapper for "covenu" in rtkcmn.c
 * @note RTKLIB solution format of covariance (Mx6 vectors)
 * @note Change input unit from radian to degree
 * @note Support vector inputs
 */

#include "mex_utility.h"

#define NIN 2

static void soltocov(const double *S, double *P) {
    P[0] = S[0];        /* xx or ee */
    P[4] = S[1];        /* yy or nn */
    P[8] = S[2];        /* zz or uu */
    P[1] = P[3] = S[3]; /* xy or en */
    P[5] = P[7] = S[4]; /* yz or nu */
    P[2] = P[6] = S[5]; /* zx or ue */
}
static void covtosol(const double *P, double *S) {
    S[0] = (float)P[0]; /* xx or ee */
    S[1] = (float)P[4]; /* yy or nn */
    S[2] = (float)P[8]; /* zz or uu */
    S[3] = (float)P[1]; /* xy or en */
    S[4] = (float)P[5]; /* yz or nu */
    S[5] = (float)P[2]; /* zx or ue */
}

/* mex interface */
extern void mexFunction(int nargout, mxArray *argout[], int nargin,
                        const mxArray *argin[]) {
    int i, m;
    double S[6], P[9], Q[9], o[3], *orgllh, *Pecef, *Qenu;

    /* check arguments */
    mxCheckNumberOfArguments(nargin, NIN);
    mxCheckSizeOfColumns(argin[0], 6);     /* Pecef */
    mxCheckSizeOfArgument(argin[1], 1, 3); /* orgllh */

    /* inputs */
    Pecef = (double *)mxGetPr(argin[0]);
    orgllh = (double *)mxGetPr(argin[1]);
    m = (int)mxGetM(argin[0]);

    /* output */
    argout[0] = mxCreateDoubleMatrix(m, 6, mxREAL);
    Qenu = mxGetPr(argout[0]);

    o[0] = D2R * orgllh[0];
    o[1] = D2R * orgllh[1];
    o[2] = orgllh[2];

    /* call RTKLIB function */
    for (i = 0; i < m; i++) {
        S[0] = Pecef[i + m * 0];
        S[1] = Pecef[i + m * 1];
        S[2] = Pecef[i + m * 2];
        S[3] = Pecef[i + m * 3];
        S[4] = Pecef[i + m * 4];
        S[5] = Pecef[i + m * 5];
        soltocov(S, P);
        covenu(o, P, Q);
        covtosol(Q, S);
        Qenu[i + m * 0] = S[0];
        Qenu[i + m * 1] = S[1];
        Qenu[i + m * 2] = S[2];
        Qenu[i + m * 3] = S[3];
        Qenu[i + m * 4] = S[4];
        Qenu[i + m * 5] = S[5];
    }
}
