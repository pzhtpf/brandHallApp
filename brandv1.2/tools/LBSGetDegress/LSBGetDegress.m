//
//  LSBGetDegress.m
//  DeviceFlatwise
//
//  Created by 李帅兵 on 14-5-21.
//  Copyright (c) 2014年 lsb. All rights reserved.
//

#import "LSBGetDegress.h"

@implementation LSBGetDegress
 CMMotionManager *motionManager;
+(void)getDegressWithBlock:(void(^)(CMAccelerometerData *latestAcc, NSError *error))aBlcok
{
    motionManager = [[CMMotionManager alloc] init];
   
    if (!motionManager.accelerometerAvailable) {
        NSLog(@"没有加速计");
    }
    motionManager.accelerometerUpdateInterval = 0.1; // 告诉manager，更新频率是100Hz
    
    [motionManager startDeviceMotionUpdates];

    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *latestAcc, NSError *error)
     {
        double a = motionManager.deviceMotion.gravity.x;
        aBlcok(latestAcc,error);
    }];
}
+(void)stopMotion{

    [motionManager stopAccelerometerUpdates];
    [motionManager stopDeviceMotionUpdates];

}
@end
