//
//  UIImageViewMultiThread.m
//  brandv1.2
//
//  Created by Apple on 15/4/2.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "UIImageViewMultiThread.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import <objc/runtime.h>
@interface UIImageView (_MultiThread)
@end
LoginInfo *loginInfo;
@implementation UIImageView (_MultiThread)
-(void)loadLocalImage:(NSString *)name{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(loadLocalImageMethod:) object:name];
    [thread start];
}
-(void)loadLocalImageMethod:(NSString *)name{
   
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *furl = [NSString stringWithFormat:@"%@/%@",documentsDirectory,name];
    UIImage *image  = [UIImage imageWithContentsOfFile:furl];
 //   image = [image resizedImage:image.size interpolationQuality: kCGInterpolationLow];
    [self setImage:image];
    [[NSNotificationCenter defaultCenter] postNotificationName:loginInfo.loadingName object:nil];
}
@end
