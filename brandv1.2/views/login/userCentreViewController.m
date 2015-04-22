//
//  userCentreViewController.m
//  brandv1.2
//
//  Created by Apple on 15/4/16.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "userCentreViewController.h"
#import "Define.h"
#import "StockData.h"
#import "globalContext.h"
#import "UIImage+Helpers.h"

@interface userCentreViewController ()

@end
@implementation userCentreViewController
@synthesize loginInfo;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLogin:) name:@"reLogin" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delayClose:) name:@"delayClose" object:nil];
    
    [self.userCentreBack addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userCentreClose:)]];
    self.headImageView.userInteractionEnabled = YES;
    [self.headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loginMethod:)]];

    
    [self initViewAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:YES];
    
    if([globalContext isLogin]){
    
         [self.userName setText:loginInfo.userName];
         [self.loginButton setTitle:@"注销" forState:UIControlStateNormal];
                
        if(loginInfo.portrait.length>0)
        
        [UIImage loadFromURL:loginInfo.portrait callback: ^(UIImage *image){
            
            if(image)
                [self.headImageView setImage:image];
            
            else{
            
                NSString *searchString = [[NSBundle mainBundle]pathForResource:@"defaultHead.png" ofType:@""];
                UIImage *defaultHead = [UIImage imageWithContentsOfFile:searchString];
                [self.headImageView setImage:defaultHead];
            
            }
        }];
        
        
        else{
            
            NSString *searchString = [[NSBundle mainBundle]pathForResource:@"defaultHead.png" ofType:@""];
            UIImage *defaultHead = [UIImage imageWithContentsOfFile:searchString];
            [self.headImageView setImage:defaultHead];
        
        }
    }
    else{
          [self.userName setText:@"未登陆"];
          [self.loginButton setTitle:@"登陆" forState:UIControlStateNormal];
    
    }

}
-(void)reLogin:(id)sender{

    if(loginInfo.portrait.length>0)
    [UIImage loadFromURL:loginInfo.portrait callback: ^(UIImage *image){
        
        if(image)
            [self.headImageView setImage:image];
    }];
    
    
    if(loginInfo.userName.length>0){
        [self.loginButton setTitle:@"注销" forState:UIControlStateNormal];
        [self.userName setText:loginInfo.userName];
    }

}
-(void)initViewAnimation{
    
    
    self.userCentreMainBack.frame = CGRectMake(self.userCentreMainBack.frame.origin.x, 768, self.userCentreMainBack.frame.size.width, self.userCentreMainBack.frame.size.height);
    [self.userCentreBack setBackgroundColor:[UIColor clearColor]];
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         [self.userCentreBack setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.7]];
                         
                         CGRect  endFrame =  self.userCentreMainBack.frame;
                         endFrame.origin.y =103;
                         self.userCentreMainBack.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}

- (IBAction)userCentreClose:(id)sender {
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         [self.userCentreBack setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.0]];
                         
                         CGRect  endFrame =  self.userCentreMainBack.frame;
                         endFrame.origin.y =768;
                         self.userCentreMainBack.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                        
                         [[NSNotificationCenter defaultCenter] removeObserver:self name:@"delayClose" object:nil];
                          [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reLogin" object:nil];
                         
                         [self.view removeFromSuperview];
                         self.view = nil;
                         
                     }
     ];

}
-(void)delayClose:(id)sender{

 [self performSelector:@selector(userCentreClose:) withObject:nil afterDelay:1];

}
-(void)loginMethod:(id)sender {

    if(![globalContext isLogin])
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLogin" object:nil];

}
- (IBAction)loginAction:(id)sender {
    
    if(![globalContext isLogin])
         [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLogin" object:nil];
    
    else{
    
        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        //   NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:Domain]];
        NSArray* facebookCookies = [cookies cookies];
        
        for (NSHTTPCookie* cookie in facebookCookies) {
            
            NSLog(@"%@:%@",cookie.name,cookie.domain);
            
            if([cookie.name isEqualToString:@"USER_ID"]){
                [cookies deleteCookie:cookie];
                
                loginInfo.userName = @"";
                loginInfo.portrait = @"";
                
                [self.userName setText:@"未登录"];
                [self.loginButton setTitle:@"登陆" forState:UIControlStateNormal];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reLogin" object:nil];
                
                NSString *searchString = [[NSBundle mainBundle]pathForResource:@"defaultHead.png" ofType:@""];
                UIImage *defaultHead = [UIImage imageWithContentsOfFile:searchString];
                [self.headImageView setImage:defaultHead];
                defaultHead = nil;
                
                break;
            }
        }

    }
}
@end
