//
//  downFirstPageViewController.h
//  brandv1.2
//
//  Created by Apple on 14-11-12.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "collocationViewController.h"

@interface downFirstPageViewController : UIViewController<UIPopoverControllerDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *sizeButton;
- (IBAction)sizeButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *taotalCount;
@property (strong, nonatomic) IBOutlet UIButton *downloaded;
- (IBAction)downloadedAction:(id)sender;
@property (strong, nonatomic) collocationViewController *collocation;
@property (strong, nonatomic) IBOutlet UITextField *searchText;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mySegmented;
@property (strong, nonatomic) IBOutlet UIButton *classSizeButton;
- (IBAction)classSizeButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *searchBack;
- (IBAction)AccountAction:(id)sender;
- (IBAction)settingAction:(id)sender;
- (IBAction)areaIconAction:(id)sender;
- (IBAction)sizeIconAction:(id)sender;
- (IBAction)searchTitleAction:(id)sender;
- (IBAction)oederByAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *orderByTextLabel;
@property (strong, nonatomic) IBOutlet UIButton *dropArrowButton;
@property (strong, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *brandLogo;
@end
