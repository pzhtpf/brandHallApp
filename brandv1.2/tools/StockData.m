//
//  Sto.m
//  GAIADemo
//
//  Created by benqguru on 12-9-9.
//  Copyright (c) 2012年 benqguru. All rights reserved.
//

#import "StockData.h"

@implementation StockData

+(StockData*) getSingleton
{
    static StockData *instance;
    @synchronized(self){
        if(instance==nil)
        {
            instance=[[self alloc] init];
        }
    }
    return instance;
}

@end
