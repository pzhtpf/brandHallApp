//
//  FileDownloadInfo.h
//  BGTransferDemo
//
//  Created by Jorge Casariego on 26/04/14.
//  Copyright (c) 2014 Jorge Casariego. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownloadInfo : NSObject

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) NSDictionary *downloadTaskData;

@property (nonatomic, strong) NSString *localName;

@property (nonatomic, strong) NSString *path;

@property (nonatomic, strong) NSString *houseId;

@property (nonatomic, strong) NSData *taskResume;

@property (nonatomic) double downloadProgress;

@property (nonatomic) BOOL isDownloading;

@property (nonatomic) BOOL downloadComplete;

@property (nonatomic) unsigned long taskIdentifier;

//Custom init method
- (id)initWithFileTitle:(NSDictionary *)data;

@end
