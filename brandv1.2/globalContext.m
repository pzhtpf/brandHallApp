//
//  globalContext.m
//  brandv1.2
//
//  Created by Apple on 14-9-5.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "globalContext.h"
#import "AFNetworkReachabilityManager.h"
#include <math.h>
#include "MobileWiFi.h"
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
#import "ChineseString.h"
#import "pinyin.h"
#import "BackGroundDownload.h"

//static dispatch_queue_t http_request_operation_processing_queue() {
//    static dispatch_queue_t af_http_request_operation_processing_queue;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        af_http_request_operation_processing_queue = dispatch_queue_create("com.gezlife.downloadImage", DISPATCH_QUEUE_CONCURRENT);
//    });
//    
//    return af_http_request_operation_processing_queue;
//}
//
//static dispatch_group_t http_request_operation_completion_group() {
//    static dispatch_group_t af_http_request_operation_completion_group;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        af_http_request_operation_completion_group = dispatch_group_create();
//    });
//    
//    return af_http_request_operation_completion_group;
//}

@implementation globalContext
LoginInfo *loginInfo;
int increaseCount = 0;
int planCount = 0;
UIImageView *tempImageView;
bool planIsComplete = true;
NSThread *downloadMainThread;
+(BOOL)netWorkStatus{
    bool flag = false;
    
    AFNetworkReachabilityManager *r = [AFNetworkReachabilityManager sharedManager];
   
    flag = [r isReachable];
    
    return flag;
}
+(void)showAlertView:(NSString *)message{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"关闭" otherButtonTitles:nil];
    [alert show];

}

+(void)startDownloadThread{
    
    BackGroundDownload *_BackGroundDownload = [[BackGroundDownload alloc] init];
    [_BackGroundDownload startDownload];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelDownloadThread:) name:@"cancelDownloadThread" object:nil];
