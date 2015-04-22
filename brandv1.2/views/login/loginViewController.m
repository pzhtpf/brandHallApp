//
//  loginViewController.m
//  brandv1.2
//
//  Created by Apple on 14-9-4.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "loginViewController.h"
#import "StockData.h"
#import "DBHelper.h"
#import "AFNetworking.h"
#import "Define.h"
#import "UIImage+Resize.h"
#import "pageControl.h"
#import "downloadImage.h"
#import "globalContext.h"
#import "AsyncImageDownloader.h"
#define ACCEPTABLE_CHARECTERS @"1234567890"

@interface loginViewController ()

@end

@implementation loginViewController
@synthesize loginInfo;
UIAlertView *alertView;
bool isLogin = true;
bool beginEdit = false;
bool isPhoneRegister = true;
NSString *smsCode;
int count = 60;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];

    [self initViewAnimation];

    self.mainView.layer.cornerRadius = 7;
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.titleLabel.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(7.0,7.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.titleLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    self.titleLabel.layer.mask = maskLayer;
    
     self.inputBorderAccount.layer.cornerRadius = 5;
     self.inputBorderAccount.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
     self.inputBorderAccount.layer.borderWidth = 1;
    
    self.inputBorderPassword.layer.cornerRadius = 5;
    self.inputBorderPassword.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.inputBorderPassword.layer.borderWidth = 1;
    
    [self initRegisterView];
    
    self.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:18];
     [self.titleLabel setTextColor:UIColorFromRGB(0x131313)];
    [self.titleLabel setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
    [self.mainView setBackgroundColor:UIColorFromRGB(0xe7e7e7)];
     self.QQButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
     self.weiboButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
     self.apliyButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
    self.loginButton.layer.cornerRadius = 7;
    [self.loginButton setBackgroundColor:UIColorFromRGB(0x1e3d7e)];
    self.forgotPasswordButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0f];
    [self.forgotPasswordButton setTitleColor:UIColorFromRGB(0x868686) forState:UIControlStateNormal];
    [self.line1 setBackgroundColor:UIColorFromRGB(0xcfcfcf)];
    [self.line2 setBackgroundColor:UIColorFromRGB(0xcfcfcf)];
    self.orLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
    [self.orLabel setTextColor:UIColorFromRGB(0xbbbbbb)];
    self.remeberPasswordTip.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13];
    [self.remeberPasswordTip setTextColor:UIColorFromRGB(0xbbbbbb)];
    [self.registerAction setTitleColor:UIColorFromRGB(0x8d8d8d) forState:UIControlStateNormal];
    self.registerTip.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13];
    [self.registerTip setTextColor:UIColorFromRGB(0x8d8d8d)];
    
    [self.password setSecureTextEntry:YES];
    [self.account setText:loginInfo.userAccount];
    [self.password setText:loginInfo.password];
    self.account.delegate = self;
    self.password.delegate = self;
    
    self.inputPhoneText.tag = 124;
    self.inputPhoneText.delegate = self;
    
 //   self.lookForPasswordTapView
    [self.lookForPassword addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lookForPasswordTap:)]];
    
    [self.account  setReturnKeyType:UIReturnKeyNext];
    
    [self.password setReturnKeyType:UIReturnKeyDone];
    
    if(loginInfo.isPush){
    
        
        UIImage *image = [UIImage imageNamed:@"勾选蓝.png"];
        [self.remeberPassword setImage:image forState:UIControlStateNormal];
        image = nil;
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(KeyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(KeyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)initRegisterView{
    
    self.inputPhoneText.delegate = self;
    self.codeTextField.delegate = self;
    self.settingPasswordText.delegate = self;
    self.confirmPasswordText.delegate = self;
    
    self.registerView.showsVerticalScrollIndicator = NO;
    
    self.getCodeButton.userInteractionEnabled = YES;
    [self.getCodeButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getCodeAction:)]];
    
    self.settingPasswordText.secureTextEntry = YES;
    self.confirmPasswordText.secureTextEntry = YES;


    self.phoneAccountBack.layer.cornerRadius = 5;
    self.phoneAccountBack.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.phoneAccountBack.layer.borderWidth = 1;
    
    self.confirmPassaordBack.layer.cornerRadius = 5;
    self.confirmPassaordBack.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.confirmPassaordBack.layer.borderWidth = 1;
    
    self.seetingPasswordBack.layer.cornerRadius = 5;
    self.seetingPasswordBack.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.seetingPasswordBack.layer.borderWidth = 1;
    
    self.codeTextField.layer.cornerRadius = 5;
    self.codeTextField.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.codeTextField.layer.borderWidth = 1;
    
    self.registerButton.layer.cornerRadius = 7;
    
    self.getCodeButton.clipsToBounds = YES;
    self.getCodeButton.layer.cornerRadius = 5;
    self.getCodeButton.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.getCodeButton.layer.borderWidth = 1;

    [self.emailExistView setHidden:true];
    [self.styleError setHidden:true];
    [self.codeTipLabel setHidden:true];

    [self.codeTextField setHidden:false];
    [self.getCodeButton setHidden:false];
    
    self.remeberPasswordTip.userInteractionEnabled = YES;
    [self.remeberPasswordTip addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remeberPasswordAction:)]];

    
    self.codeTextField.frame = CGRectMake(0, 50, self.codeTextField.frame.size.width,  self.codeTextField.frame.size.height);
    self.getCodeButton.frame = CGRectMake(self.getCodeButton.frame.origin.x, 50, self.getCodeButton.frame.size.width,  self.getCodeButton.frame.size.height);
    
    self.registerPasswordArea.frame = CGRectMake(0, 100, self.registerPasswordArea.frame.size.width,  self.registerPasswordArea.frame.size.height);
}
-(void)initViewAnimation{

    [self.mainBack addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMethod:)]];
    
    self.mainView.frame = CGRectMake(self.mainView.frame.origin.x, 768, self.mainView.frame.size.width, self.mainView.frame.size.height);
    [self.mainBack setBackgroundColor:[UIColor clearColor]];
    self.view.frame = CGRectMake(0, 0, 1024, 768);
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                        [self.mainBack setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.7]];
                         
                         CGRect  endFrame =  self.mainView.frame;
                         endFrame.origin.y =100;
                         self.mainView.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                       
                         count =0;
                     }
     ];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
   
    [super viewWillAppear:YES];
    
    if(loginInfo.keyBoardIsShow){
    
        [self KeyboardDidShow:self.account];
    }
}
-(void)lookForPasswordTap:(UIGestureRecognizer *)recognizer{

    [globalContext showAlertView:@"不支持此功能"];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(isLogin){
        
    if (textField == self.account) {       
        
        return [self.password becomeFirstResponder]; //点击右下角的Next按钮,则将键盘第一响应者设为_textField_password,即密码输入框
        
    }else{
        
        [self login:nil];
        return [self.password resignFirstResponder]; //否则(键盘第一响应者为密码输入框),则使键盘失去第一响应者,即消失
        
    }
    }
    else{
    
        if(!isPhoneRegister){   //邮箱注册界面
        
        if (textField == self.inputPhoneText) {
            
            return [self.settingPasswordText becomeFirstResponder]; //点击右下角的Next按钮,则将键盘第一响应者设为_textField_password,即密码输入框
            
        }
        else  if (textField == self.settingPasswordText){
            
            return [self.confirmPasswordText becomeFirstResponder]; //否则(键盘第一响应者为密码输入框),则使键盘失去第一响应者,即消失
            
        }
        else{
              [self registerAction:nil];
              return [self.confirmPasswordText resignFirstResponder];
        }
    }
        else{    //手机注册界面
        
            
            if (textField == self.inputPhoneText) {
                
                return [self.codeTextField becomeFirstResponder]; //点击右下角的Next按钮,则将键盘第一响应者设为_textField_password,即密码输入框
                
            }
            else  if (textField == self.codeTextField){
                
                return [self.settingPasswordText becomeFirstResponder]; //否则(键盘第一响应者为密码输入框),则使键盘失去第一响应者,即消失
                
            }
            else  if (textField == self.settingPasswordText){
                
                return [self.confirmPasswordText becomeFirstResponder]; //否则(键盘第一响应者为密码输入框),则使键盘失去第一响应者,即消失
                
            }
            else{
                [self registerAction:nil];
                return [self.confirmPasswordText resignFirstResponder];
            }

            
        }
    }
    
}
- (void)KeyboardDidShow:(UITextField *)textField
{
    /* keyboard is visible, move views */
      loginInfo.keyBoardIsShow = true;
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         CGRect  endFrame =  self.mainView.frame;
                         endFrame.origin.y =0;
                         self.mainView.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];

}

