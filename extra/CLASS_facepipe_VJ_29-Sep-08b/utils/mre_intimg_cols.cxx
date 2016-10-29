#include "mex.h"
#include <math.h>
#include <string.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	bool			inplace;
	const mxArray	*pX;

	if (nrhs != 2)
		mexErrMsgTxt("two input arguments expected");

	if (nlhs != 1)
		mexErrMsgTxt("one output argument expected");
	
	pX = prhs[0];

	if (!mxIsDouble(pX) || mxIsComplex(pX) || mxGetNumberOfDimensions(pX) != 2 || !mxGetNumberOfElements(pX))
		mexErrMsgTxt("input must be a non-empty double matrix");

	if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || mxGetNumberOfElements(prhs[1]) != 2)
		mexErrMsgTxt("argument 2 must be a double 2-vector");

	const double *sz = mxGetPr(prhs[1]);

	int	ih = (int) sz[0];
	int	iw = (int) sz[1];

	double	*X = mxGetPr(pX);
	int		n = mxGetN(pX);
	double	*Y;

	int	xd = ih * iw;
	int yd = (ih + 1) * (iw + 1);

	plhs[0] = mxCreateDoubleMatrix(yd, n, mxREAL);
	Y = mxGetPr(plhs[0]);

	Y += ih + 2;
	for (int i = 0; i < n; i++, X += xd, Y += yd)
	{
		const double	*xp;
		double	*yp;
		
		xp = X;
		yp = Y;
		for (int x = 0; x < iw; x++)
		{
			double s = *(xp++);

			*(yp++) = s;
			for (int y = 1; y < ih; y++, xp++, yp++)
				*yp = (s += *xp);
			yp++;
		}

		yp = Y + ih + 1;
		for (int x = 1; x < iw; x++)
		{
			for (int y = 0; y < ih; y++, yp++)
				*yp += *(yp - ih - 1);
			yp++;
		}
	}
}
