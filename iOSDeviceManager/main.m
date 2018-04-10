
#import "CLI.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "ShellRunner.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
      NSString *xcodeSelectPath = [ShellRunner shell:@"/usr/bin/xcode-select"
                                                args:@[@"--print-path"]][0];

      NSDictionary *environment = [[NSProcessInfo processInfo] environment];
      NSString *xcodeFromEnvironment = environment[@"DEVELOPER_DIR"];

      NSLog(@"enviroment: %@", environment);
      NSLog(@"xcode path from process env: %@", xcodeFromEnvironment);
      NSLog(@"xcode path from xcode-select: %@", xcodeSelectPath);


        [iOSDeviceManagerLogging startLumberjackLogging];
        return [CLI process:[NSProcessInfo processInfo].arguments];
    }
}