//    loginInfo = [[StockData getSingleton] valueForKey:@"loginInfo"];
//
//    if (!loginInfo.downloadList)
//    loginInfo.downloadList = [DBHelper getDataFromPlanTable:1];
//    
//    if( loginInfo.downloadList.count>0){
//        
//        loginInfo.isRedownload = false;
//        loginInfo.isDownloadComplete = false;
//        planIsComplete = true;
//        
//        downloadMainThread = [[NSThread alloc] initWithTarget:self selector:@selector(startDownloadMethod:) object: loginInfo.downloadList];
//        [downloadMainThread start];
//        
//    }
//    else{
//        loginInfo.isDownloadComplete = true;
//
//    }
//    
//      loginInfo.isRedownload = false;
}
+(void)cancelDownloadThread:(NSNotification *)notification{

    [downloadMainThread cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cancelDownloadThread" object:nil];

}
+(void)startDownloadMethod:(NSMutableDictionary *)dataArray{

    while (true) {
        
        
        if(loginInfo.isRedownload){
            
            loginInfo.isRedownload = false;
          //  break;
        }
        
        NSArray *keys = [loginInfo.downloadList allKeys];
        
        if(keys.count>0){
            
            increaseCount = 0;
            planCount = 0;
        
        NSDictionary *temp = [dataArray objectForKey:keys[0]];
            
     //   [self performSelectorInBackground:@selector(changeWaitToDownloadViewMethod:) withObject:[temp objectForKey:@"housesId"]];
        
        if([temp objectForKey:@"nowStart"]){
        
            [self saveDownloadData:temp];
            
            if(loginInfo.progressArray){
                
               [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownloadingView" object:nil];
            }
        }
        
        NSArray *data = [temp objectForKey:@"data"];
        
        int dataCount = 0;
        while (true) {
            
            if(loginInfo.isRedownload)
                break;
            
         //   if(increaseCount == planCount){
            if(planIsComplete){
                
             if(dataCount == data.count )
                 break;
           
            NSMutableDictionary *temp2= [[NSMutableDictionary alloc] initWithDictionary:data[dataCount]];
            [temp2 setValue:[temp objectForKey:@"housesId"] forKey:@"housesId"];
            [temp2 setValue:[temp objectForKey:@"housesName"] forKey:@"housesName"];
            [temp2 setValue:[temp objectForKey:@"id"] forKey:@"id"];
            if([temp objectForKey:@"isHigh"])
            [temp2 setValue:[temp objectForKey:@"isHigh"] forKey:@"isHigh"];   
            [self startDownload:temp2];
            dataCount++;
            }
            
            
            
            [NSThread sleepForTimeInterval:1];
        }
        
        
        [loginInfo.downloadList removeObjectForKey:[temp objectForKey:@"housesId"]];
        [loginInfo.progressArray removeObjectForKey:[temp objectForKey:@"housesId"]];
        loginInfo.isTouching = true;
        
        if(loginInfo.downloadList.count ==0){
            loginInfo.isDownloadComplete =true;
            break;
        }
    }
        else{
        
            loginInfo.isDownloadComplete =true;
            loginInfo.isRedownload = false;
            break;
        
        }
    }


}
+(void)saveDownloadData:(NSDictionary *)temp{
        
        [DBHelper saveDataToPlanTable:temp];
        
        NSString *angle = [temp objectForKey:@"angle"];
        
        NSArray *defaultDataArray = [temp objectForKey:@"data"];
        
        for(NSDictionary *temp7 in defaultDataArray){
            
            NSArray *defaultData = [temp7 objectForKey:@"defaultData"];
            if(![defaultData isKindOfClass:[NSNull class]])
                [DBHelper saveDataToDefaultTable:defaultData planId:[temp7 objectForKey:@"planId"] angle:angle];
            
        }
    
        
        NSMutableDictionary *temp6 = [DBHelper getDataFromPlanTable:[[temp objectForKey:@"housesId"] intValue]];
        NSArray *keys = [temp6 allKeys];
        if(keys.count>0){
        //    temp = [temp6 objectForKey:keys[0]];
            [loginInfo.dataFromPlanTable setValue:[temp6 objectForKey:keys[0]] forKey:keys[0]];
        }
 
}
+(void)downloadThreadByPlanId:(NSDictionary *)planData housesId:(NSString *)housesId{
    
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:planData];
    [temp setValue:housesId forKey:@"housesId"];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(startDownload:) object:temp];

    [thread start];
    
    

}
+(void)startDownload:(NSMutableDictionary *)dataArgs{
    
    increaseCount = 0;
    planIsComplete = false;

    NSString *planId = [dataArgs objectForKey:@"planId"];
    
    NSMutableArray *dataArrays = [DBHelper getUndownloadByPlanId:planId];
    
    planCount  = (int)dataArrays.count;
    
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
    
        
        dispatch_group_t group = dispatch_group_create();
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(6);
        
        
    int isHigh = [[dataArgs objectForKey:@"isHigh"] intValue];
    
//    int count = 0;
//    int flag = 0;
        
    for(NSDictionary *temp in dataArrays){
        
        if(loginInfo.isRedownload){
            planIsComplete = true;
            break;
        }

         dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
         dispatch_group_async(group,dispatch_get_main_queue(), ^{
        
        NSDictionary *dataTemp = [[NSDictionary alloc] initWithObjectsAndKeys:dataArgs,@"dataArgs",temp,@"temp", nil];


        if(![[temp objectForKey:@"imageUrl"] isEqualToString:@"0"]){
        
        NSString *path = [imageUrl stringByAppendingString:[temp objectForKey:@"imageUrl"]];
            
        if(isHigh ==0){
        NSArray *names = [path componentsSeparatedByString:@"."];
        path = [NSString stringWithFormat:@"%@_thumb.%@",path,names[names.count-1]];
        
        }
        
        NSString *name = [temp objectForKey:@"localImageName"];
            
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:path,@"path",name,@"name", nil];
            

            AsyncImageDownloader *downloader = [[AsyncImageDownloader alloc] initWithMediaURL:path data:data tempData:dataTemp successBlock:^(UIImage *image,NSDictionary *data,NSDictionary *dataTemp){
               
            [self singleImageDownloadComplete:dataTemp image:image];
                
                if(loginInfo.isRedownload && loginInfo.downloadList.count ==0){
                    planIsComplete = true;
                    loginInfo.isDownloadComplete = true;
                    
                    [downloadMainThread cancel];
                }
                else
                    dispatch_semaphore_signal(semaphore);
                
                
            if(image){
                
           //       NSLog(@"下载成功的图片：%@",[temp objectForKey:@"imageUrl"]);

                }
                else{
                    NSLog(@"下载失败的图片：%@",[temp objectForKey:@"imageUrl"]);
                  //  [dataArrays addObject:temp];
                }
                
            } failBlock:^(NSError *error){
                
               [self singleImageDownloadComplete:dataTemp image:nil];
              //  [dataArrays addObject:temp];
                NSLog(@"下载失败的图片：%@",[temp objectForKey:@"imageUrl"]);


                if(loginInfo.isRedownload && loginInfo.downloadList.count ==0){
                    
                    planIsComplete = true;
                    loginInfo.isDownloadComplete = true;

                    [downloadMainThread cancel];
                  //  [NSThread exit];
                }
                else
                    dispatch_semaphore_signal(semaphore);
                
            }];
            
            [downloader startDownload];
            
        }
        else{
        
         [self singleImageDownloadComplete:dataTemp image:nil];
         dispatch_semaphore_signal(semaphore);
        }
    });


    }
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
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
        planIsComplete = true;
    }
}

