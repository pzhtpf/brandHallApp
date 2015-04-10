//
//  BackGroundDownload.m
//  brandv1.2
//
//  Created by Apple on 15/4/7.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "BackGroundDownload.h"
#import "AppDelegate.h"
#import "DBHelper.h"
#import "downloadImage.h"
#import "Define.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "UIImageView+AFNetworking.h"
#import "AsyncImageDownloader.h"
#import "DAProgressOverlayView.h"
#import "AFNetworking.h"
#import "LDProgressView.h"
#import "UIImage+Helpers.h"
#import "UIImage+Resize.h"
#import "globalContext.h"
#import "FileDownloadInfo.h"

@implementation BackGroundDownload
LoginInfo *loginInfo;
int increaseCountBackGroundDownload = 0;
int planCountBackGroundDownload = 0;
UIImageView *tempImageView;
bool planIsCompleteBackGroundDownload = true;
NSThread *downloadMainThread;
-(void)startDownload{

    // backgroundSessionConfiguration class method is used when it’s desirable to perform background tasks
    // The backgroundSessionConfiguration class method accepts one parameter, an identifier, which uniquely
    // identifies the session started by our app in the system.
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.gezlife.leju.prebuild"];
    
    //Through this, we will allow five simultaneous downloads to take place at once
    sessionConfiguration.HTTPMaximumConnectionsPerHost = 10;
    
    //The next step that must be performed, is to instantiate the session property using the sessionConfiguration object
    //Here a NSURLSession session has been instantiated and is now ready to be used in order to fire background download tasks.
    self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];

    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    self.docDirectoryURL = [URLs objectAtIndex:0];
    
    loginInfo = [[StockData getSingleton] valueForKey:@"loginInfo"];
    if (!loginInfo.arrFileDownloadData)
    loginInfo.arrFileDownloadData = [[NSMutableDictionary alloc] init];
    
    [self startDownloadThread];
}

#pragma mark - NSURLSession Delegate method implementation

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    //The first thing we have to do, is to check if the system is aware of the size of the file that’s being downloaded.
    if(totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown)
    {
        NSLog(@"Unknown transfer size");
    }
    else    //We will proceed with the progress update if only this data exists.
    {
        //We locate the index of the appropriate FileDownloadInfo object in the arrFileDownloadData array, based on the task description of the downloadTask parameter object, and we use a local pointer to access it.
        
        
//        // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
//        int index = [self getFileDownloadInfoIndexWithTaskIdentifier:downloadTask.taskIdentifier];
//        FileDownloadInfo *fdi = [self.arrFileDownloadData objectAtIndex:index];
//        
//        //Because the download task works in background threads, any visual upgrades must take place in the main thread of the app
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            //Calculate the progress
//            fdi.downloadProgress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
//            
//            // Get the progress view of the appropriate cell and update its progress.
//            UITableViewCell *cell = [self.tblFiles cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//            UIProgressView *progressView = (UIProgressView *)[cell viewWithTag:CellProgressBarTagValue];
//            progressView.progress = fdi.downloadProgress;
//        }];
        
    }
}

