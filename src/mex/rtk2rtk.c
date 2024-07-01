/**
 * @file rtk2rtk.c
 * @brief Convert mxArray mxrtk to rtk_t rtk, and vice versa
 * @author Taro Suzuki
 */

#include "mex_utility.h"

/* rtk2mxrtk ----------------------------------------------------------*/
extern mxArray *rtk2mxrtk(const rtk_t *rtks, const int n) {
    mxArray *mxrtk, *mxep, *mxrb, *mxx, *mxP, *mxxa, *mxPa;
    double ep[6];
    int i;

    /* output struct */
    const char *rtkf[] = {"ep", "rb", "nx", "na",   "tt",   "x",
                          "P",   "xa", "Pa", "nfix", "errmsg"};
    mxrtk = mxCreateStructMatrix(n, 1, 11, rtkf);

    for (i = 0; i < n; i++) {
        /* epoch time */
        mxep = mxCreateDoubleMatrix(1, 6, mxREAL);
        time2epoch(rtks[i].sol.time, ep);
        memcpy(mxGetPr(mxep), ep, 6 * sizeof(double));
        mxSetField(mxrtk, i, "ep", mxep);
        /* rb */
        mxrb = mxCreateDoubleMatrix(1, 6, mxREAL);
        memcpy(mxGetPr(mxrb), rtks[i].rb, 6 * sizeof(double));
        mxSetField(mxrtk, i, "rb", mxrb);
        /* nx */
        mxSetField(mxrtk, i, "nx", mxCreateDoubleScalar(rtks[i].nx));
        /* na */
        mxSetField(mxrtk, i, "na", mxCreateDoubleScalar(rtks[i].na));
        /* tt */
        mxSetField(mxrtk, i, "tt", mxCreateDoubleScalar(rtks[i].tt));
        /* x */
        mxx = mxCreateDoubleMatrix(1, rtks[i].nx, mxREAL);
        memcpy(mxGetPr(mxx), rtks[i].x, rtks[i].nx * sizeof(double));
        mxSetField(mxrtk, i, "x", mxx);
        /* P */
        mxP = mxCreateDoubleMatrix(rtks[i].nx, rtks[i].nx, mxREAL);
        memcpy(mxGetPr(mxP), rtks[i].P, rtks[i].nx * rtks[i].nx * sizeof(double));
        mxSetField(mxrtk, i, "P", mxP);
        /* xa */
        mxxa = mxCreateDoubleMatrix(1, rtks[i].na, mxREAL);
        memcpy(mxGetPr(mxxa), rtks[i].xa, rtks[i].na * sizeof(double));
        mxSetField(mxrtk, i, "xa", mxxa);
        /* Pa */
        mxPa = mxCreateDoubleMatrix(rtks[i].na, rtks[i].na, mxREAL);
        memcpy(mxGetPr(mxPa), rtks[i].Pa, rtks[i].na * rtks[i].na * sizeof(double));
        mxSetField(mxrtk, i, "Pa", mxPa);
        /* nfix */
        mxSetField(mxrtk, i, "nfix", mxCreateDoubleScalar(rtks[i].nfix));
        /* errbuf */
        mxSetField(mxrtk, i, "errmsg", mxCreateString(rtks[i].errbuf));
    }

    return mxrtk;
}
/* mxrtk2rtk ----------------------------------------------------------*/
extern rtk_t mxrtk2rtk(const mxArray *mxrtk, const prcopt_t *popt, const sol_t *sol) {
    rtk_t rtk;
    double ep[6];

    rtkinit(&rtk, popt);

    /* sol */
    if (sol != NULL) {
       memcpy(&rtk.sol, sol, sizeof(sol));
    } else {
       memcpy(ep, (double *)mxGetPr(mxGetField(mxrtk, 0, "ep")), 6 * sizeof(double));
       rtk.sol.time = epoch2time(ep); 
    }
    /* rb */
    memcpy(rtk.rb, (double *)mxGetPr(mxGetField(mxrtk, 0, "rb")), 6 * sizeof(double));
    /* nx */
    rtk.nx = (int)mxGetScalar(mxGetField(mxrtk, 0, "nx"));
    /* na */
    rtk.na = (int)mxGetScalar(mxGetField(mxrtk, 0, "na"));
    /* tt */
    rtk.tt = mxGetScalar(mxGetField(mxrtk, 0, "tt"));
    /* x */
    memcpy(rtk.x, (double *)mxGetPr(mxGetField(mxrtk, 0, "x")),
           rtk.nx * sizeof(double));
    /* P */
    memcpy(rtk.P, (double *)mxGetPr(mxGetField(mxrtk, 0, "P")),
           rtk.nx * rtk.nx * sizeof(double));
    /* xa */
    memcpy(rtk.xa, (double *)mxGetPr(mxGetField(mxrtk, 0, "xa")),
           rtk.na * sizeof(double));
    /* Pa */
    memcpy(rtk.Pa, (double *)mxGetPr(mxGetField(mxrtk, 0, "Pa")),
           rtk.na * rtk.na * sizeof(double));
    /* nfix */
    rtk.nfix = (int)mxGetScalar(mxGetField(mxrtk, 0, "nfix"));

    return rtk;
}
