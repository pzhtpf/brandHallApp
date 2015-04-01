//
//  StockData.h
//  GAIADemo
//
//  Created by benqguru on 12-9-9.
//  Copyright (c) 2012年 benqguru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginInfo.h"

@interface StockData : NSObject{
     NSString * url;
    NSString * userId;
    NSString * lang;
     NSString* closePop;
     NSInteger languageNo;
     NSMutableArray *favArray;
     NSDictionary *userInfo;
     LoginInfo * loginInfo;
}
+(StockData*) getSingleton;
@end



