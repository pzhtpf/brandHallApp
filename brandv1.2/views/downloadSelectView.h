//
//  downloadSelectView.h
//  brandv1.2
//
//  Created by Apple on 14/12/17.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface downloadSelectView : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSMutableArray *downloadPlanSelectAllData;
-(void)configView:(NSMutableArray *)data;

@end
