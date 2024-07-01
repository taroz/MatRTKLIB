/**
 * @file obs2obs.c
 * @brief Convert mxArray mxobs to obsd_t obs, and vice versa
 * @author Taro Suzuki
 */

#include "mex_utility.h"

static void SetNaNtoObs(int n, int nsat, double *P, double *L, double *D,
                        double *S, double *I) {
    mxSetNaN(P, n * nsat);
    mxSetNaN(L, n * nsat);
    mxSetNaN(D, n * nsat);
    mxSetNaN(S, n * nsat);
}
static void SetFreqStruct(mxArray *mxFL, mxArray *mxP, mxArray *mxL,
                          mxArray *mxD, mxArray *mxS, mxArray *mxI,
                          mxArray *mxctype) {
    mxSetField(mxFL, 0, "P", mxP);
    mxSetField(mxFL, 0, "L", mxL);
    mxSetField(mxFL, 0, "D", mxD);
    mxSetField(mxFL, 0, "S", mxS);
    mxSetField(mxFL, 0, "I", mxI);
    mxSetField(mxFL, 0, "ctype", mxctype);
}
static void SetObs(int j, int n, int k, int si, double *P, double *L, double *D,
                   double *S, double *I, uint8_t *ctype, int *recv,
                   obsd_t data) {
    P[j + n * si] = data.P[k] == 0.0 ? mxGetNaN() : data.P[k];
    L[j + n * si] = data.L[k] == 0.0 ? mxGetNaN() : data.L[k];
    D[j + n * si] = data.D[k] == 0.0 ? mxGetNaN() : data.D[k];
    S[j + n * si] =
        data.SNR[k] == 0 ? mxGetNaN() : (double)data.SNR[k] * SNR_UNIT;
    I[j + n * si] = data.LLI[k] == 0 ? mxGetNaN() : (double)data.LLI[k];
    if (ctype[si] == 0) ctype[si] = data.code[k];
    if (data.P[k] != 0.0) (*recv) = 1;
}
static bool nisnan(double d) {
    if (mxIsNaN(d) || d == 0.0)
        return false;
    else
        return true;
}