+(void)singleImageDownloadComplete:(NSDictionary *)data image:(UIImage *)image{
    
    NSDictionary *temp =[data objectForKey:@"temp"];
    NSMutableDictionary *dataArgs =[data objectForKey:@"dataArgs"];
    
    NSString *planId = [temp objectForKey:@"planId"];

//    [DBHelper saveDownloadingTable:[temp objectForKey:@"housesId"] plan_id:planId localImageName:[temp objectForKey:@"localImageName"] image_url:[temp objectForKey:@"imageUrl"] image_size:[temp objectForKey:@"imageSize"] type:[temp objectForKey:@"type"] elementId:[temp objectForKey:@"elementId"] productId:[temp objectForKey:@"productId"] id:[temp objectForKey:@"id"] status:[NSNumber numberWithInt:1]];
    
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
    
    
    

    if(!loginInfo.isRedownload){
        
  //    [self performSelectorInBackground:@selector(addProgressingView:) withObject:dataArgs];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self addProgressingView:dataArgs];
            
        });
    }
    
    
    increaseCount++;
    
    if(increaseCount == planCount){    //下载完毕
        
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
        planIsComplete = true;
        
        [self addStatusBarNotification:[NSString stringWithFormat:@"%@已下载完毕",[dataArgs objectForKey:@"name"]]];
        
    }

}

