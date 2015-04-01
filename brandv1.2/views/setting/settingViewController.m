//
//  settingViewController.m
//  brandv1.2
//
//  Created by Apple on 15/1/12.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "settingViewController.h"
#import "Define.h"
#import "AFNetworking.h"
#import "globalContext.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "feedbackViewController.h"

@interface settingViewController ()

@end

@implementation settingViewController
NSMutableArray *settingData;
LoginInfo *loginInfo;
feedbackViewController *_feedbackViewController;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    settingData = [[NSMutableArray alloc] initWithObjects:@"清除图片缓存",@"为我打分",@"意见反馈",@"新版本检测",@"关于GEZLIFE", nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAction:) name:@"closeSetting" object:nil];
    
    self.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:18.0f];
    self.userExit.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
    [self.titleBackgroundLabel setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
    [self.userExit setTitleColor:UIColorFromRGB(0x131313) forState:UIControlStateNormal];
    [self.mainView setBackgroundColor:UIColorFromRGB(0xe7e7e7)];
    
   self.tableView.dataSource = self;
   self.tableView.delegate = self;
   self.tableView.scrollEnabled = false;
    
   loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    
    [self initViewAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initViewAnimation{
    
    [self.mainBack addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeAction:)]];
    
    self.mainView.frame = CGRectMake(-350,0, self.mainView.frame.size.width, self.mainView.frame.size.height);
    [self.mainBack setBackgroundColor:[UIColor clearColor]];
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         [self.mainBack setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.7]];
                         
                         CGRect  endFrame =  self.mainView.frame;
                         endFrame.origin.x =0;
                         self.mainView.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return settingData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellTest";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = settingData[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
    cell.textLabel.textColor = UIColorFromRGB(0X131313);
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.contentView.backgroundColor = UIColorFromRGB(0X222222);
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row == 0){
        [self removeCache];
    }
   else if(indexPath.row == 1){
        [self grade];
    }
    else if(indexPath.row == 2){
       // [[NSNotificationCenter defaultCenter] postNotificationName:@"contractUs" object:nil];
        
        _feedbackViewController  = [[feedbackViewController alloc] init];
        _feedbackViewController.view.frame = CGRectMake(-350, 0, 350,768);
        [self.mainView addSubview:_feedbackViewController.view];
        
        [UIView setAnimationsEnabled:true];
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                            _feedbackViewController.view.frame = CGRectMake(0, 0, 350,768);
                             
                         }
                         completion:^(BOOL finished) {
                             
                            
                         }
         ];

    }
    else if(indexPath.row == 3){
        [self onCheckVersion];
    }
   else if(indexPath.row == 4){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addInfoView" object:nil];
    }
}
- (IBAction)closeAction:(id)sender {
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         [self.mainBack setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.0]];
                         
                         CGRect  endFrame =  self.mainView.frame;
                         endFrame.origin.x = -350;
                         self.mainView.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [[NSNotificationCenter defaultCenter] removeObserver:self name:@"closeSetting" object:nil];
                         [self.view removeFromSuperview];
                         self.view = nil;
                     }
     ];

}
-(void)onCheckVersion{

    [loginInfo.progressBarView setTip:@"正在检查更新..."];
    [self.view addSubview:loginInfo.progressBarView];
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDic objectForKey:@"CFBundleVersion"];
    
    
    NSString *URL = @"http://itunes.apple.com/lookup?id=923182521";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //   NSLog(@"JSON: %@", responseObject);
        
         [loginInfo.progressBarView removeFromSuperview];
        
        NSArray *infoArray = [responseObject objectForKey:@"results"];
        if ([infoArray count]) {
            NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
            NSString *lastVersion = [releaseInfo objectForKey:@"version"];
            
            if (![lastVersion isEqualToString:currentVersion]) {
                //trackViewURL = [releaseInfo objectForKey:@"trackVireUrl"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本更新，是否前往更新？" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
                alert.tag = 10000;
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"此版本为最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alert.tag = 10001;
                [alert show];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [loginInfo.progressBarView removeFromSuperview];
        [globalContext showAlertView:@"网络异常"];
        
    }];
    
}
-(void)grade{

    NSString *str = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%d",923182521];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
-(void)removeCache{

    NSCache  *memCache = [[NSCache alloc] init];
    [memCache removeAllObjects];
    
    loginInfo.allDownloadedImage = nil;
    
    [globalContext addStatusBarNotification:@"清除成功"];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10000) {
        if (buttonIndex==1) {
            NSString *str = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%d",923182521];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
    }
}
- (IBAction)userExitAction:(id)sender {
    
    [self.view removeFromSuperview];
     self.view = nil;
    
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
 //   NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:Domain]];
    NSArray* facebookCookies = [cookies cookies];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        
        NSLog(@"%@:%@",cookie.name,cookie.domain);
        
        if([cookie.name isEqualToString:@"USER_ID"]){
            [cookies deleteCookie:cookie];
            break;
        }
    }
    

    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLogin" object:nil];
}
@end
