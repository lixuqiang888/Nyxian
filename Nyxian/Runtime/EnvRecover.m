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

#import "EnvRecover.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern char **environ;

/*
 @Brief extension of EnvRecover holding the sensitive backup safely
 */
@interface EnvRecover ()

@property (nonatomic,readonly) char **backup;

@end

/*
 @Brief NSObject to handle changes to environment variables
 basically resetting them after use
 */
@implementation EnvRecover

- (instancetype)init
{
    self = [super init];
    return self;
}

- (void)createBackup
{
    size_t total_size = 0;
    char **env = environ;
    while (*env != NULL) {
        total_size += strlen(*env) + 1;
        env++;
    }
    total_size += sizeof(char **) * (env - environ);
    _backup = malloc(total_size);
    memcpy(_backup, environ, total_size);
}

- (void)restoreBackup
{
    size_t total_size = 0;
    char **env = _backup;
    
    while (*env != NULL) {
        total_size += strlen(*env) + 1;
        env++;
    }
    
    total_size += sizeof(char **) * (env - _backup);
    memcpy(environ, _backup, total_size);
    free(_backup);
}


@end
