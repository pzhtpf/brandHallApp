//
//  FirstViewController.m
//  brandv1.2
//
//  Created by Apple on 14-7-24.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "FirstViewController.h"
#import "ProgressBarView.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "globalContext.h"
//#import "UIImage+Resize.h"
#import <MessageUI/MessageUI.h>
#import "Define.h"
#import "typeSearchTableViewController.h"


@interface FirstViewController ()

@end

@implementation FirstViewController
LoginInfo *loginInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initView];
    
}
- (void)viewWillUnload
{
    [super viewWillUnload];
	// Do any additional setup after loading the view, typically from a nib.
    
}
-(void)initView{
    
    for(UITabBarItem *item in self.tabBarController.tabBar.items) {
        // use the UIImage category code for the imageWithColor: method
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    [loginInfo.progressBarView setTip:@"正在加载......"];
    [self.view addSubview:loginInfo.progressBarView];
    
    //  [self addInfoButton];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(startLoadView:) object:nil];
    [thread start];
    
}

-(void)startLoadView:(id)data{
    
    
    @autoreleasepool {
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mall.gezlife.com/vtour/cxl/"]];
        [self.webView setDelegate:self];
        [self.webView loadRequest:request];
    }
    
    
    
    //   NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index"
    //                                                       ofType:@"html"
    //                                                  inDirectory:@"/www" ];
    
    //   NSString *html = [NSString stringWithContentsOfFile:htmlPath
    //                                             encoding:NSUTF8StringEncoding
    //                                                error:nil];
    
    //[self.webView loadHTMLString:html
    //                baseURL:[NSURL fileURLWithPath:
    //                      [NSString stringWithFormat:@"%@/www/",
    //                         [[NSBundle mainBundle] bundlePath]]]];
    
    // [NSThread sleepForTimeInterval:2];
    // [progressView.view removeFromSuperview];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"%@",@"hi,哥们,发生内存警告了");
    // [self.webView removeFromSuperview];
    //   self.webView = nil;
    // [globalContext showAlertView:@"系统内存不足，程序可能会强制退出"];
}
- (void)webViewDidStartLoad:(UIWebView  *)webView{}
- (void)webViewDidFinishLoad:(UIWebView  *)webView{
    
    [loginInfo.progressBarView removeFromSuperview];
}
- (void)webView:(UIWebView *)webView  didFailLoadWithError:(NSError *)error{
    [loginInfo.progressBarView removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    
    if(self.webView == nil){
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 44,self.view.frame.size.width, 670)];
        [self.view addSubview:self.webView];
        [self initView];
        
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    
    [self.webView removeFromSuperview];
    self.webView = nil;
    
    NSCache  *memCache = [[NSCache alloc] init];
    [memCache removeAllObjects];
}
@end
