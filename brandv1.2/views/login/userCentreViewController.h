//
//  userCentreViewController.h
//  brandv1.2
//
//  Created by Apple on 15/4/16.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginInfo.h"

@interface userCentreViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *userCentreBack;
@property (strong, nonatomic) IBOutlet UIView *userCentreMainBack;
- (IBAction)userCentreClose:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *headImageView;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) LoginInfo *loginInfo;
- (IBAction)loginAction:(id)sender;
@end
