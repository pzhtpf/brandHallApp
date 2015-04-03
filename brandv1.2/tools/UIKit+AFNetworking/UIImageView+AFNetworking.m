// UIImageView+AFNetworking.m
//
// Copyright (c) 2013-2014 AFNetworking (http://afnetworking.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIImageView+AFNetworking.h"

#import <objc/runtime.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

#import "AFHTTPRequestOperation.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "downloadImage.h"


static dispatch_queue_t http_request_operation_processing_queue() {
    static dispatch_queue_t af_http_request_operation_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_http_request_operation_processing_queue = dispatch_queue_create("com.gezlife.loadLocalImage", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return af_http_request_operation_processing_queue;
}

static dispatch_group_t http_request_operation_completion_group() {
    static dispatch_group_t af_http_request_operation_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_http_request_operation_completion_group = dispatch_group_create();
    });
    
    return af_http_request_operation_completion_group;
}

@interface AFImageCache : NSCache <AFImageCache>
@end

#pragma mark -

@interface UIImageView (_AFNetworking)
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AFHTTPRequestOperation *af_imageRequestOperation;
@end

@implementation UIImageView (_AFNetworking)

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        _af_sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });

    return _af_sharedImageRequestOperationQueue;
}

- (AFHTTPRequestOperation *)af_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, @selector(af_imageRequestOperation));
}

- (void)af_setImageRequestOperation:(AFHTTPRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, @selector(af_imageRequestOperation), imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -
LoginInfo *loginInfo;
dispatch_queue_t queue;
@implementation UIImageView (AFNetworking)

@dynamic imageResponseSerializer;

+ (id <AFImageCache>)sharedImageCache {
    static AFImageCache *_af_defaultImageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _af_defaultImageCache = [[AFImageCache alloc] init];

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_af_defaultImageCache removeAllObjects];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"customerClearImageCache" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_af_defaultImageCache removeAllObjects];
        }];
        
            loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
            queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        
    });

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, @selector(sharedImageCache)) ?: _af_defaultImageCache;
#pragma clang diagnostic pop
}

+ (void)setSharedImageCache:(id<AFImageCache>)imageCache {
    objc_setAssociatedObject(self, @selector(sharedImageCache), imageCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id <AFURLResponseSerialization>)imageResponseSerializer {
    static id <AFURLResponseSerialization> _af_defaultImageResponseSerializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_defaultImageResponseSerializer = [AFImageResponseSerializer serializer];
    });

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    return objc_getAssociatedObject(self, @selector(imageResponseSerializer)) ?: _af_defaultImageResponseSerializer;
#pragma clang diagnostic pop
}

