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
    //dispatch_queue_create([url cStringUsingEncoding:NSASCIIStringEncoding], NULL);
    //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    dispatch_async(queue, ^{
//
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *furl = [NSString stringWithFormat:@"%@/%@",documentsDirectory,url];
        image  = [UIImage imageWithContentsOfFile:furl];
    //    image =  [self resizeImageAtPath:url];

        dispatch_async(dispatch_get_main_queue(), ^{
        
            if(loginInfo.isMirror)
                image = [UIImage imageWithCGImage:image.CGImage
                                            scale:image.scale
                                      orientation:UIImageOrientationUpMirrored];
      //      image = [image resizedImage:image.size interpolationQuality: kCGInterpolationLow];

            
            
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
+(UIImage *)resizeImageAtPath:(NSString *)imagePath {
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
 //   CGImageWriteToFile(thumbnail, imagePath);
    return [UIImage imageWithCGImage:thumbnail];
}
//-(void) CGImageWriteToFile(CGImageRef image, NSString *path) {
//    CFURLRef url = (__bridge CFURLRef) [NSURL fileURLWithPath:path];
//    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
//    CGImageDestinationAddImage(destination, image, nil);
//    
//    if (!CGImageDestinationFinalize(destination)) {
//        NSLog(@"Failed to write image to %@", path);
//    }
//}
@end