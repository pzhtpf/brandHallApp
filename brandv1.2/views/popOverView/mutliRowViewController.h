//
//  mutliRowViewController.h
//  brandv1.2
//
//  Created by Apple on 15/2/4.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mutliRowViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *firstTableViw;
@property (strong, nonatomic) IBOutlet UITableView *secondTableView;
@property (strong, nonatomic) IBOutlet UITableView *thridTableView;
-(void)initView:(NSMutableArray *)data type:(int)type;
@end
