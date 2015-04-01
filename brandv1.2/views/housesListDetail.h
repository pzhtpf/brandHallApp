//
//  housesListDetail.h
//  brandv1.2
//
//  Created by Apple on 14-11-13.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface housesListDetail : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,EGORefreshTableHeaderDelegate>{
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
}
@property (strong, nonatomic) NSMutableArray *housesListDetailAllData;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
-(void)configView:(NSMutableArray *)data;
-(void)initHousesIndex:(id)sender;
-(void)getMessageList:(id)sender;@end
