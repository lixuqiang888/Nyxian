//
//  LLVMBridge.h
//  Declaration of Objective-C class LLVMBridge to expose C++ services of LLVM to Swift
//  For simplicity, this file is also used as Swift-ObjC bridging header in this sample project
//
//  Created by Lightech on 10/24/2048.
//

#ifndef FCMBridge_H
#define FCMBridge_H

#import <Foundation/Foundation.h>

/// Class (intended to be single-instanced) to provide LLVM C++ service to Swift front-end
@interface FCMBridge : NSObject

// Interpret the C++ source code file
- (int)compileObject:(nonnull NSString*)fileName;

@end

///
/// Function to typecheck code before we compile it to prevent memory leakage before compilation.
///
int typecheck( NSArray * _Nonnull nsargs);

#endif /* FCMBridge_H */