-(FileDownloadInfo *)getFileDownloadInfo:(int)taskIdentifier{
    
    if(!loginInfo.isRedownload){
    
    NSArray *allKeys = [loginInfo.arrFileDownloadData allKeys];
    
    for (NSString *key in allKeys) {
        
        FileDownloadInfo *fdi = [loginInfo.arrFileDownloadData objectForKey:key];
       if(fdi.taskIdentifier ==taskIdentifier)
           return fdi;
    }
 }
    return nil;
}
+(void)removeDownloadTask:(NSString *)houseId{
    
    loginInfo.isDownloadComplete = true;
    
    NSArray *allKeys = [loginInfo.arrFileDownloadData allKeys];
    for (NSString *key in allKeys) {
        FileDownloadInfo *fdi = [loginInfo.arrFileDownloadData objectForKey:key];
        if([houseId isEqualToString:fdi.houseId]){
            [fdi.downloadTask cancel];
            [loginInfo.arrFileDownloadData removeObjectForKey:key];
        }
    }
    
}
//This method is called by the system every time a download is over, and is our duty to write the appropriate code in order
//to get the file from its temporary location
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if(loginInfo.arrFileDownloadData.count>0){
    
 
    FileDownloadInfo *fdi =  [self getFileDownloadInfo:downloadTask.taskIdentifier];
        
        //[loginInfo.arrFileDownloadData objectForKey:[NSString stringWithFormat:@"%d",downloadTask.taskIdentifier]];
    
    if(fdi!=nil){
        
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //lastPathComponent provide us the actual file name, along with its extension
  //  NSString *destinationFileName = downloadTask.originalRequest.URL.lastPathComponent;
    //This destination is where the file will be copied permanently
    
    NSURL *destinationURL = [self.docDirectoryURL URLByAppendingPathComponent:fdi.localName];
    
    //Check if the file already exists in the Documents directory, using the fileManager object
    //that was instantiated at the beginning of the method, and the destinationURL value
    if([fileManager fileExistsAtPath:[destinationURL path]])
    {
        //If it already exists, then is being removed.
        [fileManager removeItemAtURL:destinationURL error:nil];
    }
    
    //The file copying process takes place here
    BOOL success = [fileManager copyItemAtURL:location toURL:destinationURL error:&error];
    
    [loginInfo.arrFileDownloadData removeObjectForKey:[NSString stringWithFormat:@"%d",downloadTask.taskIdentifier]];
    fdi.isDownloading = NO;
    fdi.downloadComplete = YES;
        
    // Set the initial value to the taskIdentifier property of the fdi object,
    // so when the start button gets tapped again to start over the file download.
    fdi.taskIdentifier = -10;
        
 //   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Reload the respective table view row using the main thread.
        [self singleImageDownloadComplete:fdi.downloadTaskData image:nil];
//    }];
        
    if(success)
    {

    }
    else
    {
        NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
    }
    }
  }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error != nil) {
        NSLog(@"Download completed with error: %@", [error localizedDescription]);
        
        FileDownloadInfo *fdi = [self getFileDownloadInfo:task.taskIdentifier];
//       if (fdi==nil) {
//             [self singleImageDownloadComplete:fdi.downloadTaskData image:nil];
//        }
      if(fdi.taskIdentifier >-1){          //第一次下载失败
            fdi.taskIdentifier = -1;
            [fdi.downloadTask resume];
        }
        else if(fdi.taskIdentifier ==-1){     //第二次下载失败
            fdi.taskIdentifier = -2;
          [self singleImageDownloadComplete:fdi.downloadTaskData image:nil];
        }
    }
    else{
        NSLog(@"Download finished successfully.");
    }
}

// When the system has no more messages to send to our app after a background transfer,
// the URLSessionDidFinishEventsForBackgroundURLSession: NSURLSession delegate method is called.
// In this method we will make the call to the completion handler, and we will show the local notification.
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
  //  [self URLSessionDidFinishEventsForBackgroundURLSessionMethod];
}
-(void)URLSessionDidFinishEventsForBackgroundURLSessionMethod{

    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // Check if all download tasks have been finished.
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([downloadTasks count] == 0) {
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                // Copy locally the completion handler.
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                // Make nil the backgroundTransferCompletionHandler.
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Call the completion handler to tell the system that there are no other background transfers.
                    completionHandler();
                    
                    // Show a local notification when all downloads are over.
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"All files have been downloaded!";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }];
            }
        }
    }];

}
//  下载主要方法，逻辑。