+(void)addProgressingView:(NSMutableDictionary *)dataArgs{

    // 添加正在下载的界面
    
    NSString *housesId = [dataArgs objectForKey:@"housesId"];
    
 //   [self addProgressingViewMethod:housesId];
    
    if(loginInfo.progressArray){
        
        UIView *tempView = [loginInfo.progressArray objectForKey:housesId];
        if(tempView){
            
            UILabel *downloaded = (UILabel *)[tempView viewWithTag:61];
            if(downloaded){
            
            [downloaded setHidden:true];
                
            double remain = [[dataArgs objectForKey:@"remain"] longLongValue];
                
            UIView *temp3View = [tempView viewWithTag:99];
            NSArray *subViews = [temp3View subviews];
                UIView *temp4View = subViews[0];
                
            if(remain<=0){
                    
            remain = 0;
              
            UIView *temp2View = [tempView viewWithTag:[[dataArgs objectForKey:@"housesId"] intValue]];
            if(temp2View)
          //  [temp2View removeFromSuperview];
                            
                if(temp3View && increaseCount == planCount){
                
                [temp3View removeFromSuperview];

                }
                }
               
                
                
            double total = [[dataArgs objectForKey:@"total"] longLongValue];
            NSString *per = [NSString stringWithFormat:@"%0.1f％",(total-remain)/total*100];
            
            float perFloat = (total-remain)/total;
                
            if([temp4View isKindOfClass:[LDProgressView class]]){
            LDProgressView *mixedIndicator =  (LDProgressView *)temp4View;
                
            if(perFloat>mixedIndicator.progress){
             mixedIndicator.tip =@"";
             mixedIndicator.progress = (total-remain)/total;
            [downloaded setText:[NSString stringWithFormat:@" 已下载%@",per]];
                }
                }
                
            }
        }
        UILabel *downloadedPlan = (UILabel *)[tempView viewWithTag:65];
        if(downloadedPlan){
         
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
            completeTotal +=complete;
            UIView *temp3View = [tempView viewWithTag:99];
            NSArray *subViews = [temp3View subviews];
            UIView *temp4View = subViews[0];
            
            if(total<=completeTotal){
                
                if(temp3View && increaseCount == planCount)
                    
                    [temp3View removeFromSuperview];
            }
            
            if([temp4View isKindOfClass:[LDProgressView class]]){
            LDProgressView *mixedIndicator =  (LDProgressView *)temp4View;
            if(complete/total>mixedIndicator.progress)
            mixedIndicator.tip =@"";
            mixedIndicator.progress = complete/total;
                 }
            
        }
        
    }
 //   [[NSNotificationCenter defaultCenter] postNotificationName:@"updateView" object:nil];
}
+(void)addProgressingViewMethod:(NSString *)housesId{
    
  if(loginInfo.progressArray){
      
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0,0,156,117)];
           tempView.tag = 99;
//            DAProgressOverlayView *mixedIndicator = [[DAProgressOverlayView alloc] initWithFrame:CGRectMake(5,5,185,120)];
//            mixedIndicator.tag = [housesId intValue];
//            mixedIndicator.progress = 0.01;
//            [mixedIndicator setBackgroundColor:[UIColor clearColor]];
      
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

+(void)changeWaitToDownloadViewMethod:(NSString *)housesId{
    
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
+(void)postAddGesture:(UIGestureRecognizer *)gestureRecognizer{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"postAddGesture" object:gestureRecognizer];
}