/* obs2mxobs ----------------------------------------------------------*/
extern mxArray *obs2mxobs(const obsd_t *obs, const int n, const int *nobslist) {
    obsd_t data;
    char satstr[10];
    int si[MAXSAT] = {0}, nsat = 0, i, j, iobs = 0, iweek, prn, sys;
    double ep[6], *eps, *week, *tow, *prns, *syss, *sats;
    int recv1 = 0, recv2 = 0, recv5 = 0, recv6 = 0, recv7 = 0, recv8 = 0,
        recv9 = 0;
    uint8_t ctype1[MAXSAT] = {0}, ctype2[MAXSAT] = {0}, ctype5[MAXSAT] = {0},
            ctype6[MAXSAT] = {0}, ctype7[MAXSAT] = {0}, ctype8[MAXSAT] = {0},
            ctype9[MAXSAT] = {0};
    double *P1, *L1, *D1, *S1, *I1;
    double *P2, *L2, *D2, *S2, *I2;
    double *P5, *L5, *D5, *S5, *I5;
    double *P6, *L6, *D6, *S6, *I6;
    double *P7, *L7, *D7, *S7, *I7;
    double *P8, *L8, *D8, *S8, *I8;
    double *P9, *L9, *D9, *S9, *I9;
    mxArray *mxobs;
    mxArray *mxP1, *mxL1, *mxD1, *mxS1, *mxI1, *mxctype1;
    mxArray *mxP2, *mxL2, *mxD2, *mxS2, *mxI2, *mxctype2;
    mxArray *mxP5, *mxL5, *mxD5, *mxS5, *mxI5, *mxctype5;
    mxArray *mxP6, *mxL6, *mxD6, *mxS6, *mxI6, *mxctype6;
    mxArray *mxP7, *mxL7, *mxD7, *mxS7, *mxI7, *mxctype7;
    mxArray *mxP8, *mxL8, *mxD8, *mxS8, *mxI8, *mxctype8;
    mxArray *mxP9, *mxL9, *mxD9, *mxS9, *mxI9, *mxctype9;
    mxArray *mxep, *mxweek, *mxtow, *mxsat, *mxprn, *mxsys, *mxsatstr;
    mxArray *mxFL1, *mxFL2, *mxFL5, *mxFL6, *mxFL7, *mxFL8, *mxFL9;

    /* check available satellites */
    for (i = 0; i < n; i++) {
        for (j = 0; j < nobslist[i]; j++) {
            data = obs[iobs++];
            if (!si[data.sat - 1]) si[data.sat - 1] = 1;
        }
    }

    /* count received satellites */
    for (i = 0; i < MAXSAT; i++) {
        if (si[i])
            si[i] = nsat++;
        else
            si[i] = -1;
    }

    mxsat = mxCreateDoubleMatrix(1, nsat, mxREAL);
    sats = mxGetPr(mxsat);
    mxprn = mxCreateDoubleMatrix(1, nsat, mxREAL);
    prns = mxGetPr(mxprn);
    mxsys = mxCreateDoubleMatrix(1, nsat, mxREAL);
    syss = mxGetPr(mxsys);
    mxep = mxCreateDoubleMatrix(n, 6, mxREAL);
    eps = mxGetPr(mxep);
    mxtow = mxCreateDoubleMatrix(n, 1, mxREAL);
    tow = mxGetPr(mxtow);
    mxweek = mxCreateDoubleMatrix(n, 1, mxREAL);
    week = mxGetPr(mxweek);
    mxsatstr = mxCreateCellMatrix(1, nsat);

    for (i = 0, j = 0; i < MAXSAT; i++) {
        if (si[i] >= 0) {
            sats[j] = i + 1;
            sys = satsys(i + 1, &prn);
            satno2id(i + 1, satstr);
            prns[j] = (double)prn;
            syss[j] = (double)sys;
            mxSetCell(mxsatstr, j, mxCreateString(satstr));
            j++;
        }
    }

    const char *obsf[] = {"n",  "nsat", "sat",  "prn", "sys", "satstr",
                          "ep", "tow",  "week", "L1",  "L2",  "L5",
                          "L6", "L7",   "L8",   "L9"};
    const char *frqf[] = {"P", "L", "D", "S", "I", "ctype"};
    mxobs = mxCreateStructMatrix(1, 1, 16, obsf);
    mxSetField(mxobs, 0, "n", mxCreateDoubleScalar(n));
    mxSetField(mxobs, 0, "nsat", mxCreateDoubleScalar(nsat));
    mxSetField(mxobs, 0, "sat", mxsat);
    mxSetField(mxobs, 0, "prn", mxprn);
    mxSetField(mxobs, 0, "sys", mxsys);
    mxSetField(mxobs, 0, "satstr", mxsatstr);

    mxFL1 = mxCreateStructMatrix(1, 1, 6, frqf);
    mxFL2 = mxCreateStructMatrix(1, 1, 6, frqf);
    mxFL5 = mxCreateStructMatrix(1, 1, 6, frqf);
    mxFL6 = mxCreateStructMatrix(1, 1, 6, frqf);
    mxFL7 = mxCreateStructMatrix(1, 1, 6, frqf);
    mxFL8 = mxCreateStructMatrix(1, 1, 6, frqf);
    mxFL9 = mxCreateStructMatrix(1, 1, 6, frqf);

    mxP1 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    P1 = mxGetPr(mxP1);
    mxL1 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    L1 = mxGetPr(mxL1);
    mxD1 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    D1 = mxGetPr(mxD1);
    mxS1 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    S1 = mxGetPr(mxS1);
    mxI1 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    I1 = mxGetPr(mxI1);
    mxctype1 = mxCreateCellMatrix(1, nsat);

    mxP2 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    P2 = mxGetPr(mxP2);
    mxL2 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    L2 = mxGetPr(mxL2);
    mxD2 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    D2 = mxGetPr(mxD2);
    mxS2 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    S2 = mxGetPr(mxS2);
    mxI2 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    I2 = mxGetPr(mxI2);
    mxctype2 = mxCreateCellMatrix(1, nsat);

    mxP5 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    P5 = mxGetPr(mxP5);
    mxL5 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    L5 = mxGetPr(mxL5);
    mxD5 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    D5 = mxGetPr(mxD5);
    mxS5 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    S5 = mxGetPr(mxS5);
    mxI5 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    I5 = mxGetPr(mxI5);
    mxctype5 = mxCreateCellMatrix(1, nsat);

    mxP6 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    P6 = mxGetPr(mxP6);
    mxL6 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    L6 = mxGetPr(mxL6);
    mxD6 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    D6 = mxGetPr(mxD6);
    mxS6 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    S6 = mxGetPr(mxS6);
    mxI6 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    I6 = mxGetPr(mxI6);
    mxctype6 = mxCreateCellMatrix(1, nsat);

    mxP7 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    P7 = mxGetPr(mxP7);
    mxL7 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    L7 = mxGetPr(mxL7);
    mxD7 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    D7 = mxGetPr(mxD7);
    mxS7 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    S7 = mxGetPr(mxS7);
    mxI7 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    I7 = mxGetPr(mxI7);
    mxctype7 = mxCreateCellMatrix(1, nsat);

    mxP8 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    P8 = mxGetPr(mxP8);
    mxL8 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    L8 = mxGetPr(mxL8);
    mxD8 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    D8 = mxGetPr(mxD8);
    mxS8 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    S8 = mxGetPr(mxS8);
    mxI8 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    I8 = mxGetPr(mxI8);
    mxctype8 = mxCreateCellMatrix(1, nsat);

    mxP9 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    P9 = mxGetPr(mxP9);
    mxL9 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    L9 = mxGetPr(mxL9);
    mxD9 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    D9 = mxGetPr(mxD9);
    mxS9 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    S9 = mxGetPr(mxS9);
    mxI9 = mxCreateDoubleMatrix(n, nsat, mxREAL);
    I9 = mxGetPr(mxI9);
    mxctype9 = mxCreateCellMatrix(1, nsat);

    SetNaNtoObs(n, nsat, P1, L1, D1, S1, I1);
    SetNaNtoObs(n, nsat, P2, L2, D2, S2, I2);
    SetNaNtoObs(n, nsat, P5, L5, D5, S5, I5);
    SetNaNtoObs(n, nsat, P6, L6, D6, S6, I6);
    SetNaNtoObs(n, nsat, P7, L7, D7, S7, I7);
    SetNaNtoObs(n, nsat, P8, L8, D8, S8, I8);
    SetNaNtoObs(n, nsat, P9, L9, D9, S9, I9);

    for (i = iobs = 0; i < n; i++) {
        for (j = 0; j < nobslist[i]; j++) {
            data = obs[iobs++];
            SetObs(i, n, 0, si[data.sat - 1], P1, L1, D1, S1, I1, ctype1,
                   &recv1, data);
            SetObs(i, n, 1, si[data.sat - 1], P2, L2, D2, S2, I2, ctype2,
                   &recv2, data);
            SetObs(i, n, 2, si[data.sat - 1], P5, L5, D5, S5, I5, ctype5,
                   &recv5, data);
            SetObs(i, n, 3, si[data.sat - 1], P6, L6, D6, S6, I6, ctype6,
                   &recv6, data);
            SetObs(i, n, 4, si[data.sat - 1], P7, L7, D7, S7, I7, ctype7,
                   &recv7, data);
            SetObs(i, n, 5, si[data.sat - 1], P8, L8, D8, S8, I8, ctype8,
                   &recv8, data);
            SetObs(i, n, 6, si[data.sat - 1], P9, L9, D9, S9, I9, ctype9,
                   &recv9, data);
        }
        time2epoch(data.time, ep);
        eps[i + n * 0] = ep[0];
        eps[i + n * 1] = ep[1];
        eps[i + n * 2] = ep[2];
        eps[i + n * 3] = ep[3];
        eps[i + n * 4] = ep[4];
        eps[i + n * 5] = ep[5];
        tow[i] = time2gpst(data.time, &iweek);
        week[i] = (double)iweek;
    }
    for (j = 0; j < nsat; j++) {
        mxSetCell(mxctype1, j, mxCreateString(code2obs(ctype1[j])));
        mxSetCell(mxctype2, j, mxCreateString(code2obs(ctype2[j])));
        mxSetCell(mxctype5, j, mxCreateString(code2obs(ctype5[j])));
        mxSetCell(mxctype6, j, mxCreateString(code2obs(ctype6[j])));
        mxSetCell(mxctype7, j, mxCreateString(code2obs(ctype7[j])));
        mxSetCell(mxctype8, j, mxCreateString(code2obs(ctype8[j])));
        mxSetCell(mxctype9, j, mxCreateString(code2obs(ctype9[j])));
    }

    SetFreqStruct(mxFL1, mxP1, mxL1, mxD1, mxS1, mxI1, mxctype1);
    SetFreqStruct(mxFL2, mxP2, mxL2, mxD2, mxS2, mxI2, mxctype2);
    SetFreqStruct(mxFL5, mxP5, mxL5, mxD5, mxS5, mxI5, mxctype5);
    SetFreqStruct(mxFL6, mxP6, mxL6, mxD6, mxS6, mxI6, mxctype6);
    SetFreqStruct(mxFL7, mxP7, mxL7, mxD7, mxS7, mxI7, mxctype7);
    SetFreqStruct(mxFL8, mxP8, mxL8, mxD8, mxS8, mxI8, mxctype8);
    SetFreqStruct(mxFL9, mxP9, mxL9, mxD9, mxS9, mxI9, mxctype9);

    mxSetField(mxobs, 0, "ep", mxep);
    mxSetField(mxobs, 0, "tow", mxtow);
    mxSetField(mxobs, 0, "week", mxweek);

    if (recv1 != 0) {
        mxSetField(mxobs, 0, "L1", mxFL1);
    } else {
        mxRemoveField(mxobs, mxGetFieldNumber(mxobs, "L1"));
        mxDestroyArray(mxFL1);
    }
    if (recv2 != 0) {
        mxSetField(mxobs, 0, "L2", mxFL2);
    } else {
        mxRemoveField(mxobs, mxGetFieldNumber(mxobs, "L2"));
        mxDestroyArray(mxFL2);
    }
    if (recv5 != 0) {
        mxSetField(mxobs, 0, "L5", mxFL5);
    } else {
        mxRemoveField(mxobs, mxGetFieldNumber(mxobs, "L5"));
        mxDestroyArray(mxFL5);
    }
    if (recv6 != 0) {
        mxSetField(mxobs, 0, "L6", mxFL6);
    } else {
        mxRemoveField(mxobs, mxGetFieldNumber(mxobs, "L6"));
        mxDestroyArray(mxFL6);
    }
    if (recv7 != 0) {
        mxSetField(mxobs, 0, "L7", mxFL7);
    } else {
        mxRemoveField(mxobs, mxGetFieldNumber(mxobs, "L7"));
        mxDestroyArray(mxFL7);
    }
    if (recv8 != 0) {
        mxSetField(mxobs, 0, "L8", mxFL8);
    } else {
        mxRemoveField(mxobs, mxGetFieldNumber(mxobs, "L8"));
        mxDestroyArray(mxFL8);
    }
    if (recv9 != 0) {
        mxSetField(mxobs, 0, "L9", mxFL9);
    } else {
        mxRemoveField(mxobs, mxGetFieldNumber(mxobs, "L9"));
        mxDestroyArray(mxFL9);
    }

    return mxobs;
}

