//
//  EncryptUtil.h
//
//  Created by Wu Kurodo on 12-6-27.
//  Copyright (c) 2012年 Kurodo Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface EncryptUtil : NSObject

+ (NSString *)encryptWithText:(NSString *)sText;
+ (NSString *)decryptWithText:(NSString *)sText;
@end