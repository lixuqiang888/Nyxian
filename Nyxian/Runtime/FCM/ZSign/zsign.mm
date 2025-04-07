#import "zsign.h"
#import "openssl.h"
#import "bundle.h"
@implementation zsign
+(bool)sign:(NSString*)strCertFile privateKey:(NSString*)strPKeyFile provision:(NSString*)strProvFile entitlements:(NSString*)strEntitlementsFile password:(NSString*)strPassword bundlePath:(NSString*)strFolder  {
    ZSignAsset zSignAsset;
    zSignAsset.Init(strCertFile.UTF8String,
                    strPKeyFile.UTF8String,
                    strProvFile.UTF8String,
                    strEntitlementsFile.UTF8String,
                    strPassword.UTF8String);
    
    ZAppBundle bundle;
    bool bEnableCache = true;
    bool bForce = false;
    bool bInstall = false;
    bool bWeakInject = false;
    bool bRet = bundle.SignFolder(&zSignAsset,
                                  strFolder.UTF8String,
                                  "",
                                  "",
                                  "",
                                  strEntitlementsFile.UTF8String,
                                  bForce,
                                  "",
                                  bEnableCache);
    return bRet;
}
@end
