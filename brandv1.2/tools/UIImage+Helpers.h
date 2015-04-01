//
//  UIImage+Helpers.h
//  brandv1.2
//
//  Created by Apple on 14/12/15.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helpers)

+ (void) loadFromURL: (NSString*) url callback:(void (^)(UIImage *image))callback;
+ (UIImage *)imageWithColor:(UIColor *)color;
+(UIImage *)resizeImageAtPath:(NSString *)imagePath;
@end
