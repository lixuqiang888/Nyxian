//
//  ArbCall.h
//  FridaScript
//
//  Created by fridakitten on 19.03.25.
//

#ifndef FS_MODULE_ARBCALL_H
#define FS_MODULE_ARBCALL_H

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <Runtime/Modules/Module.h>

@protocol ArbCallModuleExport <JSExport>

- (id)allocCall;
- (id)deallocCall:(JSValue*)callObject;
JSExportAs(allocFuncName,                        - (id)allocFuncName:(JSValue*)callObject name:(NSString*)name                                      );
JSExportAs(deallocFuncName,                      - (id)deallocFuncName:(JSValue*)callObject name:(NSString*)name                                    );

/// Args setter functions
/// 8 bits
JSExportAs(args_set_signedshort,                 - (id)args_set_signedshort:(JSValue*)callObject pos:(UInt8)pos param:(signed short)param           );
JSExportAs(args_set_unsignedshort,               - (id)args_set_unsignedshort:(JSValue*)callObject pos:(UInt8)pos param:(unsigned short)param       );

/// 16 bits
JSExportAs(args_set_signed,                     - (id)args_set_signed:(JSValue*)callObject pos:(UInt8)pos param:(signed)param                       );
JSExportAs(args_set_unsigned,                   - (id)args_set_unsigned:(JSValue*)callObject pos:(UInt8)pos param:(unsigned)param                   );

/// 32bit
JSExportAs(args_set_signedlong,                 - (id)args_set_signedlong:(JSValue*)callObject pos:(UInt8)pos param:(signed long)param              );
JSExportAs(args_set_unsignedlong,               - (id)args_set_unsignedlong:(JSValue*)callObject pos:(UInt8)pos param:(unsigned long)param          );

/// 64bit
JSExportAs(args_set_signedlonglong,             - (id)args_set_signedlonglong:(JSValue*)callObject pos:(UInt8)pos param:(signed long long)param     );
JSExportAs(args_set_unsignedlonglong,           - (id)args_set_unsignedlonglong:(JSValue*)callObject pos:(UInt8)pos param:(unsigned long long)param );

/// Ptr set
/// 64bit ptr
JSExportAs(args_set_ptr,                        - (id)args_set_ptr:(JSValue*)callObject pos:(UInt8)pos param:(uint64_t)param                        );

/// call
- (UInt64)call:(JSValue*)callObject;
- (void)findFunc:(JSValue*)callObject;

@end

@interface ArbCallModule : Module <ArbCallModuleExport>



@end

#endif