- (void)KeyboardDidHide:(UITextField *)textField
{
    /* resign first responder, hide keyboard, move views */
    
    loginInfo.keyBoardIsShow = false;
    
    [self.registerView setContentSize:CGSizeMake(0,0)];
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         CGRect  endFrame =  self.mainView.frame;
                         endFrame.origin.y =100;
                         self.mainView.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
            
                     }
     ];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)register:(id)sender {
}

-(BOOL)inputValid{

    
    if(self.account.text.length ==0){
        [self showAlertView:@"账号不能为空"];
        return false;
    }
    else if(self.password.text.length ==0){
        [self showAlertView:@"密码不能为空"];
        return false;
    }
    else{
       return  true;
    }
    
}

- (IBAction)login:(id)sender {
    
    if(isLogin){

    if([self inputValid]){

        [loginInfo.progressBarView setTip:@"正在登陆..."];
        [self.view addSubview:loginInfo.progressBarView];
        
       
        [self loginValid:nil];
       
    }
    }
    else
        [self registerValid];
    
    
}
-(void)registerValid{

}
-(void)loginValid:(id)sender{
    
   [globalContext changeBrandId];
   [globalContext detectBrandIDIsChange];

   AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"account":self.account.text,@"password":self.password.text,@"areaCode":@"01",@"brandId":@"51"};
    
    [manager POST:[BASEURL stringByAppendingString:loginApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
      //  NSLog(@"JSON: %@", responseObject);
        
        [loginInfo.progressBarView removeFromSuperview];
        
        NSDictionary *rootDic = responseObject;
        NSString *flag  =[rootDic objectForKey:@"flag"];
        
        if([flag isEqualToString:@"true"]){
            
            loginInfo.userType = @"normal";
            [self loginSuccess:rootDic];
        }
        else{
            
            [self showAlertView:@"用户名或密码错误"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
          [loginInfo.progressBarView removeFromSuperview];
           [self showAlertView:@"网络异常"];
        
    }];
    
    
}

-(void)loginSuccess:(NSDictionary *)rootDic{

        
      NSString  *enableDownload = [rootDic objectForKey:@"enableDownload"];
    
    //   loginInfo.portrait = [rootDic objectForKey:@"portrait"];
    
       loginInfo.userId = [rootDic objectForKey:@"userId"];
    
      [globalContext setCookies:[rootDic objectForKey:@"userId"]];
    
        loginInfo.userName  = [rootDic objectForKey:@"userName"];
    
        loginInfo.userAccount = self.account.text;
    
        if([enableDownload isEqualToString:@"false"])
            loginInfo.enableDownload = 0;
        else
            loginInfo.enableDownload = 1;
        
        if(loginInfo.isPush){
            loginInfo.password = self.password.text;
        }
        else{
            loginInfo.password = @"";
            [self.password setText:@""];
        }
        loginInfo.serverUrl = [rootDic objectForKey:@"serverUrl"];
    
        
        NSString *url = [rootDic objectForKey:@"portrait"];
    
    if (loginInfo.portrait && loginInfo.portrait.length>0) {
        
         [downloadImage removeImage:loginInfo.portrait];
    }
    
    
    NSString *localImageName  = @"defaultHead.png";

    if(url.length>0){
        
        NSArray *names =[url componentsSeparatedByString:@"/"];
        
        localImageName  =[NSString stringWithFormat:@"%@%@",names[names.count-1],@"userPortrait.png"];
        NSString *path = url;
        
        if([loginInfo.userType isEqualToString:@"normal"]){
        
        path = [NSString stringWithFormat:@"%@%@",@"http://imgs.gezlife.com/Imgs/gezsns/",url];
        NSArray *names =[url componentsSeparatedByString:@"/"];
        localImageName = names[names.count-1];
        }
        
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:path,@"path",localImageName,@"name", nil];
        
        AsyncImageDownloader *downloader = [[AsyncImageDownloader alloc] initWithMediaURL:path data:data tempData:nil successBlock:^(UIImage *image,NSDictionary *data,NSDictionary *dataTemp){
            
            NSLog(@"%@",@"用户头像下载成功");
            
             loginInfo.portrait = localImageName;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reLogin" object:nil];

            
        } failBlock:^(NSError *error){
            
            NSLog(@"%@",@"用户头像下载失败");
            
                   }];
        
        [downloader startDownload];
    }
    
        loginInfo.portrait = localImageName;
        [DBHelper settingSaveToDB];
    
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeMessageNotification" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"unloadView" object:nil];
        

        [self closeMethod:nil];
    
      [[NSNotificationCenter defaultCenter] postNotificationName:@"delayClose" object:nil];

}
-(void)showAlertView:(NSString *)message{     //显示提示框
    
    alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:message delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
    [alertView setMessage:message];
    alertView.tag = 110;
    [alertView show];
}
- (IBAction)close:(id)sender {
    
    [self closeMethod:sender];
}
-(void)closeMethod:(id)sender{
        
        [UIView setAnimationsEnabled:true];
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                             [self.mainBack setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.0]];
                             
                             CGRect  endFrame =  self.mainView.frame;
                             endFrame.origin.y =768;
                             self.mainView.frame = endFrame;
                             
                         }
                         completion:^(BOOL finished) {
                              [loginInfo.progressBarView setHidden:false];
                             [self.view removeFromSuperview];
                             isLogin = true;
                          //   [self dismissViewControllerAnimated:NO completion:^{}];
                         }
         ];

}
- (IBAction)remeberPasswordAction:(id)sender {
    
    if(!loginInfo.isPush){
        
        loginInfo.isPush = true;
        UIImage *image = [UIImage imageNamed:@"勾选蓝.png"];
        [self.remeberPassword setImage:image forState:UIControlStateNormal];
        image = nil;
    }
    else{
        loginInfo.isPush = false;
        UIImage *image = [UIImage imageNamed:@"勾选灰.png"];
        [self.remeberPassword setImage:image forState:UIControlStateNormal];
        image = nil;
    }
    [DBHelper settingSaveToDB];
}
- (IBAction)QQButtonAction:(id)sender {
    
    [loginInfo.progressBarView setTip:@"正在使用QQ登陆......"];
    [self.view addSubview:loginInfo.progressBarView];
    
    if([ShareSDK hasAuthorizedWithType:ShareTypeQQSpace]){
        
        [ShareSDK cancelAuthWithType:ShareTypeQQSpace];
    }
    
    [ShareSDK getUserInfoWithType:ShareTypeQQSpace authOptions:nil result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
 
        if (result) {
            //成功登录后，判断该用户的ID是否在自己的数据库中。
            //如果有直接登录，没有就将该用户的ID和相关资料在数据库中创建新用户。
            
          //  NSLog(@"%@",[userInfo sourceData]);
           // [self reloadStateWithType:ShareTypeQQSpace];
            
            [self regLogin:@"login" type:@"qq" keyId:[userInfo uid] info:[userInfo sourceData]];
        }
        
        else{
            
       //    NSLog(@"%ld",(long)[error errorCode]);
            [loginInfo.progressBarView removeFromSuperview];
        
            if([error errorCode] == -6004)
                
            [globalContext addStatusBarNotification:@"尚未安装QQ"];
            
            else
            [globalContext addStatusBarNotification:[NSString stringWithFormat:@"%@",[error errorDescription]]];
          
        }
    }];
    
}
-(void)regLogin:(NSString *)status type:(NSString *)type keyId:(NSString *)keyId info:(NSDictionary *)info{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"status":status,@"type":type,@"keyid":keyId,@"info":info};
    
    [manager POST:[BASEURL stringByAppendingString:regLoginApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //   NSLog(@"JSON: %@", responseObject);
        
      [loginInfo.progressBarView removeFromSuperview];
        
        NSDictionary *rootDic = responseObject;
        NSString *flag  =[rootDic objectForKey:@"flag"];
        
        if([flag isEqualToString:@"true"]){
            
          loginInfo.userType = type;
            
            [self loginSuccess:rootDic];
        }
        else{
            
            [self showAlertView:@"QQ登录失败"];
        }

        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [loginInfo.progressBarView removeFromSuperview];
        [self showAlertView:@"网络异常"];
        
    }];


}
-(void)reloadStateWithType:(ShareType)type{
    //现实授权信息，包括授权ID、授权有效期等。
    //此处可以在用户进入应用的时候直接调用，如授权信息不为空且不过期可帮用户自动实现登录。
    id<ISSPlatformCredential> credential = [ShareSDK getCredentialWithType:type];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TEXT_TIPS", @"提示")
                                                        message:[NSString stringWithFormat:
                                                                 @"uid = %@\ntoken = %@\nsecret = %@\n expired = %@\nextInfo = %@",
                                                                 [credential uid],
                                                                 [credential token],
                                                                 [credential secret],
                                                                 [credential expired],
                                                                 [credential extInfo]]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"TEXT_KNOW", @"知道了")
                                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)weiboButtonAction:(id)sender {
    
    [loginInfo.progressBarView setTip:@"正在使用新浪微博登陆......"];
    [self.view addSubview:loginInfo.progressBarView];
    
   if([ShareSDK hasAuthorizedWithType:ShareTypeSinaWeibo]){
    
      [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
  }

    [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo authOptions:nil result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
        NSLog(@"%d",result);
        if (result) {
            //成功登录后，判断该用户的ID是否在自己的数据库中。
            //如果有直接登录，没有就将该用户的ID和相关资料在数据库中创建新用户。
            
        //    [globalContext addStatusBarNotification:[NSString stringWithFormat:@"欢迎你，%@",[userInfo nickname]]];
            
          //  [self reloadStateWithType:ShareTypeSinaWeibo];
            
            [self regLogin:@"login" type:@"sina" keyId:[userInfo uid] info:[userInfo sourceData]];

        }
        
        else{
            
            [loginInfo.progressBarView removeFromSuperview];
            [globalContext addStatusBarNotification:[NSString stringWithFormat:@"%@",[error errorDescription]]];
        }

    }];
    
}
- (IBAction)forgotPasswordButtonAction:(id)sender {
    
    [globalContext showAlertView:@"不支持此功能"];
}
- (IBAction)registerButtonAction:(id)sender {
    
    if(isLogin){
        isLogin = false;
        
        [self.loginArea setHidden:true];
        
        self.registerView.frame = CGRectMake(120, 220,300, self.registerView.frame.size.height);
        [self.mainView addSubview:self.registerView];
        
        [self.registerTip setText:@"已经拥有账号了？"];
        [self.registerAction setTitle:@"点击这里登录" forState:UIControlStateNormal];
        [self.titleLabel setText:@"加入GEZLIFE"];
        [self.QQButton setTitle:@"用QQ账号注册" forState:UIControlStateNormal];
      
   
    //    [self.password setReturnKeyType:UIReturnKeyNext];
        
//        [UIView setAnimationsEnabled:true];
//        [UIView animateWithDuration:0.3f
//                              delay:0.0f
//                            options:UIViewAnimationOptionTransitionFlipFromLeft
//                         animations:^{
//                             
//            
//                             
//                             self.loginButton.frame = CGRectMake(self.loginButton.frame.origin.x,self.loginButton.frame.origin.y+50, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
//                         }
//                         completion:^(BOOL finished) {
//                            
//                         }
//         ];

    }
    else{
        isLogin = true;
        
        [self.loginArea setHidden:false];
        
        [self.registerView removeFromSuperview];
        
   
        [self.registerTip setText:@"还没有账号？"];
        [self.registerAction setTitle:@"点击这里注册" forState:UIControlStateNormal];
        [self.titleLabel setText:@"登录GEZLIFE"];
        [self.QQButton setTitle:@"用QQ账号登陆" forState:UIControlStateNormal];
    
      //  [self.password setReturnKeyType:UIReturnKeyDone];
        
//        [UIView setAnimationsEnabled:true];
//        [UIView animateWithDuration:0.3f
//                              delay:0.0f
//                            options:UIViewAnimationOptionTransitionFlipFromLeft
//                         animations:^{
//                             
//                             
//                             self.loginButton.frame = CGRectMake(self.loginButton.frame.origin.x,self.loginButton.frame.origin.y-50, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
//                         }
//                         completion:^(BOOL finished) {
//                            
//                         }
//         ];

    }
}
-(void)switchView{

}
- (IBAction)apliyButtonAction:(id)sender {
    
     [globalContext addStatusBarNotification:@"暂不支持此登陆"];
}
- (IBAction)getCodeAction:(id)sender {
    
    self.phoneAccountBack.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.codeTextField.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    
    if(self.inputPhoneText.text.length==0){
    self.phoneAccountBack.layer.borderColor = [UIColor redColor].CGColor;
        [self showStyleError:@"手机号码不能为空"];
    }
   else  if(self.inputPhoneText.text.length<11){
      self.phoneAccountBack.layer.borderColor = [UIColor redColor].CGColor;
        [self showStyleError:@"手机号码长度必须为11位"];
    }
   else  if(![self validateMobile:self.inputPhoneText.text]){
       self.phoneAccountBack.layer.borderColor = [UIColor redColor].CGColor;
       [self showStyleError:@"手机号码格式错误，请重新输入"];
   }
     else{
       [self hideStyleError];
       [self postCode];
   }
}
-(void)showStyleError:(NSString *)text{

    [self.styleError setText:text];
    [self.styleError setHidden:false];
    self.styleError.frame = CGRectMake(0, 50, self.styleError.frame.size.width, self.styleError.frame.size.height);
    self.codeTextField.frame = CGRectMake(0, 81, self.codeTextField.frame.size.width,  self.codeTextField.frame.size.height);
    self.getCodeButton.frame = CGRectMake(self.getCodeButton.frame.origin.x, 81, self.getCodeButton.frame.size.width,  self.getCodeButton.frame.size.height);
    
    if(isPhoneRegister){
    if(self.codeTipLabel.isHidden)
        
       self.registerPasswordArea.frame = CGRectMake(0,131, self.registerPasswordArea.frame.size.width,  self.registerPasswordArea.frame.size.height);
        
    else{
        
        [self showCodeTipLabel:self.codeTipLabel.text];
        
    }
    }
    else
    self.registerPasswordArea.frame = CGRectMake(0,81, self.registerPasswordArea.frame.size.width,  self.registerPasswordArea.frame.size.height);


}
-(void)hideStyleError{
    
    [self.styleError setText:@""];
    [self.styleError setHidden:true];
    self.codeTextField.frame = CGRectMake(0, 50, self.codeTextField.frame.size.width,  self.codeTextField.frame.size.height);
    self.getCodeButton.frame = CGRectMake(self.getCodeButton.frame.origin.x, 50, self.getCodeButton.frame.size.width,  self.getCodeButton.frame.size.height);
    
    if(isPhoneRegister)
    self.registerPasswordArea.frame = CGRectMake(0,100, self.registerPasswordArea.frame.size.width,  self.registerPasswordArea.frame.size.height);
    else
    self.registerPasswordArea.frame = CGRectMake(0,50, self.registerPasswordArea.frame.size.width,  self.registerPasswordArea.frame.size.height);
    
}
-(void)showCodeTipLabel:(NSString *)text{
    
    [self.codeTipLabel setText:text];
    [self.codeTipLabel setHidden:false];
    self.codeTipLabel.frame = CGRectMake(0,self.codeTextField.frame.origin.y+40, self.codeTipLabel.frame.size.width, self.codeTipLabel.frame.size.height);
    
    self.registerPasswordArea.frame = CGRectMake(0,self.codeTipLabel.frame.origin.y+50, self.registerPasswordArea.frame.size.width,  self.registerPasswordArea.frame.size.height);
    
}
-(void)hideCodeTipLabel{
    
    [self.codeTipLabel setHidden:true];
    
    self.registerPasswordArea.frame = CGRectMake(0,self.codeTextField.frame.origin.y+50, self.registerPasswordArea.frame.size.width,  self.registerPasswordArea.frame.size.height);
    
}
-(void)showEmailExistView{
    
    [self.emailExistView setHidden:false];
    
    self.phoneAccountBack.layer.borderColor = [UIColor redColor].CGColor;
    
    self.emailExistView.frame = CGRectMake(0, 50, self.emailExistView.frame.size.width, self.emailExistView.frame.size.height);
    self.codeTextField.frame = CGRectMake(0,60+ self.emailExistView.frame.size.height, self.codeTextField.frame.size.width,  self.codeTextField.frame.size.height);
    self.getCodeButton.frame = CGRectMake(self.getCodeButton.frame.origin.x, 60+ self.emailExistView.frame.size.height, self.getCodeButton.frame.size.width,  self.getCodeButton.frame.size.height);
    
    if(isPhoneRegister){
    [self.forgetPasswordTopTip setText:@"很抱歉，您输入的手机号码已经被注册，如果您忘记"];
    self.registerPasswordArea.frame = CGRectMake(0,self.getCodeButton.frame.origin.y+self.getCodeButton.frame.size.height+10, self.registerPasswordArea.frame.size.width,  self.registerPasswordArea.frame.size.height);
    }
    
    else
    {
        [self.forgetPasswordTopTip setText:@"很抱歉，您输入的邮箱地址已经被注册，如果您忘记"];
        self.registerPasswordArea.frame = CGRectMake(0,60+ self.emailExistView.frame.size.height, self.registerPasswordArea.frame.size.width,  self.registerPasswordArea.frame.size.height);
    }
    
}
-(void)hideEmailExistView{
    
    [self.emailExistView setHidden:true];
    
    self.codeTextField.frame = CGRectMake(0,50, self.codeTextField.frame.size.width,  self.codeTextField.frame.size.height);
    self.getCodeButton.frame = CGRectMake(self.getCodeButton.frame.origin.x,50, self.getCodeButton.frame.size.width,  self.getCodeButton.frame.size.height);
    
    self.registerPasswordArea.frame = CGRectMake(0,self.getCodeButton.frame.origin.x+self.getCodeButton.frame.size.height+10, self.registerPasswordArea.frame.size.width,  self.registerPasswordArea.frame.size.height);
}
-(void)postCode{
    
     [loginInfo.progressBarView setTip:@"正在发送验证码..."];
     [self.view addSubview:loginInfo.progressBarView];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"checkval":self.inputPhoneText.text};
    
    [manager POST:[BASEURL stringByAppendingString:checkSendApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
       // NSLog(@"JSON: %@", responseObject);
        
        [loginInfo.progressBarView removeFromSuperview];
        
        NSDictionary *rootDic = responseObject;
        
        int status = [[rootDic objectForKey:@"status"] intValue];
        NSString *message = [rootDic objectForKey:@"msg"];
        
        
        if(status==0){
            //号码已经被注册
            
            [self showEmailExistView];
        }
       else if(status==1){
            //手机验证码发送失败
           [self showCodeTipLabel:message];
        }
       else if(status==2){
            //手机验证码发送成功
           [self showCodeTipLabel:@"校验码短信已发送到您的手机上，有效时间为30分钟，请及时查收。"];
           smsCode = [rootDic objectForKey:@"code"];
          
           self.getCodeButton.userInteractionEnabled = false;
         NSThread  *thread = [[NSThread alloc] initWithTarget:self selector:@selector(countDown:) object:nil];
         [thread start];
        }
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [loginInfo.progressBarView removeFromSuperview];
        [self showAlertView:@"网络异常"];
        
    }];

}
-(void)countDown:(id)sender{

    count = 60;
    
    while (true) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
            [self.getCodeButton setText:[NSString stringWithFormat:@"重发验证码(%d)",count]];
  
        });
        
        if(count==0){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.getCodeButton setText:@"重新获取验证码"];
                self.getCodeButton.userInteractionEnabled = YES;

            });

            
            break;
        }
        
        count--;
        [NSThread sleepForTimeInterval:1];
    }

}
- (IBAction)registerAction:(id)sender {
    
    

    self.phoneAccountBack.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
   
    self.confirmPassaordBack.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;

    self.seetingPasswordBack.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    
    self.codeTextField.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;

    [self hideStyleError];
    [self hideEmailExistView];
    [self hideCodeTipLabel];
    
    if (isPhoneRegister) {
        
        if(self.inputPhoneText.text.length==0){
         
        self.phoneAccountBack.layer.borderColor = [UIColor redColor].CGColor;
         [self showStyleError:@"手机号码不能为空"];
        }
        else if(self.inputPhoneText.text.length<11){
            
            self.phoneAccountBack.layer.borderColor = [UIColor redColor].CGColor;

            [self showStyleError:@"手机号码必须为11位"];
        }
        else  if(![self validateMobile:self.inputPhoneText.text]){
            
            self.phoneAccountBack.layer.borderColor = [UIColor redColor].CGColor;
            [self showStyleError:@"手机号码格式错误，请重新输入"];
        }
        else if(self.codeTextField.text.length==0){
            
            self.codeTextField.layer.borderColor = UIColorFromRGB(0xff0000).CGColor;
            [self showStyleError:@"请输入6位验证码"];
        }
        else if(self.settingPasswordText.text.length==0){
              self.confirmPassaordBack.layer.borderColor = UIColorFromRGB(0xff0000).CGColor;
            [self showStyleError:@"请输入密码"];
        }
        else if(self.confirmPasswordText.text.length==0){
              self.seetingPasswordBack.layer.borderColor = UIColorFromRGB(0xff0000).CGColor;
            [self showStyleError:@"请再次输入密码"];
        }
        else if(![self.confirmPasswordText.text isEqualToString:self.settingPasswordText.text]){
              self.seetingPasswordBack.layer.borderColor = UIColorFromRGB(0xff0000).CGColor;
              self.confirmPassaordBack.layer.borderColor = UIColorFromRGB(0xff0000).CGColor;
            [self showStyleError:@"两次密码不一致"];
        }
        else if(![self.codeTextField.text isEqualToString:smsCode]){
            self.codeTextField.layer.borderColor = UIColorFromRGB(0xff0000).CGColor;
            [self showStyleError:@"验证码错误"];
        }
        else{
            //输入合法，发送请求去注册
             [self hideStyleError];
            [self registerMethod:@"phone"];
        }
    }
    
    else{
        
        if(self.inputPhoneText.text.length==0){
            self.phoneAccountBack.layer.borderColor = [UIColor redColor].CGColor;
            [self showStyleError:@"邮箱不能为空"];
        }
        else if(![self NSStringIsValidEmail:self.inputPhoneText.text]){
            self.phoneAccountBack.layer.borderColor = [UIColor redColor].CGColor;
            [self showStyleError:@"邮箱格式错误，请重新输入"];
        }
        else if(self.settingPasswordText.text.length==0){
            self.confirmPassaordBack.layer.borderColor = UIColorFromRGB(0xff0000).CGColor;
 
            [self showStyleError:@"请输入密码"];
        }
        else if(self.confirmPasswordText.text.length==0){
            self.seetingPasswordBack.layer.borderColor = UIColorFromRGB(0xff0000).CGColor;
            [self showStyleError:@"请再次输入密码"];
        }
        else if(![self.confirmPasswordText.text isEqualToString:self.settingPasswordText.text]){
            self.seetingPasswordBack.layer.borderColor = UIColorFromRGB(0xff0000).CGColor;
            self.confirmPassaordBack.layer.borderColor = UIColorFromRGB(0xff0000).CGColor;

            [self showStyleError:@"两次密码不一致"];
        }
        else{
            //输入合法，发送请求去注册
            
            [self hideStyleError];
            [self registerMethod:@"email"];
        }
        
    }
}
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)validateMobile:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


