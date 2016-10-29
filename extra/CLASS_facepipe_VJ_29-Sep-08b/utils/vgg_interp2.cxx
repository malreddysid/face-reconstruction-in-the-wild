/* Linear interpolation of a 2D matrix. Hope to speed up interp2 by
 * bypassing all the special checks.
 *
 *
 *
 * $Id: vgg_interp2.cxx,v 1.17 2005/01/25 16:06:06 awf Exp $
 * Yoni, Wed Jul 25 12:14:22 2001
 */

#include <mex.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "vgg_real_2_int.h"


/* Nearest neighbor */
template<class T>
static void nearest2_color(const T A[],
			   const int h, const int w, const int col,
			   const double X[], const double Y[], const int n,
			   double V[], const int step,
			   const double oobv /* = NaN */)
{
   if (h > 32767) mexErrMsgTxt("h > 32767");
   if (w > 32767) mexErrMsgTxt("w > 32767");
   const double dw = w;
   const double dh = h;
   for(int j=0; j<col; j++) {
      const double *pX = X;
      const double *pY = Y;
      double *out=V + step*j;
      const T *pA = A + h*w*j;
      for(int i=0; i<n; ++i, ++out, ++pX, ++pY) {

	 // Now reals are > 1.0.  If < 32768.0 can use fast f2i
	 int x1 = Real2Int(*pX);
	 int y1 = Real2Int(*pY);

	 if (x1<1 || x1>w || y1<1 || y1>h) {
	    *out = oobv;
	    continue;
	 }
//#define AWF_DEBUG
#ifdef AWF_DEBUG
	 if (Real2Int(*pX) != int(*pX))
	    printf("y %30.20f -> R2I: %d int: %d\n", *pX, Real2Int(*pX), int(*pX));
#endif

// 	 const T *pA = A + h*(x1-1) + (y1-1) + (h*w*j);
// 	 const T a = pA[0];
// 	 *out = pA[0];
	 *out =  pA[h*(x1-1) + (y1-1)];
      }
   }
}



template<class T>
static void interp2_color(const T A[],
			  const int h, const int w, const int col,
			  const double X[], const double Y[], const int n,
			  double V[], const int step, double oobv)
{
   double *out=V;
   //const double oobv = mxGetNaN();

   if (h > 32767) mexErrMsgTxt("h > 32767");
   if (w > 32767) mexErrMsgTxt("w > 32767");
   const double dw = w;
   const double dh = h;

   for(int i=0; i<n; ++i, ++out, ++X, ++Y) {
      double d1 = (*X);
      double d2 = (*Y);
      if (d1 < 1.0 || d1>dw || d2 < 1.0 || d2>dh) {
	 for(int j=0; j<col; j++)
	    out[step*j] = oobv;
	 continue;
      }

      // Now reals are > 1.0.  If < 32768.0 can use fast f2i
      int x1 = Real2Int(d1);
      int y1 = Real2Int(d2);

#ifdef AWF_DEBUG
      if (Real2Int(d2) != int(d2))
	 printf("y %30.20f -> R2I: %d int: %d\n", d2, Real2Int(d2), int(d2));
#endif

      double u = d1 - double(x1);
      double v = d2 - double(y1);
      // Fix the fact that real2int(x) rounds upwards
      // if x is too close to ceil(x).
      if (u < 0) {
	 --x1;
	 u += 1.0;
      }
      if (v < 0) {
	 --y1;
	 v += 1.0;
      }

      if (x1<w && y1<h) {
	 for(int j=0; j<col; j++) {
	    const T *pA = A + h*(x1-1) + (y1-1) + (h*w*j);

	    const T a = pA[0];
	    const T b = pA[h];
	    const T c = pA[1];
	    const T d = pA[h+1];

	    const double t1 = a + (b - a)* u;
	    const double t2 = c + (d - c)* u;

	    out[step*j] = t1 + (t2 - t1)* v;
	 }
      } else if (x1 < w) {
	 for(int j=0; j<col; j++) {
	    const T *pA = A + h*(x1-1) + (y1-1) + (h*w*j);

	    const T a = pA[0];
	    const T b = pA[h];

	    out[step*j] = a + (b - a)* u;
	 }
      } else if (y1 < h) {
	 for(int j=0; j<col; j++) {
	    const T *pA = A + h*(x1-1) + (y1-1) + (h*w*j);

	    const T a = pA[0];
	    const T c = pA[1];

	    const double t1 = a;
	    const double t2 = c;

	    out[step*j] = t1 + (t2 - t1)* v;
	 }
      } else { // x1==w && y1==h
	for(int j=0; j<col; j++)
	  out[step*j] = A[h*w-1 + (h*w*j)];
      }
   }
}

