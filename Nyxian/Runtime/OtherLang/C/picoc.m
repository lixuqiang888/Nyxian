#import <bridge.h>
#include "picoc.h"
#include "LICENSE.h"

#define PICOC_STACK_SIZE (128000*4)

int c_interpret(NSString *files, NSString *proot)
{
    chdir([proot UTF8String]);
    
    int ParamCount = 1;
    Picoc pc;

    PicocInitialize(&pc, PICOC_STACK_SIZE);

    if (PicocPlatformSetExitPoint(&pc)) {
        PicocCleanup(&pc);
        return pc.PicocExitValue;
    }
    
    NSArray *splitPaths = [files componentsSeparatedByString:@" "];
    for (NSString *path in splitPaths) {
        if (path.length > 0) {
            PicocPlatformScanFile(&pc, [path UTF8String]);
        }
    }
    
    char *argv[] = { "picoc", NULL };
    PicocCallMain(&pc, 0, &argv[ParamCount]);

    PicocCleanup(&pc);
    return pc.PicocExitValue;
}

void c_repl(NSString *proot)
{
    chdir([proot UTF8String]);
    
    Picoc pc;
    PicocInitialize(&pc, PICOC_STACK_SIZE);
    
    if (PicocPlatformSetRealExitPoint(&pc)) {
        PicocCleanup(&pc);
        return;
    }
    
    PicocParseInteractive(&pc);
    
    PicocCleanup(&pc);
}
