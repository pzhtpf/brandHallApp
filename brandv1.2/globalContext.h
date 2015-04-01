//
//  globalContext.h
//  brandv1.2
//
//  Created by Apple on 14-9-5.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface globalContext : NSObject
+(BOOL)netWorkStatus;
+(void)showAlertView:(NSString *)message;
+(int)GettingTheWiFiSignalStrength;
+(void)startDownloadThread;
+(void)downloadThreadByPlanId:(NSDictionary *)planData housesId:(NSString *)housesId;
+(void)addProgressingViewMethod:(NSString *)housesId;
+(BOOL)isLogin;
+(void)checkVersion;
+(void)saveDownloadData:(NSDictionary *)temp;
+(void)judgeHousesList;
+(void)addStatusBarNotification:(NSString *)text;
+(void)clearStatusNotification;
+(void)getBrandhallDetail;
+(void)settingBrandLogo:(UIImageView *)imageView nameLabel:(UILabel *)nameLabel;
+(void)downloadBrandLogoImage:(NSMutableDictionary *)argsData;
+(void)changeBrandId;
+(void)setCookies:(NSString *)userId;
+(BOOL)detectBrandIDIsChange;
+(NSString *)toPinYin:(NSString *)name;
@end
