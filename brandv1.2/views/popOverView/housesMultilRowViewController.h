//
//  housesMultilRowViewController.h
//  brandv1.2
//
//  Created by Apple on 15/3/19.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface housesMultilRowViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *firstTableView;
@property (strong, nonatomic) IBOutlet UITableView *secondTableView;
-(void)initView:(NSMutableArray *)data type:(int)type;
@end
