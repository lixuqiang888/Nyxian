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

#import "zsign.h"
#import "openssl.h"
#import "bundle.h"

@implementation zsign

+(bool)sign:(NSString*)strCertFile
 privateKey:(NSString*)strPKeyFile
  provision:(NSString*)strProvFile
entitlements:(NSString*)strEntitlementsFile
   password:(NSString*)strPassword
 bundlePath:(NSString*)strFolder
{
    ZSignAsset zSignAsset;
    
    // FIXME: Entitlements break the app and I dont know why
    zSignAsset.Init(strCertFile.UTF8String,
                    strPKeyFile.UTF8String,
                    strProvFile.UTF8String,
                    "",
                    strPassword.UTF8String);
    
    ZAppBundle bundle;
    bool bEnableCache = true;
    bool bForce = false;
    //bool bInstall = false;
    //bool bWeakInject = false;
    bool bRet = bundle.SignFolder(&zSignAsset,
                                  strFolder.UTF8String,
                                  "",
                                  "",
                                  "",
                                  "",
                                  bForce,
                                  "",
                                  bEnableCache);
    return bRet;
}

@end
