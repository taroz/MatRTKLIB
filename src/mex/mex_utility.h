/**
 * @file mex_utility.h
 * @brief utility functions for mex files
 * @author Taro Suzuki
 */

#ifndef _MEX_UTILITY_
#define _MEX_UTILITY_

#include <mex.h>
#include <stdio.h>
#include <string.h>

#include "rtklib.h"

/* constants/macros from RTKLIB */
#define SQR(x) ((x) * (x))
#define ERR_SAAS 0.3  /* Saastamoinen model error Std (m) */
#define ERR_BRDCI 0.5 /* broadcast ionosphere model error factor */
#define REL_HUMI 0.7  /* relative humidity for Saastamoinen model */

/* declare functions */
extern mxArray *obs2mxobs(const obsd_t *obs, const int nobs,
                          const int *nobslist);
extern obsd_t *mxobs2obs(const mxArray *mxobs, const int rcv, int *nout,
                         int **nobslist);
extern obsd_t *mxobs2obs_all(const mxArray *mxobs, const int rcv, int *nout,
                             int *nsatout, int *satout);
extern mxArray *nav2mxnav(const nav_t *nav);
extern nav_t mxnav2nav(const mxArray *mxnav);
extern mxArray *eph2mxeph(const eph_t *eph, const int n);
extern mxArray *geph2mxgeph(const geph_t *geph, const int n);
extern void mxeph2eph(const mxArray *mxeph, const int n, eph_t *eph);
extern void mxgeph2geph(const mxArray *mxgeph, const int n, geph_t *geph);
extern mxArray *opt2mxopt(const prcopt_t *popt, const solopt_t *sopt);
extern void mxopt2opt(const mxArray *mxopt, prcopt_t *popt, solopt_t *sopt);
extern mxArray *sol2mxsol(const sol_t *sol, const int n);
extern sol_t *mxsol2sol(const mxArray *mxsol);
extern mxArray *ssat2mxssat(const ssat_t *ssat, const gtime_t *time,
                            const int n);
extern mxArray *solstat2mxsolstat(const solstat_t *stat, const int nstat);
extern mxArray *rtk2mxrtk(const rtk_t *rtks, const int n);
extern rtk_t mxrtk2rtk(const mxArray *mxrtk, const prcopt_t *popt,
                       const sol_t *sol);
extern mxArray *peph2mxpeph(const peph_t *peph, const int n);
extern void mxpeph2peph(const mxArray *mxpeph, const int n, peph_t *peph);
extern mxArray *pclk2mxpclk(const pclk_t *pclk, const int n);
extern void mxpclk2pclk(const mxArray *mxpclk, const int n, pclk_t *pclk);
extern mxArray *pcv2mxpcv(const pcv_t *pcvs, const int n);
extern void mxpcv2pcv(const mxArray *mxpcvs, const int n, pcv_t *pcvs);
extern mxArray *erp2mxerp(const erp_t *erp);
extern void mxerp2erp(const mxArray *mxerp, erp_t *erp);

// /* additional declere functions in rtklib */
// extern int relpos(rtk_t *rtk, const obsd_t *obs, int nu, int nr,
//                   const nav_t *nav);
// extern eph_t *seleph(gtime_t time, int sat, int iode, const nav_t *nav);
// /* select glonass ephememeris
// ------------------------------------------------*/ extern geph_t
// *selgeph(gtime_t time, int sat, int iode, const nav_t *nav);
// /* select sbas ephememeris
// ---------------------------------------------------*/ extern seph_t
// *selseph(gtime_t time, int sat, const nav_t *nav);
// /* satellite clock with broadcast ephemeris
// ----------------------------------*/ extern int ephclk(gtime_t time, gtime_t
// teph, int sat, const nav_t *nav,
//                   double *dts);

