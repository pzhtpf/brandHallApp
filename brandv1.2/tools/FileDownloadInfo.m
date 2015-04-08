//
//  FileDownloadInfo.m
//  BGTransferDemo
//
//  Created by Jorge Casariego on 26/04/14.
//  Copyright (c) 2014 Jorge Casariego. All rights reserved.
//

#import "FileDownloadInfo.h"

@implementation FileDownloadInfo

- (id)initWithFileTitle:(NSDictionary *)data
{
    if(self == [super init])
    {

        self.downloadTaskData = data;
        self.downloadProgress = 0.0;
        self.isDownloading = NO;
        self.downloadComplete = NO;
        self.taskIdentifier = -1;
    }
    
    return self;
}

@end
