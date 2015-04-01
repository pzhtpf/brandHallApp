//
//  housesDetailController.h
//  brandv1.2
//
//  Created by Apple on 14-8-16.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "collocationViewController.h"

@interface housesDetailController : UIViewController<UIGestureRecognizerDelegate,UIPopoverControllerDelegate>
- (IBAction)backAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *back;
@property (strong, nonatomic) collocationViewController *collocation;
-(void)initView:(NSMutableArray *)array;
@property (strong, nonatomic) IBOutlet UIImageView *housesImageView;
@property (strong, nonatomic) IBOutlet UILabel *housesName;
@property (strong, nonatomic) IBOutlet UILabel *houseCount;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *housesTypeLabel;
- (IBAction)settingAction:(id)sender;
- (IBAction)accountAction:(id)sender;
- (IBAction)infoAction:(id)sender;
- (IBAction)selectPlanAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *selectPlanButton;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@end
