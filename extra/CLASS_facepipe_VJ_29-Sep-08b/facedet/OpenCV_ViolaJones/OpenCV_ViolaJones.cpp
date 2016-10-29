#ifdef _CH_
#define WIN32
#error "The file needs cvaux, which is not wrapped yet. Sorry"
#endif

#ifndef _EiC
#include "cv.h"
#include "highgui.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <float.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>
#endif

#ifdef _EiC
#define WIN32
#endif

static CvMemStorage* storage = 0;
static CvHaarClassifierCascade* cascade = 0;

void detect_and_draw( IplImage* image );
void detect_and_save( IplImage* image, const char *outpath );

int main( int argc, char** argv )
{
    CvCapture* capture = 0;
    IplImage *frame_copy = 0;
    const char * cascade_name, * input_name, * output_name;

	if (argc != 4)
	{
        fprintf(stderr,"Usage: facedetect <cascade_path> <image_path> <out_path>\n");
		return 1;
	}

	cascade_name = argv[1];
	input_name = argv[2];
	output_name = argv[3];

    cascade = (CvHaarClassifierCascade*)cvLoad( cascade_name, 0, 0, 0 );
    
    if( !cascade )
    {
        fprintf( stderr, "ERROR: Could not load classifier cascade\n" );
        return -1;
    }
    storage = cvCreateMemStorage(0);
/*    
    cvNamedWindow( "result", 1 );

    IplImage* image = cvLoadImage( input_name, 1 );

    if( image )
    {
        detect_and_draw( image );
        cvWaitKey(0);
        cvReleaseImage( &image );
    }
    
    cvDestroyWindow("result");
*/
    IplImage* image = cvLoadImage( input_name, 1 );

    if( image )
    {
        detect_and_save( image, output_name );
        cvReleaseImage( &image );
    }

    return 0;
}

void detect_and_draw( IplImage* img )
{
    int scale = 1;
//    IplImage* temp = cvCreateImage( cvSize(img->width/scale,img->height/scale), 8, 3 );
    CvPoint pt1, pt2;
    int i;

    //cvPyrDown( img, temp, CV_GAUSSIAN_5x5 );
    cvClearMemStorage( storage );

    if( cascade )
    {
        CvSeq* faces = cvHaarDetectObjects( img, cascade, storage,
                                            1.1, 2, CV_HAAR_DO_CANNY_PRUNING,
                                            cvSize(40, 40) );
        for( i = 0; i < (faces ? faces->total : 0); i++ )
        {
            CvRect* r = (CvRect*)cvGetSeqElem( faces, i );
            pt1.x = r->x*scale;
            pt2.x = (r->x+r->width)*scale;
            pt1.y = r->y*scale;
            pt2.y = (r->y+r->height)*scale;
            cvRectangle( img, pt1, pt2, CV_RGB(255,0,0), 3, 8, 0 );
        }
    }

    cvShowImage( "result", img );
//    cvReleaseImage( &temp );
}

void detect_and_save( IplImage* img, const char *outpath)
{
    int scale = 1;
    CvPoint pt1, pt2;
    int i;

	FILE *fp = fopen(outpath,"w");

    cvClearMemStorage( storage );

    if( cascade )
    {
        CvSeq* faces = cvHaarDetectObjects( img, cascade, storage,
                                            1.1, 2, CV_HAAR_DO_CANNY_PRUNING,
                                            cvSize(40, 40) );
		fprintf(fp, "%d\n", (faces ? faces->total : 0));

		for( i = 0; i < (faces ? faces->total : 0); i++ )
        {
            CvRect* r = (CvRect*)cvGetSeqElem( faces, i );
            pt1.x = r->x*scale;
            pt2.x = (r->x+r->width)*scale;
            pt1.y = r->y*scale;
            pt2.y = (r->y+r->height)*scale;

            cvRectangle( img, pt1, pt2, CV_RGB(255,0,0), 3, 8, 0 );

			fprintf(fp, "%d %d %d %d\n", pt1.x + 1, pt2.x + 1, pt1.y + 1, pt2.y + 1);
        }
    }
	else
		fprintf(fp, "%d\n", 0);

	fclose(fp);
}

#ifdef _EiC
main(1,"facedetect.c");
#endif