/* mxobs2obs ----------------------------------------------------------*/
extern obsd_t *mxobs2obs(const mxArray *mxobs, const int rcv, int *nout,
                         int **nobslist) {
    obsd_t *obs;
    double *sat, *week, *tow, *P, *L, *D, *S, *I;
    uint8_t *ctype;
    int i, j, k, l, n, nsat, nobs = 0;
    bool fexist[NFREQ] = {false}, dataflag;
    const char *obsf[] = {"n", "nsat", "sat", "tow", "week"};
    const char *frqf[] = {"P", "L", "D", "S", "I", "ctype"};
    char FTYPE[NFREQ][3] = {"L1", "L2", "L5", "L6", "L7", "L8", "L9"};
    mxArray *mxfrq;

    /* check obs struct */
    mxCheckStruct(mxobs, obsf, 5);

    n = (int)mxGetScalar(mxGetField(mxobs, 0, "n"));
    nsat = (int)mxGetScalar(mxGetField(mxobs, 0, "nsat"));
    sat = (double *)mxGetPr(mxGetField(mxobs, 0, "sat"));
    tow = (double *)mxGetPr(mxGetField(mxobs, 0, "tow"));
    week = (double *)mxGetPr(mxGetField(mxobs, 0, "week"));

    // mexPrintf("n:%d nsat:%d\n",n,nsat);
    if (!(obs = (obsd_t *)calloc(n * nsat, sizeof(obsd_t))))
        mexErrMsgTxt("mxobs2obs: memory allocation error");
    if (!(*nobslist = (int *)calloc(n, sizeof(int))))
        mexErrMsgTxt("mxobs2obs: memory allocation error");
    if (!(P = (double *)calloc(NFREQ * nsat * n, sizeof(double))))
        mexErrMsgTxt("mxobs2obs: memory allocation error");
    if (!(L = (double *)calloc(NFREQ * nsat * n, sizeof(double))))
        mexErrMsgTxt("mxobs2obs: memory allocation error");
    if (!(D = (double *)calloc(NFREQ * nsat * n, sizeof(double))))
        mexErrMsgTxt("mxobs2obs: memory allocation error");
    if (!(S = (double *)calloc(NFREQ * nsat * n, sizeof(double))))
        mexErrMsgTxt("mxobs2obs: memory allocation error");
    if (!(I = (double *)calloc(NFREQ * nsat * n, sizeof(double))))
        mexErrMsgTxt("mxobs2obs: memory allocation error");
    if (!(ctype = (uint8_t *)calloc(NFREQ * nsat, sizeof(uint8_t))))
        mexErrMsgTxt("mxobs2obs: memory allocation error");

    for (i = 0; i < NFREQ; i++) {
        if (mxGetField(mxobs, 0, FTYPE[i]) != NULL) {
            mxfrq = mxGetField(mxobs, 0, FTYPE[i]);

            /* check frequency struct */
            mxCheckStruct(mxfrq, frqf, 6);

            memcpy(&P[i * nsat * n],
                   (double *)mxGetPr(mxGetField(mxfrq, 0, "P")),
                   nsat * n * sizeof(double));
            memcpy(&L[i * nsat * n],
                   (double *)mxGetPr(mxGetField(mxfrq, 0, "L")),
                   nsat * n * sizeof(double));
            memcpy(&D[i * nsat * n],
                   (double *)mxGetPr(mxGetField(mxfrq, 0, "D")),
                   nsat * n * sizeof(double));
            memcpy(&S[i * nsat * n],
                   (double *)mxGetPr(mxGetField(mxfrq, 0, "S")),
                   nsat * n * sizeof(double));
            memcpy(&I[i * nsat * n],
                   (double *)mxGetPr(mxGetField(mxfrq, 0, "I")),
                   nsat * n * sizeof(double));
            for (j = 0; j < nsat; j++) {
                ctype[i * nsat + j] = obs2code(mxArrayToString(
                    mxGetCell(mxGetField(mxfrq, 0, "ctype"), j)));
            }
            fexist[i] = true;
        }
    }
    // mexPrintf("%d %d %d %d %d %d
    // %d\n",fexist[0],fexist[1],fexist[2],fexist[3],fexist[4],fexist[5],fexist[6]);

    /* generation of obsd struct */
    for (i = 0; i < n; i++) {
        (*nobslist)[i] = 0;
        for (j = 0; j < nsat; j++) {
            dataflag = false;
            for (k = 0; k < NFREQ; k++) {
                l = i + n * j + n * nsat * k; /* data index */
                if (fexist[k]) {
                    if (nisnan(P[l]) || nisnan(L[l]) || nisnan(D[l]) ||
                        nisnan(S[l])) {
                        /* copy to obsd struct*/
                        // mexPrintf("i=%d j=%d k=%d l=%d nobs=%d
                        // rcv=%d\n",i,j,k,l,nobs,rcv);
                        obs[nobs].rcv = rcv;
                        obs[nobs].sat = (uint8_t)sat[j];
                        obs[nobs].time = gpst2time((int)week[i], tow[i]);
                        obs[nobs].P[k] = mxIsNaN(P[l]) ? 0.0 : P[l];
                        obs[nobs].L[k] = mxIsNaN(L[l]) ? 0.0 : L[l];
                        obs[nobs].D[k] = mxIsNaN(D[l]) ? 0.0f : (float)D[l];
                        obs[nobs].SNR[k] =
                            mxIsNaN(S[l]) ? 0
                                          : (uint16_t)(S[l] / SNR_UNIT + 0.5);
                        obs[nobs].LLI[k] = mxIsNaN(I[l]) ? 0 : (uint8_t)I[l];
                        obs[nobs].code[k] = (uint8_t)ctype[j + k * nsat];
                        // mexPrintf("sat=%d,
                        // P=%f\n",obs[nobs].sat,obs[nobs].P[k]);
                        dataflag = true;
                    }
                }
            }
            if (dataflag) {
                (*nobslist)[i]++;
                nobs++;
            }
        }
    }
    // mexPrintf("i=%d, nobslist[i]=%d\n",i,(*nobslist)[i-1]);
    free(P);
    free(L);
    free(D);
    free(S);
    free(I);
    free(ctype);
    *nout = n;
    return obs;
}