+(BOOL)isLogin{

    BOOL flag = false;
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookies];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        if([cookie.name isEqualToString:@"USER_ID"]){
            flag = true;
            [self setCookies:cookie.value];
            break;
        }
    }
    
    return flag;

}
+(void)uploadDownloadRecord:(NSString *)planId version:(NSString *)version{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":planId,@"version":version};
    
    
    [manager POST:[BASEURL stringByAppendingString: downRecordApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
       // NSLog(@"JSON: %@", responseObject);
        
//    JSON: {
//        flag = true;
//    }

        
    //   NSDictionary  *temp = responseObject;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        
    }];

     
}
+(void)checkVersion{
    
    NSMutableDictionary *updateArray = [DBHelper getDataFromPlanTable:-3];
    
    NSArray *keys = [updateArray allKeys];
    
    NSString *planId = @"";
    NSString *version = @"";
    
    for (NSString *key in keys) {
        NSDictionary *temp1 = [updateArray objectForKey:key];
        NSArray *data = [temp1 objectForKey:@"data"];
        for(NSDictionary *temp2 in data){
        
            planId = [NSString stringWithFormat:@"%@%@,",planId,[temp2 objectForKey:@"planId"]];
            version = [NSString stringWithFormat:@"%@%@,",version,[temp2 objectForKey:@"nowVersion"]];

        }
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":planId,@"version":version};
    
    
    [manager POST:[BASEURL stringByAppendingString: checkVersionApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
      //   NSLog(@"JSON: %@", responseObject);
        
        //    JSON: {
        //        flag = true;
        //    }
        if([responseObject isKindOfClass:[NSArray class]]){
         NSArray *temp = responseObject;
        [DBHelper updateVersion:temp];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        
    }];
    
    
}
+(void)judgeHousesList{
    
    //    type   ＝ 1           1，只拥有户型列表
    //    2，只拥有经典样板间
    //    3，两者都拥有
    //    4，两者都没有
    if(!loginInfo)
         loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[BASEURL stringByAppendingString:judgeHousesListApi] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *data = responseObject;
        
        loginInfo.housesType = [[data objectForKey:@"type"] intValue];
        
        if(loginInfo.mySegmented){
        if(loginInfo.housesType ==3){
            
            NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MicrosoftYaHei" size:14.0f], UITextAttributeFont, nil];
            [loginInfo.mySegmented setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
            
            [loginInfo.mySegmented setHidden:false];
        }
        else if(loginInfo.housesType ==1){
            loginInfo.downloadType = 3;
            [loginInfo.mySegmented setHidden:true];
            
        }
        else if(loginInfo.housesType ==2){
            loginInfo.downloadType = 1;
            [loginInfo.mySegmented setHidden:true];
            
        }
        else{
        
            [loginInfo.mySegmented setHidden:true];

        }
    }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        loginInfo.housesType = 0;
        
    }];
    
}
+(void)getBrandhallDetail{


    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[BASEURL stringByAppendingString:brandhallDetailApi] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
      //  NSLog(@"JSON: %@", responseObject);
    
        NSDictionary *data = responseObject;
        
        [self downloadBrandLogoImage:[data mutableCopy]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        
    }];
  

}
+(void)downloadBrandLogoImage:(NSMutableDictionary *)argsData{
    
    NSString *logo_rectangle =  [argsData objectForKey:@"logo_app"];
    
    if(![logo_rectangle isKindOfClass:[NSNull class]] && logo_rectangle.length>0){

    NSString *rec_path = [imageUrl stringByAppendingString:logo_rectangle];
    

    NSArray *names = [[argsData objectForKey:@"logo_app"] componentsSeparatedByString:@"/"];
    NSString *name = [NSString stringWithFormat:@"BrandLogo%@",names[names.count-1]];
        

    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:rec_path,@"path",name,@"name", nil];
    
    
    AsyncImageDownloader *downloader = [[AsyncImageDownloader alloc] initWithMediaURL:rec_path data:data tempData:nil successBlock:^(UIImage *image,NSDictionary *data,NSDictionary *dataTemp){
        
        [argsData setValue:name forKey:@"local_logo_app"];
        
        [DBHelper saveBrandDetailToDB:argsData];
        
    } failBlock:^(NSError *error){
        
    }];
    
    [downloader startDownload];
       
    }
    
    else{
       [argsData setValue:@"" forKey:@"local_logo_app"];
         [DBHelper saveBrandDetailToDB:argsData];
    }
    
}
+(void)settingBrandLogo:(UIImageView *)imageView nameLabel:(UILabel *)nameLabel{

    NSString *path =@"";
    
    if(loginInfo.brand_logo_app.length>0)

        path = loginInfo.brand_logo_app;

    else  if(loginInfo.brandName.length>0){
    
        [imageView setHidden:true];
         [nameLabel setHidden:false];
        [nameLabel setText:loginInfo.brandName];
    }
    
    if(path.length>0){
     
    [nameLabel setHidden:true];
        
    [UIImage loadFromURL:path callback: ^(UIImage *image){
        
     //   image = nil;
        
        if(image){
        
        int width = image.size.width/image.size.height*25;
        
        image = [image resizedCenterImage:CGSizeMake(width,25) interpolationQuality:kCGInterpolationLow];
        
        imageView.frame = CGRectMake(imageView.frame.origin.x,9, width,25);
        
        [imageView setImage:image];
            
        }
        else  if(loginInfo.brandName.length>0){
            [imageView setHidden:true];
            [nameLabel setHidden:false];
            [nameLabel setText:loginInfo.brandName];
        }
       
    }];
  }
}
+(void)changeBrandId{

    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookies];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        if([cookie.name isEqualToString:@"GezLife_BRAND_ID"]){
            [cookies deleteCookie:cookie];
            break;
        }
    }
    
    NSDictionary *properties1 = [[NSMutableDictionary alloc] init];
    // [properties1 setValue:@"4" forKey:NSHTTPCookieValue];       //喜鹊筑家
    //  [properties1 setValue:@"5" forKey:NSHTTPCookieValue];       //和木居
       [properties1 setValue:@"51" forKey:NSHTTPCookieValue];       //乐居
    //   [properties1 setValue:@"105" forKey:NSHTTPCookieValue];       //丰成紫韵
   //    [properties1 setValue:@"110" forKey:NSHTTPCookieValue];       //古珀
    //  [properties1 setValue:@"11" forKey:NSHTTPCookieValue];       //梦之蓝
    //   [properties1 setValue:@"1" forKey:NSHTTPCookieValue];       //富邦
    [properties1 setValue:@"GezLife_BRAND_ID" forKey:NSHTTPCookieName];
    [properties1 setValue:Domain forKey:NSHTTPCookieDomain];
    //   [properties1 setValue:@"mall.local-gez.cn" forKey:NSHTTPCookieDomain];
    [properties1 setValue:[NSDate dateWithTimeIntervalSinceNow:24*60*60] forKey:NSHTTPCookieExpires];
    [properties1 setValue:@"/" forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie1 = [[NSHTTPCookie alloc] initWithProperties:properties1];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie1];

}
+(void)setCookies:(NSString *)userId{
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray* facebookCookies = [cookies cookiesForURL:
//                                [NSURL URLWithString:Domain]];
     NSArray* facebookCookies = [cookies cookies];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        if([cookie.name isEqualToString:@"USER_ID"]){
            [cookies deleteCookie:cookie];
            break;
        }
    }
    
    NSDictionary *properties1 = [[NSMutableDictionary alloc] init];
    [properties1 setValue:userId forKey:NSHTTPCookieValue];       //乐居
    [properties1 setValue:@"USER_ID" forKey:NSHTTPCookieName];
    [properties1 setValue:Domain forKey:NSHTTPCookieDomain];
    [properties1 setValue:[NSDate dateWithTimeIntervalSinceNow:24*60*60] forKey:NSHTTPCookieExpires];
    [properties1 setValue:@"/" forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie1 = [[NSHTTPCookie alloc] initWithProperties:properties1];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie1];
    
}
+(BOOL)detectBrandIDIsChange{

    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookies];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        if([cookie.name isEqualToString:@"GezLife_BRAND_ID"]){
            NSDictionary *brandDetail = [DBHelper getBrandDetailFromDB];
            NSString *brandId = [brandDetail objectForKey:@"id"];
            if(![brandId isEqualToString:cookie.value]){
                [self getBrandhallDetail];
                return true;
            }
            break;
        }
    }
    
    return false;
}
+(int)GettingTheWiFiSignalStrength{

//    WiFiManagerRef manager = WiFiManagerClientCreate(kCFAllocatorDefault, 0);
//    CFArrayRef devices = WiFiManagerClientCopyDevices(manager);
//    
//    WiFiDeviceClientRef client = (WiFiDeviceClientRef)CFArrayGetValueAtIndex(devices, 0);
//    CFDictionaryRef data = (CFDictionaryRef)WiFiDeviceClientCopyProperty(client, CFSTR("RSSI"));
//    CFNumberRef scaled = (CFNumberRef)WiFiDeviceClientCopyProperty(client, kWiFiScaledRSSIKey);
//    
//    CFNumberRef RSSI = (CFNumberRef)CFDictionaryGetValue(data, CFSTR("RSSI_CTL_AGR"));
//    
//    int raw;
//    CFNumberGetValue(RSSI, kCFNumberIntType, &raw);
//    
//    float strength;
//    CFNumberGetValue(scaled, kCFNumberFloatType, &strength);
//    CFRelease(scaled);
//    
//    strength *= -1;
//    
//    // Apple uses -3.0.
//    int bars = (int)ceilf(strength * -3.0f);
//    bars = MAX(1, MIN(bars, 3));
//    
//    
//    printf("WiFi signal strength: %d dBm\n\t Bars: %d\n", raw,  bars);
//    
//    CFRelease(data);
//    CFRelease(scaled);
//    CFRelease(devices);
//    CFRelease(manager);
//    
//    return bars;
      return 0;
}
+(NSString *)getId{
    
    NSString *idStr =@"";
    
    for(int i=0;i<12;i++){
        
        int value =arc4random_uniform(10);
        
        idStr =[NSString stringWithFormat:@"%@%d",idStr,value];
    }
    
    return  idStr;
}
+(void)addStatusBarNotification:(NSString *)text{
    
    if(!loginInfo.notificationQueue){
    
        loginInfo.notificationQueue  = [[NSMutableDictionary alloc] init] ;
    }
    
    
    [loginInfo.notificationQueue setValue:text forKey:[self getId]];
    
    if(loginInfo.notificationQueue.count>0){
        NSArray *keys = [loginInfo.notificationQueue allKeys];
        [self showNextNotification:keys[0]];
    }

  }