- (void)setImageResponseSerializer:(id <AFURLResponseSerialization>)serializer {
    objc_setAssociatedObject(self, @selector(imageResponseSerializer), serializer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url   size:(CGSize)size{
    [self setImageWithURL:url placeholderImage:nil size:size];
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
       size:(CGSize)size
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil size:size data:nil tempData:nil];
}
-(void)loadlocalImage:(NSString *)name size:(CGSize)size setCenter:(BOOL)flag{

//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    static dispatch_once_t once;
    static const int max_in_flight = 1;  // Also try 4, 8, and maybe some other numbers
    static dispatch_semaphore_t limit = NULL;
    dispatch_once(&once, ^{
        limit = dispatch_semaphore_create(max_in_flight);
    });
//    dispatch_async(queue, ^{
//        dispatch_semaphore_wait(limit, DISPATCH_TIME_FOREVER);
//        UIImage * result = [UIImage imageWithContentsOfFile:furl];
//        if(!flag)
//        result = [result resizedImage:result.size interpolationQuality: kCGInterpolationHigh];
//        else
//        result = [result resizedCenterImage:size interpolationQuality:kCGInterpolationHigh];
//        if(loginInfo.isMirror)
//            result = [UIImage imageWithCGImage:result.CGImage
//                                           scale:result.scale
//                                     orientation:UIImageOrientationUpMirrored];
//
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [self setImage:result];
//        });
//        dispatch_semaphore_signal(limit);
//    });
    
 //   dispatch_async(http_request_operation_processing_queue(), ^{
     
                dispatch_group_async(http_request_operation_completion_group(),queue, ^{
                    
                     dispatch_semaphore_wait(limit, DISPATCH_TIME_FOREVER);
                    
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString *furl = [NSString stringWithFormat:@"%@/%@",documentsDirectory,name];
                    
                  __block  UIImage *result = [UIImage imageWithContentsOfFile:furl];
                    
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
//                                if(!flag)
//                                    result = [result resizedImage:result.size interpolationQuality: kCGInterpolationHigh];
//                                else
//                                    result = [result resizedCenterImage:size interpolationQuality:kCGInterpolationHigh];
                                if(loginInfo.isMirror)
                                    result = [UIImage imageWithCGImage:result.CGImage
                                                                 scale:result.scale
                                                           orientation:UIImageOrientationUpMirrored];
                                

                            
                                [self setImage:result];
                                dispatch_semaphore_signal(limit);
                           });

                 //   [self performSelector:@selector(setImage:) withObject:result afterDelay:0.0];
                //    [self performSelectorInBackground:@selector(setImageMethod:) withObject:result];

                    
               });
          //    });

    
    
}

-(void)loadlocalCollocationImage:(NSString *)name size:(CGSize)size{
    
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    static dispatch_once_t once;
    static const int max_in_flight = 2;  // Also try 4, 8, and maybe some other numbers
    static dispatch_semaphore_t limit = NULL;
    dispatch_once(&once, ^{
        limit = dispatch_semaphore_create(max_in_flight);
    });

    
    dispatch_async(http_request_operation_processing_queue(), ^{
    
    dispatch_group_async(http_request_operation_completion_group(),queue, ^{
        
        dispatch_semaphore_wait(limit, DISPATCH_TIME_FOREVER);
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *furl = [NSString stringWithFormat:@"%@/%@",documentsDirectory,name];
        
        __block  UIImage *result = [UIImage imageWithContentsOfFile:furl];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //                                if(!flag)
            //                                    result = [result resizedImage:result.size interpolationQuality: kCGInterpolationHigh];
            //                                else
            //                                    result = [result resizedCenterImage:size interpolationQuality:kCGInterpolationHigh];
            if(loginInfo.isMirror)
                result = [UIImage imageWithCGImage:result.CGImage
                                             scale:result.scale
                                       orientation:UIImageOrientationUpMirrored];
            
            
            
            [self setImage:result];
            dispatch_semaphore_signal(limit);
        });
        
        
    });
        });
    
    
    
}