// The body of this one should be exactly the same as interp2_color.
// The different template definition, combined with -funroll-loops
// compiler option (gcc) will remove the unnecessary code in the
// grayscale case. It is also a bit faster for color.
template<class T, int col>
struct interp2 {
  static void f(const T A[],
		const int h, const int w,
		const double X[], const double Y[], const int n,
		double V[], const int step, double oobv);
};

template<class T, int col>
void interp2<T,col>::f(const T A[],
		       const int h, const int w,
		       const double X[], const double Y[], const int n,
		       double V[], const int step, double oobv)
{
  double *out=V;
  //const double oobv = mxGetNaN();

  if (h > 32767) mexErrMsgTxt("h > 32767");
  if (w > 32767) mexErrMsgTxt("w > 32767");
  const double dw = w;
  const double dh = h;

  for(int i=0; i<n; ++i, ++out, ++X, ++Y) {
    double d1 = (*X);
    double d2 = (*Y);

    if (d1 < 1.0 || d1>dw || d2 < 1.0 || d2>dh) {
      for(int j=0; j<col; j++)
	out[step*j] = oobv;
      continue;
    }

    // Now reals are > 1.0.  If < 32768.0 can use fast f2i
    int x1 = Real2Int(d1);
    int y1 = Real2Int(d2);

#ifdef AWF_DEBUG
    if (Real2Int(d2) != int(d2))
      printf("y %30.20f -> R2I: %d int: %d\n", d2, Real2Int(d2), int(d2));
#endif

    double u = d1 - double(x1);
    double v = d2 - double(y1);
    // Fix the fact that real2int(x) rounds upwards
    // if x is too close to ceil(x).
    if (u < 0) {
      --x1;
      u += 1.0;
    }
    if (v < 0) {
      --y1;
      v += 1.0;
    }

    if (x1<w && y1<h) {
      for(int j=0; j<col; j++) {
	const T *pA = A + h*(x1-1) + (y1-1) + (h*w*j);

	const T a = pA[0];
	const T b = pA[h];
	const T c = pA[1];
	const T d = pA[h+1];

	//if (pA+h+1 >= A+h*w*col) printf("zoiks1!");

	const double t1 = a + (b - a)* u;
	const double t2 = c + (d - c)* u;

	out[step*j] = t1 + (t2 - t1)* v;
      }
    } else if (x1 < w) {
      for(int j=0; j<col; j++) {
	const T *pA = A + h*(x1-1) + (y1-1) + (h*w*j);

	const T a = pA[0];
	const T b = pA[h];

	//if (pA+h >= A+h*w*col) printf("zoiks2!");

	out[step*j] = a + (b - a)* u;
      }
    } else if (y1 < h) {
      for(int j=0; j<col; j++) {
	const T *pA = A + h*(x1-1) + (y1-1) + (h*w*j);

	const T a = pA[0];
	const T c = pA[1];

	//if (pA+1 >= A+h*w*col) printf("zoiks3!");
	
	const double t1 = a;
	const double t2 = c;

	out[step*j] = t1 + (t2 - t1)* v;
      }
    } else { // x1==w && y1==h 
      if (!(x1 == w && y1 == h))
	printf("Zoiks: x1,y1 = %d,%d   w,h = %d,%d\n", x1,y1, w,h);

      //if (h*w-1 + (h*w*(col-1)) >= h*w*col) printf("zoiks3!");
	
      for(int j=0; j<col; j++)
	out[step*j] = A[h*w-1 + (h*w*j)];
    }
  }
}

