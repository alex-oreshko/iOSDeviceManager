
#import <XCTest/XCTest.h>
#import "XCTestControlWrapper.h"

@interface DeviceLibTests : XCTestCase

@property (nonatomic) const char *deviceID;
@property (nonatomic) const char *ipaPath;
@property (nonatomic) const char *codesignIdentity;
@property (nonatomic) const char *testIpaRunnerPath;
@property (nonatomic) const char *deviceTestBundlePath;
@property (nonatomic) const char *unitTestAppBundleID;
@property (nonatomic) const char *taskyID;
@end

@implementation DeviceLibTests

#define SUCCESS 0
#define FAILURE 1

- (void)setUp {
    [super setUp];
    
    _unitTestAppBundleID = "sh.calaba.UnitTestApp";
    _taskyID = "com.xamarin.samples.taskytouch";
    _deviceID = "49a29c9e61998623e7909e35e8bae50dd07ef85f";
    _ipaPath = "/Users/chrisf/calabash-xcuitest-server/Products/ipa/UnitTestApp/UnitTestApp.app";
    _codesignIdentity = "iPhone Developer: Chris Fuentes (G7R46E5NX7)";
    _testIpaRunnerPath = "/Users/chrisf/calabash-xcuitest-server/Products/ipa/CBX-Runner.app";
    _deviceTestBundlePath = "/Users/chrisf/calabash-xcuitest-server/Products/ipa/CBX-Runner.app/PlugIns/CBX.xctest";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUninstallFromDevice {
    XCTAssertEqual(uninstall_app(_unitTestAppBundleID, _deviceID), SUCCESS);
}

- (void)testInstallToDevice {
    XCTAssertEqual(install_app(_ipaPath, _deviceID, _codesignIdentity), SUCCESS);
}

- (void)testAppIsInstalledOnDevice {
    XCTAssertTrue(is_installed("com.apple.Preferences", _deviceID) == 1);
    
    if (is_installed(_unitTestAppBundleID, _deviceID)) {
        uninstall_app(_unitTestAppBundleID, _deviceID);
    }
    XCTAssertTrue(is_installed(_unitTestAppBundleID, _deviceID) == 0);
    install_app(_ipaPath, _deviceID, _codesignIdentity);
    XCTAssertTrue(is_installed(_unitTestAppBundleID, _deviceID) == 1);
}

@end