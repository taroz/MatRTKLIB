/**
 * @file erp2erp.c
 * @brief Convert mxArray mxerp to erp_t, and vice versa
 * @author Taro Suzuki
 */

#include "mex_utility.h"

/* erp2mxerp ----------------------------------------------------------*/
extern mxArray *erp2mxerp(const erp_t *erp) {
    int i;
    mxArray *mxerp;

    /* output struct */
    const char *erpf[] = {"mjd", "xp", "yp", "xpr", "ypr", "ut1_utc", "lod"};

    mxerp = mxCreateStructMatrix(erp->n, 1, 7, erpf);

    for (i = 0; i < erp->n; i++) {
        mxSetField(mxerp, i, "mjd", mxCreateDoubleScalar(erp->data[i].mjd));
        mxSetField(mxerp, i, "xp", mxCreateDoubleScalar(erp->data[i].xp));
        mxSetField(mxerp, i, "yp", mxCreateDoubleScalar(erp->data[i].yp));
        mxSetField(mxerp, i, "xpr", mxCreateDoubleScalar(erp->data[i].xpr));
        mxSetField(mxerp, i, "ypr", mxCreateDoubleScalar(erp->data[i].ypr));
        mxSetField(mxerp, i, "ut1_utc", mxCreateDoubleScalar(erp->data[i].ut1_utc));
        mxSetField(mxerp, i, "lod", mxCreateDoubleScalar(erp->data[i].lod));
    }
    return mxerp;
}

/* mxerp2erp ----------------------------------------------------------*/
extern void mxerp2erp(const mxArray *mxerp, erp_t *erp) {
    int i;
    erpd_t *erpd;
    const char *erpf[] = {"mjd", "xp", "yp", "xpr", "ypr", "ut1_utc", "lod"};
    
    /* check nav struct */
    mxCheckStruct(mxerp, erpf, 7);

    erp->n = (int)mxGetM(mxerp);
    erp->nmax = erp->n;

    if (!(erpd = (erpd_t *)realloc(erp->data, sizeof(erpd_t) * erp->n))) {
        mexErrMsgTxt("mxerp2erp: memory allocation error");
        free(erp->data);
        erp->data = NULL;
        erp->n = erp->nmax = 0;
        return;
    }
    erp->data = erpd;

    for (i = 0; i < erp->n; i++) {
        erp->data[i].mjd = mxGetScalar(mxGetField(mxerp, i, "mjd"));
        erp->data[i].xp = mxGetScalar(mxGetField(mxerp, i, "xp"));
        erp->data[i].yp = mxGetScalar(mxGetField(mxerp, i, "yp"));
        erp->data[i].xpr = mxGetScalar(mxGetField(mxerp, i, "xpr"));
        erp->data[i].ypr = mxGetScalar(mxGetField(mxerp, i, "ypr"));
        erp->data[i].ut1_utc = mxGetScalar(mxGetField(mxerp, i, "ut1_utc"));
        erp->data[i].lod = mxGetScalar(mxGetField(mxerp, i, "lod"));
    }
}
