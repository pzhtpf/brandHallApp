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
    
     [loginInfo addObserver:self forKeyPath:@"portrait" options:NSKeyValueObservingOptionNew context:nil];
     [loginInfo addObserver:self forKeyPath:@"userName" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.userCentreBack addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userCentreClose:)]];
    
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
        
        [UIImage loadFromURL:loginInfo.portrait callback: ^(UIImage *image){
            
            if(image)
                [self.headImageView setImage:image];
        }];
        
    }
    else{
          [self.userName setText:@"未登陆"];
          [self.loginButton setTitle:@"登陆" forState:UIControlStateNormal];
    
    }

}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"portrait"] && object == loginInfo) {
        
        [UIImage loadFromURL:loginInfo.portrait callback: ^(UIImage *image){
            
          if(image)
              [self.headImageView setImage:image];
        }];
    }
    else if ([keyPath isEqualToString:@"userName"] && object == loginInfo) {
        
        if(loginInfo.userName.length>0){
         [self.loginButton setTitle:@"注销" forState:UIControlStateNormal];
         [self.userName setText:loginInfo.userName];
        }
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
                        
                         [loginInfo removeObserver:self forKeyPath:@"portrait" context:nil];
                          [loginInfo removeObserver:self forKeyPath:@"userName" context:nil];
                         
                         [self.view removeFromSuperview];
                         self.view = nil;
                         
                     }
     ];

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
                
               // loginInfo.userName = @"";
                
                [self.userName setText:@"未登录"];
                [self.loginButton setTitle:@"登陆" forState:UIControlStateNormal];
                
                NSString *searchString = [[NSBundle mainBundle]pathForResource:@"defaultHead.png" ofType:@""];
                UIImage *defaultHead = [UIImage imageWithContentsOfFile:searchString];
                [self.headImageView setImage:defaultHead];
                
                break;
            }
        }

    }
}
@end