/* inline functions */
static inline void mxCheckNumberOfArguments(int nargin, int n) {
    if (nargin < n) {
        char msg[512];
        sprintf(msg, "Wrong number of arguments: given %d, expected >=%d",
                nargin, n);
        mexErrMsgTxt(msg);
    }
}

static inline void mxCheckSizeOfRows(const mxArray *arg, int row) {
    int m;
    const mwSize *dim;
    dim = mxGetDimensions(arg);
    m = (int)dim[0];
    if (m != row) {
        char msg[512];
        sprintf(msg, "Wrong number of rows of argument: given %d, expected %d",
                m, row);
        mexErrMsgTxt(msg);
    }
}

static inline void mxCheckSizeOfColumns(const mxArray *arg, int col) {
    int n;
    const mwSize *dim;
    dim = mxGetDimensions(arg);
    n = (int)dim[1];
    if (n != col) {
        char msg[512];
        sprintf(msg,
                "Wrong number of columns of argument: given %d, expected %d", n,
                col);
        mexErrMsgTxt(msg);
    }
}

static inline void mxCheckSizeOfArgument(const mxArray *arg, int row, int col) {
    int m, n;
    const mwSize *dim;
    dim = mxGetDimensions(arg);
    m = (int)dim[0];
    n = (int)dim[1];
    if (m != row) {
        char msg[512];
        sprintf(msg, "Wrong number of rows of argument: given %d, expected %d",
                m, row);
        mexErrMsgTxt(msg);
    }

    if (n != col) {
        char msg[512];
        sprintf(msg,
                "Wrong number of columns of argument: given %d, expected %d", n,
                col);
        mexErrMsgTxt(msg);
    }
}

static inline void mxCheckSameSize(const mxArray *arg1, const mxArray *arg2) {
    int m1, n1;
    int m2, n2;
    const mwSize *dim1, *dim2;
    dim1 = mxGetDimensions(arg1);
    dim2 = mxGetDimensions(arg2);
    m1 = (int)dim1[0];
    n1 = (int)dim1[1];
    m2 = (int)dim2[0];
    n2 = (int)dim2[1];
    if ((m1 != m2) || (n1 != n2)) {
        char msg[512];
        sprintf(msg, "Not same size of arguments: arg:(%d,%d) arg:(%d,%d)",
                m1, n1, m2, n2);
        mexErrMsgTxt(msg);
    }
}

static inline void mxCheckSameRows(const mxArray *arg1, const mxArray *arg2) {
    int m1, m2;
    const mwSize *dim1, *dim2;
    dim1 = mxGetDimensions(arg1);
    dim2 = mxGetDimensions(arg2);
    m1 = (int)dim1[0];
    m2 = (int)dim2[0];
    if (m1 != m2) {
        char msg[512];
        sprintf(msg, "Not same number of rows: arg:%d arg:%d", m1, m2);
        mexErrMsgTxt(msg);
    }
}

static inline void mxCheckSameColumns(const mxArray *arg1, const mxArray *arg2) {
    int n1, n2;
    const mwSize *dim1, *dim2;
    dim1 = mxGetDimensions(arg1);
    dim2 = mxGetDimensions(arg2);
    n1 = (int)dim1[1];
    n2 = (int)dim2[1];
    if (n1 != n2) {
        char msg[512];
        sprintf(msg, "Not same number of columns: arg:%d arg:%d", n1, n2);
        mexErrMsgTxt(msg);
    }
}

static inline void mxCheckCell(const mxArray *arg) {
    if (!mxIsCell(arg)) mexErrMsgTxt("Input argument must be Cell");
}

static inline void mxCheckChar(const mxArray *arg) {
    if (!mxIsChar(arg)) mexErrMsgTxt("Input argument must be Char");
}

static inline void mxCheckDouble(const mxArray *arg) {
    if (!mxIsDouble(arg)) mexErrMsgTxt("Input argument must be Double");
}

static inline void mxCheckScalar(const mxArray *arg) {
    if (!mxIsDouble(arg) || mxGetNumberOfElements(arg) != 1) {
        mexErrMsgTxt("Input argument must be Scalar");
    }
}