-(void)startDownloadThread{
    
    if (!loginInfo.downloadList)
        loginInfo.downloadList = [DBHelper getDataFromPlanTable:1];
    
    if( loginInfo.downloadList.count>0){
        
        loginInfo.isRedownload = false;
        loginInfo.isDownloadComplete = false;
        planIsCompleteBackGroundDownload = true;
        
        downloadMainThread = [[NSThread alloc] initWithTarget:self selector:@selector(startDownloadMethod:) object: loginInfo.downloadList];
        [downloadMainThread start];
        
    }
    else{
        loginInfo.isDownloadComplete = true;
        
    }
    
    loginInfo.isRedownload = false;
}
+(void)cancelDownloadThread:(NSNotification *)notification{
    
    [downloadMainThread cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cancelDownloadThread" object:nil];
    
}
-(void)startDownloadMethod:(NSMutableDictionary *)dataArray{
    
        NSArray *keys = [loginInfo.downloadList allKeys];
        
        if(keys.count>0){
            
            increaseCountBackGroundDownload = 0;
            planCountBackGroundDownload = 0;
            
            NSDictionary *temp = [dataArray objectForKey:keys[0]];
            
            [self performSelectorInBackground:@selector(changeWaitToDownloadViewMethod:) withObject:[temp objectForKey:@"housesId"]];
            
            
            if(loginInfo.progressArray){
                    
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownloadingView" object:nil];
            }
            
            NSArray *data = [temp objectForKey:@"data"];
            
            int count = 0;
            
          //  for (NSDictionary *tempData in data){
            while (true) {
                
                if(loginInfo.isRedownload){    //用户暂停下载
            
                    break;
                }

                if([self isComplete:[temp objectForKey:@"housesId"]]){
                    
                    if(count<data.count){
                    
                    NSDictionary *tempData = data[count];
                    NSMutableDictionary *temp2= [[NSMutableDictionary alloc] initWithDictionary:tempData];
                    [temp2 setValue:[temp objectForKey:@"housesId"] forKey:@"housesId"];
                    [temp2 setValue:[temp objectForKey:@"housesName"] forKey:@"housesName"];
                    [temp2 setValue:[temp objectForKey:@"id"] forKey:@"id"];
                    if([temp objectForKey:@"isHigh"])
                    [temp2 setValue:[temp objectForKey:@"isHigh"] forKey:@"isHigh"];
                    [self startDownload:temp2];
                  //  [self initCompleteStart];
                    }
                    
                    else
                        break;
                        
                    count++;
        
                }
                [NSThread sleepForTimeInterval:1];
            }
         
            [self downloadComplete:[temp objectForKey:@"housesId"]];
            [self startDownloadThread];   //下载下一个样板间
        }
        else{
            
            loginInfo.isDownloadComplete =true;
            loginInfo.isRedownload = false;
        }
    
}


+(void)downloadThreadByPlanId:(NSDictionary *)planData housesId:(NSString *)housesId{
    
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:planData];
    [temp setValue:housesId forKey:@"housesId"];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(startDownload:) object:temp];
    
    [thread start];
    
    
    
}
-(void)startDownload:(NSMutableDictionary *)dataArgs{
    
    increaseCountBackGroundDownload = 0;
    planIsCompleteBackGroundDownload = false;
    
    NSString *planId = [dataArgs objectForKey:@"planId"];
    
    NSMutableArray *dataArrays = [DBHelper getUndownloadByPlanId:planId];
    
    planCountBackGroundDownload  = (int)dataArrays.count;
    
    if(dataArrays.count>0){
        
        //        //如果为排队状态的话1，把状态改为正在下载2
        if([[dataArgs  objectForKey:@"status"] intValue] ==1){
            
            [dataArgs setValue:[NSNumber numberWithInt:2] forKey:@"status"];
            [DBHelper updatePlanTable:dataArgs];
            
            NSMutableDictionary *temp6 = [DBHelper getDataFromPlanTable:[[dataArgs objectForKey:@"housesId"] intValue]];     //通知经典样板间更新界面
            NSArray *keys = [temp6 allKeys];
            if(keys.count>0){
                [loginInfo.dataFromPlanTable setValue:[temp6 objectForKey:[dataArgs objectForKey:@"housesId"]] forKey:[dataArgs objectForKey:@"housesId"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateView" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHousesView" object:nil];
            }
        }
        
        int isHigh = [[dataArgs objectForKey:@"isHigh"] intValue];
        
        for(NSDictionary *temp in dataArrays){
            
            if(loginInfo.isRedownload){
                planIsCompleteBackGroundDownload = true;
                break;
            }
            
                NSDictionary *dataTemp = [[NSDictionary alloc] initWithObjectsAndKeys:dataArgs,@"dataArgs",temp,@"temp", nil];
                
                
                if(![[temp objectForKey:@"imageUrl"] isEqualToString:@"0"]){
                    
                    NSString *path = [imageUrl stringByAppendingString:[temp objectForKey:@"imageUrl"]];
                    
                    if(isHigh ==0){
                        NSArray *names = [path componentsSeparatedByString:@"."];
                        path = [NSString stringWithFormat:@"%@_thumb.%@",path,names[names.count-1]];
                        
                    }
                    
                    NSString *name = [temp objectForKey:@"localImageName"];
                    
                    FileDownloadInfo *fdi = [[FileDownloadInfo alloc] initWithFileTitle:dataTemp];
                    fdi.localName = name;
                    fdi.path = path;
                    fdi.houseId = [dataArgs objectForKey:@"housesId"];
            
                    // Check if a file is already being downloaded or not.
                  
                    fdi.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:path]];
                   
                        
                    // Keep the new taskIdentifier.
                    fdi.taskIdentifier = fdi.downloadTask.taskIdentifier;
//                    NSLog(@"%lu",fdi.taskIdentifier);
                    
                    [loginInfo.arrFileDownloadData setValue:fdi forKey:[NSString stringWithFormat:@"%lu",fdi.taskIdentifier]];

                        
                    // Start the download
                    [fdi.downloadTask resume];
                    
                    

                    
                }
                else{
                    
                    [self singleImageDownloadComplete:dataTemp image:nil];
                }
            
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Your main thread code goes in here
            NSLog(@"Im on the main thread");
            [self addProgressingView:dataArgs];
        });
        
        [dataArgs setValue:@"0" forKey:@"remain"];
        [dataArgs setValue:[NSNumber numberWithInt:3] forKey:@"status"];
        [DBHelper updatePlanTable:dataArgs];
        
        NSMutableDictionary *temp6 = [DBHelper getDataFromPlanTable:[[dataArgs objectForKey:@"housesId"] intValue]];
        NSArray *keys = [temp6 allKeys];
        if(keys.count>0){
            [loginInfo.dataFromPlanTable setValue:[temp6 objectForKey:[dataArgs objectForKey:@"housesId"]] forKey:[dataArgs objectForKey:@"housesId"]];
        }
        planIsCompleteBackGroundDownload = true;
    }
}

