#include "mex.h"
#include <float.h>

#ifdef _WIN32
	#define isfinite _finite
#else
	#include <math.h>
#endif

template<class T>
T MAX(T x, T y)
{
	return (x > y) ? x : y;
}

const double big = 1e200;

// [D,L] = mre_disttransform(I)

void DT1D(const double *f, int n, int *v, double *z, double *d, int *l)
{
	int k = 0;

	v[0] = 0;
	z[0] = -big;
	z[1] = big;
	
	for (int q = 1; q <= n - 1; q++)
	{
		double s  = ((f[q] + q * q) - (f[v[k]] + v[k] * v[k])) / (2 * q - 2 * v[k]);

		while (s <= z[k])
		{
			k--;
			s  = ((f[q] + q * q) - (f[v[k]] + v[k] * v[k])) / (2 * q - 2 * v[k]);
		}
		k++;
		v[k] = q;
		z[k] = s;
		z[k + 1] = big;
	}

	k = 0;
	for (int q = 0; q <= n - 1; q++)
	{
		while (z[k + 1] < q)
			k++;		
		*(d++) = (q - v[k]) * (q - v[k]) + f[v[k]];
		*(l++) = v[k];
	}
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs != 1)
		mexErrMsgTxt("1 input arguments expected.");
	if (nlhs != 2)
		mexErrMsgTxt("2 distput arguments expected.");

	if (!(mxIsDouble(prhs[0]) || mxIsLogical(prhs[0])) || mxIsComplex(prhs[0]) ||
		mxGetNumberOfDimensions(prhs[0]) != 2)
		mexErrMsgTxt("input 1 must be a double matrix");

	int ih = mxGetM(prhs[0]), iw = mxGetN(prhs[0]);

	plhs[0] = mxCreateDoubleMatrix(ih, iw, mxREAL);
	double *dist = mxGetPr(plhs[0]);

	plhs[1] = mxCreateNumericMatrix(ih, iw, mxINT32_CLASS, mxREAL);
	int *inds = (int *) mxGetData(plhs[1]);

	double *f = (double *) mxMalloc(MAX(iw, ih) * sizeof(double));
	double *d = (double *) mxMalloc(MAX(iw, ih) * sizeof(double));
	double *z = (double *) mxMalloc((MAX(iw, ih) + 1) * sizeof(double));
	int *v = (int *) mxMalloc(MAX(iw, ih) * sizeof(int));
	int *l = (int *) mxMalloc(MAX(iw, ih) * sizeof(int));

	double	*distp;
	int		*indp;

	if (mxIsLogical(prhs[0]))
	{
		const mxLogical *imgp = mxGetLogicals(prhs[0]);

		distp = dist;
		indp = inds;
		for (int x = 0, l0 = 1; x < iw; x++, l0 += ih)
		{
			for (int y = 0; y < ih; y++)
				f[y] = *(imgp++) ? 0 : big;
			DT1D(f, ih, v, z, d, l);
			for (int y = 0; y < ih; y++)
			{
				*(distp++) = d[y];
				*(indp++) = l[y] + l0;
			}
		}
	}
	else
	{
		const double *imgp = mxGetPr(prhs[0]);

		distp = dist;
		indp = inds;
		for (int x = 0, l0 = 1; x < iw; x++, l0 += ih)
		{
			for (int y = 0; y < ih; y++, imgp++)
				f[y] = isfinite(*imgp) ? *imgp : (*imgp > 0 ? big : -big);
			DT1D(f, ih, v, z, d, l);
			for (int y = 0; y < ih; y++)
			{
				*(distp++) = d[y];
				*(indp++) = l[y] + l0;
			}
		}
	}

	distp = dist;
	indp = inds;
	for (int y = 0; y < ih; y++, distp++, indp++)
	{
		const double *srcp = distp;
		for (int x = 0; x < iw; x++, srcp += ih)
			f[x] = *srcp;
		DT1D(f, iw, v, z, d, l);
		
		for (int x = 0; x < iw; x++)
			l[x] = indp[l[x] * ih];

		double *dp = distp;
		int *lp = indp;
		for (int x = 0; x < iw; x++, dp += ih, lp += ih)
		{
			*dp = d[x];
			*lp = l[x];
		}
	}

	mxFree(l);
	mxFree(v);
	mxFree(z);
	mxFree(d);
	mxFree(f);
}
