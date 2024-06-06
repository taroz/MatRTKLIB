/**
 * @file sol2sol.c
 * @brief Convert mxArray mxsol to sol_t, and vice versa
 * @author Taro Suzuki
 */

#include "mex_utility.h"

/* sol2mxsol ----------------------------------------------------------*/
extern mxArray *sol2mxsol(const sol_t *sol, const int n) {
    mxArray *mxsol, *mxeps, *mxrr, *mxqr, *mxqv, *mxdtr, *mxtype,
        *mxstat, *mxns, *mxage, *mxratio, *mxthres;
    double ep[6], *eps, *rr, *qr, *qv, *dtr, *type, *stat, *ns, *age,
        *ratio, *thres;
    int i, j;

    /* output struct */
    const char *solf[] = {"n",   "ep", "rr",  "qr",    "qv",   "dtr",
                          "type", "stat", "ns",   "age", "ratio", "thres"};
    mxsol = mxCreateStructMatrix(1, 1, 12, solf);

    mxeps = mxCreateDoubleMatrix(n, 6, mxREAL);
    eps = mxGetPr(mxeps);
    mxrr = mxCreateDoubleMatrix(n, 6, mxREAL);
    rr = mxGetPr(mxrr);
    mxqr = mxCreateDoubleMatrix(n, 6, mxREAL);
    qr = mxGetPr(mxqr);
    mxqv = mxCreateDoubleMatrix(n, 6, mxREAL);
    qv = mxGetPr(mxqv);
    mxdtr = mxCreateDoubleMatrix(n, 6, mxREAL);
    dtr = mxGetPr(mxdtr);
    mxtype = mxCreateDoubleMatrix(n, 1, mxREAL);
    type = mxGetPr(mxtype);
    mxstat = mxCreateDoubleMatrix(n, 1, mxREAL);
    stat = mxGetPr(mxstat);
    mxns = mxCreateDoubleMatrix(n, 1, mxREAL);
    ns = mxGetPr(mxns);
    mxage = mxCreateDoubleMatrix(n, 1, mxREAL);
    age = mxGetPr(mxage);
    mxratio = mxCreateDoubleMatrix(n, 1, mxREAL);
    ratio = mxGetPr(mxratio);
    mxthres = mxCreateDoubleMatrix(n, 1, mxREAL);
    thres = mxGetPr(mxthres);

    for (i = 0; i < n; i++) {
        time2epoch(sol[i].time, ep); /* time */
        for (j = 0; j < 6; j++) eps[i + n * j] = ep[j];
        for (j = 0; j < 6; j++) rr[i + n * j] = sol[i].rr[j];
        for (j = 0; j < 6; j++)
            qr[i + n * j] = (double)sol[i].qr[j];
        for (j = 0; j < 6; j++)
            qv[i + n * j] = (double)sol[i].qv[j];
        for (j = 0; j < 6; j++) dtr[i + n * j] = sol[i].dtr[j];
        type[i] = (double)sol[i].type;
        stat[i] = (double)sol[i].stat;
        ns[i] = (double)sol[i].ns;
        age[i] = (double)sol[i].age;
        ratio[i] = (double)sol[i].ratio;
        thres[i] = (double)sol[i].thres;
    }
    mxSetField(mxsol, 0, "n", mxCreateDoubleScalar((double)n));
    mxSetField(mxsol, 0, "ep", mxeps);
    mxSetField(mxsol, 0, "rr", mxrr);
    mxSetField(mxsol, 0, "qr", mxqr);
    mxSetField(mxsol, 0, "qv", mxqv);
    mxSetField(mxsol, 0, "dtr", mxdtr);
    mxSetField(mxsol, 0, "type", mxtype);
    mxSetField(mxsol, 0, "stat", mxstat);
    mxSetField(mxsol, 0, "ns", mxns);
    mxSetField(mxsol, 0, "age", mxage);
    mxSetField(mxsol, 0, "ratio", mxratio);
    mxSetField(mxsol, 0, "thres", mxthres);

    return mxsol;
}

/* mxsol2sol ----------------------------------------------------------*/
extern sol_t *mxsol2sol(const mxArray *mxsol) {
    sol_t *sol;
    double ep[6], *eps, *rr, *qr, *qv, *dtr, *type, *stat, *ns, *age,
        *ratio, *thres;
    int i, j, n;
    const char *solf[] = {"n",   "ep", "rr",  "qr",    "qv",   "dtr",
                          "type", "stat", "ns",   "age", "ratio", "thres"};

    /* check sol struct */
    mxCheckStruct(mxsol, solf, 12);

    n = (int)mxGetScalar(mxGetField(mxsol, 0, "n"));
    eps = (double *)mxGetPr(mxGetField(mxsol, 0, "ep"));
    rr = (double *)mxGetPr(mxGetField(mxsol, 0, "rr"));
    qr = (double *)mxGetPr(mxGetField(mxsol, 0, "qr"));
    qv = (double *)mxGetPr(mxGetField(mxsol, 0, "qv"));
    dtr = (double *)mxGetPr(mxGetField(mxsol, 0, "dtr"));
    type = (double *)mxGetPr(mxGetField(mxsol, 0, "type"));
    stat = (double *)mxGetPr(mxGetField(mxsol, 0, "stat"));
    ns = (double *)mxGetPr(mxGetField(mxsol, 0, "ns"));
    age = (double *)mxGetPr(mxGetField(mxsol, 0, "age"));
    ratio = (double *)mxGetPr(mxGetField(mxsol, 0, "ratio"));
    thres = (double *)mxGetPr(mxGetField(mxsol, 0, "thres"));

    if (!(sol = (sol_t *)calloc(n, sizeof(sol_t)))) {
        mexErrMsgTxt("sol2sol: memory allocation error");
    }

    for (i = 0; i < n; i++) {
        for (j = 0; j < 6; j++) ep[j] = eps[i + n * j];
        sol[i].time = epoch2time(ep);
        for (j = 0; j < 6; j++) sol[i].rr[j] = rr[i + n * j];
        for (j = 0; j < 6; j++) sol[i].qr[j] = (float)qr[i + n * j];
        for (j = 0; j < 6; j++) sol[i].qv[j] = (float)qv[i + n * j];
        for (j = 0; j < 6; j++) sol[i].dtr[j] = dtr[i + n * j];
        sol[i].type = (uint8_t)type[i];
        sol[i].stat = (uint8_t)stat[i];
        sol[i].ns = (uint8_t)ns[i];
        sol[i].age = (float)age[i];
        sol[i].ratio = (float)ratio[i];
        sol[i].thres = (float)thres[i];
    }
    return sol;
}
