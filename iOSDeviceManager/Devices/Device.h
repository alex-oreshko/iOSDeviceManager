
#import "TestParameters.h"
#import "iOSDeviceManagementCommand.h"
#import <Foundation/Foundation.h>

@interface Device : NSObject

/**
 Defined as first available launched simulator if any, 
 else first attached device,
 else nil.
 */
+ (NSString *)defaultDeviceID;

+ (iOSReturnStatusCode)startTestOnDevice:(NSString *)deviceID
                               sessionID:(NSUUID *)sessionID
                          runnerBundleID:(NSString *)runnerBundleID
                              runnerArgs:(NSString *)runnerArgs
                               keepAlive:(BOOL)keepAlive; //helps with integration testing

+ (iOSReturnStatusCode)uninstallApp:(NSString *)bundleID
                           deviceID:(NSString *)deviceID;
+ (iOSReturnStatusCode)installApp:(NSString *)pathToBundle
                         deviceID:(NSString *)deviceID
                        updateApp:(BOOL)updateApp
                       codesignID:(NSString *)codesignID;
+ (iOSReturnStatusCode)appIsInstalled:(NSString *)bundleID
                             deviceID:(NSString *)deviceID;

+ (iOSReturnStatusCode)setLocation:(NSString *)deviceID
                               lat:(double)lat
                               lng:(double)lng;

+ (NSDictionary *)infoPlistForInstalledBundleID:(NSString *)bundleID
                                       deviceID:(NSString *)deviceID;

+ (iOSReturnStatusCode)uploadFile:(NSString *)filepath
                         toDevice:(NSString *)deviceID
                   forApplication:(NSString *)bundleID
                        overwrite:(BOOL)overwrite;

+ (iOSReturnStatusCode)uploadFile:(NSString *)filepath
                         toDevice:(NSString *)deviceID
                   forApplication:(NSString *)bundleID
                        overwrite:(BOOL)overwrite;

+ (iOSReturnStatusCode)launchApp:(NSString *)bundleID
                         appArgs:(NSString *)appArgs
                          appEnv:(NSString *)appEnv
                        deviceID:(NSString *)deviceID;

+ (iOSReturnStatusCode)terminateApp:(NSString *)bundleID
                           deviceID:(NSString *)deviceID;

@property BOOL testingComplete;
@end