// Implements matlab's peculiar interpretation of the
// METHOD string, documented in shell wildcard syntax as: 
//  l*, bil*   bilinear (code 1)
//  n*         nearest neighbour (code 2)
//  c*, bic*   bicubic (unimplemented)
//  s*         spline (unimplemented)
/*
*/
int parse_interp_type(char const* const buffer)
{
  char const* p = buffer;
  if (*p == '*') {
    printf("vgg_interp2: NOTE: *syntax ignored\n");
    ++p;
  }
  char const *rn = 0;
  if (*p == 'b') {
    // strip "bi" if present
    if (strlen(p) < 3 || p[1] != 'i') 
      goto unrecognized;
    p += 2;
  }
  
  switch (*p) {
  case 'l': return 1;
  case 'c': rn = "bicubic"; goto unimplemented;
  case 's': rn = "spline"; goto unimplemented;
  case 'n': return 2;
  }
 unrecognized: {
    char buf[1024];
    sprintf(buf, "vgg_interp2: Unrecognized interp type [%s]", buffer);
    mexErrMsgTxt(buf);
    return 0;
  }

 unimplemented: {
    char buf[1024];
    sprintf(buf, "vgg_interp2: Interp type '%s' [called as '%s'] is unimplemented", rn, buffer);
    mexErrMsgTxt(buf);
    return 0;
  }
}


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
   if(nrhs<3 || nrhs > 5)
      mexErrMsgTxt("Wrong number of arguments for vgg_interp2");

   if (!(mxIsDouble(prhs[1]) && mxIsDouble(prhs[2])))
      mexErrMsgTxt("vgg_interp2 takes only double arguments for X,Y");

   const int *dims =  mxGetDimensions(prhs[0]);
   int h=dims[0], w=dims[1], col=1;

   int number_of_dims = mxGetNumberOfDimensions(prhs[0]);
   for(int i=2; i<number_of_dims; i++)
      col *= dims[i];

   //This is incorrect: I may well have a 1x500x3 image if it's
   //a row in a rectified stereo pair.
   //if (h<2 || w<2)
   //  mexErrMsgTxt("'img' must be 2- or 3-dimensional");

   if (mxGetM(prhs[1])!=mxGetM(prhs[2]) || mxGetN(prhs[1])!=mxGetN(prhs[2]))
     mexErrMsgTxt("X,Y must have the same size");

   if (nlhs>1)
     mexErrMsgTxt("Must have at most one output.");

   double *X = mxGetPr(prhs[1]);
   double *Y = mxGetPr(prhs[2]);
   int n = mxGetM(prhs[1]) * mxGetN(prhs[1]);

   int *odims = (int *)mxMalloc(sizeof(int)*number_of_dims);
   {for(int i=0; i<number_of_dims; i++)
     odims[i] = dims[i];}
   odims[0] = mxGetM(prhs[1]);
   odims[1] = mxGetN(prhs[1]);

   plhs[0] = mxCreateNumericArray(number_of_dims, odims,
				  mxDOUBLE_CLASS, mxREAL);
   double *V=(double *)mxGetData(plhs[0]);
   const int step = odims[0]*odims[1];

   int interp_type = 1; // 1: linear, 2: nearest
   if (nrhs>=4) {
      const int buflen=1024;
      char buffer[buflen];
      mxGetString(prhs[3], buffer, buflen);
      interp_type = parse_interp_type(buffer);
   }

   double oobv;
   if (nrhs>=5) {
      if(mxGetM(prhs[4])>1 || mxGetN(prhs[4])>1 || !mxIsDouble(prhs[4]))
	 mexErrMsgTxt("Wrong argument for oobv");
      oobv = *mxGetPr(prhs[4]);
   } else
     oobv = mxGetNaN();
   
   switch(interp_type) {
   case 1:
      if(mxGetClassID(prhs[0])==mxDOUBLE_CLASS) {
	 const double *A = mxGetPr(prhs[0]);

	 switch(col) {
	 case 1:
	    interp2<double, 1>::f(A, h, w, X, Y, n, V, step, oobv);
	    break;
	 case 3:
	    interp2<double, 3>::f(A, h, w, X, Y, n, V, step, oobv);
	    break;
	 default:
	    interp2_color(A, h, w, col, X, Y, n, V, step, oobv);
	 }
      } else if (mxGetClassID(prhs[0]) == mxUINT8_CLASS) {
	 const unsigned char *A=(unsigned char *)mxGetData(prhs[0]);
	 switch(col) {
	 case 1:
	    interp2<unsigned char, 1>::f(A, h, w, X, Y, n, V, step, oobv);
	    break;
	 case 3:
	    interp2<unsigned char, 3>::f(A, h, w, X, Y, n, V, step, oobv);
	    break;
	 default:
	    interp2_color(A, h, w, col, X, Y, n, V, step, oobv);
	 }
      } else if (mxGetClassID(prhs[0]) == mxLOGICAL_CLASS) {
	 const mxLogical *A=mxGetLogicals(prhs[0]);
	 switch(col) {
	 case 1:
	    interp2<mxLogical, 1>::f(A, h, w, X, Y, n, V, step, oobv);
	    break;
	 case 3:
	    interp2<mxLogical, 3>::f(A, h, w, X, Y, n, V, step, oobv);
	    break;
	 default:
	    interp2_color(A, h, w, col, X, Y, n, V, step, oobv);
	 }

      } else
	 mexErrMsgTxt("Unsupported type of 'A'");
      break;
   case 2:
      if(mxGetClassID(prhs[0])==mxDOUBLE_CLASS) {
	 const double *A = mxGetPr(prhs[0]);
	 nearest2_color<double>(A, h, w, col, X, Y, n, V, step,oobv);
      } else if (mxGetClassID(prhs[0]) == mxUINT8_CLASS) {
	 const unsigned char *A=(unsigned char *)mxGetData(prhs[0]);
	 nearest2_color<unsigned char>(A, h, w, col, X, Y, n, V, step,oobv);
      } else if (mxGetClassID(prhs[0]) == mxLOGICAL_CLASS) {
	 const mxLogical *A=mxGetLogicals(prhs[0]);
	 nearest2_color<mxLogical>(A, h, w, col, X, Y, n, V, step,oobv);
      }
      break;
   default:
      mexErrMsgTxt("Internal error");
   }

   // Apparently we are not supposed to free this one:
   //mxFree(odims);
}

