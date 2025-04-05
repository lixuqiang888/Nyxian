//
//  LLVMBridge.h
//  Declaration of Objective-C class LLVMBridge to expose C++ services of LLVM to Swift
//  For simplicity, this file is also used as Swift-ObjC bridging header in this sample project
//
//  Created by Lightech on 10/24/2048.
//

#ifndef LLVMBridge_h
#define LLVMBridge_h

#import <Foundation/Foundation.h>

/// Class (intended to be single-instanced) to provide LLVM C++ service to Swift front-end
@interface LLVMBridge : NSObject

// Interpret the C++ source code file
- (void)interpretProgram:(nonnull NSData*)fileName;

@end

#endif /* LLVMBridge_h */