-(void)setImageMethod:(UIImage *)image{

    [self setImage:image];

}
- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
                          size:(CGSize) size data:(NSDictionary *)data tempData:(NSDictionary *)tempData
{
    
    [self cancelImageRequestOperation];

    UIImage *cachedImage = [loginInfo.allDownloadedImage objectForKey:[[urlRequest URL] absoluteString]];
    
    //[[[self class] sharedImageCache] cachedImageForRequest:urlRequest];
    
    if (cachedImage) {
        
        UIImage *tempCachedImage = cachedImage;
        
        if([loginInfo.loadingName isEqualToString:@"switchImage"] &&size.width ==66 && loginInfo.isMirror){
            
            tempCachedImage = [UIImage imageWithCGImage:cachedImage.CGImage];
            tempCachedImage = [UIImage imageWithCGImage:tempCachedImage.CGImage
                                             scale:tempCachedImage.scale
                                       orientation:UIImageOrientationUpMirrored];
        }
        
        
        if (success) {
            success(nil, nil, tempCachedImage);
        } else {
            self.image = tempCachedImage;
        }

        if(size.width ==67){
            [[NSNotificationCenter defaultCenter] postNotificationName:loginInfo.loadingName object:nil];
        }
        
        if([loginInfo.loadingName isEqualToString:@"switchImage"] &&size.width ==66){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:loginInfo.loadingName object:nil];
        }
        
        self.af_imageRequestOperation = nil;
    } else {
        if (placeholderImage) {
            self.image = placeholderImage;
        }
        
       if(size.width !=67 && size.width != 66)
       {
       UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [activityIndicator setCenter:self.center];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
           activityIndicator.tag = 134;
        [self addSubview:activityIndicator];
        
        [activityIndicator startAnimating];
       }
        
        __weak __typeof(self)weakSelf = self;
        self.af_imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        self.af_imageRequestOperation.responseSerializer = self.imageResponseSerializer;
        [self.af_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]]) {
                if (success) {
                    success(urlRequest, operation.response, responseObject);
                } else if (responseObject) {

                        @autoreleasepool {
                    
                    UIImage * thumbImage = responseObject;
                            
                    if(size.width >0 &&size.height>0){
                        
                    thumbImage = [thumbImage resizedImage:size interpolationQuality: kCGInterpolationLow];

                    }
                    else
                    {
                  //  UIGraphicsBeginImageContext(thumbImage.size);
                  //   UIGraphicsBeginImageContextWithOptions(thumbImage.size, NO, 0);
                 //    [thumbImage drawInRect:CGRectMake(0,0,thumbImage.size.width,thumbImage.size.height)];
                 //    thumbImage = UIGraphicsGetImageFromCurrentImageContext();
                 //    UIGraphicsEndImageContext();
    
                        
                   thumbImage = [thumbImage resizedImage:thumbImage.size interpolationQuality: kCGInterpolationLow];
                    }
               
                    UIImage *orginImage = [UIImage imageWithCGImage:thumbImage.CGImage];
                            
                    if([loginInfo.loadingName isEqualToString:@"switchImage"] &&size.width ==66 && loginInfo.isMirror){
                    
                        thumbImage = [UIImage imageWithCGImage:thumbImage.CGImage
                                                                    scale:thumbImage.scale
                                                              orientation:UIImageOrientationUpMirrored];
                    }
    
                            
                    if(size.width ==67){
                        
                        NSArray *data = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:strongSelf.tag],[NSNumber numberWithInt:thumbImage.size.width],[NSNumber numberWithInt:thumbImage.size.height], nil];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:loginInfo.loadingName object:data];
                    }
                    
                    if([loginInfo.loadingName isEqualToString:@"switchImage"] && size.width ==66){
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:loginInfo.loadingName object:nil];
                    }
                
                    strongSelf.image= thumbImage;
                     
                    if(!loginInfo.allDownloadedImage)
                        loginInfo.allDownloadedImage = [[NSMutableDictionary alloc] init];
                            
                            [loginInfo.allDownloadedImage setValue:orginImage forKey:[[urlRequest URL] absoluteString]];
                            
                    thumbImage = nil;
                            orginImage = nil;
                            
                    
                    if(size.width !=67 && size.width != 66){
                        
                        [[strongSelf viewWithTag:134] removeFromSuperview];
                    }
                }
                    
                    
                }
                
                if (operation == strongSelf.af_imageRequestOperation){
                        strongSelf.af_imageRequestOperation = nil;
                }
            }

            
       //     [[strongSelf class] sharedImageCache];
       //     [[[strongSelf class] sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
           
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if(data){
            
             [[NSNotificationCenter defaultCenter] postNotificationName:@"singleImageDownloadComplete" object:tempData];
            }
            
            if(size.width ==67){
                [[NSNotificationCenter defaultCenter] postNotificationName:loginInfo.loadingName object:nil];
            }
            
            if([loginInfo.loadingName isEqualToString:@"switchImage"]&&size.width ==66){
                
                [[NSNotificationCenter defaultCenter] postNotificationName:loginInfo.loadingName object:nil];
            }

            if(size.width !=67 && size.width != 66)
            {
                [[weakSelf viewWithTag:134] removeFromSuperview];
            }
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]]) {
                if (failure) {
                    failure(urlRequest, operation.response, error);
                }

                if (operation == strongSelf.af_imageRequestOperation){
                        strongSelf.af_imageRequestOperation = nil;
                }
            }
        }];

        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}
