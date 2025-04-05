/*
 MIT License

 Copyright (c) 2025 SeanIsTethered

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#include <stdio.h>
#include <unistd.h>
#include <Runtime/Hook/stdfd.h>

///
/// stdfd pipes
///
int stdfd_out[2] = {-1, -1};
int stdfd_in[2] = {-1, -1};;

///
/// stdfd file pointers (write end only)
///
FILE *stdfd_out_fp = NULL;
FILE *stdfd_in_fp = NULL;

///
/// Initilizer for the entire stdfd system
///
__attribute__((constructor))
void stdfd_init(void)
{
    // open both stdfds
    // on failure instead of just returning we just hook them to their original file descriptor
    if(pipe(stdfd_in) == -1)
    {
        stdfd_in[0] = STDIN_FILENO;
    } else {
        // if it didnt fail for stdin.. then we gonna go to the next round with hooking it
        dup2(stdfd_in[0], STDIN_FILENO);
    }
    
    if(pipe(stdfd_out) == -1)
        stdfd_out[1] = STDOUT_FILENO;
    
    // prepare the file pointers
    stdfd_in_fp = fdopen(stdfd_in[1], "w");
    stdfd_out_fp = fdopen(stdfd_out[1], "w");
    
    // so we are still here...
    // now ur on ur own
}
