//
//  BackGroundDownload.h
//  brandv1.2
//
//  Created by Apple on 15/4/7.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackGroundDownload : NSObject<NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURL *docDirectoryURL;
-(void)startDownload;
+(void)removeDownloadTask:(NSString *)houseId;
@end
