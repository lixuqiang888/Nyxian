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

import Foundation
import Swifter

///
/// Private API code to open a app with a specific bundle identifier
///
private func obfuscatedClass(_ className: String) -> AnyClass? {
    return NSClassFromString(className)
}

private func obfuscatedSelector(_ selectorName: String) -> Selector? {
    return NSSelectorFromString(selectorName)
}

func OpenApp(_ bundleID: String) -> Bool {
    guard let workspaceClass = obfuscatedClass("LSApplicationWorkspace") as? NSObject.Type else {
        print("Failed to find LSApplicationWorkspace")
        return false
    }
    
    guard let defaultWorkspaceSelector = obfuscatedSelector("defaultWorkspace") else {
        print("Failed to find defaultWorkspace selector")
        return false
    }
    
    let workspace = workspaceClass.perform(defaultWorkspaceSelector)?.takeUnretainedValue() as? NSObject
    
    guard let openAppSelector = obfuscatedSelector("openApplicationWithBundleID:") else {
        print("Failed to find openApplicationWithBundleID selector")
        return false
    }
    
    if let workspace = workspace {
        let result = workspace.perform(openAppSelector, with: bundleID)
        if result == nil {
            print("Failed to open app with bundle ID \(bundleID)")
        } else {
            return true
        }
    } else {
        print("Failed to initialize LSApplicationWorkspace")
    }
    return false
}
