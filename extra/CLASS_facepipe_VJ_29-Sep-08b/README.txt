Oxford VGG Baseline Face Processing Code

Mark Everingham, me@comp.leeds.ac.uk, 11-Jul-06 - 29-Sep-08

When using this code please cite:

Everingham, M. , Sivic, J. and Zisserman, A.
"Hello! My name is... Buffy" - Automatic Naming of Characters in TV Video
Proceedings of the British Machine Vision Conference (2006) 

http://www.robots.ox.ac.uk/~vgg/publications/html/everingham06a-abstract.html

-----------------------------------------------------------------------------

This archive contains a MATLAB implementation of a baseline face
processing pipeline, specifically:

- face detection
- facial feature localization
- face descriptor extraction

The face detector is from OpenCV. Bilinear interpolation code
is by Yoni Wexler/Andrew Fitzgibbon. Remaining code is by
Mark Everingham.

To get started, run "demo". This detects faces in the example
image, loading cached detections from files if available,
localizes the facial features and extracts descriptors for each
face.

The code needs MATLAB R13SP1 or later. You may need to recompile
the MEX files for your particular system. If your compiler is set
up correctly (run mex -setup), you should be able to compile all
by running "mexall" from the MATLAB command line. Precompiled MEX
files are included for Windows R13SP1 and Linux R14.

Face detector is hacked from OpenCV.
The file "demo" shows how to use the code. The main function
provided is "extfacedescs" which runs the complete pipeline on an
image:

[DETS,PTS,DESC]=extfacedescs(opts,img,debug)

You need to run "init" first to initialize the options structure
"opts".

The parameter "img" is the input image. If this is a string, it is
assumed to be the path to an image file (JPEG, PNG, etc.). In this
case the face detector output is also written to a file for later
use e.g. "test.jpg" produces a face detection file "test.jpg.vj".
If "img" is not a string, it should either by an RGB or grayscale
image.

If the "debug" parameter is included and "true", the face
detections and descriptor patches are displayed.

The output is as follows:

DETS:   4 x n matrix of face detections.
        Each column is [x y scale confidence]' for a face detection.
        (x,y) is the center of the face (top-left is 1,1)
        <scale> is the half-width of the bounding box.
        <confidence> is the face detection confidence.

PTS:    2 x 9 x n matrix of facial feature points.

DESC:   m x n matrix of face descriptors. Each column is a
        descriptor for the corresponding face detection.

Note that the facial feature localization is *not* scale
invariant. This means that you should run it on the bounding boxes
output by, or similar to those output by, the provided face
detector. Its behaviour on bounding boxes of other sizes is
unpredictable.