#if 0
// This is not needed anymore. Left here as reference:
static void interp2(const double A[], const int h, const int w,
		    const double X[], const double Y[], const int n,
		    double V[], double oobv)
{
   double *out=V;
   //const double oobv = mxGetNaN();

   for(int i=0; i<n; i++) {

      int x1 = int(*X);
      int y1 = int(*Y);
      if (x1>=1 && y1>=1 && x1<w && y1<h) {
	double u = *X - double(x1);
	double v = *Y - double(y1);

	const double *pA = A + h*(x1-1) + (y1-1);

	const double a = pA[0];
	const double b = pA[h];
	const double c = pA[1];
	const double d = pA[h+1];

	const double t1 = a + (b - a)* u;
	const double t2 = c + (d - c)* u;

	*out = t1 + (t2 - t1)* v;

      } else if (y1 == h && (x1 < w) && (x1 >= 1)) {
	double u = *X - x1;
	double v = *Y - y1;

	const double *pA = A + h*(x1-1) + (y1-1);

	const double a = pA[0];
	const double b = pA[h];

	*out = a + (b - a)* u;

      } else if (x1 == w && (y1 < h) && (y1 >= 1)) {
	double u = *X - double(x1);
	double v = *Y - double(y1);

	const double *pA = A + h*(x1-1) + (y1-1);

	const double a = pA[0];
	const double c = pA[1];

	const double t1 = a;
	const double t2 = c;

	*out = t1 + (t2 - t1)* v;

      } else if (x1 == w && y1 == h) {
	*out = A[h*w-1];

      } else
	*out=oobv;

      out++; X++; Y++;
   }
}
#endif