static inline void mxCheckNumberOfDimensions(const mxArray *arg, int dim) {
    int d = (int)mxGetNumberOfDimensions(arg);
    if (d != dim) {
        char msg[512];
        sprintf(msg, "Wrong number of dimensions: given %d, expected %d", d,
                dim);
        mexErrMsgTxt(msg);
    }
}

static inline void mxCheckSquareMatrix(const mxArray *arg) {
    int m, n;
    const mwSize *dim;
    dim = mxGetDimensions(arg);
    m = (int)dim[0];
    n = (int)dim[1];
    if (m != n) {
        char msg[512];
        sprintf(msg, "Not square matrix, rows: %d columns:%d", m, n);
        mexErrMsgTxt(msg);
    }
}

static inline void mxCheckStruct(const mxArray *arg, const char **fields,
                          const int nfields) {
    int i;
    if (!mxIsStruct(arg)) {
        mexErrMsgTxt("Input argument must be struct");
    }
    for (i = 0; i < nfields; i++) {
        if (mxGetFieldNumber(arg, fields[i]) < 0) {
            char msg[512];
            sprintf(msg, "Input struct does not have filed: %s", fields[i]);
            mexErrMsgTxt(msg);
        }
    }
}

static inline void mxSetNaN(double *data, const int n) {
    int i;
    for (i = 0; i < n; i++) data[i] = mxGetNaN();
}

static inline int mxGetSize(const mxArray *arg) {
    int m, n;
    m = (int)mxGetM(arg);
    n = (int)mxGetN(arg);
    return m > n ? m : n;
}

static inline double *transpose_mw_malloc(const double *data, const mwSize *dims) {
    int i, j, k;
    int m = (int)dims[0], n = (int)dims[1],
        d = ((int)dims[2] == 0) ? 1 : (int)dims[2];
    double *datat;
    datat = (double *)malloc(m * n * d * sizeof(double));
    for (i = 0; i < m; i++) {
        for (j = 0; j < n; j++) {
            for (k = 0; k < d; k++) {
                datat[j + n * i + k * m * n] = data[i + m * j + k * m * n];
            }
        }
    }
    return datat;
}

static inline void transpose_mw(const double *data, const mwSize *dims,
                         double *datat) {
    int i, j, k;
    int m = (int)dims[0], n = (int)dims[1],
        d = ((int)dims[2] == 0) ? 1 : (int)dims[2];
    for (i = 0; i < m; i++) {
        for (j = 0; j < n; j++) {
            for (k = 0; k < d; k++) {
                datat[j + n * i + k * m * n] = data[i + m * j + k * m * n];
            }
        }
    }
}

static inline double *transpose_malloc(const double *data, const int m, const int n,
                                const int d) {
    int i, j, k;
    double *datat;
    datat = (double *)malloc(m * n * d * sizeof(double));
    for (i = 0; i < m; i++) {
        for (j = 0; j < n; j++) {
            for (k = 0; k < d; k++) {
                datat[j + n * i + k * m * n] = data[i + m * j + k * m * n];
            }
        }
    }
    return datat;
}

static inline void transpose(const double *data, const int m, const int n, const int d,
                      double *datat) {
    int i, j, k;
    for (i = 0; i < m; i++) {
        for (j = 0; j < n; j++) {
            for (k = 0; k < d; k++) {
                datat[j + n * i + k * m * n] = data[i + m * j + k * m * n];
            }
        }
    }
}

static inline void double2int(const double *ddata, const int n, int *idata) {
    int i;
    for (i = 0; i < n; i++) {
        idata[i] = (int)ddata[i];
    }
}

static inline void int2double(const int *idata, const int n, double *ddata) {
    int i;
    for (i = 0; i < n; i++) {
        ddata[i] = (double)idata[i];
    }
}
#endif
