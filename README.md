
Implementation of the paper - Face Reconstruction in the Wild

## Setup

I am using MATLAB 2016a on MacOSX10.12 (Sierra)

Go to the folder /Applications/MATLAB_R2016a.app/bin/maci64/mexopts and edit the files clang++_maci64.xml and clang_maci64.xml . In both of those files, search for lines containing the string MacOSX10.10.sdk or MacOSX10.11.sdk . Duplicate the line and change it to MacOSX10.12.sdk . You will need to change 4 lines total in each of the two files, a line that mentions dirExists then a line that mentions cmdReturns and then the same two again.

Now, go into either Applications or LaunchPad and find your XCode icon, and launch it. You will need to agree to the license terms. If XCode launches without presenting the license terms dialog then you have already agreed for that version and do not need to repeat it.

The edits and the license agreement having been done, you should now be able to go into MATLAB and use

mex -setup C
mex -setup C++
