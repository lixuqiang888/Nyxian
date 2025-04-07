#import <Foundation/Foundation.h>

@interface zsign : NSObject

+(bool)sign:(NSString*)strCertFile privateKey:(NSString*)strPKeyFile provision:(NSString*)strProvFile entitlements:(NSString*)strEntitlementsFile password:(NSString*)strPassword bundlePath:(NSString*)strFolder;

@end
