//
//  loginViewController.h
//  brandv1.2
//
//  Created by Apple on 14-9-4.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWPageModel.h"
#import <ShareSDK/ShareSDK.h>
#import "LoginInfo.h"

@interface loginViewController : UIViewController<UIPageViewControllerDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *account;
@property (strong, nonatomic) IBOutlet UITextField *password;
- (IBAction)register:(id)sender;
- (IBAction)login:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *remeberPassword;
- (IBAction)close:(id)sender;
@property (strong, nonatomic) LoginInfo *loginInfo;

- (IBAction)remeberPasswordAction:(id)sender;
@property (nonatomic,retain) UIPageViewController *pageController;
@property (nonatomic,retain) CWPageModel    *pModel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *QQButton;
- (IBAction)QQButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *weiboButton;
- (IBAction)weiboButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *apliyButton;
- (IBAction)apliyButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *line1;
@property (strong, nonatomic) IBOutlet UILabel *orLabel;
@property (strong, nonatomic) IBOutlet UILabel *line2;
@property (strong, nonatomic) IBOutlet UILabel *remeberPasswordTip;
@property (strong, nonatomic) IBOutlet UIButton *forgotPasswordButton;
- (IBAction)forgotPasswordButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *registerAction;
- (IBAction)registerButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *registerTip;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIImageView *inputBorderAccount;
@property (strong, nonatomic) IBOutlet UIImageView *inputBorderPassword;
@property (strong, nonatomic) IBOutlet UIView *mainBack;


@property (strong, nonatomic) IBOutlet UIScrollView *registerView;
@property (strong, nonatomic) IBOutlet UITextView *codeTipLabel;
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;
- (IBAction)getCodeAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *emailExistView;
@property (strong, nonatomic) IBOutlet UIView *lookForPassword;
@property (strong, nonatomic) IBOutlet UILabel *styleError;
@property (strong, nonatomic) IBOutlet UIImageView *phoneAccountBack;
@property (strong, nonatomic) IBOutlet UITextField *inputPhoneText;
@property (strong, nonatomic) IBOutlet UITextField *settingPasswordText;
@property (strong, nonatomic) IBOutlet UIImageView *confirmPassaordBack;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordText;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
- (IBAction)registerAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *changeRegisterButton;
- (IBAction)changeRegisterAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *registerPasswordArea;
@property (strong, nonatomic) IBOutlet UIView *loginArea;
@property (strong, nonatomic) IBOutlet UILabel *getCodeButton;
@property (strong, nonatomic) IBOutlet UIImageView *seetingPasswordBack;
@property (strong, nonatomic) IBOutlet UILabel *forgetPasswordTopTip;
@property (strong, nonatomic) IBOutlet UILabel *lookForPasswordTapView;
@end
