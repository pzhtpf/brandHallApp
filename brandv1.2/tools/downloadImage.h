//
//  downloadImage.h
//  brandv1.2
//
//  Created by Apple on 14-9-22.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AFURLResponseSerialization, AFImageCache;

@interface downloadImage : NSObject
+(void)downloadImage:(NSString *)path name:(NSString *)name;
+(BOOL)saveImage:(NSString *)name image:(NSData*) data;
+(BOOL)saveImageToLocal:(NSDictionary *)data;
+(bool)saveImageWithImage:(UIImage *)image name:(NSString *)name;
+(void)removeImage:(NSString*)fileName;
@end
