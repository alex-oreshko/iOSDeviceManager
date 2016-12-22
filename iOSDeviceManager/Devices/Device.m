
#import "PhysicalDevice.h"
#import "ShellRunner.h"
#import "Resources.h"
#import "Simulator.h"
#import "AppUtils.h"

@implementation Device

- (id)init {
    if (self = [super init]) {
        _testingComplete = NO;
    }
    return self;
}

+ (NSString *)defaultDeviceID {
    return [[Resources shared] defaultDeviceUDID] ?: [[Resources shared] defaultSimulatorUDID];
}

+ (void)initialize {
    const char *FBLog = [ShellRunner verbose] ? "YES" : "NO";
    setenv("FBCONTROLCORE_LOGGING", FBLog, 1);
    setenv("FBCONTROLCORE_DEBUG_LOGGING", FBLog, 1);
}

+ (iOSReturnStatusCode)startTestOnDevice:(NSString *)deviceID
                               sessionID:(NSUUID *)sessionID
                          runnerBundleID:(NSString *)runnerBundleID
                              runnerArgs:(NSString *)runnerArgs
                               keepAlive:(BOOL)keepAlive {
    if ([TestParameters isDeviceID:deviceID]) {
        return [PhysicalDevice startTestOnDevice:deviceID
                                       sessionID:sessionID
                                  runnerBundleID:runnerBundleID
                                      runnerArgs:(NSString *)runnerArgs
                                       keepAlive:keepAlive];
    } else {
        return [Simulator startTestOnDevice:deviceID
                                  sessionID:sessionID
                             runnerBundleID:runnerBundleID
                                 runnerArgs:(NSString *)runnerArgs
                                  keepAlive:keepAlive];
    }
}

+ (iOSReturnStatusCode)installApp:(NSString *)pathToBundle
                         deviceID:(NSString *)deviceID
                        updateApp:(BOOL)updateApp
                       codesignID:(NSString *)codesignID {
    if ([TestParameters isDeviceID:deviceID]) {
        return [PhysicalDevice installApp:pathToBundle
                                 deviceID:deviceID
                                updateApp:updateApp
                               codesignID:codesignID];
    } else {
        return [Simulator installApp:pathToBundle
                            deviceID:deviceID
                           updateApp:updateApp
                          codesignID:nil];
    }
}

+ (iOSReturnStatusCode)uninstallApp:(NSString *)bundleID
                           deviceID:(NSString *)deviceID {
    if ([TestParameters isSimulatorID:deviceID]) {
        return [Simulator uninstallApp:bundleID deviceID:deviceID];
    } else {
        return [PhysicalDevice uninstallApp:bundleID deviceID:deviceID];
    }
}

+ (iOSReturnStatusCode)appIsInstalled:(NSString *)bundleID
                             deviceID:(NSString *)deviceID {
    if ([TestParameters isSimulatorID:deviceID]) {
        return [Simulator appIsInstalled:bundleID deviceID:deviceID];
    } else {
        return [PhysicalDevice appIsInstalled:bundleID deviceID:deviceID];
    }
}

+ (iOSReturnStatusCode)setLocation:(NSString *)deviceID
                               lat:(double)lat
                               lng:(double)lng {
    if ([TestParameters isSimulatorID:deviceID]) {
        return [Simulator setLocation:deviceID
                                  lat:lat
                                  lng:lng];
    } else {
        return [PhysicalDevice setLocation:deviceID
                                       lat:lat
                                       lng:lng];
    }
}

+ (NSDictionary *)infoPlistForInstalledBundleID:(NSString *)bundleID
                                       deviceID:(NSString *)deviceID {
    if ([TestParameters isSimulatorID:deviceID]) {
        return [Simulator infoPlistForInstalledBundleID:bundleID
                                               deviceID:deviceID];
    } else {
        return [PhysicalDevice infoPlistForInstalledBundleID:bundleID
                                                    deviceID:deviceID];
    }
}

+ (iOSReturnStatusCode)uploadFile:(NSString *)filepath
                         toDevice:(NSString *)deviceID
                   forApplication:(NSString *)bundleID
                        overwrite:(BOOL)overwrite {
    if ([TestParameters isSimulatorID:deviceID]) {
        return [Simulator uploadFile:filepath
                            toDevice:deviceID
                      forApplication:bundleID
                           overwrite:overwrite];
    } else {
        return [PhysicalDevice
                uploadFile:filepath
                toDevice:deviceID
                forApplication:bundleID
                overwrite:overwrite];
    }
}

+ (iOSReturnStatusCode) launchApp:(NSString *)bundleID
                          appArgs:(NSString *)appArgs
                           appEnv:(NSString *)appEnv
                         deviceID:(NSString *)deviceID {
        return [PhysicalDevice launchApp:bundleID
                                 appArgs:appArgs
                                  appEnv:appEnv
                                deviceID:deviceID];
}

+ (iOSReturnStatusCode) terminateApp:(NSString *)bundleID
                            deviceID:(NSString *)deviceID {
        return [PhysicalDevice terminateApp:bundleID
                              deviceID:deviceID];
}

@end
