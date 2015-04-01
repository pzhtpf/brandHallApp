//
//  beautifyPictureViewController.h
//  brandv1.2
//
//  Created by Apple on 15/3/4.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface beautifyPictureViewController : UIViewController<UITextFieldDelegate>

- (IBAction)searchAction:(id)sender;
- (IBAction)accountAction:(id)sender;
- (IBAction)settingAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIImageView *searchBorder;
@property (strong, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *brandLogo;
@end
