#import "UIImage+Helpers.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (Helpers)
LoginInfo *loginInfo;
+ (void) loadFromURL: (NSString*) url callback:(void (^)(UIImage *image))callback {
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    
    __block  UIImage *image = [loginInfo.allDownloadedImage objectForKey:url];
    
    if(!image){
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    dispatch_async(queue, ^{

        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *furl = [NSString stringWithFormat:@"%@/%@",documentsDirectory,url];
     //   NSURL *imageURL = [NSURL fileURLWithPath:furl];
        image  = [UIImage imageWithContentsOfFile:furl];
     //   NSData *data = [NSData dataWithContentsOfURL:imageURL];
     //   image = [UIImage imageWithData:data];
//        image = [UIImage imageWithCGImage: [self MyCreateThumbnailImageFromData:data imageSize:image.size.width>image.size.height?image.size.width:image.size.height]];

        dispatch_async(dispatch_get_main_queue(), ^{
        
            if(loginInfo.isMirror)
                image = [UIImage imageWithCGImage:image.CGImage
                                            scale:image.scale
                                      orientation:UIImageOrientationUpMirrored];
         //   image = [image resizedImage:image.size interpolationQuality: kCGInterpolationLow];

//            if(!loginInfo.allDownloadedImage)
//                loginInfo.allDownloadedImage = [[NSMutableDictionary alloc] init];
//            
//            [loginInfo.allDownloadedImage setValue:image forKey:url];
   
              callback(image);
        });
    });
    }
    else{
    
      callback(image);
    }
}
+(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 60,60);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
+(void)resizeImageAtPath:(NSString *)imagePath {
    // Create the image source
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *furl = [NSString stringWithFormat:@"%@/%@",documentsDirectory,imagePath];
    NSData *imageData = [NSData dataWithContentsOfFile:furl];
    
    
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, nil);
    
    //CGImageSourceCreateWithURL((__bridge CFURLRef) [NSURL fileURLWithPath:imagePath], NULL);
    // Create thumbnail options
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(1024)
                                                           };
    // Generate the thumbnail
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options); 
    CFRelease(src);
    // Write the thumbnail at path
 //  CGImageWriteToFile(thumbnail, imagePath);
    [self CGImageWriteToFile:thumbnail path:furl];
 //   return [UIImage imageWithCGImage:thumbnail];
}
+(void)CGImageWriteToFile:(CGImageRef) image path:(NSString *)path{
//    CFURLRef url = (__bridge CFURLRef) [NSURL fileURLWithPath:path];
//    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
//    CGImageDestinationAddImage(destination, image, nil);
//    
//    if (!CGImageDestinationFinalize(destination)) {
//        NSLog(@"Failed to write image to %@", path);
//    }
}
+(CGImageRef)MyCreateThumbnailImageFromData:(NSData *)data imageSize:(int)imageSize
{
    CGImageRef        myThumbnailImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[3];
    CFTypeRef         myValues[3];
    CFNumberRef       thumbnailSize;
    
    // Create an image source from NSData; no options.
    myImageSource = CGImageSourceCreateWithData((CFDataRef)data,
                                                NULL);
    // Make sure the image source exists before continuing.
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    
    // Package the integer as a  CFNumber object. Using CFTypes allows you
    // to more easily create the options dictionary later.
    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    
    // Set up the thumbnail options.
    myKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    myValues[2] = (CFTypeRef)thumbnailSize;
    
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                   (const void **) myValues, 2,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   & kCFTypeDictionaryValueCallBacks);
    
    // Create the thumbnail image using the specified options.
    myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource,
                                                           0,
                                                           myOptions);
    // Release the options dictionary and the image source
    // when you no longer need them.
    CFRelease(thumbnailSize);
    CFRelease(myOptions);
    CFRelease(myImageSource);
    
    // Make sure the thumbnail image exists before continuing.
    if (myThumbnailImage == NULL){
        fprintf(stderr, "Thumbnail image not created from image source.");
        return NULL;
    }
    
    return myThumbnailImage;
}

@end