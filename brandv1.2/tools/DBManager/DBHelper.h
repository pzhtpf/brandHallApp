//
//  DBHelper.h
//  gezlife
//
//  Created by Roc.Tian on 13-11-13.
//  Copyright (c) 2013年 GPM0-MAC-mini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBHelper : NSObject
+(NSString *)dataFilePath;     //得到数据库的路径
+(void)createOrOpenDataBase;
+(void)createTabel;
+(void)insert:(NSString *)sql;
+(void)delete;
+(NSString *)update:(NSString *)sql;
+(void) settingSaveToDB;
+(void) lanuchImageSaveToDB:(NSArray *)data;
+(void) loadUserInfo;
+(void) loadLanuchImageInfo;
+(void)createDownloadTabel;
+(void)saveDataToPlanTable:(NSDictionary *)data;
+(NSMutableDictionary *)getDataFromPlanTable:(int)type;
+(void)savePlanGoodsTable:(NSDictionary *)data housesId:(NSString *)housesId;
//+(void)saveDownloadingTable:(NSString *)houses_id plan_id:(NSString *)plan_id localImageName:(NSString *)localImageName
//                  image_url:(NSString *)image_url image_size:(NSString *)image_size type:(NSString *)type elementId:(NSString *)elementId productId:(NSString *)productId id:(NSString *)idStr status:(NSNumber *)status;
+(void)saveDownloadingTable:(NSMutableArray *)data;
+(NSMutableArray *)getUndownloadByPlanId:(NSString *) planId;
+(BOOL)updatePlanTable:(NSMutableDictionary *)data;
+(NSMutableArray *)getGoodsByPlanId:(NSString *) planId;
+(void)saveDataToDefaultTable:(NSArray *)dataArgs planId:(NSString *)planId angle:(NSString *)angle;
+(NSDictionary *)getDataToDefaultTable:(NSString *)planId angle:(NSString *)angle;
+(NSMutableArray *)getElement:(NSString *)planId layer:(NSString *)layer angle:(NSString *)angle;
+(BOOL)deleteByHousesId:(NSString *)housesId;
+(double)getTotal;
+(NSMutableArray *)getDetailByHousesId:(int)housesId;
+(NSMutableArray *)getDefaultByPlanId:(int)planId;
+(BOOL)updateVersion:(NSArray *)versions;
+(NSMutableDictionary *)getAllElement:(NSString *)planId  angle:(NSString *)angle;
+(BOOL)updateDownloadingTable:(NSNumber *)status localImageName:(NSString *)localImageName;
+(void)saveBrandDetailToDB:(NSDictionary *)data;
+(NSDictionary *)getBrandDetailFromDB;
@end