- (void)setCenterImageWithURL:(NSURL *)url  placeholderImage:(UIImage *)image  size:(CGSize)size{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setCenterImageWithURLRequest:request placeholderImage:image success:nil failure:nil size:size data:nil tempData:nil];
    
}
- (void)setCenterImageWithURL:(NSURL *)url   size:(CGSize)size{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    [self setCenterImageWithURLRequest:request placeholderImage:nil success:nil failure:nil size:size data:nil tempData:nil];

}
- (void)setCenterImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
                          size:(CGSize) size data:(NSDictionary *)data tempData:(NSDictionary *)tempData
{
    
    [self cancelImageRequestOperation];
    
     UIImage *cachedImage = [loginInfo.allDownloadedImage objectForKey:[[urlRequest URL] absoluteString]];
    
    //[[[self class] sharedImageCache] cachedImageForRequest:urlRequest];
    
    
    if (cachedImage) {
        
        if (success) {
            success(nil, nil, cachedImage);
        } else {
            self.image = cachedImage;
        }
        
        self.af_imageRequestOperation = nil;
    } else {
        if (placeholderImage) {
            self.image = placeholderImage;
        }
        
        if(size.width !=67 && size.width != 66)
        {
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
            [activityIndicator setCenter:self.center];
            [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            activityIndicator.tag = 134;
            [self addSubview:activityIndicator];
            
            [activityIndicator startAnimating];
        }
        
        __weak __typeof(self)weakSelf = self;
        self.af_imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        self.af_imageRequestOperation.responseSerializer = self.imageResponseSerializer;
        [self.af_imageRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]]) {
                if (success) {
                    success(urlRequest, operation.response, responseObject);
                } else if (responseObject) {
                    
                    @autoreleasepool {
                        
                        UIImage * thumbImage = responseObject;
                        
                        thumbImage = [thumbImage resizedCenterImage:size interpolationQuality: kCGInterpolationLow];
                                
                        if(size.width !=67 && size.width != 66)
                        {
                            [[strongSelf viewWithTag:134] removeFromSuperview];
                        }
                        
                        strongSelf.image= thumbImage;
                        
                        if(!loginInfo.allDownloadedImage)
                            loginInfo.allDownloadedImage = [[NSMutableDictionary alloc] init];
                        
                        [loginInfo.allDownloadedImage setValue:thumbImage forKey:[[urlRequest URL] absoluteString]];

                        
                        thumbImage = nil;
                    }
                }
                
                if (operation == strongSelf.af_imageRequestOperation){
                    strongSelf.af_imageRequestOperation = nil;
                }
            }
           
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.af_imageRequestOperation.request URL]]) {
                if (failure) {
                    failure(urlRequest, operation.response, error);
                }
                
                if (operation == strongSelf.af_imageRequestOperation){
                    strongSelf.af_imageRequestOperation = nil;
                }
            }
        }];
        
        [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
    }
}
-(void)saveImage:(NSArray *)data{
    
[downloadImage saveImage:data[0] image:data[1]];   //将已加载的图片保存到本地

}
- (void)cancelImageRequestOperation {
    [self.af_imageRequestOperation cancel];
    self.af_imageRequestOperation = nil;
}

@end

#pragma mark -

static inline NSString * AFImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation AFImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }

	return [self objectForKey:AFImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:AFImageCacheKeyFromURLRequest(request)];
    }
}

@end

#endif
