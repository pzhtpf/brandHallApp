/*
 * Copyright (c) 2013 Kyle W. Banks
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  AsyncImageDownloader.m
//
//  Created by Kyle Banks on 2012-11-29.
//  Modified by Nicolas Schteinschraber 2013-05-30
//

#import "AsyncImageDownloader.h"
#import "downloadImage.h"
#import "UIImage+Resize.h"

#define kAppIdentifier [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *) kCFBundleIdentifierKey]

NSString *filePathForURL1(NSString * url);
@implementation AsyncImageDownloader

@synthesize mediaURL, fileURL,name,dataTemp;

NSString *filePathForURL1(NSString * url) {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //  NSString *imageDir = [documentsDirectory stringByAppendingPathComponent:kAppIdentifier];
    //   NSString *furl = [[[url.absoluteString stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSString *furl = [NSString stringWithFormat:@"%@/%@",documentsDirectory,url];
    
    //  return [imageDir stringByAppendingPathComponent:furl];
    return furl;
}

-(id)initWithMediaURL:(NSString *)theMediaURL data:(NSDictionary *)dataArgs tempData:(NSDictionary *)dataTempArgs successBlock:(void (^)(UIImage *image,NSDictionary *data,NSDictionary *dataTemp))success failBlock:(void (^)(NSError *))fail
{
    self = [super init];
    
    if(self)
    {
        dataTemp = dataTempArgs;
        name =  dataArgs;
        [self setMediaURL:theMediaURL];
        [self setFileURL:nil];
        successCallback = success;
        failCallback = fail;
    }
    
    return self;
}
-(id)initWithFileURL:(NSString *)theFileURL successBlock:(void (^)(NSData *data))success failBlock:(void(^)(NSError *error))fail
{
    self = [super init];
    
    if(self)
    {
        [self setMediaURL:nil];
        [self setFileURL:theFileURL];
        successCallbackFile = success;
        failCallback = fail;
    }
    
    return self;
}

//Perform the actual download
-(void)startDownload
{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    
      NSString *namePath = [name objectForKey:@"name"];
//    NSString *temp = [namePath substringToIndex:9];
//    
//    if(![temp isEqualToString:@"planTable"]){
//    
    if ([self hasWrittenDataToFilePath:filePathForURL1(namePath)]) {
       
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *furl = [NSString stringWithFormat:@"%@/%@",documentsDirectory,namePath];
        UIImage *image  = [UIImage imageWithContentsOfFile:furl];
         successCallback(image,name,dataTemp);
        return;
    }
    else{
    
        fileData = [[NSMutableData alloc] init];
        
        NSURLRequest *request = nil;
        if (fileURL)
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileURL]];
        else
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:mediaURL]];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        if(!connection)
        {
            failCallback([NSError errorWithDomain:@"Failed to create connection" code:0 userInfo:nil]);
        }

    
    }
//    }
//    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    static dispatch_once_t once;
//    static const int max_in_flight = 8;  // Also try 4, 8, and maybe some other numbers
//    static dispatch_semaphore_t limit = NULL;
//    dispatch_once(&once, ^{
//        limit = dispatch_semaphore_create(max_in_flight);
//    });
//    dispatch_async(queue, ^{
//        dispatch_semaphore_wait(limit, DISPATCH_TIME_FOREVER);
//     //   UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:mediaURL]]];
//        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:mediaURL]];
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//           // [self writeImageData:UIImagePNGRepresentation(image) toFilePath:filePathForURL1(namePath)];
//            [self writeImageData:imageData toFilePath:filePathForURL1(namePath)];
//              //  completionBlock(image,name,dataTemp,nil);
//              successCallback(nil,name,dataTemp);
//            
//            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//           
//        });
//        dispatch_semaphore_signal(limit);
//    });
   
}


- (BOOL) hasWrittenDataToFilePath:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

-(BOOL) writeImageData:(NSData *) data toFilePath:(NSString *) filePath {
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageDir = [documentsDirectory stringByAppendingPathComponent:kAppIdentifier];
    
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDir]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        
    }
    
   // if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        
        
        return YES;
        
  //  }
    
 //   return NO;
}

#pragma mark NSURLConnection Delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    failCallback(error);
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = (int)[((NSHTTPURLResponse *)response) statusCode];
        if (statusCode >= 400)
        {
            [connection cancel];
            failCallback([NSError errorWithDomain:@"Image download failed due to bad server response" code:0 userInfo:nil]);
        }
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [fileData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    int cacheSizeMemory = 0*1024*1024; // 4MB
    int cacheSizeDisk = 0*1024*1024; // 32MB
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    NSCache  *memCache = [[NSCache alloc] init];
    [memCache removeAllObjects];
    
  //  [[NSURLCache sharedURLCache] removeAllCachedResponses];

    if(fileData == nil)
    {
        failCallback([NSError errorWithDomain:@"No data received" code:0 userInfo:nil]);
    }
    else
    {
        if (fileURL) {
            successCallbackFile(fileData);
        } else {
           UIImage *image = [UIImage imageWithData:fileData];
        //    image = [image resizedImage:image.size interpolationQuality:kCGInterpolationHigh];
       //     NSData* dataImage = UIImagePNGRepresentation(image);
           [downloadImage saveImage:[name objectForKey:@"name"] image:fileData];
            
            successCallback(image,name,dataTemp);
        }
    }    
}

@end
