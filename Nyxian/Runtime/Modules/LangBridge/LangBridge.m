//
//  LangBridge.m
//  Nyxian
//
//  Created by fridakitten on 25.03.25.
//

#import <Runtime/Modules/LangBridge/LangBridge.h>
#import <Runtime/Modules/IO/Helper/UniOrigHolder.h>
#import <Runtime/OtherLang/C/picoc.h>
#import <Runtime/ErrorThrow.h>
#import <Runtime/Safety.h>

@implementation LBModule

- (instancetype)init
{
    self = [super init];
    return self;
}

- (id)C_Alloc
{
    if(NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED)
        return JS_THROW_ERROR(EW_PERMISSION);
    
    Picoc *pc = malloc(sizeof(Picoc));
    UniversalOriginalHolder *holder = [[UniversalOriginalHolder alloc] init:pc];
    return holder;
}

- (id)C_Release:(id)holder
{
    if(NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED)
        return JS_THROW_ERROR(EW_PERMISSION);
    
    UniversalOriginalHolder *oholder = holder;
    Picoc *pc = oholder.ptr;
    free(pc);
    
    return NULL;
}

- (id)C_Init:(id)holder stack_size:(int)stack_size
{
    if(NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED)
        return JS_THROW_ERROR(EW_PERMISSION);
    
    UniversalOriginalHolder *oholder = holder;
    Picoc *pc = oholder.ptr;
    PicocInitialize(pc, stack_size);
    
    return NULL;
}

- (id)C_CleanUp:(id)holder
{
    if(NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED)
        return JS_THROW_ERROR(EW_PERMISSION);
    
    UniversalOriginalHolder *oholder = holder;
    Picoc *pc = oholder.ptr;
    PicocCleanup(pc);
    
    return NULL;
}

- (id)C_ParseFile:(id)holder path:(NSString*)path
{
    if(NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED)
        return JS_THROW_ERROR(EW_PERMISSION);
    
    UniversalOriginalHolder *oholder = holder;
    Picoc *pc = oholder.ptr;
    PicocPlatformScanFile(pc, [path UTF8String]);
    
    return NULL;
}

- (id)C_CallMain:(id)holder args:(NSArray*)args
{
    if(NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED)
        return JS_THROW_ERROR(EW_PERMISSION);
    
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
    
    return @(pc->PicocExitValue);
}

- (id)C_Interactive:(id)holder
{
    if(NYXIAN_RUNTIME_SAFETY_LANGBRIDGE_ENABLED)
        return JS_THROW_ERROR(EW_PERMISSION);
    
    UniversalOriginalHolder *oholder = holder;
    Picoc *pc = oholder.ptr;
    
    if (PicocPlatformSetRealExitPoint(pc)) {
        return NULL;
    }
    
    PicocParseInteractive(pc);
    
    return NULL;
}

@end
