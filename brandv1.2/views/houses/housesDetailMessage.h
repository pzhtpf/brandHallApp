//
//  housesDetailMessage.h
//  brandv1.2
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface housesDetailMessage : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,EGORefreshTableHeaderDelegate>{
    
	BOOL _reloading;
}

- (void)reloadTableViewDataSource:(int)index;
- (void)doneLoadingTableViewData:(int)index;
-(void)configView:(NSMutableArray *)data index:(int) index;
-(void)setHousesId:(NSString *)housesId housesName:(NSString *)housesNameParams;
-(void)setHousesType:(NSArray *)typeDictionary housesId:(NSString *)housesId housesName:(NSString *)housesNameParams mainScrollView:(UIScrollView *) mainScrollView;
@property (strong, nonatomic) NSString *housesId;
@property (strong, nonatomic) NSString *housesTypeValue;
@property (strong, nonatomic) NSString *housesName;
@property (strong, nonatomic) NSMutableArray *allIndexArray;
@end