-(void)registerMethod:(NSString *)type {
    
    [loginInfo.progressBarView setTip:@"正在注册，请稍候..."];
    [self.view addSubview:loginInfo.progressBarView];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"account":self.inputPhoneText.text,@"password":self.settingPasswordText.text,@"type":type};
    
    [manager POST:[BASEURL stringByAppendingString:saveRegApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //      NSLog(@"JSON: %@", responseObject);
        
        [loginInfo.progressBarView removeFromSuperview];
        
        NSDictionary *rootDic = responseObject;
        int status = [[rootDic objectForKey:@"status"] intValue];
        NSString *message = [rootDic objectForKey:@"msg"];
        
        
        if(status==0){
            //号码已经被注册
            
            [self showEmailExistView];
        }
        else if(status==1){
            //注册失败
            [globalContext showAlertView:message];
        }
        else if(status==2){
            //注册成功
              [globalContext showAlertView:message];
            self.inputPhoneText.text =@"";
            self.codeTextField.text = @"";
            self.settingPasswordText.text = @"";
            self.confirmPasswordText.text = @"";
            [self hideCodeTipLabel];
            [self hideEmailExistView];
            [self hideStyleError];
            
            count = 0;

        }
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [loginInfo.progressBarView removeFromSuperview];
        [self showAlertView:@"网络异常"];
        
    }];
    
    
}
- (IBAction)changeRegisterAction:(id)sender {
    
    [self hideEmailExistView];
    
    if(isPhoneRegister){
    
        isPhoneRegister = false;
        
        [self.changeRegisterButton setTitle:@"使用手机号码注册" forState:UIControlStateNormal];
         [self.inputPhoneText setPlaceholder:@"请输入您的邮箱地址"];
        
        [self.codeTextField setHidden:true];
        [self.getCodeButton setHidden:true];
        
        self.inputPhoneText.keyboardType = UIKeyboardTypeEmailAddress;
        
        self.registerPasswordArea.frame = CGRectMake(0, 50, self.registerPasswordArea.frame.size.width,  self.registerPasswordArea.frame.size.height);
    }
    else{
    
       isPhoneRegister = true;
        
        [self.inputPhoneText setPlaceholder:@"请输入您的手机号码"];
        
       [self.changeRegisterButton setTitle:@"使用邮箱注册" forState:UIControlStateNormal];
        self.inputPhoneText.keyboardType = UIKeyboardTypeDecimalPad;
        
       [self initRegisterView];
    }
}
- (BOOL)textField: (UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString: (NSString *)string {
    //return yes or no after comparing the characters
    
    if(theTextField.tag == 124){
    
    if(isPhoneRegister){
        
        // allow backspace
    if (!string.length)
    {
        return YES;
    }
 
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
    if ([string isEqualToString:filtered]&& theTextField.text.length<11)
    {
        
        if(theTextField.text.length==0){
        if([string intValue]==1)
        return YES;
        else
        return NO;
        }
        else
            return YES;
    }
    
    return NO;
    }
    else{
    
        return YES;
    }
    }
    else{
    
        return YES;

    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    //返回一个BOOL值，指定是否循序文本字段开始编辑
    
    [self textFieldMoveTop:textField];
    
    return YES;
}
-(void)textFieldMoveTop:(UITextField *)textField{
    
    float y = 0;

    if (textField ==self.inputPhoneText) {
        
    }
    else if (textField ==self.codeTextField) {
        
        y = self.codeTextField.frame.origin.y;
    }
    else if (textField ==self.settingPasswordText) {
        
        y = self.registerPasswordArea.frame.origin.y;
    }
    else if (textField ==self.confirmPasswordText) {
        
        y = self.registerPasswordArea.frame.origin.y;

    }
    
    [self.registerView setContentSize:CGSizeMake(0, self.registerView.frame.size.height+y)];
    
    [self.registerView setContentOffset:CGPointMake(0,y) animated:YES];

}
@end