-(void)singleImageDownloadComplete:(NSDictionary *)data image:(UIImage *)image{
    
    NSDictionary *temp =[data objectForKey:@"temp"];
    NSMutableDictionary *dataArgs =[data objectForKey:@"dataArgs"];
    
    NSString *planId = [temp objectForKey:@"planId"];
    
    [DBHelper updateDownloadingTable:[NSNumber numberWithInt:1] localImageName:[temp objectForKey:@"localImageName"] ];
    
    double thisDownloadSize = [[temp objectForKey:@"imageSize"] longLongValue];
    double beforeRemain = [[dataArgs objectForKey:@"remain"] longLongValue];
    
    NSDictionary *tempDictionary = [loginInfo.dataFromPlanTable objectForKey:[temp objectForKey:@"housesId"]];
    NSArray *tempArray = [tempDictionary objectForKey:@"data"];
    for (NSDictionary *temp in tempArray) {
        NSString *tempPlanId  = [temp objectForKey:@"planId"];
        if([planId isEqualToString:tempPlanId]){
            
            [temp setValue:[NSString stringWithFormat:@"%0.1f",beforeRemain-thisDownloadSize] forKey:@"remain"];
            [dataArgs setValue:[temp objectForKey:@"status"] forKey:@"status"];
            break;
        }
    }
    
    [dataArgs setValue:[NSString stringWithFormat:@"%0.1f",beforeRemain-thisDownloadSize] forKey:@"remain"];
    
    [DBHelper updatePlanTable:dataArgs];
    
    
    
    
    if(!loginInfo.isRedownload && [loginInfo.downloadList objectForKey:[dataArgs objectForKey:@"housesId"]]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self addProgressingView:dataArgs];
            
        });
    }
    
    
    increaseCountBackGroundDownload++;
    
    if(increaseCountBackGroundDownload == planCountBackGroundDownload){    //下载完毕
    
 //   if([self isComplete:[dataArgs objectForKey:@"housesId"]]){
        
        [dataArgs setValue:@"0" forKey:@"remain"];
        [dataArgs setValue:[NSNumber numberWithInt:3] forKey:@"status"];
        [dataArgs setValue:[dataArgs objectForKey:@"latestVersion"] forKey:@"nowVersion"];
        [DBHelper updatePlanTable:dataArgs];
        
        
        NSMutableDictionary *temp6 = [DBHelper getDataFromPlanTable:[[dataArgs objectForKey:@"housesId"] intValue]];
        NSArray *keys = [temp6 allKeys];
        if(keys.count>0){
            [loginInfo.dataFromPlanTable setValue:[temp6 objectForKey:[dataArgs objectForKey:@"housesId"]] forKey:[dataArgs objectForKey:@"housesId"]];
        }
        
        
        if(loginInfo.progressArray){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownloadingView" object:nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateView" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHousesView" object:nil];
        
        [self uploadDownloadRecord:[dataArgs objectForKey:@"planId"] version:[dataArgs objectForKey:@"nowVersion"]];
        planIsCompleteBackGroundDownload = true;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
           [globalContext addStatusBarNotification:[NSString stringWithFormat:@"%@已下载完毕",[dataArgs objectForKey:@"name"]]];
        });
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = [NSString stringWithFormat:@"%@已下载完毕",[dataArgs objectForKey:@"name"]];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        
    }
    
}
-(BOOL)isComplete:(NSString *)houseId{

         int count = 0;
    
            NSArray *allKeys = [loginInfo.arrFileDownloadData allKeys];
            for (NSString *key in allKeys) {
                FileDownloadInfo *tempFdi = [loginInfo.arrFileDownloadData objectForKey:key];
                if([houseId isEqualToString:tempFdi.houseId])
                    count++;
            }

    return count==0;
}
-(void)addProgressingView:(NSMutableDictionary *)dataArgs{
    
    // 添加正在下载的界面
    
    NSString *housesId = [dataArgs objectForKey:@"housesId"];
    
    if(loginInfo.progressArray){
        
        UIView *tempView = [loginInfo.progressArray objectForKey:housesId];
        if(tempView){
            
            UILabel *downloaded = (UILabel *)[tempView viewWithTag:61];
            UILabel *downloadedPlan = (UILabel *)[tempView viewWithTag:65];
            
            if(downloaded && !downloadedPlan){
                
                [downloaded setHidden:true];
                
                double remain = [[dataArgs objectForKey:@"remain"] longLongValue];
                
                UIView *temp3View = [tempView viewWithTag:99];
                NSArray *subViews = [temp3View subviews];
                UIView *temp4View = subViews[0];
                
                if(remain<=0){
                    
                    remain = 0;
                    
                    UIView *temp2View = [tempView viewWithTag:[[dataArgs objectForKey:@"housesId"] intValue]];
                    if(temp2View)
                        
                        if(temp3View){
                            
                            [temp3View removeFromSuperview];
                            
                        }
                }
                
                
                
                double total = [[dataArgs objectForKey:@"total"] longLongValue];
                NSString *per = [NSString stringWithFormat:@"%0.1f％",(total-remain)/total*100];
                
                float perFloat = (total-remain)/total;
                
                if([temp4View isKindOfClass:[LDProgressView class]] && perFloat<=1){
                    LDProgressView *mixedIndicator =  (LDProgressView *)temp4View;
                    
                    if(perFloat>mixedIndicator.progress){
                        mixedIndicator.tip =@"";
                        mixedIndicator.progress = (total-remain)/total;
                        [downloaded setText:[NSString stringWithFormat:@" 已下载%@",per]];
                    }
                }
            }
            
            
           else if(downloadedPlan){
                
                NSDictionary *temp1 = [loginInfo.dataFromPlanTable objectForKey:housesId];
                NSArray *data = [temp1 objectForKey:@"data"];
                
                double total = 0;
                double completeTotal = 0;
                for(NSDictionary *temp2 in data){
                    
                    total = total + [[temp2 objectForKey:@"total"] longLongValue];
                    if([[temp2 objectForKey:@"status"] intValue] == 3){
                        
                        completeTotal = completeTotal +[[temp2 objectForKey:@"total"] longLongValue];
                    }
                    
                }
                
                double complete = completeTotal+ [[dataArgs objectForKey:@"total"] longLongValue]-[[dataArgs objectForKey:@"remain"] longLongValue];
                UIView *temp3View = [tempView viewWithTag:99];
                NSArray *subViews = [temp3View subviews];
                UIView *temp4View = subViews[0];
                
                if(total<=completeTotal){
                    
                    if(temp3View)
                        
                        [temp3View removeFromSuperview];
                }
                
                if([temp4View isKindOfClass:[LDProgressView class]] && complete/total<=1){
                    LDProgressView *mixedIndicator =  (LDProgressView *)temp4View;
                    if(complete/total>mixedIndicator.progress)
                    mixedIndicator.tip =@"";
                    mixedIndicator.progress = complete/total;
                }
                
            }
            
        }
    }
    //   [[NSNotificationCenter defaultCenter] postNotificationName:@"updateView" object:nil];
}
-(void)downloadComplete:(NSString *)housesId{

    [loginInfo.downloadList removeObjectForKey:housesId];
  //  [loginInfo.progressArray removeObjectForKey:housesId];
    loginInfo.isTouching = true;
    
    if(loginInfo.downloadList.count ==0){
        loginInfo.isDownloadComplete =true;
    }

}
-(void)addProgressingViewMethod:(NSString *)housesId{
    
    if(loginInfo.progressArray){
        
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0,0,156,117)];
        tempView.tag = 99;
        LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(0,0,156,117)];
        progressView.showText = @YES;
        progressView.borderRadius = @4;
        progressView.type = LDProgressSolid;
        progressView.tag = [housesId intValue];
        // 6682c3
        progressView.color = UIColorFromRGB(0x6682c3);
        [progressView setAnimate:0];
        
        progressView.tip =@"";
        progressView.progress = 0.001;
        
        [tempView addSubview:progressView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,80,156,117)];
        [label setText:@"下载中"];
        label.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13];
        [label setTextColor:[UIColor whiteColor]];
        label.textAlignment = NSTextAlignmentCenter;
        
        
        //  [mixedIndicator addSubview:label];
        
        //     [tempView addSubview:mixedIndicator];
        
        [loginInfo.progressArray setValue:tempView forKey:housesId];
        
    }
}

