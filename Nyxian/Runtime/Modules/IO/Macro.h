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

/// Header to the MacroHelper needed to build the macro map
#include <Runtime/Modules/MacroHelper.h>

/// Headers required to even build the macro map
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <dirent.h>

/// Macro map of the I/O module
#define IO_MACRO_MAP() \
DECLARE_CONTEXT_MAPPING(O_RDONLY) \
DECLARE_CONTEXT_MAPPING(O_WRONLY) \
DECLARE_CONTEXT_MAPPING(O_RDWR) \
DECLARE_CONTEXT_MAPPING(O_APPEND) \
DECLARE_CONTEXT_MAPPING(O_CREAT) \
DECLARE_CONTEXT_MAPPING(O_EXCL) \
DECLARE_CONTEXT_MAPPING(O_TRUNC) \
DECLARE_CONTEXT_MAPPING(O_NOCTTY) \
DECLARE_CONTEXT_MAPPING(O_NOFOLLOW) \
DECLARE_CONTEXT_MAPPING(O_SYNC) \
DECLARE_CONTEXT_MAPPING(O_DSYNC) \
DECLARE_CONTEXT_MAPPING(O_NONBLOCK) \
DECLARE_CONTEXT_MAPPING(O_CLOEXEC) \
DECLARE_CONTEXT_MAPPING(O_ACCMODE) \
DECLARE_CONTEXT_MAPPING(O_DIRECTORY) \
DECLARE_CONTEXT_MAPPING(F_OK) \
DECLARE_CONTEXT_MAPPING(R_OK) \
DECLARE_CONTEXT_MAPPING(W_OK) \
DECLARE_CONTEXT_MAPPING(X_OK) \
DECLARE_CONTEXT_MAPPING(F_DUPFD) \
DECLARE_CONTEXT_MAPPING(F_GETFD) \
DECLARE_CONTEXT_MAPPING(F_SETFD) \
DECLARE_CONTEXT_MAPPING(F_GETFL) \
DECLARE_CONTEXT_MAPPING(F_SETFL) \
DECLARE_CONTEXT_MAPPING(F_GETLK) \
DECLARE_CONTEXT_MAPPING(F_SETLK) \
DECLARE_CONTEXT_MAPPING(F_SETLKW) \
DECLARE_CONTEXT_MAPPING(F_GETOWN) \
DECLARE_CONTEXT_MAPPING(F_SETOWN) \
DECLARE_CONTEXT_MAPPING(F_RDLCK) \
DECLARE_CONTEXT_MAPPING(F_WRLCK) \
DECLARE_CONTEXT_MAPPING(F_UNLCK) \
DECLARE_CONTEXT_MAPPING(SEEK_SET) \
DECLARE_CONTEXT_MAPPING(SEEK_CUR) \
DECLARE_CONTEXT_MAPPING(SEEK_END) \
DECLARE_CONTEXT_MAPPING(S_IFMT) \
DECLARE_CONTEXT_MAPPING(S_IFSOCK) \
DECLARE_CONTEXT_MAPPING(S_IFMT) \
DECLARE_CONTEXT_MAPPING(S_IFLNK) \
DECLARE_CONTEXT_MAPPING(S_IFREG) \
DECLARE_CONTEXT_MAPPING(S_IFBLK) \
DECLARE_CONTEXT_MAPPING(S_IFDIR) \
DECLARE_CONTEXT_MAPPING(S_IFCHR) \
DECLARE_CONTEXT_MAPPING(S_IFIFO) \
DECLARE_CONTEXT_MAPPING(S_IRWXU) \
DECLARE_CONTEXT_MAPPING(S_IRUSR) \
DECLARE_CONTEXT_MAPPING(S_IWUSR) \
DECLARE_CONTEXT_MAPPING(S_IXUSR) \
DECLARE_CONTEXT_MAPPING(S_IRWXG) \
DECLARE_CONTEXT_MAPPING(S_IRGRP) \
DECLARE_CONTEXT_MAPPING(S_IWGRP) \
DECLARE_CONTEXT_MAPPING(S_IXGRP) \
DECLARE_CONTEXT_MAPPING(S_IRWXO) \
DECLARE_CONTEXT_MAPPING(S_IROTH) \
DECLARE_CONTEXT_MAPPING(S_IWOTH) \
DECLARE_CONTEXT_MAPPING(S_IXOTH) \
DECLARE_CONTEXT_MAPPING(S_ISUID) \
DECLARE_CONTEXT_MAPPING(S_ISGID) \
DECLARE_CONTEXT_MAPPING(S_ISVTX) \
DECLARE_CONTEXT_MAPPING(DT_BLK) \
DECLARE_CONTEXT_MAPPING(DT_CHR) \
DECLARE_CONTEXT_MAPPING(DT_DIR) \
DECLARE_CONTEXT_MAPPING(DT_LNK) \
DECLARE_CONTEXT_MAPPING(DT_REG) \
DECLARE_CONTEXT_MAPPING(DT_WHT) \
DECLARE_CONTEXT_MAPPING(DT_WHT) \
DECLARE_CONTEXT_MAPPING(DT_FIFO) \
DECLARE_CONTEXT_MAPPING(DT_SOCK) \
DECLARE_CONTEXT_MAPPING(DT_UNKNOWN) \
DECLARE_CONTEXT_MAPPING(STDIN_FILENO) \
