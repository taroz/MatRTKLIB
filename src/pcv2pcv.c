/**
 * @file pcv2pcv.c
 * @brief Convert mxArray mxpcvs/mxpcv to pcvs_t/pcv_t, and vice versa
 * @author Taro Suzuki
 */

#include "mex_utility.h"

/* pcv2mxpcv ----------------------------------------------------------*/
extern mxArray *pcv2mxpcv(const pcv_t *pcvs, const int n) {
    int i;
    double ts[6], te[6];
    mxArray *mxpcvs, *mxts, *mxte, *mxoff, *mxvar;

    /* output struct */
    const char *pcvf[] = {"sat", "type", "code", "ts", "te", "off", "var"};

    mxpcvs = mxCreateStructMatrix(n, 1, 7, pcvf);

    for (i = 0; i < n; i++) {
        /* sat */
        mxSetField(mxpcvs, i, "sat", mxCreateDoubleScalar(pcvs[i].sat));

        /* type,code */
        mxSetField(mxpcvs, i, "type", mxCreateString(pcvs[i].type));
        mxSetField(mxpcvs, i, "code", mxCreateString(pcvs[i].code));

        /* ts,te */
        mxts = mxCreateDoubleMatrix(1, 6, mxREAL);
        time2epoch(pcvs[i].ts, ts);
        memcpy(mxGetPr(mxts), ts, 6 * sizeof(double));
        mxSetField(mxpcvs, i, "ts", mxts);

        mxte = mxCreateDoubleMatrix(1, 6, mxREAL);
        time2epoch(pcvs[i].te, te);
        memcpy(mxGetPr(mxte), te, 6 * sizeof(double));
        mxSetField(mxpcvs, i, "te", mxte);

        /* off,var */
        mxoff = mxCreateDoubleMatrix(NFREQ, 3, mxREAL);
        memcpy(mxGetPr(mxoff), pcvs[i].off, NFREQ * 3 * sizeof(double));
        mxSetField(mxpcvs, i, "off", mxoff);

        mxvar = mxCreateDoubleMatrix(NFREQ, 19, mxREAL);
        memcpy(mxGetPr(mxvar), pcvs[i].var, NFREQ * 19 * sizeof(double));
        mxSetField(mxpcvs, i, "var", mxvar);
    }
    return mxpcvs;
}

/* mxpcv2pcv ----------------------------------------------------------*/
extern void mxpcv2pcv(const mxArray *mxpcvs, const int n, pcv_t *pcvs) {
    int i;
    const char *pcvf[] = {"sat", "type", "code", "ts", "te", "off", "var"};

    /* check nav struct */
    mxCheckStruct(mxpcvs, pcvf, 7);

    for (i = 0; i < n; i++) {
        /* sat */
        pcvs[i].sat = (int)mxGetScalar(mxGetField(mxpcvs, i, "sat"));

        /* type,code */
        mxGetString(mxGetField(mxpcvs, i, "type"), pcvs[i].type,
                    sizeof(pcvs[i].type));
        mxGetString(mxGetField(mxpcvs, i, "code"), pcvs[i].code,
                    sizeof(pcvs[i].code));

        /* ts,te */
        pcvs[i].ts = epoch2time((double *)mxGetPr(mxGetField(mxpcvs, i, "ts")));
        pcvs[i].te = epoch2time((double *)mxGetPr(mxGetField(mxpcvs, i, "te")));

        /* off,var */
        memcpy(pcvs[i].off, (double *)mxGetPr(mxGetField(mxpcvs, i, "off")),
               NFREQ * 3 * sizeof(double));
        memcpy(pcvs[i].var, (double *)mxGetPr(mxGetField(mxpcvs, i, "var")),
               NFREQ * 19 * sizeof(double));
    }
}