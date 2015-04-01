//
//  downloadPlanDetail.h
//  brandv1.2
//
//  Created by Apple on 14-11-17.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface downloadPlanDetail :  UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSMutableArray *downloadPlanDetailAllData;
-(void)configView:(NSMutableArray *)data;
@end