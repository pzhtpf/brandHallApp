//
//  messageView.h
//  brandv1.2
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface productMessageView : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,EGORefreshTableHeaderDelegate>{
	
	EGORefreshTableHeaderView *_refreshHeaderView;
	
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
}

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
-(void)configView:(NSMutableArray *)data;
-(void)getMessageList:(id)sender;
@property (strong, nonatomic) NSMutableArray *data;
@property (strong, nonatomic) UITableView *table ;
-(void)initProductIndex:(id)sender;
-(void)orderByType:(int)type;
@end