+(void)showNextNotification:(NSString *)key{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    
    
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    
    NSArray *subViews = [window subviews];
    
    if(![[subViews objectAtIndex:subViews.count-1] viewWithTag:631]){
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -44, 1024, 44)];
        
       
        
        [view setBackgroundColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:0.95]];
//        [view setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
        view.tag = 631;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addUITapGestureRecognizer" object:view];
        
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 34, 34)];
//        [imageView setImage:[UIImage imageNamed:@"icon_40x40.png"]];
//        [imageView.layer setShadowRadius:5];
//        
//        [view addSubview:imageView];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 1024, 44)];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [tipLabel setText:[loginInfo.notificationQueue objectForKey:key]];
        tipLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17.0f];
        [tipLabel setTextColor:[UIColor whiteColor]];
        
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 44)];
        [keyLabel setText:key];
        keyLabel.tag = 56;
        keyLabel.alpha = 0;
        
        [view addSubview:keyLabel];
        [view addSubview:tipLabel];

        
        
        [[[window subviews] objectAtIndex:subViews.count-1] addSubview:view];
        
        [UIView setAnimationsEnabled:true];
        
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                             view.frame = CGRectMake(0, 0,1024,44);
                             
                         }
                         completion:^(BOOL finished) {
                             
                             [self performSelector:@selector(removeStatusNotification:)
                                        withObject:key
                                        afterDelay:2];
                         }
         ];
    }


}
+(void)removeStatusNotification:(NSString *)key{

    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    
    
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    
    NSArray *subViews = [window subviews];

   __block UIView *view  = [[subViews objectAtIndex:subViews.count-1] viewWithTag:631];
    
    if(view){
        
        [UIView setAnimationsEnabled:true];
     
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                             view.frame = CGRectMake(0,-44,1024,44);
                             
                         }
                         completion:^(BOOL finished) {
                             [view removeFromSuperview];
                             view = nil;
                             
                             [loginInfo.notificationQueue removeObjectForKey:key];
                             
                             if(loginInfo.notificationQueue.count>0){
                                 NSArray *keys = [loginInfo.notificationQueue allKeys];
                                  [self performSelector:@selector(showNextNotification:)
                                        withObject:keys[0]
                                        afterDelay:0];
                             }
                         }
         ];

    }
}
+(void)clearStatusNotification{

    if(loginInfo.notificationQueue)
    [loginInfo.notificationQueue removeAllObjects];
}
+(NSString *)toPinYin:(NSString *)name{
    
    ChineseString *chineseString=[[ChineseString alloc]init];
    
    chineseString.string=[NSString stringWithString:name];
    
    if(chineseString.string==nil){
        chineseString.string=@"";
    }
    
    if(![chineseString.string isEqualToString:@""]){
        NSString *pinYinResult=[NSString string];
        for(int j=0;j<chineseString.string.length;j++){
            NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([chineseString.string characterAtIndex:j])]uppercaseString];
            
            pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
        }
        chineseString.pinYin=pinYinResult;
    }else{
        chineseString.pinYin=@"";
    }
    
    return chineseString.pinYin;
}
@end
