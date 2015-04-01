//
//  feedbackViewController.h
//  brandv1.2
//
//  Created by Apple on 15/3/17.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface feedbackViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>

- (IBAction)backAction:(id)sender;
- (IBAction)closeAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *nameView;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UIView *contactView;
@property (strong, nonatomic) IBOutlet UITextField *contactTextField;
@property (strong, nonatomic) IBOutlet UIView *addressView;
@property (strong, nonatomic) IBOutlet UITextField *addressTextField;
@property (strong, nonatomic) IBOutlet UIView *descriptionView;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *mustInputTip;
- (IBAction)submitAction:(id)sender;
@end