/* mxobs2obsall ----------------------------------------------------------*/
extern obsd_t *mxobs2obs_all(const mxArray *mxobs, const int rcv, int *nout,
                             int *nsatout, int *satout) {
    obsd_t *obs;
    double *sat, *week, *tow, *P, *L, *D, *S, *I;
    uint8_t *ctype;
    int i, j, k, l, n, nsat, nobs = 0;
    char FTYPE[NFREQ][3] = {"L1", "L2", "L5", "L6", "L7", "L8", "L9"};
    const char *obsf[] = {"n", "nsat", "sat", "tow", "week"};
    const char *frqf[] = {"P", "L", "D", "S", "I", "ctype"};
    mxArray *mxfrq;

    /* check obs struct */
    mxCheckStruct(mxobs, obsf, 5);

    n = (int)mxGetScalar(mxGetField(mxobs, 0, "n"));
    nsat = (int)mxGetScalar(mxGetField(mxobs, 0, "nsat"));
    sat = (double *)mxGetPr(mxGetField(mxobs, 0, "sat"));
    tow = (double *)mxGetPr(mxGetField(mxobs, 0, "tow"));
    week = (double *)mxGetPr(mxGetField(mxobs, 0, "week"));

    if (!(obs = (obsd_t *)calloc(n * nsat, sizeof(obsd_t))))
        mexErrMsgTxt("mxobs2obs_all: memory allocation error");
    if (!(P = (double *)calloc(NFREQ * nsat * n, sizeof(double))))
        mexErrMsgTxt("mxobs2obs_all: memory allocation error");
    if (!(L = (double *)calloc(NFREQ * nsat * n, sizeof(double))))
        mexErrMsgTxt("mxobs2obs_all: memory allocation error");
    if (!(D = (double *)calloc(NFREQ * nsat * n, sizeof(double))))
        mexErrMsgTxt("mxobs2obs_all: memory allocation error");
    if (!(S = (double *)calloc(NFREQ * nsat * n, sizeof(double))))
        mexErrMsgTxt("mxobs2obs_all: memory allocation error");
    if (!(I = (double *)calloc(NFREQ * nsat * n, sizeof(double))))
        mexErrMsgTxt("mxobs2obs_all: memory allocation error");
    if (!(ctype = (uint8_t *)calloc(NFREQ * nsat, sizeof(uint8_t))))
        mexErrMsgTxt("mxobs2obs_all: memory allocation error");

    for (i = 0; i < NFREQ; i++) {
        if (mxGetField(mxobs, 0, FTYPE[i]) != NULL) {
            mxfrq = mxGetField(mxobs, 0, FTYPE[i]);

            /* check frequency struct */
            mxCheckStruct(mxfrq, frqf, 6);

            memcpy(&P[i * nsat * n],
                   (double *)mxGetPr(mxGetField(mxfrq, 0, "P")),
                   nsat * n * sizeof(double));
            memcpy(&L[i * nsat * n],
                   (double *)mxGetPr(mxGetField(mxfrq, 0, "L")),
                   nsat * n * sizeof(double));
            memcpy(&D[i * nsat * n],
                   (double *)mxGetPr(mxGetField(mxfrq, 0, "D")),
                   nsat * n * sizeof(double));
            memcpy(&S[i * nsat * n],
                   (double *)mxGetPr(mxGetField(mxfrq, 0, "S")),
                   nsat * n * sizeof(double));
            memcpy(&I[i * nsat * n],
                   (double *)mxGetPr(mxGetField(mxfrq, 0, "I")),
                   nsat * n * sizeof(double));
            for (j = 0; j < nsat; j++) {
                ctype[i * nsat + j] = obs2code(mxArrayToString(
                    mxGetCell(mxGetField(mxfrq, 0, "ctype"), j)));
            }
        }
    }

    /* generation of obsd struct */
    for (i = 0; i < n; i++) {
        for (j = 0; j < nsat; j++) {
            for (k = 0; k < NFREQ; k++) {
                l = i + n * j + n * nsat * k; /* data index */
                                              /* copy to obsd struct*/
                // mexPrintf("i=%d j=%d k=%d l=%d nobs=%d
                // rcv=%d\n",i,j,k,l,nobs,rcv);
                obs[nobs].rcv = rcv;
                obs[nobs].sat = (uint8_t)sat[j];
                obs[nobs].time = gpst2time((int)week[i], tow[i]);
                obs[nobs].P[k] = mxIsNaN(P[l]) ? 0.0 : P[l];
                obs[nobs].L[k] = mxIsNaN(L[l]) ? 0.0 : L[l];
                obs[nobs].D[k] = mxIsNaN(D[l]) ? 0.0f : (float)D[l];
                obs[nobs].SNR[k] =
                    mxIsNaN(S[l]) ? 0 : (uint16_t)(S[l] / SNR_UNIT + 0.5);
                obs[nobs].LLI[k] = mxIsNaN(I[l]) ? 0 : (uint8_t)I[l];
                obs[nobs].code[k] = (uint8_t)ctype[j + k * nsat];
                // mexPrintf("sat=%d,
                // P=%f\n",obs[nobs].sat,obs[nobs].P[k]);
            }
            nobs++;
        }
    }
    free(P);
    free(L);
    free(D);
    free(S);
    free(I);
    free(ctype);
    *nout = n;
    *nsatout = nsat;
    for (i = 0; i < nsat; i++) satout[i] = (int)sat[i];
    return obs;
}
