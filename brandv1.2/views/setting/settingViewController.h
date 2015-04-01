//
//  settingViewController.h
//  brandv1.2
//
//  Created by Apple on 15/1/12.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface settingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *titleBackgroundLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)closeAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *userExit;
- (IBAction)userExitAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIView *mainBack;
@end