-(void)changeWaitToDownloadViewMethod:(NSString *)housesId{
    
    if(loginInfo.progressArray){
        
        UIView *tempView = [loginInfo.progressArray objectForKey:housesId];
        
        if([tempView viewWithTag:62]){
            
            [[tempView viewWithTag:62] removeFromSuperview];
            
            UIView *tempView1 = [[UIView alloc] initWithFrame:CGRectMake(0,0,156,117)];
            tempView1.tag = 99;
            
            //        DAProgressOverlayView *mixedIndicator = [[DAProgressOverlayView alloc] initWithFrame:CGRectMake(5,5,254,192)];
            //        mixedIndicator.tag = [housesId intValue];
            //        mixedIndicator.progress = 0.01;
            //        [mixedIndicator setBackgroundColor:[UIColor clearColor]];
            
            LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(0,0,156,117)];
            progressView.showText = @YES;
            progressView.borderRadius = @4;
            progressView.type = LDProgressSolid;
            progressView.tag = [housesId intValue];
            progressView.color = UIColorFromRGB(0x6682c3);
            [progressView setAnimate:0];
            progressView.tip =@"";
            progressView.progress = 0.001;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,80,156,20)];
            [label setText:@"下载中"];
            label.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13];
            [label setTextColor:[UIColor whiteColor]];
            label.textAlignment = NSTextAlignmentCenter;
            
            //        [mixedIndicator addSubview:label];
            //        [mixedIndicator addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(postAddGesture:)]];
            //        [tempView1 addSubview:mixedIndicator];
            
            [progressView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(postAddGesture:)]];
            [tempView1 addSubview:progressView];
            
            [tempView addSubview:tempView1];
            [loginInfo.progressArray setValue:tempView forKey:housesId];
        }
    }
}
-(void)postAddGesture:(UIGestureRecognizer *)gestureRecognizer{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"postAddGesture" object:gestureRecognizer];
}

-(void)uploadDownloadRecord:(NSString *)planId version:(NSString *)version{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":planId,@"version":version};
    
    
    [manager POST:[BASEURL stringByAppendingString: downRecordApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // NSLog(@"JSON: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        
    }];
    
    
}
@end
