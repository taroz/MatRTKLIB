/**
 * @file nav2nav.c
 * @brief Convert mxArray mxnav to nav_t nav, and vice versa
 * @author Taro Suzuki
 */

#include "mex_utility.h"

/* nav2mxnav ----------------------------------------------------------*/
extern mxArray *nav2mxnav(const nav_t *nav) {
    double cbiast[MAXSAT * 3] = {0};
    mxArray *mxnav, *mxeph, *mxgeph, *mxpeph, *mxpclk, *mxcbias, *mxpcvs;
    mxArray *mxerp;
    mxArray *mxion_gps, *mxion_qzs, *mxion_cmp, *mxion_gal, *mxion_irn;
    mxArray *mxutc_gps, *mxutc_glo, *mxutc_qzs, *mxutc_cmp, *mxutc_gal,
        *mxutc_irn, *mxutc_sbs;

    /* output struct field */
    const char *navf[] = {"eph",     "geph",    "peph",    "pclk",    "erp",
                          "pcvs",    "cbias",   "utc_gps", "utc_glo", "utc_gal",
                          "utc_qzs", "utc_cmp", "utc_irn", "utc_sbs", "ion_gps",
                          "ion_gal", "ion_qzs", "ion_cmp", "ion_irn"};

    /* output struct */
    mxnav = mxCreateStructMatrix(1, 1, 19, navf);

    /* eph to mxeph */
    mxeph = eph2mxeph(nav->eph, nav->n);

    /* geph to mxgeph */
    mxgeph = geph2mxgeph(nav->geph, nav->ng);

    /* peph to mxpeph */
    mxpeph = peph2mxpeph(nav->peph, nav->ne);

    /* pclk to mxpclk */
    mxpclk = pclk2mxpclk(nav->pclk, nav->nc);

    /* pcvs to mxpcvs */
    mxpcvs = pcv2mxpcv(nav->pcvs, MAXSAT);

    /* erp to mxerp */
    mxerp = erp2mxerp(&nav->erp);

    /* set ephemeris */
    mxSetField(mxnav, 0, "eph", mxeph);
    mxSetField(mxnav, 0, "geph", mxgeph);
    mxSetField(mxnav, 0, "peph", mxpeph);
    mxSetField(mxnav, 0, "pclk", mxpclk);
    mxSetField(mxnav, 0, "pcvs", mxpcvs);
    mxSetField(mxnav, 0, "erp", mxerp);

    /* set ionosphere parameters */
    /* GPS */
    mxion_gps = mxCreateDoubleMatrix(1, 8, mxREAL);
    memcpy(mxGetPr(mxion_gps), nav->ion_gps, 8 * sizeof(double));
    mxSetField(mxnav, 0, "ion_gps", mxion_gps);
    /* QZS */
    mxion_qzs = mxCreateDoubleMatrix(1, 8, mxREAL);
    memcpy(mxGetPr(mxion_qzs), nav->ion_qzs, 8 * sizeof(double));
    mxSetField(mxnav, 0, "ion_qzs", mxion_qzs);
    /* BDS */
    mxion_cmp = mxCreateDoubleMatrix(1, 8, mxREAL);
    memcpy(mxGetPr(mxion_cmp), nav->ion_cmp, 8 * sizeof(double));
    mxSetField(mxnav, 0, "ion_cmp", mxion_cmp);
    /* GAL */
    mxion_gal = mxCreateDoubleMatrix(1, 4, mxREAL);
    memcpy(mxGetPr(mxion_gal), nav->ion_gal, 4 * sizeof(double));
    mxSetField(mxnav, 0, "ion_gal", mxion_gal);
    /* IRN */
    mxion_irn = mxCreateDoubleMatrix(1, 8, mxREAL);
    memcpy(mxGetPr(mxion_irn), nav->ion_irn, 8 * sizeof(double));
    mxSetField(mxnav, 0, "ion_irn", mxion_irn);

    /* set UTC parameters */
    /* GPS */
    mxutc_gps = mxCreateDoubleMatrix(1, 8, mxREAL);
    memcpy(mxGetPr(mxutc_gps), nav->utc_gps, 8 * sizeof(double));
    mxSetField(mxnav, 0, "utc_gps", mxutc_gps);
    /* GLO */
    mxutc_glo = mxCreateDoubleMatrix(1, 8, mxREAL);
    memcpy(mxGetPr(mxutc_glo), nav->utc_glo, 8 * sizeof(double));
    mxSetField(mxnav, 0, "utc_glo", mxutc_glo);
    /* QZS */
    mxutc_qzs = mxCreateDoubleMatrix(1, 8, mxREAL);
    memcpy(mxGetPr(mxutc_qzs), nav->utc_qzs, 8 * sizeof(double));
    mxSetField(mxnav, 0, "utc_qzs", mxutc_qzs);
    /* BDS */
    mxutc_cmp = mxCreateDoubleMatrix(1, 8, mxREAL);
    memcpy(mxGetPr(mxutc_cmp), nav->utc_cmp, 8 * sizeof(double));
    mxSetField(mxnav, 0, "utc_cmp", mxutc_cmp);
    /* GAL */
    mxutc_gal = mxCreateDoubleMatrix(1, 8, mxREAL);
    memcpy(mxGetPr(mxutc_gal), nav->utc_gal, 8 * sizeof(double));
    mxSetField(mxnav, 0, "utc_gal", mxutc_gal);
    /* IRN */
    mxutc_irn = mxCreateDoubleMatrix(1, 9, mxREAL);
    memcpy(mxGetPr(mxutc_irn), nav->utc_irn, 9 * sizeof(double));
    mxSetField(mxnav, 0, "utc_irn", mxutc_irn);
    /* SBS */
    mxutc_sbs = mxCreateDoubleMatrix(1, 4, mxREAL);
    memcpy(mxGetPr(mxutc_sbs), nav->utc_sbs, 4 * sizeof(double));
    mxSetField(mxnav, 0, "utc_sbs", mxutc_sbs);

    /* cbias */
    transpose(&nav->cbias[0][0], 3, MAXSAT, 1, cbiast);
    mxcbias = mxCreateDoubleMatrix(MAXSAT, 3, mxREAL);
    memcpy(mxGetPr(mxcbias), cbiast, 3 * MAXSAT * sizeof(double));
    mxSetField(mxnav, 0, "cbias", mxcbias);

    return mxnav;
}
/* mxnav2nav ----------------------------------------------------------*/
extern nav_t mxnav2nav(const mxArray *mxnav) {
    double cbiast[MAXSAT * 3] = {0};
    nav_t nav = {0};
    mxArray *mxeph, *mxgeph, *mxpeph, *mxpclk, *mxpcvs, *mxerp;
    const char *navf[] = {"eph",     "geph",    "peph",    "pclk",    "erp",
                          "pcvs",    "cbias",   "utc_gps", "utc_glo", "utc_gal",
                          "utc_qzs", "utc_cmp", "utc_irn", "utc_sbs", "ion_gps",
                          "ion_gal", "ion_qzs", "ion_cmp", "ion_irn"};

    /* check nav struct */
    mxCheckStruct(mxnav, navf, 19);

    nav.n = (int)mxGetM(mxGetField(mxnav, 0, "eph"));
    nav.ng = (int)mxGetM(mxGetField(mxnav, 0, "geph"));
    nav.ne = (int)mxGetM(mxGetField(mxnav, 0, "peph"));
    nav.nc = (int)mxGetM(mxGetField(mxnav, 0, "pclk"));

    if (!(nav.eph = (eph_t *)malloc(sizeof(eph_t) * nav.n)) ||
        !(nav.geph = (geph_t *)malloc(sizeof(geph_t) * nav.ng)) ||
        !(nav.peph = (peph_t *)malloc(sizeof(peph_t) * nav.ne)) ||
        !(nav.pclk = (pclk_t *)malloc(sizeof(pclk_t) * nav.nc))) {
        if (nav.eph) free(nav.eph);
        if (nav.geph) free(nav.geph);
        if (nav.peph) free(nav.peph);
        if (nav.pclk) free(nav.pclk);
        mexErrMsgTxt("mxnav2nav: memory allocation error");
    }

    /* mxeph to eph */
    mxeph = mxGetField(mxnav, 0, "eph");
    mxeph2eph(mxeph, nav.n, nav.eph);

    /* mxgeph to geph */
    mxgeph = mxGetField(mxnav, 0, "geph");
    mxgeph2geph(mxgeph, nav.ng, nav.geph);

    /* mxpeph to peph */
    mxpeph = mxGetField(mxnav, 0, "peph");
    mxpeph2peph(mxpeph, nav.ne, nav.peph);

    /* mxpclk to pclk */
    mxpclk = mxGetField(mxnav, 0, "pclk");
    mxpclk2pclk(mxpclk, nav.nc, nav.pclk);

    /* mxpcvs to pcvs */
    mxpcvs = mxGetField(mxnav, 0, "pcvs");
    mxpcv2pcv(mxpcvs, MAXSAT, nav.pcvs);

    /* mxerp to erp */
    mxerp = mxGetField(mxnav, 0, "erp");
    mxerp2erp(mxerp, &nav.erp);

    /* ionosphere parameters */
    memcpy(nav.ion_gps, mxGetPr(mxGetField(mxnav, 0, "ion_gps")),
           8 * sizeof(double));
    memcpy(nav.ion_qzs, mxGetPr(mxGetField(mxnav, 0, "ion_qzs")),
           8 * sizeof(double));
    memcpy(nav.ion_cmp, mxGetPr(mxGetField(mxnav, 0, "ion_cmp")),
           8 * sizeof(double));
    memcpy(nav.ion_gal, mxGetPr(mxGetField(mxnav, 0, "ion_gal")),
           4 * sizeof(double));
    memcpy(nav.ion_irn, mxGetPr(mxGetField(mxnav, 0, "ion_irn")),
           8 * sizeof(double));

    /* UTC parameters */
    memcpy(nav.utc_gps, mxGetPr(mxGetField(mxnav, 0, "utc_gps")),
           8 * sizeof(double));
    memcpy(nav.utc_glo, mxGetPr(mxGetField(mxnav, 0, "utc_glo")),
           8 * sizeof(double));
    memcpy(nav.utc_cmp, mxGetPr(mxGetField(mxnav, 0, "utc_cmp")),
           8 * sizeof(double));
    memcpy(nav.utc_qzs, mxGetPr(mxGetField(mxnav, 0, "utc_qzs")),
           8 * sizeof(double));
    memcpy(nav.utc_gal, mxGetPr(mxGetField(mxnav, 0, "utc_gal")),
           8 * sizeof(double));
    memcpy(nav.utc_irn, mxGetPr(mxGetField(mxnav, 0, "utc_irn")),
           9 * sizeof(double));
    memcpy(nav.utc_sbs, mxGetPr(mxGetField(mxnav, 0, "utc_sbs")),
           4 * sizeof(double));

    /* cbias */
    transpose(mxGetPr(mxGetField(mxnav, 0, "cbias")), MAXSAT, 3, 1, cbiast);
    memcpy(nav.cbias, cbiast, 3 * MAXSAT * sizeof(double));

    uniqnav(&nav);
    return nav;
}
