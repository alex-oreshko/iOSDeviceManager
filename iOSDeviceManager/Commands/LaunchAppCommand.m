
#import "LaunchAppCommand.h"
#import "PhysicalDevice.h"

static NSString *const BUNDLE_ID_FLAG = @"-b";
static NSString *const APPARGUMENTS_ID_FLAG = @"-a";
static NSString *const APPENVIRONMENT_ID_FLAG = @"-e";

@implementation LaunchAppCommand
+ (NSString *)name {
    return @"launch_app";
}

+ (iOSReturnStatusCode)execute:(NSDictionary *)args {
    NSString *appArgs = [self optionDict][APPARGUMENTS_ID_FLAG].defaultValue;
    if ([args.allKeys containsObject:APPARGUMENTS_ID_FLAG]) {
        appArgs = args[APPARGUMENTS_ID_FLAG];
    }
    
    NSString *appEnv = [self optionDict][APPENVIRONMENT_ID_FLAG].defaultValue;
    if ([args.allKeys containsObject:APPENVIRONMENT_ID_FLAG]) {
        appEnv = args[APPENVIRONMENT_ID_FLAG];
    }
    
    return [PhysicalDevice launchApp:args[BUNDLE_ID_FLAG] appArgs:appArgs
                                                           appEnv:appEnv
                                                         deviceID:args[DEVICE_ID_FLAG]];
}

+ (NSArray <CommandOption *> *)options {
    static NSMutableArray *options;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        options = [NSMutableArray array];
        [options addObject:[CommandOption withShortFlag:DEVICE_ID_FLAG
                                               longFlag:@"--device-id"
                                             optionName:@"device-identifier"
                                                   info:@"iOS Simulator GUID or 40-digit physical device ID"
                                               required:YES
                                             defaultVal:nil]];
        [options addObject:[CommandOption withShortFlag:BUNDLE_ID_FLAG
                                               longFlag:@"--bundle-identifier"
                                             optionName:@"bundle-id"
                                                   info:@"bundle identifier (e.g. com.my.app)"
                                               required:YES
                                             defaultVal:@"com.apple.mobilesafari"]];
        [options addObject:[CommandOption withShortFlag:APPARGUMENTS_ID_FLAG
                                               longFlag:@"--app-arguments"
                                             optionName:@"app-args"
                                                   info:@"App arguments to be passed at launch"
                                               required:NO
                                             defaultVal:@""]];
        [options addObject:[CommandOption withShortFlag:APPENVIRONMENT_ID_FLAG
                                               longFlag:@"--app-environment"
                                             optionName:@"app-env"
                                                   info:@"App environment variables in key:value format seprated by space"
                                               required:NO
                                             defaultVal:@""]];
    });
    return options;
}

@end
