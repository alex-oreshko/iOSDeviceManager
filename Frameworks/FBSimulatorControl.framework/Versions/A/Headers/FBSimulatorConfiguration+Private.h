/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <FBSimulatorControl/FBSimulator.h>
#import <FBSimulatorControl/FBSimulatorConfiguration.h>
#import <FBSimulatorControl/FBSimulatorConfigurationVariants.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBSimulatorConfiguration ()

@property (nonatomic, strong, readwrite) id<FBSimulatorConfiguration_Device> device;
@property (nonatomic, strong, readwrite) id<FBSimulatorConfiguration_OS> os;
@property (nonatomic, copy, readwrite) NSString *auxillaryDirectory;

- (instancetype)updateNamedDevice:(id<FBSimulatorConfiguration_Device>)device;
- (instancetype)updateOSVersion:(id<FBSimulatorConfiguration_OS>)OS;

@end

NS_ASSUME_NONNULL_END
