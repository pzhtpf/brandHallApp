//
//  LSBGetDegress.h
//  DeviceFlatwise
//
//  Created by 李帅兵 on 14-5-21.
//  Copyright (c) 2014年 lsb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h>
@interface LSBGetDegress : NSObject
+(void)getDegressWithBlock:(void(^)(CMAccelerometerData *latestAcc, NSError *error))aBlcok;
+(void)stopMotion;
@end
