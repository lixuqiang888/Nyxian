//
//  LangBridge.m
//  Nyxian
//
//  Created by fridakitten on 25.03.25.
//

#import <Runtime/Modules/LangBridge/LangBridge.h>
#import <Runtime/Modules/IO/Helper/UniOrigHolder.h>
#import <Runtime/OtherLang/C/picoc.h>

@implementation LBModule

- (instancetype)init
{
    self = [super init];
    return self;
}

- (id)C_Alloc
{
    Picoc *pc = malloc(sizeof(Picoc));
    UniversalOriginalHolder *holder = [[UniversalOriginalHolder alloc] init:pc];
    return holder;
}

- (void)C_Release:(id)holder
{
    UniversalOriginalHolder *oholder = holder;
    Picoc *pc = oholder.ptr;
    free(pc);
}

- (void)C_Init:(id)holder stack_size:(int)stack_size
{
    UniversalOriginalHolder *oholder = holder;
    Picoc *pc = oholder.ptr;
    PicocInitialize(pc, stack_size);
}

- (void)C_CleanUp:(id)holder
{
    UniversalOriginalHolder *oholder = holder;
    Picoc *pc = oholder.ptr;
    PicocCleanup(pc);
}

- (void)C_ParseFile:(id)holder path:(NSString*)path
{
    UniversalOriginalHolder *oholder = holder;
    Picoc *pc = oholder.ptr;
    PicocPlatformScanFile(pc, [path UTF8String]);
}

- (int)C_CallMain:(id)holder args:(NSArray*)args
{
    UniversalOriginalHolder *oholder = holder;
    Picoc *pc = oholder.ptr;
    
    int argc = (int)[args count];
    char **argv = (char **)malloc((argc + 1) * sizeof(char *)); // Allocate memory for argv

    for (int i = 0; i < argc; i++) {
        const char *arg = [args[i] UTF8String];
        argv[i] = strdup(arg);
    }
    argv[argc] = NULL;
    
    PicocCallMain(pc, argc, argv);

    // Free allocated memory
    for (int i = 0; i < argc; i++) {
        free(argv[i]);
    }
    free(argv);
    
    return pc->PicocExitValue;
}

- (void)C_Interactive:(id)holder
{
    UniversalOriginalHolder *oholder = holder;
    Picoc *pc = oholder.ptr;
    
    PicocParseInteractive(pc);
}

@end
