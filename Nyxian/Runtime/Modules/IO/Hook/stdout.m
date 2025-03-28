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

#include <Runtime/Modules/IO/Hook/stdin.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <dispatch/dispatch.h>
#include <fcntl.h>

int fake_stdout[2];

void fake_stdout_init(void)
{
    if (pipe(fake_stdout) == -1) {
        perror("pipe failed");
        return;
    }
}

int getFakeStdoutReadFD(void)
{
    return fake_stdout[0];
}

int getFakeStdoutWriteFD(void)
{
    return fake_stdout[1];
}

void setFakeStdoutReadFD(int fd)
{
    fake_stdout[0] = fd;
}

void setFakeStdoutWriteFD(int fd)
{
    fake_stdout[1] = fd;
}
