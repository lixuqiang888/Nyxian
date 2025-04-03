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

int stdout_plus_err = 0;
FILE *stdout_plus_err_file;

void set_std_fd(int fd)
{
    // its already set, for security reasons, forbid overwrite
    if(stdout_plus_err != 0)
        return;
    
    // set file descriptor
    stdout_plus_err = fd;
    
    // get flags from the OG
    int flags = fcntl(STDOUT_FILENO, F_GETFL);
    
    // set flags to the made in china copy
    fcntl(stdout_plus_err, F_SETFL, flags);
    
    // gettint its file structure
    stdout_plus_err_file = fdopen(stdout_plus_err, "w");
}

int get_std_fd(void)
{
    return stdout_plus_err;
}

FILE *get_std_file(void)
{
    return stdout_plus_err_file;
}
