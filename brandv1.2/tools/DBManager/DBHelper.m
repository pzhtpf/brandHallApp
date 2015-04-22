//
//  DBHelper.m
//  gaia
//
//  Created by GPM0-MAC-mini on 13-11-13.
//  Copyright (c) 2013年 GPM0-MAC-mini. All rights reserved.
//

#import "DBHelper.h"
#import "LoginInfo.h"
#import "StockData.h"
#import <sqlite3.h>
#import "downloadImage.h"
#import "Define.h"
#import "AsyncImageDownloader.h"
#import "UIImage+Helpers.h"

@implementation DBHelper
sqlite3* database;
char * errorMsg;
LoginInfo *loginInfo;
+ (NSString *)dataFilePath     //得到数据库的路径
{
	//在documentsDirectory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"brand.sqlite"];
	
}

+(void)createOrOpenDataBase{
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		//sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
        [self createTabel];
	}
}

+(void)createTabel{
    NSString *createTableSql=@"create table if not exists brand_user(rowid integer primary key,UserName text,Password text,AutoLogin integer,remeberPassword integer,Domain text,isPush integer);";
    
    NSString *createLanuchTableSql=@"create table if not exists lanuch_image(rowid integer primary key,path text,property1 text,property2 text);";
    
    if(sqlite3_exec(database, [createTableSql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK){
        sqlite3_close(database);
    }
    
    if(sqlite3_exec(database, [createLanuchTableSql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK){
        sqlite3_close(database);
    }
}

+(void)insert:(NSString *)sql{
    
}

+(void)delete{}

+(NSString *)update:(NSString *)sql{
    [self createOrOpenDataBase];
    sqlite3_stmt   *statement = NULL;
    if(sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK){
        if(sqlite3_step(statement)==SQLITE_DONE)
            return @"保存成功";
        else
            return  @"保存失败";
    }
    else
        return  @"保存失败";
}
+(void)settingSaveToDB{
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    //  NSString *dbpwd = [[EncryptUtil encryptWithText:loginInfo.password] copy];
    NSString *dbpwd = loginInfo.password;
    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSLog(@"Failed to open database");
        
	}
    
    char * errorMsg;
    NSString *createTableSql=@"create table if not exists brand_user(userId text primary key,UserName text,Password text,AutoLogin integer,remeberPassword integer,Domain text,isPush integer,enableDownload int,portrait text,type text,account text);";
    if(sqlite3_exec(database, [createTableSql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK){
        sqlite3_close(database);
    }
    sqlite3_stmt *stmt;
    
    NSString *sql=@"delete from brand_user";
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
    }
    
    char *update = "insert or replace into brand_user (rowid,UserName, Password, AutoLogin,remeberPassword, Domain, isPush,enableDownload,portrait,type,account) values(?,?,?,?,?,?,?,?,?,?,?);";
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [loginInfo.userId>0?loginInfo.userId:@"" UTF8String], -1,nil);
        sqlite3_bind_text(stmt, 2, [loginInfo.userName>0?loginInfo.userName:@"" UTF8String], -1,nil);
        //[self showAlertView:tf_username.text.length>0?tf_username.text:@""];
        sqlite3_bind_text(stmt, 3, [dbpwd.length>0?dbpwd:@"" UTF8String], -1,nil);
        sqlite3_bind_int(stmt, 4,(loginInfo.isAutoLogin)?1:0);
        sqlite3_bind_int(stmt, 5, (loginInfo.isPush)?1:0);
        sqlite3_bind_text(stmt, 6,[loginInfo.serverUrl>0? loginInfo.serverUrl:@"" UTF8String],-1,nil);
        sqlite3_bind_int(stmt, 8, loginInfo.enableDownload);
        sqlite3_bind_text(stmt, 9, [loginInfo.portrait>0?loginInfo.portrait:@"" UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 10,[loginInfo.userType>0?loginInfo.userType:@"" UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 10,[loginInfo.userType>0?loginInfo.userType:@"" UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 11,[loginInfo.userAccount>0?loginInfo.userAccount:@"" UTF8String],-1,nil);

        // NSAssert1(0, @"Error updating tables: %s", errorMsg);
        
    }
    if(sqlite3_step(stmt)!=SQLITE_DONE){
        //  [self showAlertView:NSLocalizedString(@"save_failed", nil)];
    }
    else{
        //  [self showAlertView:NSLocalizedString(@"saved_success", nil)];
        //if(loginInfo.lang != select_Picker_ItemNo){
        //loginInfo.lang = select_Picker_ItemNo;
        //   }
    }
    sqlite3_step(stmt);
    sqlite3_close(database);
        
}
+(void)saveBrandDetailToDB:(NSDictionary *)data{
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];

    
    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
        
    }
    
    
//    'id'=>"",
//    'name'=>'',//品牌馆名字
//    'logo_square'=>"",//正方形logo
//    'logo_rectangle'=>"",//长方形logo
//    'summary'=>"",品牌馆简介
    
    NSString *id = [data objectForKey:@"id"];
    NSString *name = [data objectForKey:@"name"];
    NSString *logo_app = [data objectForKey:@"logo_app"];
    NSString *local_logo_app = [data objectForKey:@"local_logo_app"];
    NSString *summary = [data objectForKey:@"summary"];
    
    loginInfo.brandName = name;
    loginInfo.brand_logo_app = local_logo_app;
    
    char * errorMsg;
    NSString *createTableSql=@"create table if not exists brand_detail(id text primary key,name text,logo_app text,local_logo_app text,summary text);";
    if(sqlite3_exec(database, [createTableSql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK){
        sqlite3_close(database);
    }
    sqlite3_stmt *stmt;
    
    NSString *sql=@"delete from brand_detail";
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
    }
    
    char *update = "insert or replace into brand_detail(id,name,logo_app,local_logo_app,summary) values(?,?,?,?,?);";
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [![id isKindOfClass:[NSNull class]]?id:@"" UTF8String], -1,nil);
        sqlite3_bind_text(stmt, 2, [![name isKindOfClass:[NSNull class]]?name:@"" UTF8String], -1,nil);
         sqlite3_bind_text(stmt, 3, [![logo_app isKindOfClass:[NSNull class]]?logo_app:@"" UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 4, [![local_logo_app isKindOfClass:[NSNull class]]?local_logo_app:@"" UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 5,[![summary isKindOfClass:[NSNull class]]?summary:@"" UTF8String],-1,nil);
        
        // NSAssert1(0, @"Error updating tables: %s", errorMsg);
        
    }
    if(sqlite3_step(stmt)!=SQLITE_DONE){
        //  [self showAlertView:NSLocalizedString(@"save_failed", nil)];
    }
    else{
        //  [self showAlertView:NSLocalizedString(@"saved_success", nil)];
        //if(loginInfo.lang != select_Picker_ItemNo){
        //loginInfo.lang = select_Picker_ItemNo;
        //   }
    }
    sqlite3_step(stmt);
    sqlite3_close(database);
}
+(NSDictionary *)getBrandDetailFromDB{

    NSDictionary *data =[[NSDictionary alloc] init];
    
    sqlite3_stmt *statement=nil;
    sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    if(loginInfo==nil)
        loginInfo = [[LoginInfo alloc] init];
    NSString *query =@"SELECT * FROM brand_detail";
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *rowData0 = (char *)sqlite3_column_text(statement, 0);   //id
            char *rowData1 = (char *)sqlite3_column_text(statement, 1);   //name
            char *rowData2 = (char *)sqlite3_column_text(statement, 2);   //logo_app
            char *rowData3 = (char *)sqlite3_column_text(statement, 3);   //local_logo_app
            char *rowData4 = (char *)sqlite3_column_text(statement, 6);   //summary
            
            NSString *id = [rowData0== NULL?@"":[NSString  stringWithUTF8String:rowData0] copy];
            NSString *name = [rowData1== NULL?@"":[NSString  stringWithUTF8String:rowData1] copy];
            NSString *logo_app = [rowData2== NULL?@"":[NSString  stringWithUTF8String:rowData2] copy];
            NSString *local_logo_app = [rowData3== NULL?@"":[NSString  stringWithUTF8String:rowData3] copy];
            NSString *summary = [rowData4== NULL?@"":[NSString  stringWithUTF8String:rowData4] copy];
        
            data = @{@"id":id,@"name":name,@"logo_app":logo_app,@"local_logo_app":local_logo_app,@"summary":summary};
            
            
        }
        
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    [[StockData getSingleton] setValue:loginInfo  forKey:@"loginInfo"];
    
    return data;
}
+(void) lanuchImageSaveToDB:(NSArray *)dataArray{
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    //   NSString *dbpwd = [[EncryptUtil encryptWithText:loginInfo.password] copy];
    
    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
        
	}
    char * errorMsg;
    
    NSString *createLanuchTableSql=@"create table if not exists lanuch_image(rowid integer primary key,path text,property1 text,property2 text);";
    
    if(sqlite3_exec(database, [createLanuchTableSql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK){
        sqlite3_close(database);
    }
    
    
    NSString *createLanuchTableHotSql=@"create table if not exists lanuch_image_hot(imageUrl text,url text,X int,Y int,width int,height int);";

    
    if(sqlite3_exec(database, [createLanuchTableHotSql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK){
        sqlite3_close(database);
    }
    else{
    
        NSLog(@"%@",@"创建成功");
    }

    
    sqlite3_stmt *stmt;
    
    NSString *sql=@"delete from lanuch_image";
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
    }
    
    NSString *sqlHot=@"delete from lanuch_image_hot";
    if (sqlite3_exec(database, [sqlHot UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
    }
    
    char *update = "insert or replace into lanuch_image (rowid,path, property1,property2) values(?,?,?,?);";
    
    for(int i =0;i<dataArray.count;i++){
        
        NSDictionary * data = dataArray[i];
        [self saveHot:[data objectForKey:@"data"] imageUrlArgs:[data objectForKey:@"imageUrl"]];
        
        if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK)
        {
            sqlite3_bind_int(stmt, 1, i);
            sqlite3_bind_text(stmt, 2, [[data objectForKey:@"imageUrl"]>0?[data objectForKey:@"imageUrl"]:@"" UTF8String], -1,nil);
            
        }
        if(sqlite3_step(stmt)!=SQLITE_DONE){
            
           NSLog(@"%@",@"启动页数据插入成功");
        }
        else{
            
           NSLog(@"%@",@"启动页数据插入成功");
        }
        
    }
    
    sqlite3_close(database);
    
    
//    for(int i =0;i<loginInfo.lanuchImages.count;i++){
//        
//        NSDictionary * data = loginInfo.lanuchImages[i];
//        [self saveHot:[data objectForKey:@"data"] imageUrl:[data objectForKey:@"imageUrl"]];
//
//    }
}

+(void)saveHot:(NSArray *)dataArray imageUrlArgs:(NSString *)imageUrlArgs{

    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
        
	}
    
    sqlite3_stmt *stmt;
    
    char *update = "insert or replace into lanuch_image_hot(imageUrl,url,X,Y,width,height) values(?,?,?,?,?,?);";
    
    NSLog(@"%@",dataArray);
    
    for(int i =0;i<dataArray.count;i++){
    
        NSDictionary *data =dataArray[i];
        
        
        if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(stmt, 1,[imageUrlArgs UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 2, [[data objectForKey:@"url"]>0?[data objectForKey:@"url"]:@"" UTF8String],-1,nil);
            sqlite3_bind_int(stmt, 3, [[data objectForKey:@"x"] intValue]);
            sqlite3_bind_int(stmt, 4, [[data objectForKey:@"y"] intValue]);
            sqlite3_bind_int(stmt, 5, [[data objectForKey:@"width"] intValue]);
            sqlite3_bind_int(stmt, 6, [[data objectForKey:@"height"] intValue]);
             NSLog(@"%d",[[data objectForKey:@"X"] intValue]);
        }
        
        if(sqlite3_step(stmt)!=SQLITE_DONE){
           
            NSLog(@"%@",@"插入失败");

        }
        else{
            NSLog(@"%@",@"插入成功");
        }
    
    }
    sqlite3_close(database);

}
+(void) loadLanuchImageInfo{
    //if setting 未設定//
	sqlite3_stmt *statement=nil;
	sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    if(loginInfo==nil){
        loginInfo = [[LoginInfo alloc] init];
    }
    
    NSDictionary *page1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"lanuchImage.png",@"imageUrl", nil];
    NSDictionary *page2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"lanuchImage.png",@"imageUrl", nil];
    
    loginInfo.lanuchImages = [[NSMutableArray alloc] initWithObjects:page1,page2, nil];
    
    NSMutableArray *tempData = [[NSMutableArray alloc] init];
    
    NSString *query =@"SELECT lanuch_image_hot.imageUrl,lanuch_image_hot.url,lanuch_image_hot.X,lanuch_image_hot.Y,lanuch_image_hot.width,lanuch_image_hot.height FROM lanuch_image_hot  LEFT OUTER join lanuch_image  on lanuch_image.path=lanuch_image_hot.imageUrl;";
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            
           int i = -1;
            
            NSMutableArray *temp = nil;
            
            char *rowData1 = (char *)sqlite3_column_text(statement, 0);
            NSString *path = [[NSString  stringWithUTF8String:rowData1] copy];
            
            for(int j=0;j<tempData.count;j++){
                NSDictionary *temp1 = tempData[j];
                if([[temp1 objectForKey:@"imageUrl"] isEqualToString:path]){
                
                    temp = [temp1 objectForKey:@"data"];
                    i =j;
                    break;
                }
            }
            
            if(!temp){
            
                temp = [[NSMutableArray alloc] init];
            }
            
            char *rowData4 = (char *)sqlite3_column_text(statement, 1);
            NSString *url = [[NSString  stringWithUTF8String:rowData4] copy];
            
            int rowData5 = sqlite3_column_int(statement, 2);
            NSNumber *X = [NSNumber numberWithInt:rowData5];
            
            int rowData6 = sqlite3_column_int(statement, 3);
            NSNumber *Y = [NSNumber numberWithInt:rowData6];
            
            int rowData7 = sqlite3_column_int(statement, 4);
            NSNumber *width = [NSNumber numberWithInt:rowData7];
            
            int rowData8 = sqlite3_column_int(statement, 5);
            NSNumber *height = [NSNumber numberWithInt:rowData8];
            
            NSDictionary *dataArgs = [[NSDictionary alloc] initWithObjectsAndKeys:url,@"url",X,@"X",Y,@"Y",width,@"width",height,@"height", nil];
            
            [temp addObject:dataArgs];
            
            NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:path,@"imageUrl",temp,@"data", nil];
            
            if(i!=-1)
            {
            tempData[i] = data;
            }
            else{
            
            [tempData addObject:data];
            }
		}
        
        
    }
    
    [loginInfo.lanuchImages addObjectsFromArray:tempData];
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    [[StockData getSingleton] setValue:loginInfo  forKey:@"loginInfo"];
    
}


