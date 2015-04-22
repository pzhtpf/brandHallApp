 //
//  downloadImage.m
//  brandv1.2
//
//  Created by Apple on 14-9-22.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "downloadImage.h"
#import "AFHTTPRequestOperation.h"
#import "UIImage+Resize.h"
#import <objc/runtime.h>
#import <ImageIO/ImageIO.h>
@implementation downloadImage
+(void)downloadImage:(NSString *)path name:(NSString *)name{

    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:path,@"path",name,@"name", nil];
    
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(saveImageToLocal:) object:data];
    
    [thread start];
    

}
+(BOOL)saveImageToLocal:(NSDictionary *)data{

    UIImage *image = [self getImageFromURL:[data objectForKey:@"path"]];
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSLog(@"保存路径:%@",documentsDirectoryPath);
    
  // NSData *imageData = UIImagePNGRepresentation(image);
 //   NSString *str = [self contentTypeForImageData:imageData];
    
    NSArray *names = [[data objectForKey:@"name"] componentsSeparatedByString:@"/"];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:names[names.count-1] ];
    NSData* dataImage = UIImagePNGRepresentation(image);
    [dataImage writeToFile:path atomically:YES];
    
//  return  [self saveImage:image withFileName:[data objectForKey:@"name"] ofType:str inDirectory:documentsDirectoryPath];
    return true;
}
+(BOOL)saveImage:(NSString *)name image:(NSData*) data{

//    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
 //   NSLog(@"保存路径:%@",documentsDirectoryPath);
    
  //  NSData *imageData = UIImagePNGRepresentation(image);
//    NSString *str = [self contentTypeForImageData:data];
    
   NSArray *names = [name componentsSeparatedByString:@"/"];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:names[names.count-1]];
    
//    [self saveImageWithData:data andName:name];
 //  
//  UIImage *image = [UIImage imageWithData:data];
//  image = [image resizedImage:image.size interpolationQuality: kCGInterpolationLow];
    
// return  [self saveImage:image withFileName:names[names.count-1] ofType:str inDirectory:documentsDirectoryPath];
  return [data writeToFile:path atomically:YES];
  //  return true;
}
+ (void)saveImageWithData:(NSData*)jpeg andName:(NSString*)name
{
    
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(1024)
                                                           };
    
    CGImageSourceRef  source ;
    
    // Notice here how I use __bridge
    source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
    
    CFStringRef UTI = CGImageSourceGetType(source);
    
    NSMutableData *dest_data = [NSMutableData data];
    
    // And here I use it again
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
    
    CGImageDestinationAddImageFromSource(destination,source,0,options);
    
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success) {
        NSLog(@"***Could not create data from image destination ***");
    }
    
    // This only saves to the disk
    NSArray *names = [name componentsSeparatedByString:@"/"];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:names[names.count-1]];
    
    NSLog(@"%@",path);
//    NSError *error;
//    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
//        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    
    [dest_data writeToFile:path atomically:YES];
    
    
    
    //This is what im not sure if i should use
    CFRelease(destination);
    CFRelease(source);
    
}
+(UIImage *)getImageFromURL:(NSString *)fileURL {
    NSLog(@"%@:%@",@"执行图片下载函数",fileURL);
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

+(bool)saveImageWithImage:(UIImage *)image name:(NSString *)name{

    NSArray *names = [name componentsSeparatedByString:@"."];
    
    NSString *extension = names[names.count-1];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [self saveImage:image withFileName:name ofType:extension inDirectory:documentsDirectory];
}
+(bool) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath
{
    bool flag = false;
    
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        NSString *path = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", imageName]];
        [UIImagePNGRepresentation(image) writeToFile:path options:NSAtomicWrite error:nil];
        flag = true;
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imageName]] options:NSAtomicWrite error:nil];
        flag = true;
    } else {
        //ALog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
        NSLog(@"文件后缀不认识");
        
        
    }
    
    image = nil;
    return flag;
}


+(UIImage *) loadImage:(NSString *)fileName inDirectory:(NSString *)directoryPath {
    UIImage * result = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", directoryPath, fileName]];
    
    return result;
}
+(NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"jpg";
        case 0x89:
            return @"png";
        case 0x47:
            return @"gif";
        case 0x49:
            break;
        case 0x42:
            return @"bmp";
        case 0x4D:
            return @"tiff";
    }
    return nil;
}

+(void)removeImage:(NSString*)fileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,   YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSError *error = nil;
    
     if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
    
    if(![fileManager removeItemAtPath: fullPath error:&error]) {
        NSLog(@"Delete failed:%@", error);
    } else {
        NSLog(@"image removed: %@", fullPath);
    }
    
}
}

@end