+(void) loadUserInfo{
    //if setting 未設定//
	sqlite3_stmt *statement=nil;
	sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    if(loginInfo==nil)
        loginInfo = [[LoginInfo alloc] init];
    NSString *query =@"SELECT UserName,Password,AutoLogin,remeberPassword,Domain,enableDownload,portrait,type,account FROM brand_user";
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            char *rowData0 = (char *)sqlite3_column_text(statement, 0);
            char *rowData1 = (char *)sqlite3_column_text(statement, 1);
            int rowData2 = sqlite3_column_int(statement, 2);
            int rowData3 = sqlite3_column_int(statement, 3);
            char *rowData4 = (char *)sqlite3_column_text(statement, 4);
            int rowData5 = sqlite3_column_int(statement, 5);
            char *rowData6 = (char *)sqlite3_column_text(statement, 6);
            char *rowData7 = (char *)sqlite3_column_text(statement, 7);
            char *rowData8 = (char *)sqlite3_column_text(statement, 8);
            
            [loginInfo setUserName: [[NSString  stringWithUTF8String:rowData0] copy]];
            //解密
            // loginInfo .password = [[EncryptUtil decryptWithText:[NSString  stringWithUTF8String:rowData1]]copy];
            loginInfo .password = [[NSString  stringWithUTF8String:rowData1] copy];
            loginInfo .isAutoLogin = (rowData2==0)?NO:YES;
            loginInfo .isPush = (rowData3==1)?YES:NO;
            loginInfo.isLogin=loginInfo.isAutoLogin;
            loginInfo.enableDownload = rowData5;
            [loginInfo setPortrait: [rowData6== NULL?@"":[NSString  stringWithUTF8String:rowData6] copy]];
            [loginInfo setUserType: [rowData7== NULL?@"":[NSString  stringWithUTF8String:rowData7] copy]];
            [loginInfo setUserAccount: [rowData8== NULL?@"":[NSString  stringWithUTF8String:rowData8] copy]];
            
            if(rowData4!=NULL)
            {
                loginInfo.serverUrl = [[NSString  stringWithUTF8String:rowData4] copy];
            }
		}
        
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    [[StockData getSingleton] setValue:loginInfo  forKey:@"loginInfo"];
    
}
+(void)createDownloadTabel{

    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
        
	}
    char * errorMsg;
    
    NSString *createPlanTableSql=@"create table if not exists download_planTable(id text,housesId text,housesName text,planId text primary key,name text,imagePath text,localImageName text,goodsCount text,status text,isHigh int,remain text,total text,nowVersion text,latestVersion text,latestUpdateTime text,downloadTime text);";
    
    if(sqlite3_exec(database, [createPlanTableSql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK){
        sqlite3_close(database);
     //   NSLog(@"%@",&errorMsg);
    }
    else{
        
        NSLog(@"%@",@"创建成功");
    }

    
    
    NSString *createPlanDefaultTableSql=@"create table if not exists download_planDefaultTable(plan_id text,angle text,dapei_pic text,element_id text,hot_pic text,layer text,pic text,type int);";
    
    
    if(sqlite3_exec(database, [createPlanDefaultTableSql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK){
        sqlite3_close(database);
    }
    else{
        
        NSLog(@"%@",@"创建成功");
    }

    NSString *createPlanGoodsTableSql=@"create table if not exists download_planGoodsTable(plan_id text,element_id text,image_url text,image_size text,name text,disprice text,price text,dapei_pic text,dapei_pic_size text,hot_pic text,hot_pic_size text,product_img text,product_img_size text,product_id text,layer text);";
    
    
    if(sqlite3_exec(database, [createPlanGoodsTableSql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK){
        sqlite3_close(database);
    }
    else{
        
        NSLog(@"%@",@"创建成功");
    }

    NSString *createDownloadingTableSql=@"create table if not exists download_downloadingTable(id text primary key, houses_id text,plan_id text,element_id  text,product_id text,localImageName text,image_url text,image_size text,type text,status int);";
    
    
    if(sqlite3_exec(database, [createDownloadingTableSql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK){
        sqlite3_close(database);
    }
    else{
        
        NSLog(@"%@",@"创建成功");
    }

    sqlite3_close(database);
}
+(void)saveDataToPlanTable:(NSDictionary *)dataTotal{

    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
        
	}
    
    sqlite3_stmt *stmt = nil;
    
    NSString *housesId = [dataTotal objectForKey:@"housesId"];
    NSString *housesName = [dataTotal objectForKey:@"housesName"];
    int isHigh = [[dataTotal objectForKey:@"isHigh"] intValue];
    NSMutableArray *dataArray = [dataTotal objectForKey:@"data"];
    
    
    char *update = "insert or replace into download_planTable (housesId,housesName,planId,name,imagePath,localImageName,goodsCount,status,isHigh,remain,total,id,nowVersion,latestVersion,latestUpdateTime,downloadTime) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
    
    NSString *id = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];;
    
    for(int i =0;i<dataArray.count;i++){
        
        NSDictionary *data = dataArray[i];
        
        NSString *imagePathTemp = [data objectForKey:@"imageUrl"];
        NSArray *names =[imagePathTemp componentsSeparatedByString:@"/"];
        NSString *localImageName = [NSString stringWithFormat:@"%@%@",@"planTable",names[names.count-1]];

        
        if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK)
        {
            
            
            sqlite3_bind_text(stmt, 1,[housesId UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 2,[housesName UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 3, [[data objectForKey:@"planId"] UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 4, [[data objectForKey:@"name"]  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 5, [[data objectForKey:@"imageUrl"]  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 6, [localImageName UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 7, [[data objectForKey:@"goodsCount"]  UTF8String],-1,nil);
            
            if([data objectForKey:@"status"])
                
            sqlite3_bind_int(stmt, 8,[[data objectForKey:@"status"] intValue]);
            
            else
            sqlite3_bind_int(stmt, 8,1);

            sqlite3_bind_int(stmt, 9,isHigh);
            sqlite3_bind_text(stmt, 10, [[data objectForKey:@"remain"]  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 11, [[data objectForKey:@"total"]  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 12, [id  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 13, [[data objectForKey:@"nowVersion"]  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 14, [[data objectForKey:@"latestVersion"]  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 15, [[data objectForKey:@"latestUpdateTime"]  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 16, [[dataTotal objectForKey:@"downloadTime"]  UTF8String],-1,nil);
        }
        
        if(sqlite3_step(stmt)!=SQLITE_DONE){
            
            NSLog(@"%@",@"插入PlanTable失败");
            
        }
        else{
            NSLog(@"%@",@"插入PlanTable成功");
            
              NSString *path = [NSString stringWithFormat:@"%@%@_S400",imageUrl,[data objectForKey:@"imageUrl"]];
            
             [self savePlanGoodsTable:data housesId:housesId];
          
            
            NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:path,@"path",localImageName,@"name", nil];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                AsyncImageDownloader *downloader = [[AsyncImageDownloader alloc] initWithMediaURL:path data:data tempData:nil successBlock:^(UIImage *image,NSDictionary *data,NSDictionary *dataTemp){
                    
                    
                    if(loginInfo.progressArray){
                        
                        UIView *tempView = [loginInfo.progressArray objectForKey:housesId];
                        NSArray *subViews = [tempView subviews];
                     
                        
                        for (int i =0; i<subViews.count;i++) {
                            UIView *view = subViews[i];
                            if([view isKindOfClass:[UIImageView class]]){
                            
                                UIImageView *imageView = (UIImageView *)view;
                                [imageView setImage:image];
                                break;
                            }
                        }
                    }
                    
                    NSLog(@"%@",@"封面图下载成功");
                    
                } failBlock:^(NSError *error){
                    
                    NSLog(@"%@",@"封面图下载失败");
                    
                }];
                
                [downloader startDownload];
               });

       
        }
        
    }
    sqlite3_reset(stmt);
    sqlite3_finalize(stmt);
    sqlite3_close(database);

}
+(void)savePlanGoodsTable:(NSDictionary *)data housesId:(NSString *)housesId{
    
    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
        
    }
    
    sqlite3_stmt *stmt = nil;
    
    char *update = "insert or replace into download_planGoodsTable (plan_id,element_id,image_url,image_size,name,disprice,price,dapei_pic,dapei_pic_size ,hot_pic ,hot_pic_size ,product_img ,product_img_size,product_id,layer) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
    
    NSArray *dataArrays = [[data objectForKey:@"productAllData"] objectForKey:@"elementData"];
    
    NSLog(@"%@",dataArrays);
    
    NSMutableArray *saveDownloadingData = [[NSMutableArray alloc] init];
    
    sqlite3_exec(database, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
    if(sqlite3_prepare(database, update, -1, &stmt, NULL) == SQLITE_OK)
    {
    
    for(NSDictionary *temp in dataArrays){
        
        //   NSLog(@"%@",temp);
        
        NSDictionary *goods = [temp objectForKey:@"productData"];
    
            
            NSString *planId =[data objectForKey:@"planId"];
            
            NSString *image_url = [temp objectForKey:@"image_url"];
            if(![image_url isKindOfClass:[NSNull class]]){
                NSArray *names =[image_url componentsSeparatedByString:@"/"];
                image_url = [NSString stringWithFormat:@"imageUrl%@",names[names.count-1]];
                image_url = [image_url stringByReplacingOccurrencesOfString:@"_" withString:@""];
            }
            else{
                
                image_url = @"";
            }
            
            NSString *dapei_pic = [temp objectForKey:@"dapei_pic"];
            if(![dapei_pic isKindOfClass:[NSNull class]]){
                NSArray *names1 =[dapei_pic componentsSeparatedByString:@"/"];
                dapei_pic = [NSString stringWithFormat:@"dapeiPic%@",names1[names1.count-1]];
                dapei_pic = [dapei_pic stringByReplacingOccurrencesOfString:@"_" withString:@""];
            }
            else{
                
                dapei_pic = @"";
            }
            
            
            
            NSString *hot_pic = [temp objectForKey:@"hot_pic"];
            if(![hot_pic isKindOfClass:[NSNull class]]){
                NSArray *names2 =[hot_pic componentsSeparatedByString:@"/"];
                hot_pic = [NSString stringWithFormat:@"hotPic%@",names2[names2.count-1]];
                hot_pic = [hot_pic stringByReplacingOccurrencesOfString:@"_" withString:@""];
            }
            else{
                
                hot_pic = @"";
            }
            
            
            
            NSString *product_image_url = [goods objectForKey:@"product_image_url"];
            if(![product_image_url isKindOfClass:[NSNull class]]){
                NSArray *names3 =[product_image_url componentsSeparatedByString:@"/"];
                product_image_url = [NSString stringWithFormat:@"productImageUrl%@",names3[names3.count-1]];
                product_image_url = [product_image_url stringByReplacingOccurrencesOfString:@"_" withString:@""];
            }
            else{
                
                product_image_url = @"";
            }
            
            
            
            sqlite3_bind_text(stmt, 1,[planId UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 2,[[temp objectForKey:@"id"] UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 3, [image_url UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 4, [[temp objectForKey:@"image_url_size"]  UTF8String],-1,nil);
            
//            [self saveDownloadingTable:housesId plan_id:planId localImageName:image_url image_url:[temp objectForKey:@"image_url"] image_size:[temp objectForKey:@"image_url_size"] type:@"imageUrl" elementId:[temp objectForKey:@"id"] productId:[goods objectForKey:@"product_id"] id:[self getId] status:0];
        
        NSDictionary *imageUrlDictionary = @{@"housesId":housesId,@"plan_id":planId,@"localImageName":image_url,@"image_url":[temp objectForKey:@"image_url"],@"image_size":[temp objectForKey:@"image_url_size"],@"type":@"imageUrl",@"elementId":[temp objectForKey:@"id"],@"productId":[goods objectForKey:@"product_id"],@"id":[self getId],@"status":@"0"};
        
        [saveDownloadingData addObject:imageUrlDictionary];
        
            sqlite3_bind_text(stmt, 5, [[goods objectForKey:@"name"]  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 6, [[goods objectForKey:@"disprice"] UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 7, [[goods objectForKey:@"price"]  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 8, [dapei_pic UTF8String],-1,nil);
            
            NSString *daPeiSize = [temp objectForKey:@"dapei_pic_ize"];
            
            if([daPeiSize isKindOfClass:[NSNull class]])
                daPeiSize = @"0";
            
            sqlite3_bind_text(stmt, 9, [daPeiSize UTF8String],-1,nil);
            
//            [self saveDownloadingTable:housesId plan_id:planId localImageName:dapei_pic image_url:[temp objectForKey:@"dapei_pic"] image_size:daPeiSize type:@"dapeiPic" elementId:[temp objectForKey:@"id"] productId:[goods objectForKey:@"product_id"] id:[self getId] status:0];
        
        NSDictionary *dapeiPicDictionary = @{@"housesId":housesId,@"plan_id":planId,@"localImageName":dapei_pic,@"image_url":[temp objectForKey:@"dapei_pic"],@"image_size":daPeiSize,@"type":@"dapeiPic",@"elementId":[temp objectForKey:@"id"],@"productId":[goods objectForKey:@"product_id"],@"id":[self getId],@"status":@"0"};
        
        [saveDownloadingData addObject:dapeiPicDictionary];
        
            sqlite3_bind_text(stmt, 10, [hot_pic UTF8String],-1,nil);
            
            NSString *hotSize = [temp objectForKey:@"hot_pic_size"];
            
            if([hotSize isKindOfClass:[NSNull class]])
                hotSize = @"0";
            
            
            sqlite3_bind_text(stmt, 11, [hotSize  UTF8String],-1,nil);
            
//            [self saveDownloadingTable:housesId plan_id:planId localImageName:hot_pic image_url:[temp objectForKey:@"hot_pic"] image_size:hotSize type:@"hotPic" elementId:[temp objectForKey:@"id"] productId:[goods objectForKey:@"product_id"] id:[self getId] status:0];
        
        
        NSDictionary *hotPicDictionary = @{@"housesId":housesId,@"plan_id":planId,@"localImageName":hot_pic,@"image_url":[temp objectForKey:@"hot_pic"],@"image_size":hotSize,@"type":@"hotPic",@"elementId":[temp objectForKey:@"id"],@"productId":[goods objectForKey:@"product_id"],@"id":[self getId],@"status":@"0"};
        
        [saveDownloadingData addObject:hotPicDictionary];
        
            sqlite3_bind_text(stmt, 12, [product_image_url UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 13, [[goods objectForKey:@"product_image_url_size"]  UTF8String],-1,nil);
            
//            [self saveDownloadingTable:housesId plan_id:planId localImageName:product_image_url image_url:[goods objectForKey:@"product_image_url"] image_size:[goods objectForKey:@"product_image_url_size"] type:@"productImageUrl" elementId:[temp objectForKey:@"id"] productId:[goods objectForKey:@"product_id"] id:[self getId] status:0];
        
        
        NSDictionary *productImageUrlDictionary = @{@"housesId":housesId,@"plan_id":planId,@"localImageName":product_image_url,@"image_url":[goods objectForKey:@"product_image_url"],@"image_size":[goods objectForKey:@"product_image_url_size"],@"type":@"productImageUrl",@"elementId":[temp objectForKey:@"id"],@"productId":[goods objectForKey:@"product_id"],@"id":[self getId],@"status":@"0"};
        
        [saveDownloadingData addObject:productImageUrlDictionary];
        
            sqlite3_bind_text(stmt, 14, [[goods objectForKey:@"product_id"]  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 15, [[temp objectForKey:@"layer"]  UTF8String],-1,nil);
    
        
        if (sqlite3_step(stmt) != SQLITE_DONE) NSLog(@"DB not updated. Error: %s",sqlite3_errmsg(database));
        if (sqlite3_reset(stmt) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
    }
    }
    if (sqlite3_finalize(stmt) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
    if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
    sqlite3_close(database);
    
    
    [self saveDownloadingTable:saveDownloadingData];
}

+(void)saveDownloadingTable:(NSMutableArray *)data{
    
    
    
    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(@"%@", @"Failed to open database");
        
    }
    
    sqlite3_stmt *stmt;
    
    char *update = "insert or replace into download_downloadingTable(houses_id,plan_id,element_id,product_id,localImageName,image_url,image_size,type,status,id) values (?,?,?,?,?,?,?,?,?,?);";
    
    
    sqlite3_exec(database, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
    if(sqlite3_prepare(database, update, -1, &stmt, NULL) == SQLITE_OK)
    {
        
        
        for (NSDictionary *temp in data) {
        
        NSString *houses_id = [temp objectForKey:@"housesId"];
        NSString *plan_id = [temp objectForKey:@"plan_id"];
        NSString *elementId = [temp objectForKey:@"elementId"];
        NSString *productId = [temp objectForKey:@"productId"];
        NSString *localImageName = [temp objectForKey:@"localImageName"];
        NSString *image_url = [temp objectForKey:@"image_url"];
        NSString *image_size = [temp objectForKey:@"image_size"];
        NSString *type = [temp objectForKey:@"type"];
        NSString *status = [temp objectForKey:@"status"];
        NSString *idStr = [temp objectForKey:@"id"];
            
        sqlite3_bind_text(stmt, 1,[houses_id UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 2,[plan_id UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 3, [elementId UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 4, [productId  UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 5, [localImageName UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 6, [image_url  UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 7, [image_size  UTF8String],-1,nil);
        sqlite3_bind_text(stmt, 8, [type UTF8String],-1,nil);
        sqlite3_bind_int(stmt, 9, [status intValue]);
        sqlite3_bind_text(stmt,10, [idStr UTF8String],-1,nil);

            if (sqlite3_step(stmt) != SQLITE_DONE) NSLog(@"DB not updated. Error: %s",sqlite3_errmsg(database));
            if (sqlite3_reset(stmt) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
        }
        
    }
    
    if (sqlite3_finalize(stmt) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
    if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
    sqlite3_close(database);
    
}
+(void)saveDataToDefaultTable:(NSArray *)dataArgs planId:(NSString *)planId angle:(NSString *)angle{
    
    
    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
        
    }
    
    sqlite3_stmt *stmt =nil;
    
    NSString *maopeiPath=@"";
    NSString *pic = @"";
    
    NSMutableArray *dataSaveing = [[NSMutableArray alloc] init];
    
    if(dataArgs.count>0){
        
        
        
        NSDictionary *data = dataArgs[0];
        
        pic = [data objectForKey:@"pic"];
        maopeiPath = [data objectForKey:@"pic"];;
        
        if(![pic isKindOfClass:[NSNull class]]){
            NSArray *names2 =[pic componentsSeparatedByString:@"/"];
            pic = [NSString stringWithFormat:@"pic%@",names2[names2.count-1]];
        }
        else{
            
            pic = @"";
        }
        
        
        maopeiPath = [imageUrl stringByAppendingString:maopeiPath];
        
        // [downloadImage downloadImage:maopeiPath name:pic];
        
        
        NSDictionary *dataTemp = [[NSDictionary alloc] initWithObjectsAndKeys:maopeiPath,@"path",pic,@"name", nil];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            AsyncImageDownloader *downloader = [[AsyncImageDownloader alloc] initWithMediaURL:maopeiPath data:dataTemp tempData:nil successBlock:^(UIImage *image,NSDictionary *data,NSDictionary *dataTemp){
                
                NSLog(@"%@",@"毛坯房下载成功");
                
            } failBlock:^(NSError *error){
                
                NSLog(@"%@",@"毛坯房下载失败");
            }];
            
            [downloader startDownload];
        });
        
        
    }
    
    // create table if not exists download_planDefaultTable(plan_id text,angle text,dapei_pic text,element_id text,hot_pic text,layer text);";
    
    char *update = "insert or replace into download_planDefaultTable (plan_id,angle,dapei_pic,element_id,hot_pic,layer,pic,type) values (?,?,?,?,?,?,?,?);";
    
    sqlite3_exec(database, "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
    if(sqlite3_prepare(database, update, -1, &stmt, NULL) == SQLITE_OK)
    {
    
    for(int i =0;i<dataArgs.count;i++){
        
        NSDictionary *data = dataArgs[i];
        
        NSString *dapei_pic = [data objectForKey:@"dapei_pic"];
        
        if(![dapei_pic isKindOfClass:[NSNull class]]){
            NSArray *names1 =[dapei_pic componentsSeparatedByString:@"/"];
            dapei_pic = [NSString stringWithFormat:@"dapeiPic%@",names1[names1.count-1]];
        }
        else{
            
            dapei_pic = @"";
        }
        
        
        
        NSString *hot_pic = [data objectForKey:@"hot_pic"];
        if(![hot_pic isKindOfClass:[NSNull class]]){
            NSArray *names2 =[hot_pic componentsSeparatedByString:@"/"];
            hot_pic = [NSString stringWithFormat:@"hotPic%@",names2[names2.count-1]];
        }
        else{
            
            hot_pic = @"";
        }
        
        NSString *element_id = [data objectForKey:@"element_id"];
        NSString *layer = [data objectForKey:@"layer"];
        
//        [self saveDownloadingTable:planId plan_id:planId localImageName:hot_pic image_url:[data objectForKey:@"hot_pic"] image_size:@"0" type:@"hotPic" elementId:@"" productId:@"" id:[self getId] status:0];
//        [self saveDownloadingTable:planId plan_id:planId localImageName:dapei_pic image_url:[data objectForKey:@"dapei_pic"] image_size:@"0" type:@"dapei_pic" elementId:@"" productId:@"" id:[self getId] status:0];
//        
    
        NSDictionary *hotPicDictionary  = @{@"housesId":planId,@"plan_id":planId,@"localImageName":hot_pic,@"image_url":[data objectForKey:@"hot_pic"],@"image_size":@"0",@"type":@"",@"elementId":@"",@"productId":@"",@"id":@"",@"status":@"0"};
        
        [dataSaveing addObject:hotPicDictionary ];
        
        NSDictionary *dapei_picDictionary  = @{@"housesId":planId,@"plan_id":planId,@"localImageName":dapei_pic,@"image_url":[data objectForKey:@"dapei_pic"],@"image_size":@"0",@"type":@"",@"elementId":@"",@"productId":@"",@"id":@"",@"status":@"0"};
        
        [dataSaveing addObject:dapei_picDictionary];
            
            
            sqlite3_bind_text(stmt, 1,[planId UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 2,[angle UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 3, [dapei_pic UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 4, [element_id  UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 5, [hot_pic UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 6, [layer UTF8String],-1,nil);
            sqlite3_bind_text(stmt, 7, [pic UTF8String],-1,nil);
            sqlite3_bind_int(stmt, 8, [[data objectForKey:@"type"] intValue]);
            
      
        
        if (sqlite3_step(stmt) != SQLITE_DONE) NSLog(@"DB not updated. Error: %s",sqlite3_errmsg(database));
        if (sqlite3_reset(stmt) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
        
    }
    
    }
    
    if (sqlite3_finalize(stmt) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
    if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
    sqlite3_close(database);
    
    
    [self saveDownloadingTable:dataSaveing];
}

+(NSString *)getId{
    
    NSString *idStr =@"";

    for(int i=0;i<12;i++){
    
    int value =arc4random_uniform(10);
    
        idStr =[NSString stringWithFormat:@"%@%d",idStr,value];
    }
    
    return  idStr;
}
//+(void)saveDownloadingTable:(NSString *)houses_id plan_id:(NSString *)plan_id localImageName:(NSString *)localImageName
//                  image_url:(NSString *)image_url image_size:(NSString *)image_size type:(NSString *)type elementId:(NSString *)elementId productId:(NSString *)productId id:(NSString *)idStr status:(NSNumber *)status{
//
//    
//    
//    sqlite3* database=nil;
//    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
//		sqlite3_close(database);
//		NSAssert(@"%@", @"Failed to open database");
//        
//	}
//    
//    sqlite3_stmt *stmt;
//    
//    char *update = "insert or replace into download_downloadingTable(houses_id,plan_id,element_id,product_id,localImageName,image_url,image_size,type,status,id) values (?,?,?,?,?,?,?,?,?,?);";
//    
//    
//        if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK)
//        {
//           
//            
//            
//            
//            sqlite3_bind_text(stmt, 1,[houses_id UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 2,[plan_id UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 3, [elementId UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 4, [productId  UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 5, [localImageName UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 6, [image_url  UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 7, [image_size  UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 8, [type UTF8String],-1,nil);
//            sqlite3_bind_int(stmt, 9, [status intValue]);
//            sqlite3_bind_text(stmt,10, [idStr UTF8String],-1,nil);
//            
//        }
//        
//        if(sqlite3_step(stmt)!=SQLITE_DONE){
//            
//            NSLog(@"%@",@"插入失败");
//            
//        }
//        else{
//            NSLog(@"%@",@"插入成功");
//        }
//        
//
//    sqlite3_reset(stmt);
//    sqlite3_finalize(stmt);
//    sqlite3_close(database);
//
//}
+(BOOL)updateDownloadingTable:(NSNumber *)status localImageName:(NSString *)localImageName{

    bool flag  = false;
    
    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(@"%@", @"Failed to open database");
        
    }
    
    
    NSString *update =[NSString stringWithFormat:@"update download_downloadingTable set status =%d where localImageName = '%@';",[status intValue],localImageName];
    
    if (sqlite3_exec(database, [update UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
        flag = true;
    }
    
    sqlite3_close(database);
   
    return flag;
}
+(NSMutableDictionary *)getDataFromPlanTable:(int)type{

    sqlite3_stmt *statement=nil;
	sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    if(loginInfo==nil)
        loginInfo = [[LoginInfo alloc] init];
    NSString *query =@"SELECT * FROM download_planTable ORDER BY id";
    
    if(type ==1){
    
        query =@"SELECT * FROM download_planTable where status = 2 or status = 1 ORDER BY status DESC";

    }
    else if(type>1){
    
        query =[NSString stringWithFormat: @"SELECT * FROM download_planTable where housesId ='%d' ORDER BY id",type];
        
    }
    else if(type==-3){
        
        query =@"SELECT * FROM download_planTable where status = 3";
        
    }
    
    NSMutableDictionary *dataFromPlanTable = [[NSMutableDictionary alloc] init];
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            char *rowData = (char *)sqlite3_column_text(statement, 0);
            char *rowData0 = (char *)sqlite3_column_text(statement, 1);
            char *rowData1 = (char *)sqlite3_column_text(statement, 2);
            char *rowData2 = (char *)sqlite3_column_text(statement, 3);
            char *rowData3 = (char *)sqlite3_column_text(statement, 4);
            char *rowData4 = (char *)sqlite3_column_text(statement, 5);
            char *rowData5 = (char *)sqlite3_column_text(statement, 6);
            char *rowData6 = (char *)sqlite3_column_text(statement, 7);
            int status = sqlite3_column_int(statement, 8);
            int isHigh = sqlite3_column_int(statement, 9);
            char *rowData9 = (char *)sqlite3_column_text(statement, 10);
            char *rowData10 = (char *)sqlite3_column_text(statement, 11);
         //   nowVersion text,latestVersion text,latestUpdateTime
            char *rowData11 = (char *)sqlite3_column_text(statement, 12);
            char *rowData12 = (char *)sqlite3_column_text(statement, 13);
            char *rowData13 = (char *)sqlite3_column_text(statement, 14);
            char *rowData14 = (char *)sqlite3_column_text(statement, 15);
        //    ,,name,,,,status,isHigh,,
            NSString *id = rowData==NULL?@"":[[NSString  stringWithUTF8String:rowData] copy];
            NSString *housesId = [[NSString  stringWithUTF8String:rowData0] copy];
            NSString *housesName = [[NSString  stringWithUTF8String:rowData1] copy];
            NSString *planId = [[NSString  stringWithUTF8String:rowData2] copy];
            NSString *name = [[NSString  stringWithUTF8String:rowData3] copy];
            NSString *imagePath = [[NSString  stringWithUTF8String:rowData4] copy];
            NSString *localImageName = [[NSString  stringWithUTF8String:rowData5] copy];
            NSString *goodsCount = [[NSString  stringWithUTF8String:rowData6] copy];
            NSString *remain = [[NSString  stringWithUTF8String:rowData9] copy];
            NSString *total = [[NSString  stringWithUTF8String:rowData10] copy];
            NSString *nowVersion = [[NSString  stringWithUTF8String:rowData11] copy];
            NSString *latestVersion = [[NSString  stringWithUTF8String:rowData12] copy];
            NSString *latestUpdateTime = [[NSString  stringWithUTF8String:rowData13] copy];
            NSString *downloadTime =rowData14==NULL?@"": [[NSString  stringWithUTF8String:rowData14] copy];
            
            NSMutableDictionary *temp = [dataFromPlanTable objectForKey:housesId];
            if(!temp){
            
                temp = [[NSMutableDictionary alloc] init];
                [temp setValue:id forKey:@"id"];
                [temp setValue:housesId forKey:@"housesId"];
                [temp setValue:housesName forKey:@"housesName"];
                [temp setValue:downloadTime forKey:@"downloadTime"];

                
                NSMutableDictionary *planTemp = [[NSMutableDictionary alloc] init];
                [planTemp setValue:planId forKey:@"planId"];
                [planTemp setValue:name forKey:@"name"];
                [planTemp setValue:localImageName forKey:@"localImageName"];
                [planTemp setValue:imagePath forKey:@"imagePath"];
                [planTemp setValue:goodsCount forKey:@"goodsCount"];
                [planTemp setValue:total forKey:@"total"];
                [planTemp setValue:remain forKey:@"remain"];
                [planTemp setValue:[NSNumber numberWithInt:status] forKey:@"status"];
                [planTemp setValue:[NSNumber numberWithInt:isHigh] forKey:@"isHigh"];
                [planTemp setValue:imagePath forKey:@"imageUrl"];
                [planTemp setValue:nowVersion forKey:@"nowVersion"];
                [planTemp setValue:latestVersion forKey:@"latestVersion"];
                [planTemp setValue:latestUpdateTime forKey:@"latestUpdateTime"];
                
                NSMutableArray *planTempArray = [[NSMutableArray alloc] init];
                [planTempArray addObject:planTemp];
                [temp setValue:planTempArray forKey:@"data"];
                
                            }
            else{
            
                NSMutableDictionary *planTemp = [[NSMutableDictionary alloc] init];
                [temp setValue:id forKey:@"id"];
                [temp setValue:downloadTime forKey:@"downloadTime"];
                [planTemp setValue:planId forKey:@"planId"];
                [planTemp setValue:name forKey:@"name"];
                [planTemp setValue:localImageName forKey:@"localImageName"];
                [planTemp setValue:imagePath forKey:@"imagePath"];
                [planTemp setValue:goodsCount forKey:@"goodsCount"];
                [planTemp setValue:total forKey:@"total"];
                [planTemp setValue:remain forKey:@"remain"];
                [planTemp setValue:[NSNumber numberWithInt:status] forKey:@"status"];
                [planTemp setValue:[NSNumber numberWithInt:isHigh] forKey:@"isHigh"];
                [planTemp setValue:imagePath forKey:@"imageUrl"];
                [planTemp setValue:nowVersion forKey:@"nowVersion"];
                [planTemp setValue:latestVersion forKey:@"latestVersion"];
                [planTemp setValue:latestUpdateTime forKey:@"latestUpdateTime"];
                
                
                NSMutableArray *planTempArray = [temp objectForKey:@"data"];
                [planTempArray addObject:planTemp];
                
                [temp setValue:planTempArray forKey:@"data"];
                
             //   [dataFromPlanTable setValue:temp forKey:housesId];
            }
            
            [dataFromPlanTable setValue:temp forKey:housesId];
		}
        
        
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    if(type ==0){
    loginInfo.dataFromPlanTable = dataFromPlanTable;
    [[StockData getSingleton] setValue:loginInfo  forKey:@"loginInfo"];
    }
    
    return dataFromPlanTable;
}
+(NSMutableArray *)getUndownloadByPlanId:(NSString *) planId{

    sqlite3_stmt *statement=nil;
	sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
 
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM download_downloadingTable where plan_id ='%@' and status =0 and image_url != '0' ",planId] ;
    
    NSMutableArray  *dataArray = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
            
            char *rowData0 = (char *)sqlite3_column_text(statement, 0);
            char *rowData1 = (char *)sqlite3_column_text(statement, 1);
            char *rowData2 = (char *)sqlite3_column_text(statement, 2);
            char *rowData3 = (char *)sqlite3_column_text(statement, 3);
            char *rowData4 = (char *)sqlite3_column_text(statement, 4);
            char *rowData5 = (char *)sqlite3_column_text(statement, 5);
            char *rowData6 = (char *)sqlite3_column_text(statement, 6);
            char *rowData7 = (char *)sqlite3_column_text(statement, 7);
            int status = sqlite3_column_int(statement, 9);
            char *type = (char *)sqlite3_column_text(statement, 8);
            
            //    houses_id,,,,,type,status
            NSString *id =  [[NSString  stringWithUTF8String:rowData0] copy];
            NSString *housesId = [[NSString  stringWithUTF8String:rowData1] copy];
            NSString *plan_id = [[NSString  stringWithUTF8String:rowData2] copy];
            NSString *elementId = [[NSString  stringWithUTF8String:rowData3] copy];
            NSString *productId = [[NSString  stringWithUTF8String:rowData4] copy];
            NSString *localImageName = [[NSString  stringWithUTF8String:rowData5] copy];
            NSString *image_url = [[NSString  stringWithUTF8String:rowData6] copy];
            NSString *image_size = [[NSString  stringWithUTF8String:rowData7] copy];
            NSString *typeStr = [[NSString  stringWithUTF8String:type] copy];
            
              [temp setValue:housesId forKey:@"housesId"];
              [temp setValue:plan_id forKey:@"planId"];
              [temp setValue:localImageName forKey:@"localImageName"];
              [temp setValue:image_url forKey:@"imageUrl"];
              [temp setValue:image_size forKey:@"imageSize"];
              [temp setValue:[NSNumber numberWithInt:status] forKey:@"status"];
              [temp setValue:typeStr forKey:@"type"];
              [temp setValue:id forKey:@"id"];
              [temp setValue:elementId forKey:@"elementId"];
              [temp setValue:productId forKey:@"productId"];
            
            [dataArray addObject:temp];
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return dataArray;
}
+(BOOL)updatePlanTable:(NSMutableDictionary *)data{
    
         //   nowVersion text,latestVersion text,latestUpdateTime
    
//    char *update = "insert or replace into download_planTable (housesId,housesName,planId,name,imagePath,localImageName,goodsCount,status,isHigh,remain,total,id,nowVersion,latestVersion,latestUpdateTime) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
    BOOL flag = false;
    
    //    sqlite3_stmt *stmt;
        sqlite3* database=nil;
       if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
       }
    
    
    NSString *update =[NSString stringWithFormat:@"update download_planTable set latestVersion ='%@',status='%@',remain='%@',nowVersion='%@' where planId = '%@';",[data objectForKey:@"latestVersion"],[data objectForKey:@"status"],[data objectForKey:@"remain"],[data objectForKey:@"nowVersion"],[data objectForKey:@"planId"]];
    
    if (sqlite3_exec(database, [update UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
        flag = true;
    }
    
    sqlite3_close(database);
    return flag;
}
+(NSMutableArray *)getGoodsByPlanId:(NSString *) planId{
    
    sqlite3_stmt *statement=nil;
	sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    
    //plan_id text,element_id text,image_url text,image_size text,name text,disprice text,price text,dapei_pic text,dapei_pic_size text,hot_pic text,hot_pic_size text,product_img text,product_img_size text,product_id text,layer text)
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM download_planGoodsTable where plan_id ='%@'",planId] ;
    
    NSMutableArray  *dataArray = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
            
         //   char *rowData0 = (char *)sqlite3_column_text(statement, 0);   //plan_id
            char *rowData1 = (char *)sqlite3_column_text(statement, 1);   // id
            char *rowData2 = (char *)sqlite3_column_text(statement, 2);   //image
            char *rowData4 = (char *)sqlite3_column_text(statement, 4);   //name
            char *rowData5 = (char *)sqlite3_column_text(statement, 5);   //disprice
            char *rowData6 = (char *)sqlite3_column_text(statement, 6);   //price
         //   char *rowData7 = (char *)sqlite3_column_text(statement, 7);
                       //    houses_id,,,,,type,status
            NSString *id =  [[NSString  stringWithUTF8String:rowData1] copy];
            NSString *image = [[NSString  stringWithUTF8String:rowData2] copy];
            NSString *name = [[NSString  stringWithUTF8String:rowData4] copy];
            NSString *disprice = [[NSString  stringWithUTF8String:rowData5] copy];
            NSString *price = [[NSString  stringWithUTF8String:rowData6] copy];
         
            
            [temp setValue:id forKey:@"id"];
            [temp setValue:image forKey:@"image"];
            [temp setValue:name forKey:@"name"];
            [temp setValue:disprice forKey:@"disprice"];
            [temp setValue:price forKey:@"price"];
            
            
            [dataArray addObject:temp];
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return dataArray;
}

//+(void)saveDataToDefaultTable:(NSArray *)dataArgs planId:(NSString *)planId angle:(NSString *)angle{
//    
//    
//    sqlite3* database=nil;
//    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
//        sqlite3_close(database);
//        NSAssert(0, @"Failed to open database");
//        
//    }
//    
//    sqlite3_stmt *stmt =nil;
//    
//    NSString *maopeiPath=@"";
//    NSString *pic = @"";
//
//    
//    if(dataArgs.count>0){
//        
//       
//    
//        NSDictionary *data = dataArgs[0];
//        
//        pic = [data objectForKey:@"pic"];
//        maopeiPath = [data objectForKey:@"pic"];;
//        
//        if(![pic isKindOfClass:[NSNull class]]){
//            NSArray *names2 =[pic componentsSeparatedByString:@"/"];
//            pic = [NSString stringWithFormat:@"pic%@",names2[names2.count-1]];
//        }
//        else{
//            
//            pic = @"";
//        }
//
//      
//        maopeiPath = [imageUrl stringByAppendingString:maopeiPath];
//        
//        // [downloadImage downloadImage:maopeiPath name:pic];
//        
//        
//        NSDictionary *dataTemp = [[NSDictionary alloc] initWithObjectsAndKeys:maopeiPath,@"path",pic,@"name", nil];
//        
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            AsyncImageDownloader *downloader = [[AsyncImageDownloader alloc] initWithMediaURL:maopeiPath data:dataTemp tempData:nil successBlock:^(UIImage *image,NSDictionary *data,NSDictionary *dataTemp){
//                
//                NSLog(@"%@",@"毛坯房下载成功");
//                
//            } failBlock:^(NSError *error){
//                
//                  NSLog(@"%@",@"毛坯房下载失败");
//            }];
//            
//            [downloader startDownload];
//        });
//
//        
//    }
//    
//   // create table if not exists download_planDefaultTable(plan_id text,angle text,dapei_pic text,element_id text,hot_pic text,layer text);";
//    
//    char *update = "insert or replace into download_planDefaultTable (plan_id,angle,dapei_pic,element_id,hot_pic,layer,pic,type) values (?,?,?,?,?,?,?,?);";
//    
//    for(int i =0;i<dataArgs.count;i++){
//        
//        NSDictionary *data = dataArgs[i];
//        
//        NSString *dapei_pic = [data objectForKey:@"dapei_pic"];
//        
//        if(![dapei_pic isKindOfClass:[NSNull class]]){
//            NSArray *names1 =[dapei_pic componentsSeparatedByString:@"/"];
//            dapei_pic = [NSString stringWithFormat:@"dapeiPic%@",names1[names1.count-1]];
//        }
//        else{
//            
//            dapei_pic = @"";
//        }
//        
//        
//        
//        NSString *hot_pic = [data objectForKey:@"hot_pic"];
//        if(![hot_pic isKindOfClass:[NSNull class]]){
//            NSArray *names2 =[hot_pic componentsSeparatedByString:@"/"];
//            hot_pic = [NSString stringWithFormat:@"hotPic%@",names2[names2.count-1]];
//        }
//        else{
//            
//            hot_pic = @"";
//        }
//        
//        NSString *element_id = [data objectForKey:@"element_id"];
//        NSString *layer = [data objectForKey:@"layer"];
//        
//      [self saveDownloadingTable:planId plan_id:planId localImageName:hot_pic image_url:[data objectForKey:@"hot_pic"] image_size:@"0" type:@"hotPic" elementId:@"" productId:@"" id:[self getId] status:0];
//      [self saveDownloadingTable:planId plan_id:planId localImageName:dapei_pic image_url:[data objectForKey:@"dapei_pic"] image_size:@"0" type:@"dapei_pic" elementId:@"" productId:@"" id:[self getId] status:0];
//        
//        if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK)
//        {
//            
//            
//            sqlite3_bind_text(stmt, 1,[planId UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 2,[angle UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 3, [dapei_pic UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 4, [element_id  UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 5, [hot_pic UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 6, [layer UTF8String],-1,nil);
//            sqlite3_bind_text(stmt, 7, [pic UTF8String],-1,nil);
//            sqlite3_bind_int(stmt, 8, [[data objectForKey:@"type"] intValue]);
//
//        }
//        
//        if(sqlite3_step(stmt)!=SQLITE_DONE){
//            
//            NSLog(@"%@",@"插入默认数据失败");
//            
//        }
//        else{
//            NSLog(@"%@",@"插入默认数据成功");
//        }
//        
//    }
//    
//    sqlite3_reset(stmt);
//    sqlite3_finalize(stmt);
//    sqlite3_close(database);
//}

+(NSDictionary *)getDataToDefaultTable:(NSString *)planId angle:(NSString *)angle{
    
    sqlite3_stmt *statement=nil;
	sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    
  // plan_id,angle,dapei_pic,element_id,hot_pic,layer,pic) values (?,?,?,?,?,?,?)
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM download_planDefaultTable where plan_id ='%@' and angle ='%@'",planId,angle] ;
    
    NSMutableArray  *dataArray = [[NSMutableArray alloc] init];
    
    NSString *pic = @"";
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
            
         //   char *rowData0 = (char *)sqlite3_column_text(statement, 0);   //plan_id
         //   char *rowData1 = (char *)sqlite3_column_text(statement, 1);   // angle
            char *rowData2 = (char *)sqlite3_column_text(statement, 2);   //dapei_pic
            char *rowData3 = (char *)sqlite3_column_text(statement, 3);   //element_id
            char *rowData4 = (char *)sqlite3_column_text(statement, 4);   //hot_pic
            char *rowData5 = (char *)sqlite3_column_text(statement, 5);   //layer
            char *rowData6 = (char *)sqlite3_column_text(statement, 6);   //pic
            int type = sqlite3_column_int(statement, 7);   //type
            
   
            NSString *dapei_pic = [[NSString  stringWithUTF8String:rowData2] copy];
            NSString *element_id = [[NSString  stringWithUTF8String:rowData3] copy];
            NSString *hot_pic = [[NSString  stringWithUTF8String:rowData4] copy];
            NSString *layer = [[NSString  stringWithUTF8String:rowData5] copy];
            pic = [[NSString  stringWithUTF8String:rowData6] copy];

            [temp setValue:dapei_pic forKey:@"dapei_pic"];
            [temp setValue:element_id forKey:@"element_id"];
            [temp setValue:hot_pic forKey:@"hot_pic"];
            [temp setValue:layer forKey:@"layer"];
            [temp setValue:[NSNumber numberWithInt:type] forKey:@"type"];
            
            [dataArray addObject:temp];
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    NSMutableDictionary *tempQ = [[NSMutableDictionary alloc] init];
    [tempQ setValue:angle forKey:@"angle"];
     [tempQ setValue:dataArray forKey:@"data"];
     [tempQ setValue:pic forKey:@"pic"];
    
    NSArray *plan = [[NSArray alloc] initWithObjects:tempQ, nil];
    NSMutableDictionary *finalData = [[NSMutableDictionary alloc] init];
    [finalData setValue:plan forKey:@"plan"];
    [finalData setValue:@"112" forKey:@"space_id"];
    [finalData setValue:planId forKey:@"id"];
    
    return finalData;

}
+(NSMutableArray *)getElement:(NSString *)planId layer:(NSString *)layer angle:(NSString *)angle{
    
    sqlite3_stmt *statement=nil;
	sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
	}
    
    //plan_id text,element_id text,image_url text,image_size text,name text,disprice text,price text,dapei_pic text,dapei_pic_size text,hot_pic text,hot_pic_size text,product_img text,product_img_size text,product_id text,layer text)
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM download_planGoodsTable where plan_id ='%@' and layer='%@'",planId,layer] ;
    
    NSMutableArray  *dataArray = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
            
            //   char *rowData0 = (char *)sqlite3_column_text(statement, 0);   //plan_id
        //    char *rowData1 = (char *)sqlite3_column_text(statement, 1);   // id
            char *rowData8 = (char *)sqlite3_column_text(statement, 7);   //image
            char *rowData5 = (char *)sqlite3_column_text(statement, 4);   //name
            char *rowData7 = (char *)sqlite3_column_text(statement, 6);   //price
            char *rowData6 = (char *)sqlite3_column_text(statement, 5);   //disprice
      //      char *rowData12 = (char *)sqlite3_column_text(statement, 11);   //product_img
            char *rowData3 = (char *)sqlite3_column_text(statement, 2);   //product_img

//            NSString *thumb =  [[NSString  stringWithUTF8String:rowData12] copy];
//            
//            if([thumb isEqualToString:@"productImageUrl0"])
//                thumb =  [[NSString  stringWithUTF8String:rowData3] copy];
            
             NSString *thumb =  [[NSString  stringWithUTF8String:rowData3] copy];
            
            NSString *name = [[NSString  stringWithUTF8String:rowData5] copy];
            NSString *disprice = [[NSString  stringWithUTF8String:rowData6] copy];
            NSString *price = [[NSString  stringWithUTF8String:rowData7] copy];
            NSString *dapei = [[NSString  stringWithUTF8String:rowData8] copy];
            
            
            [temp setValue:thumb forKey:@"thumb"];
            [temp setValue:name forKey:@"name"];
            [temp setValue:dapei forKey:@"dapei"];
            [temp setValue:disprice forKey:@"disprice"];
            [temp setValue:price forKey:@"price"];
            
            
            [dataArray addObject:temp];
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return dataArray;


}

+(NSMutableDictionary *)getAllElement:(NSString *)planId  angle:(NSString *)angle{
    
    sqlite3_stmt *statement=nil;
    sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    //plan_id text,element_id text,image_url text,image_size text,name text,disprice text,price text,dapei_pic text,dapei_pic_size text,hot_pic text,hot_pic_size text,product_img text,product_img_size text,product_id text,layer text)
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM download_planGoodsTable where plan_id ='%@'",planId] ;
    
    NSMutableDictionary *allElements = [[NSMutableDictionary alloc] init];
    
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
            
            //   char *rowData0 = (char *)sqlite3_column_text(statement, 0);   //plan_id
            //    char *rowData1 = (char *)sqlite3_column_text(statement, 1);   // id
            char *rowData8 = (char *)sqlite3_column_text(statement, 7);   //image
            char *rowData5 = (char *)sqlite3_column_text(statement, 4);   //name
            char *rowData7 = (char *)sqlite3_column_text(statement, 6);   //price
            char *rowData6 = (char *)sqlite3_column_text(statement, 5);   //disprice
            char *rowData12 = (char *)sqlite3_column_text(statement, 11);   //product_img
            char *rowData3 = (char *)sqlite3_column_text(statement, 2);   //product_img
            char *rowData14 = (char *)sqlite3_column_text(statement, 14);   //layer
            
            NSString *thumb =  [[NSString  stringWithUTF8String:rowData12] copy];
            
            if([thumb isEqualToString:@"productImageUrl0"])
                thumb =  [[NSString  stringWithUTF8String:rowData3] copy];
            
            NSString *name = [[NSString  stringWithUTF8String:rowData5] copy];
            NSString *disprice = [[NSString  stringWithUTF8String:rowData6] copy];
            NSString *price = [[NSString  stringWithUTF8String:rowData7] copy];
            NSString *dapei = [[NSString  stringWithUTF8String:rowData8] copy];
            NSString *layer = [[NSString  stringWithUTF8String:rowData14] copy];
            
            
            [temp setValue:thumb forKey:@"thumb"];
            [temp setValue:name forKey:@"name"];
            [temp setValue:dapei forKey:@"dapei"];
            [temp setValue:disprice forKey:@"disprice"];
            [temp setValue:price forKey:@"price"];
            
            NSMutableArray  *dataArray = [allElements objectForKey:layer];
            
            if(!dataArray){
                dataArray = [[NSMutableArray alloc] init];
            }
            [dataArray addObject:temp];
            [allElements setValue:dataArray forKey:layer];
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return allElements;
    
    
}
+(BOOL)deleteByHousesId:(NSString *)housesId{

    BOOL flag = false;
    
    sqlite3_stmt *statement=nil;
    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
        
	}
    
  //  download_planGoodsTable(plan_id text,element_id text,image_url text,image_size text,name text,disprice text,price text,dapei_pic text,dapei_pic_size text,hot_pic text,hot_pic_size text,product_img text,product_img_size text,product_id text,layer text)

    NSString *query = [NSString stringWithFormat:@"select image_url,dapei_pic,hot_pic,product_img from download_planGoodsTable where plan_id in (select planId from download_planTable where housesId = '%@')",housesId];
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
      
            char *rowData0 = (char *)sqlite3_column_text(statement, 0);   //image
            char *rowData1 = (char *)sqlite3_column_text(statement, 1);   //dapei_pic
            char *rowData2 = (char *)sqlite3_column_text(statement, 2);   //hot_pic
            char *rowData3 = (char *)sqlite3_column_text(statement, 3);   //product_img
            
            NSString *image = [[NSString  stringWithUTF8String:rowData0] copy];
            NSString *dapei_pic = [[NSString  stringWithUTF8String:rowData1] copy];
            NSString *hot_pic = [[NSString  stringWithUTF8String:rowData2] copy];
            NSString *product_img = [[NSString  stringWithUTF8String:rowData3] copy];
            
          //  NSString *regular = @"\.(?:jpg|gif|png)";
            
            if(image.length>9){
              
                [downloadImage removeImage:image];
            }
            if(dapei_pic.length>9){
                
                [downloadImage removeImage:dapei_pic];

            }
            if(hot_pic.length>7){
                
                [downloadImage removeImage:hot_pic];

            }
            if(product_img.length>16){
                
                [downloadImage removeImage:product_img];
 
            }
        }
        
    }

  //  download_planDefaultTable(plan_id text,angle text,dapei_pic text,element_id text,hot_pic text,layer text,pic text);";

    
    NSString *query1 = [NSString stringWithFormat:@"select pic from download_planDefaultTable where plan_id in (select planId from download_planTable where housesId = '%@')",housesId];
    
    if (sqlite3_prepare_v2(database, [query1 UTF8String], -1, &statement, nil) == SQLITE_OK) {
		while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *rowData0 = (char *)sqlite3_column_text(statement, 0);   //image
            
            NSString *image = [[NSString  stringWithUTF8String:rowData0] copy];
    
            
       //     NSString *regular = @"\.(?:jpg|gif|png)";
            
            if(image.length>4){
                
                [downloadImage removeImage:image];
            }
        }
    }
        //download_planTable(id text,housesId text,housesName text,planId text primary key,name text,imagePath text,localImageName text,goodsCount text,status text,isHigh int,remain text,total text);";
        
        NSString *query2 = [NSString stringWithFormat:@"select localImageName from download_planTable where housesId = '%@'",housesId];
        
        if (sqlite3_prepare_v2(database, [query2 UTF8String], -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                char *rowData0 = (char *)sqlite3_column_text(statement, 0);   //image
                
                NSString *image = [[NSString  stringWithUTF8String:rowData0] copy];
                
                
           //     NSString *regular = @"\.(?:jpg|gif|png)";
                
                if(image.length>10){
                    
                    [downloadImage removeImage:image];
                }
            }
        }

       // download_planGoodsTable(plan_id
        
         NSString *deletePlanGoodsTable =[NSString stringWithFormat:@"delete from download_planGoodsTable where plan_id in (select planId from download_planTable where housesId = '%@')",housesId];
        
        if (sqlite3_exec(database, [deletePlanGoodsTable UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        }

        
        NSString *deleteDefaultTable =[NSString stringWithFormat:@"delete from download_planDefaultTable where plan_id in (select planId from download_planTable where housesId = '%@')",housesId];
        
        if (sqlite3_exec(database, [deleteDefaultTable UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        }
    
      NSString *deleteDownloadingTable =[NSString stringWithFormat:@"delete from download_downloadingTable where houses_id = '%@')",housesId];
    
       if (sqlite3_exec(database, [deleteDownloadingTable UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
     }
    
        NSString *sqlHot = [NSString stringWithFormat:@"delete from download_planTable where housesId = '%@'",housesId];
        if (sqlite3_exec(database, [sqlHot UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        }
        else{
            flag = true;
        }
    
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return  flag;
}
+(double)getTotal{
    
    double total = 0;
    
    sqlite3_stmt *statement=nil;
    sqlite3* database=nil;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert(0, @"Failed to open database");
        
	}

    //download_planTable(id text,housesId text,housesName text,planId text primary key,name text,imagePath text,localImageName text,goodsCount text,status text,isHigh int,remain text,total text);";
    
    NSString *query2 = @"select total from download_planTable";
    
    if (sqlite3_prepare_v2(database, [query2 UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *rowData0 = (char *)sqlite3_column_text(statement, 0);   //image
            
            NSString *totalStr = [[NSString  stringWithUTF8String:rowData0] copy];
            
            total = total + [totalStr longLongValue];
        }
    }

    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return total;
}

+(NSMutableArray *)getDetailByHousesId:(int)housesId{
    
    sqlite3_stmt *statement=nil;
    sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
  // download_planDefaultTable(plan_id text,angle text,dapei_pic text,element_id text,hot_pic text,layer text,pic text)
    
 //  download_planTable(id text,housesId text,housesName text,planId text primary key,name text,imagePath text,localImageName text,goodsCount text,status text,isHigh int,remain text,total text)
    
 //download_planGoodsTable (plan_id,element_id,image_url,image_size,name,disprice,price,dapei_pic,dapei_pic_size ,hot_pic ,hot_pic_size ,product_img ,product_img_size,product_id,layer)
    
    
//    NSMutableArray *goodsData = [DBHelper getGoodsByPlanId:[temp1 objectForKey:@"planId"]];
//    [temp1 setValue:goodsData forKey:@"data"];
//    
//    [temp1 setValue:[temp1 objectForKey:@"planId"] forKey:@"id"];
//    [temp1 setValue:[temp1 objectForKey:@"localImageName"] forKey:@"image"];
//    [temp1 setValue:@"3500" forKey:@"length"];
//    [temp1 setValue:@"4500" forKey:@"width"];
//    [temp1 setValue:@"描述未知" forKey:@"description"];
    
//    NSString *query = [NSString stringWithFormat:@"select  download_planTable.housesName,download_planTable.name,download_planTable.localImageName,download_planDefaultTable.* from download_planTable left outer join download_planDefaultTable on  download_planTable.planId=download_planDefaultTable.plan_id where download_planTable.housesId='%d'",housesId] ;
    
    NSString *query = [NSString stringWithFormat:@"select  download_planTable.housesName,download_planTable.name,download_planTable.localImageName,download_planDefaultTable.*,download_planGoodsTable.image_url,download_planGoodsTable.name,download_planGoodsTable.disprice,download_planGoodsTable.price from download_planTable left outer join download_planDefaultTable on download_planTable.planId=download_planDefaultTable.plan_id left outer join download_planGoodsTable on download_planGoodsTable.element_id=download_planDefaultTable.element_id where download_planTable.housesId='%d' group by download_planGoodsTable.element_id",housesId] ;
    
   
    NSMutableArray  *dataArray = [[NSMutableArray alloc] init];
    NSMutableDictionary  *temp = [[NSMutableDictionary alloc] init];
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            
            char *rowData0 = (char *)sqlite3_column_text(statement, 0);   //housesName
            char *rowData1 = (char *)sqlite3_column_text(statement, 1);   // name
            char *rowData2 = (char *)sqlite3_column_text(statement, 2);   //localImageName
            char *rowData3 = (char *)sqlite3_column_text(statement, 3);   //plan_id
       //     char *rowData4 = (char *)sqlite3_column_text(statement, 4);   //angle
            char *rowData5 = (char *)sqlite3_column_text(statement, 5);   //element_id
            char *rowData6 = (char *)sqlite3_column_text(statement,6);   //dapei_pic
      //      char *rowData7 = (char *)sqlite3_column_text(statement, 7);   //hot_pic
      //      char *rowData8 = (char *)sqlite3_column_text(statement,8);   //layer
     //       char *rowData9 = (char *)sqlite3_column_text(statement, 9);   //pic
            char *rowData10 = (char *)sqlite3_column_text(statement,10);   //dapei_pic
            char *rowData11 = (char *)sqlite3_column_text(statement, 11);   //hot_pic
            char *rowData12 = (char *)sqlite3_column_text(statement,12);   //layer
            char *rowData13 = (char *)sqlite3_column_text(statement, 13);   //pic
            
            NSString *housesName = [[NSString  stringWithUTF8String:rowData0] copy];
            NSString *name = [[NSString  stringWithUTF8String:rowData1] copy];
            NSString *localImageName = [[NSString  stringWithUTF8String:rowData2] copy];
            NSString *plan_id = [[NSString  stringWithUTF8String:rowData3] copy];
       //     NSString *angle = [[NSString  stringWithUTF8String:rowData4] copy];
            NSString *dapei_pic= [[NSString  stringWithUTF8String:rowData5] copy];
            NSString *element_id = [[NSString  stringWithUTF8String:rowData6] copy];
      //      NSString *hot_pic = [[NSString  stringWithUTF8String:rowData7] copy];
      //      NSString *layer = [[NSString  stringWithUTF8String:rowData8] copy];
      //      NSString *pic = [[NSString  stringWithUTF8String:rowData9] copy];
            
             NSString *thumb = @"";
            if(rowData10 != NULL){
                thumb = [[NSString  stringWithUTF8String:rowData10] copy];
            }
            
            NSString *goodsName = @"未知信息";
            
            if(rowData11 != NULL){

            goodsName = [[NSString  stringWithUTF8String:rowData11] copy];
            }
            
            NSString *disprice = @"未知信息";
            
            if(rowData12 != NULL){
                
                disprice = [[NSString  stringWithUTF8String:rowData12] copy];
            }
            
            NSString *price = @"未知信息";
            
            if(rowData13 != NULL){
                
                price = [[NSString  stringWithUTF8String:rowData13] copy];
            }
            
            NSMutableDictionary *temp2 = [temp objectForKey:plan_id];
            
            if(temp2){
            
                NSMutableDictionary *temp3 = [[NSMutableDictionary alloc] init];
                [temp3 setValue:element_id forKey:@"id"];
                [temp3 setValue:dapei_pic forKey:@"image"];
                [temp3 setValue:goodsName forKey:@"name"];
                [temp3 setValue:disprice forKey:@"disprice"];
                [temp3 setValue:price forKey:@"price"];
            
                NSMutableArray *temp4 = [temp2 objectForKey:@"data"];
                [temp4 addObject:temp3];
                [temp2 setValue:temp4 forKey:@"data"];
                [temp setValue:temp2 forKey:plan_id];
            }
           
            else{
             temp2 =[[NSMutableDictionary alloc] init];
                
                    [temp2 setValue:plan_id forKey:@"id"];
                    [temp2 setValue:localImageName forKey:@"image"];
                    [temp2 setValue:@"3500" forKey:@"length"];
                    [temp2 setValue:@"4500" forKey:@"width"];
                    [temp2 setValue:@"描述未知" forKey:@"description"];
                    [temp2 setValue:housesName forKey:@"authorName"];
                    [temp2 setValue:name forKey:@"name"];
            
                NSMutableDictionary *temp3 = [[NSMutableDictionary alloc] init];
                [temp3 setValue:element_id forKey:@"id"];
                [temp3 setValue:thumb forKey:@"image"];
                [temp3 setValue:goodsName forKey:@"name"];
                [temp3 setValue:disprice forKey:@"disprice"];
                [temp3 setValue:price forKey:@"price"];

                NSMutableArray *temp4 = [[NSMutableArray alloc] init];
                [temp4 addObject:temp3];
                
                [temp2 setValue:temp4 forKey:@"data"];
                
                [temp setValue:temp2 forKey:plan_id];

            }
            }
    }
    
    NSArray *allKeys = [temp allKeys];
    
    for(NSString *key in allKeys){
    
        [dataArray addObject:[temp objectForKey:key]];
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return dataArray;

}
+(NSMutableArray *)getDefaultByPlanId:(int)planId{

    sqlite3_stmt *statement=nil;
    sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    // download_planDefaultTable(plan_id text,angle text,dapei_pic text,element_id text,hot_pic text,layer text,pic text)
    
    //  download_planTable(id text,housesId text,housesName text,planId text primary key,name text,imagePath text,localImageName text,goodsCount text,status text,isHigh int,remain text,total text)
    
    //download_planGoodsTable (plan_id,element_id,image_url,image_size,name,disprice,price,dapei_pic,dapei_pic_size ,hot_pic ,hot_pic_size ,product_img ,product_img_size,product_id,layer)
    
    
    //    NSMutableArray *goodsData = [DBHelper getGoodsByPlanId:[temp1 objectForKey:@"planId"]];
    //    [temp1 setValue:goodsData forKey:@"data"];
    //
    //    [temp1 setValue:[temp1 objectForKey:@"planId"] forKey:@"id"];
    //    [temp1 setValue:[temp1 objectForKey:@"localImageName"] forKey:@"image"];
    //    [temp1 setValue:@"3500" forKey:@"length"];
    //    [temp1 setValue:@"4500" forKey:@"width"];
    //    [temp1 setValue:@"描述未知" forKey:@"description"];
    
    //    NSString *query = [NSString stringWithFormat:@"select  download_planTable.housesName,download_planTable.name,download_planTable.localImageName,download_planDefaultTable.* from download_planTable left outer join download_planDefaultTable on  download_planTable.planId=download_planDefaultTable.plan_id where download_planTable.housesId='%d'",housesId] ;
    
//    NSString *query = [NSString stringWithFormat:@"select  download_planTable.housesName,download_planTable.name,download_planTable.localImageName,download_planDefaultTable.*,download_planGoodsTable.image_url,download_planGoodsTable.name,download_planGoodsTable.disprice,download_planGoodsTable.price from download_planTable left outer join download_planDefaultTable on download_planTable.planId=download_planDefaultTable.plan_id left outer join download_planGoodsTable on download_planGoodsTable.element_id=download_planDefaultTable.element_id where download_planTable.planId='%d' group by download_planGoodsTable.element_id",planId] ;
    
    NSString *query = [NSString stringWithFormat:@"SELECT download_planDefaultTable.dapei_pic,download_planGoodsTable.image_url,download_planGoodsTable.name,download_planGoodsTable.disprice,download_planGoodsTable.price,download_planGoodsTable.element_id,download_planDefaultTable.type FROM download_planDefaultTable LEFT OUTER JOIN download_planGoodsTable ON download_planDefaultTable.element_id = download_planGoodsTable.element_id WHERE download_planDefaultTable.plan_id = '%d' GROUP BY download_planDefaultTable.element_id",planId] ;
    
    NSMutableArray  *dataArray = [[NSMutableArray alloc] init];
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            
            char *rowData0 = (char *)sqlite3_column_text(statement, 0);   //dapei_pic
            char *rowData1 = (char *)sqlite3_column_text(statement, 1);   // image_url
            char *rowData2 = (char *)sqlite3_column_text(statement, 2);   //name
            char *rowData3 = (char *)sqlite3_column_text(statement, 3);   //disprice
            char *rowData4 = (char *)sqlite3_column_text(statement, 4);   //price
            char *rowData5 = (char *)sqlite3_column_text(statement, 5);   //element_id
            int type  = sqlite3_column_int(statement, 6);   //type
            
            NSString *element_id = @"";
            
            if(rowData5 != NULL){
            
                element_id = [[NSString  stringWithUTF8String:rowData5] copy];
            }
            
            
            NSString *thumb = @"";
            if(rowData1 != NULL){
                thumb = [[NSString  stringWithUTF8String:rowData1] copy];
            }
            else if(rowData0!=NULL){
            
                thumb = [[NSString  stringWithUTF8String:rowData0] copy];

            }
            
            
            NSString *goodsName = @"未知信息";
            
            if(rowData2 != NULL){
                
                goodsName = [[NSString  stringWithUTF8String:rowData2] copy];
            }
            
            NSString *disprice = @"未知信息";
            
            if(rowData3 != NULL){
                
                disprice = [[NSString  stringWithUTF8String:rowData3] copy];
            }
            
            NSString *price = @"未知信息";
            
            if(rowData4 != NULL){
                
                price = [[NSString  stringWithUTF8String:rowData4] copy];
            }
            
     
                
                NSMutableDictionary *temp3 = [[NSMutableDictionary alloc] init];
                [temp3 setValue:element_id forKey:@"id"];
                [temp3 setValue:thumb forKey:@"image"];
                [temp3 setValue:goodsName forKey:@"name"];
                [temp3 setValue:disprice forKey:@"disprice"];
                [temp3 setValue:price forKey:@"price"];
                [temp3 setValue:[NSNumber numberWithInt:type] forKey:@"type"];
                
                [dataArray addObject:temp3];
            
            }
    }
    
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return dataArray;

}
+(BOOL)updateVersion:(NSArray *)versions{

    BOOL flag = false;
    
    sqlite3* database=nil;
    if (sqlite3_open([[DBHelper dataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    
    for (NSDictionary *data in versions) {
        
    NSString *update =[NSString stringWithFormat:@"update download_planTable set latestVersion ='%@' where planId = '%@';",[data objectForKey:@"Version"],[data objectForKey:@"Id"]];
   
        if (sqlite3_exec(database, [update UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK) {
            flag = true;
        }
    }
    

    sqlite3_close(database);
    return flag;
}
@end
