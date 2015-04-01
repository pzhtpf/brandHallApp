//
//  lanuchImageController.m
//  brandv1.2
//
//  Created by Apple on 14-9-27.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "lanuchImageController.h"
#import "pageControl.h"
#import "downloadImage.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "DBHelper.h"
#import "AFNetworking.h"
#import "Define.h"
#import "typeSearchTableViewController.h"
#import "globalContext.h"
#import "UIImage+Helpers.h"
#import "settingViewController.h"
#import "UIImage+Resize.h"
#import "AppDelegate.h"

@interface lanuchImageController ()

@end

@implementation lanuchImageController
@synthesize pageController;
pageControl *pagecontrol;
LoginInfo *loginInfo;
bool isInitState = false;
UIButton *contractUs;
UIButton *logout;
UIButton *infoButton;
UIButton *userButton;
typeSearchTableViewController *typeSearch;
UIImageView *imageView;
UITabBarController *tabBarController;
UIPopoverController *popController;
settingViewController *setting;
int lanuchPageIndex =0;
UIViewController *loginController;
bool EndDragging = false;
int lastOffsetX = 0;
UIImage *shareImage;
NSString *shareText;
NSMutableArray *tabItemArray;

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
    loginInfo.housesType = 0;
    loginInfo.isProductDetail = false;
    loginInfo.permissionsMutableArray = permissionsArray;
    loginInfo.defaultPermissionsMutableArray = defaultPermissionsArray;
    
    [globalContext startDownloadThread];    //如果有下载任务，则开始下载
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLogin:) name:@"goToLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSettingView:) name:@"addSettingView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addShareView:) name:@"addShareView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contractUs:) name:@"contractUs" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addInfoView:) name:@"addInfoView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLoadView:) name:@"startLoadView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUITapGestureRecognizer:) name:@"addUITapGestureRecognizer" object:nil];

        
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(getLanuchData:) object:nil];
        [thread start];
        
        [globalContext judgeHousesList];
    
        [self getData];
  
        [self tabItemPression];
    
        [globalContext checkVersion];
    
        [self changeBrandLogo];

}
-(void)changeBrandLogo{

    NSDictionary *brandDetail = [DBHelper getBrandDetailFromDB];
    
    if(brandDetail.count>0){
        
        if(![globalContext detectBrandIDIsChange])
        loginInfo.brandName = [brandDetail objectForKey:@"name"];
        loginInfo.brand_logo_app = [brandDetail objectForKey:@"local_logo_app"];
    }
    else{
    
        [globalContext getBrandhallDetail];

    }

}
-(void)lanuchToMain:(id)sender{

    if(!loginInfo.isWiFi){
        
        [self isInitCompleted];
    }
    else{
        if(!isInitState){
            [loginInfo.progressBarView setTip:@"初始化中......"];
            [self.view addSubview:loginInfo.progressBarView];
            
            NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(judgeInitComplete:) object:nil];
            [thread start];
        }
        else{
            [self isInitCompleted];
        }
    }


}
-(void)judgeInitComplete:(id)sender{

    while (true) {
        if(isInitState){
            [loginInfo.progressBarView removeFromSuperview];
            [self isInitCompleted];
            break;
        }
        [NSThread sleepForTimeInterval:1];
    }

}
-(void)isInitCompleted{
    
  //  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToLogin" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startLoadView" object:nil];
    
    
    // [self performSegueWithIdentifier:@"goToLogin" sender:self];
    [self performSegueWithIdentifier:@"goToMain" sender:self];
    [pageController.view removeFromSuperview];
    pageController.view = nil;
    [pagecontrol removeFromSuperview];
    pagecontrol = nil;
    pageController = nil;

}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goToMain"]) //"goView2"是SEGUE连线的标识
    {
        UITabBarController *theSegue = segue.destinationViewController;
        NSMutableArray *newViewControllers = [NSMutableArray arrayWithArray:theSegue.viewControllers];
        NSMutableArray *new = [[NSMutableArray alloc] init];
        [self orderBy];
        for(NSNumber *temp in loginInfo.defaultPermissionsMutableArray){
        
            int index = [temp intValue];
            if(index<newViewControllers.count){
             
                [new addObject:newViewControllers[index]];
            }
        }
        
        [theSegue setViewControllers:new];
        tabBarController = theSegue;
   //     [self addInfoButton:theSegue];
        
//        CGRect viewFrame=tabBarController.tabBar.frame;
//        //Sample parameters, add what fits your needs
//     
//        viewFrame.size.height=50;
//        viewFrame.size.width=200;
//        tabBarController.tabBar.frame=viewFrame;
        
        [self addFooterView];

    }
}
-(void)orderBy{

    for(int i=0; i<loginInfo.defaultPermissionsMutableArray.count;++i){
        for(int j=(int)loginInfo.defaultPermissionsMutableArray.count-1;j>i;--j){
            if([loginInfo.defaultPermissionsMutableArray[j] intValue] < [loginInfo.defaultPermissionsMutableArray[j-1] intValue]){
              NSNumber *temp = loginInfo.defaultPermissionsMutableArray[j];
                loginInfo.defaultPermissionsMutableArray[j] = loginInfo.defaultPermissionsMutableArray[j-1];
                loginInfo.defaultPermissionsMutableArray[j-1] = temp;
            }
        }
    }

}
-(void)getLanuchData:(id)sender{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[BASEURL stringByAppendingString:getLanuchApi] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //    NSLog(@"JSON: %@", responseObject);
        
        NSArray *rootArray = responseObject;
        
    //    NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for(NSDictionary *temp in rootArray){
            
            NSString *name = [temp objectForKey:@"imageUrl"];
            NSArray *names = [name componentsSeparatedByString:@"/"];
            NSString *path = name;
            [downloadImage downloadImage:path name:names[names.count-1]];
            
      //      NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:names[names.count-1],@"path", nil];
      //      [array addObject:data];
        }
        
        
        
      //  [loginInfo.lanuchImages addObjectsFromArray:rootArray];
        
     //   loginInfo.lanuchImages = [rootArray mutableCopy];
        [DBHelper lanuchImageSaveToDB:rootArray];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
    }];
    
}
-(void)getData{
    
    if(loginInfo.lanuchImages.count>0){
        
        loginInfo.collocationType = 4;
        [self initPage:loginInfo.lanuchImages];
    }
    else{
        loginInfo.collocationType = 5;
        
        NSDictionary *path1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"品牌官app启动2.jpg",@"@",nil];
        NSDictionary *path2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"07info2(1).png",@"imageUrl",nil];
        NSMutableArray * data = [[NSMutableArray alloc] init];
        [data addObject:path1];
        [data addObject:path2];
        [loginInfo.lanuchImages addObject:path1];
        [loginInfo.lanuchImages addObject:path2];
        [self initPage:loginInfo.lanuchImages];
        
    }
    
}
-(void)initPage:(NSMutableArray *)array{
    
    
    
    NSMutableArray *detailData = [[NSMutableArray alloc] init];
    
//    int count = 0;
//    for (NSDictionary *path in array) {
//        
//        NSDictionary *temp =[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:count],@"id",[path objectForKey:@"imageUrl"],@"image" ,[path objectForKey:@"data"],@"data",nil];
//        [detailData addObject:temp];
//        count++;
//    }
    
    for (int i =0;i<6;i++) {
        
        NSDictionary *temp =[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:i],@"id",[NSString stringWithFormat:@"lanuch%d.png",i+1],@"image",nil];
        [detailData addObject:temp];
    }
    

    loginInfo.lanuchImages = detailData;
    
    UIImageView *backGroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,1024,768)];
    [self.view addSubview:backGroundImage];
    
    NSString *pathImage = [[NSBundle mainBundle]pathForResource:@"lanuchBackImage.png" ofType:@""];
    
    UIImage * result = [UIImage imageWithContentsOfFile:pathImage];
    
    if(result)
    {
        
        result = [result resizedImage:result.size interpolationQuality: kCGInterpolationHigh];
        
        
        
        [backGroundImage setImage:result];
        result = nil;
    }

    
    _pModel = [[CWPageModel alloc] init];
    [_pModel createContentPages:detailData];
    
    
    NSDictionary *options =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                forKey: UIPageViewControllerOptionSpineLocationKey];
    
    pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                     navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                   options:options];
    pageController.delegate = self;
    
    CWPageController *initialViewController =
    [_pModel viewControllerAtIndex:0];
    NSArray *viewControllers =
    [NSArray arrayWithObject:initialViewController];
    [pageController setDataSource:_pModel];
    
    [pageController setViewControllers:viewControllers
                             direction:UIPageViewControllerNavigationDirectionReverse
                              animated:NO
                            completion:^(BOOL f){}];
    [self addChildViewController:pageController];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 8)
    pageController.view.frame = CGRectMake(252,76,250,870);
    
    else
     pageController.view.frame = CGRectMake(252,76,520,615);
    
    pageController.view.layer.cornerRadius = 8;
    [self.view addSubview:pageController.view];
    [pageController didMoveToParentViewController:self];
    
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
//    scrollView.contentSize = CGSizeMake(1024*6,768);
//    scrollView.delegate = self;

    
      [self addDot:6];
    
//    [self switchLanuchImage:scrollView];
    
   
}
-(void)switchLanuchImage:(UIScrollView *)scrollView1{
    
    // 520 * 615
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    scrollView.contentSize = CGSizeMake(772*5+1024,768);
    scrollView.delegate = self;
    scrollView.tag = 477;
    [self.view insertSubview:scrollView belowSubview:pagecontrol];
  //   [self.view addSubview:scrollView];
    
    for (int i= 0; i<6;i++) {
        
  
    
    UIImageView *mainView =[[UIImageView alloc] initWithFrame:CGRectMake(252+i*(252+520),76,520,615)];
  //  mainView.center = scrollView.center;
    mainView.tag= 935;
   // mainView.alpha = 0;
    
    NSString *pathImage;
    
    switch (i) {
        case 0:
           pathImage = [[NSBundle mainBundle]pathForResource:@"lanuch1.png" ofType:@""];
            break;
        case 1:
           pathImage = [[NSBundle mainBundle]pathForResource:@"lanuch2.png" ofType:@""];
            break;
        case 2:
            pathImage = [[NSBundle mainBundle]pathForResource:@"lanuch3.png" ofType:@""];
            break;
        case 3:
            pathImage = [[NSBundle mainBundle]pathForResource:@"lanuch4.png" ofType:@""];
            break;
        case 4:
            pathImage = [[NSBundle mainBundle]pathForResource:@"lanuch5.png" ofType:@""];
            break;
        case 5:
            pathImage = [[NSBundle mainBundle]pathForResource:@"lanuch6.png" ofType:@""];
            break;
        default:
            break;
    }



        
        UIImage * result = [UIImage imageWithContentsOfFile:pathImage];
        
        if(result)
        {
            
            result = [result resizedImage:result.size interpolationQuality: kCGInterpolationHigh];
            
            [mainView setImage:result];
            result = nil;
        }
 
    [scrollView addSubview:mainView];
    
  //  if(lanuchPageIndex ==5){
        
      if(i ==5){
    
        UIButton *tiyanButton = [[UIButton alloc] initWithFrame:CGRectMake(212,565, 96, 27)];
        tiyanButton.layer.cornerRadius = 5;
        [tiyanButton setBackgroundColor:UIColorFromRGB(0x3a5697)];
        [tiyanButton setTitle:@"开始体验" forState:UIControlStateNormal];
        tiyanButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];
        [tiyanButton addTarget:self action:@selector(lanuchToMain:) forControlEvents:UIControlEventTouchUpInside];
        tiyanButton.tag =478;
        
          mainView.userInteractionEnabled = YES;
          
        [mainView addSubview:tiyanButton];

    }

        
}
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSLog(@" scrollViewDidScroll");
    EndDragging = false;
    
    float x = scrollView.contentOffset.x/772;
    
    int  thisLanuchPageIndex = round(x);
    
    if(lanuchPageIndex != thisLanuchPageIndex){
        
          EndDragging = true;
        
      if(lanuchPageIndex >thisLanuchPageIndex)
          lanuchPageIndex--;
       else if(lanuchPageIndex < thisLanuchPageIndex)
            lanuchPageIndex++;
    
    [scrollView setContentOffset:CGPointMake(lanuchPageIndex*772, 0) animated:YES];
    
     if(lanuchPageIndex == 5)
          [pagecontrol setHidden:true];
        else
        [pagecontrol setHidden:false];

        
    
    [self pageChanged:lanuchPageIndex];
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

  //  EndDragging = false;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
  //  NSLog(@"scrollViewDidEndDragging");
  //  NSLog(@"ContentOffset  x is  %f,yis %f",scrollView.contentOffset.x,scrollView.contentOffset.y);
  //   EndDragging = true;
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating  -   End of Scrolling.");
    
    if(!EndDragging){
        
        float x = scrollView.contentOffset.x/772;
        
        int  thisLanuchPageIndex = round(x);
        
        
        [scrollView setContentOffset:CGPointMake(thisLanuchPageIndex*772, 0) animated:YES];
        
        if(lanuchPageIndex == 5)
            [pagecontrol setHidden:true];
        else
            [pagecontrol setHidden:false];
        
        [self pageChanged:thisLanuchPageIndex];
    }

    
}

-(void)addDot:(int)count{
    
 //   NSLog(@"%d",count);
    
    if(pagecontrol ==nil){
        pagecontrol = [[pageControl alloc] initWithFrame:CGRectMake(0,648,1024, 20)];
        [pagecontrol setPageCount:count];
        
        [self.view addSubview:pagecontrol];
        
        UIButton *skip = [[UIButton alloc] initWithFrame:CGRectMake(900,700, 75, 30)];
        [skip setTitle:@"跳过" forState:UIControlStateNormal];
        skip.layer.cornerRadius = 5;
        skip.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];
        [skip setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        [skip addTarget:self action:@selector(lanuchToMain:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:skip];
        
//        UIButton *login = [[UIButton alloc] initWithFrame:CGRectMake(815,700, 75, 30)];
//        [login setTitle:@"登录" forState:UIControlStateNormal];
//        login.layer.cornerRadius = 5;
//        login.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];
//        [login setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
//        [login addTarget:self action:@selector(goLogin:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:login];
        
    }
    else{
        
        [pagecontrol setPageCount:count];
        
    }
}
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
    if(completed)
    {
        
        
        UIView *temp  = [[pageViewController.viewControllers objectAtIndex:0] view];
        
        NSArray *allViews =[temp subviews];
        for(UIView *x in allViews){
            if([x isKindOfClass:[UIImageView class]]){
                
                if(x.tag==loginInfo.lanuchImages.count-1){
                    [pagecontrol setHidden:true];
                    
                    if(![temp viewWithTag:478]){
                    UIButton *tiyanButton = [[UIButton alloc] initWithFrame:CGRectMake(212,565, 96, 27)];
                    tiyanButton.layer.cornerRadius = 5;
                    [tiyanButton setBackgroundColor:UIColorFromRGB(0x3a5697)];
                    [tiyanButton setTitle:@"开始体验" forState:UIControlStateNormal];
                    tiyanButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];
                    [tiyanButton addTarget:self action:@selector(lanuchToMain:) forControlEvents:UIControlEventTouchUpInside];
                    tiyanButton.tag =478;
                    
                    temp.userInteractionEnabled = YES;
                    
                    [temp addSubview:tiyanButton];
                    }
                }
                else
                    [pagecontrol setHidden:false];

                
                [self pageChanged:(int)x.tag];
                
                break;
                
            }
            
        }
        
    }
}
-(void)pageChanged:(int)tag{
    
    
    if(pagecontrol){
        
        [pagecontrol setSelected:tag];
    }
    
}


-(void)addWebView:(NSString *)url{
    
    @autoreleasepool {
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        webView.tag =987;
        
        [self.view addSubview:webView];
        
        UIButton *e = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50,30, 40, 40)];
        [e setBackgroundImage:[UIImage imageNamed:@"叉.png"] forState:UIControlStateNormal];
        [e addTarget:self action:@selector(removeWebView:) forControlEvents:UIControlEventTouchUpInside];
        [webView addSubview:e];
        
        [webView setDelegate:self];
        [webView loadRequest:request];
    }
    
    
    
    
    //   NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(startLoadView:) object:url];
    //   [thread start];
    
}

-(void)startLoadView:(NSNotification *)notification{
    
    NSString *url= [notification object];
    
    @autoreleasepool {
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        webView.tag =987;
        
        [self.view addSubview:webView];
        
        [webView setDelegate:self];
        [webView loadRequest:request];
    }
    
}

- (void)webViewDidStartLoad:(UIWebView  *)webView{
    
    
    [loginInfo.progressBarView setTip:@"正在加载......"];
    [webView addSubview:loginInfo.progressBarView];
    
    UIButton *e = [[UIButton alloc] initWithFrame:CGRectMake(974,30, 40, 40)];
    [e setBackgroundImage:[UIImage imageNamed:@"叉.png"] forState:UIControlStateNormal];
    [e addTarget:self action:@selector(removeWebView:) forControlEvents:UIControlEventTouchUpInside];
    [webView addSubview:e];
    
    
}
- (void)webViewDidFinishLoad:(UIWebView  *)webView{
    
    [loginInfo.progressBarView removeFromSuperview];
}
- (void)webView:(UIWebView *)webView  didFailLoadWithError:(NSError *)error{
    [loginInfo.progressBarView removeFromSuperview];
}
-(void)removeWebView:(id)sender{
    
    UIButton *close  = (UIButton *)sender;
    [close removeFromSuperview];
    close = nil;
    UIView *view = [self.view viewWithTag:987];
    [view removeFromSuperview];
    view = nil;
    
}

-(void)tabItemPression{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[BASEURL stringByAppendingString:permissionsControlApi] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
     //   NSLog(@"JSON: %@", responseObject);
        
        NSMutableArray *rootArray = responseObject;
        
        if([rootArray isKindOfClass:[NSMutableArray class]]){
       
        for(int i =0;i< loginInfo.permissionsMutableArray.count;i++){
        
            if(i ==1||i==2|| i==5){
            
                continue;
            }
            for(NSDictionary *temp in rootArray){
            
                if([loginInfo.permissionsMutableArray[i] isEqualToString:[temp objectForKey:@"url"]]){
                
                    [loginInfo.defaultPermissionsMutableArray addObject:[NSNumber numberWithInt:i]];
                    break;
                }
                
            }
        
        }
        }
           isInitState = true;
        
            } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"Error: %@", error);
                
            [DBHelper getDataFromPlanTable:0];
                if(loginInfo.dataFromPlanTable.count>0){
                  [loginInfo.defaultPermissionsMutableArray addObject:[NSNumber numberWithInt:6]];
                }
            isInitState = true;
        
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    [pageController.view removeFromSuperview];
    pageController.view = nil;
    [pagecontrol removeFromSuperview];
     pagecontrol= nil;
    
    NSCache  *memCache = [[NSCache alloc] init];
    [memCache removeAllObjects];
}


-(void)goToLogin:(id)sender{
    
    //    [loginInfo superDealloc];
    //    loginInfo.planSearch = @"";
    //    loginInfo.productSearch = @"";
    //    loginInfo.houseSearch = @"";
    //    loginInfo.loadingName = @"";
    //    loginInfo = nil;
    
    
    infoButton = nil;
    [popController dismissPopoverAnimated:YES];
    loginInfo.isLogin = true;
    popController = nil;
    
//    tabBarController.modalPresentationStyle = UIModalPresentationCurrentContext;
//    [tabBarController performSegueWithIdentifier:@"goToLogin" sender:tabBarController];
    
    loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
 //   tabBarController.modalPresentationStyle = UIModalPresentationCurrentContext;
 //   [tabBarController presentViewController:login animated:NO completion:nil];
 //   [tabBarController.view addSubview:loginController.view];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    
    
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    
    NSArray *subViews = [window subviews];
    
  [[subViews objectAtIndex:subViews.count-1] addSubview:loginController.view];

    
}
- (void)searchAction:(id)sender {
    
    //   UIButton *x =sender;
    typeSearch = [[typeSearchTableViewController alloc] init];
    
    typeSearch.view.frame = CGRectMake(0, 0, 110, 40);
    
    popController = [[UIPopoverController alloc] initWithContentViewController:typeSearch];
    popController.popoverContentSize = CGSizeMake(110,40);
    popController.delegate=self;
    
    
    CGRect frame = CGRectMake(self.view.frame.size.width-130,20,110, 40);
    
    [typeSearch initView:4];
    
    [popController presentPopoverFromRect:frame inView:tabBarController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}


-(void)addInfoView:(id)sender{
    
//    UIButton *infoButton = (UIButton *)sender;
//    [infoButton setEnabled:false];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    imageView.alpha = 0;
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"07info2(1).png" ofType:@""];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    if(image){
        //  image = [image resizedImage:image.size interpolationQuality: kCGInterpolationLow];
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
        //  UIGraphicsBeginImageContext(thumbImage.size);
        [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        imageView.image = image;
    }
    
    
    UIButton *e = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50,30, 40, 40)];
    [e setBackgroundImage:[UIImage imageNamed:@"叉.png"] forState:UIControlStateNormal];
    [e addTarget:self action:@selector(onInfoTap:) forControlEvents:UIControlEventTouchUpInside];
    e.alpha = 0;
    
    contractUs = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-77,self.view.frame.size.height-100,154, 40)];
    // [contractUs setTitle:@"联系我们" forState:UIControlStateNormal];
    [contractUs setImage:[UIImage imageNamed:@"联系我们.png"] forState:UIControlStateNormal];
    [contractUs setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [contractUs addTarget:self action:@selector(contractUs:) forControlEvents:UIControlEventTouchUpInside];
    contractUs.alpha = 0;
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    [[[window subviews] objectAtIndex:0] addSubview:imageView];
    [[[window subviews] objectAtIndex:0] addSubview:e];
    [[[window subviews] objectAtIndex:0] addSubview:contractUs];
    
//    [infoButton setEnabled:false];
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         imageView.alpha = 1;
                         e.alpha = 1;
                         contractUs.alpha = 1;
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}
- (void)onInfoTap:(id)sender{
    
     __block UIButton *close = (UIButton *)sender;
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         imageView.alpha = 0;
                         close.alpha = 0;
                         contractUs.alpha = 0;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         UIButton *infoButton = (UIButton *)[loginInfo.topBarView viewWithTag:4];
                         [infoButton setEnabled:true];
                         [imageView removeFromSuperview];
                         imageView = nil;
                         [close removeFromSuperview];
                         close = nil;
                         [contractUs removeFromSuperview];
                         contractUs = nil;
                         [infoButton setEnabled:true];
                     }
     ];
    
   
    
}
- (void)contractUs:(id)sender{
 
    if ([MFMailComposeViewController canSendMail]) {
            // device is configured to send mail
        // Email Subject
        NSString *emailTitle = @"";
        // Email Content
        NSString *messageBody = @"";
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:@"leju@gezlife.com"];

        
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:YES];
            [mc setToRecipients:toRecipents];
            
            // Present mail view controller on screen
            [tabBarController presentViewController:mc animated:YES completion:NULL];
            
        }
 
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请配置邮件账号" message:@"邮件帐号为空，请在 \n设置—>邮件—>添加帐户 \n中添加" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 10000;
        [alert show];
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10000) {
        if (buttonIndex==1) {
//            NSURL*url=[NSURL URLWithString:@"prefs:root=ACCOUNT_SETTINGS"];
//            [[UIApplication sharedApplication] openURL:url];
            
   //         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
            
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            
        }
    }
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [controller dismissViewControllerAnimated:YES completion:NULL];
}
-(void)addShareView:(NSNotification *) notification{

//    typeSearch = [[typeSearchTableViewController alloc] init];
//    
//    typeSearch.view.frame = CGRectMake(0, 0,335,104);
//    
//    popController = [[UIPopoverController alloc] initWithContentViewController:typeSearch];
//    popController.popoverContentSize = CGSizeMake(335,104);
//    popController.delegate=self;
//    
//    
//    CGRect frame = CGRectMake(740,-50,335,104);
//    
//    [typeSearch initView:9];
//    
//    [popController presentPopoverFromRect:frame inView:tabBarController.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    NSString *shareImagePath = [[NSBundle mainBundle] pathForResource:@"systemLanuch.png" ofType:@""];
    shareImage = [UIImage imageWithContentsOfFile:shareImagePath];
    
    shareText = @"格致生活,设计你家居的新途径！";

    
    NSArray *data = [notification object];
    
    UIButton *sender = data[0];
    
    if(data.count>1)
       shareImage = data[1];
    
    if(data.count>2)
       shareText = data[2];
    
    
    NSString *moreIconPath = [[NSBundle mainBundle] pathForResource:@"moreIcon.png" ofType:@""];
    
      //[ShareSDK imageWithPath:imagePath]
    
    id<ISSContent> publishContent = [ShareSDK content:shareText
                                       defaultContent:nil
                                                image:[ShareSDK imageWithData:UIImagePNGRepresentation(shareImage) fileName:@"shareImage" mimeType:@"png"]
                                                title:@"格致生活"
                                                  url:@"http://www.gezlife.com"
                                          description:@"格致生活,设计你家居的新途径！"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //创建容器
    id<ISSContainer> container = [ShareSDK container];
    
    if(!loginInfo.isProductDetail){
        
       [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    }
    else{
    
      [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionDown];
    }
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    id<ISSShareActionSheetItem> more = [ShareSDK shareActionSheetItemWithTitle:@"更多"
                                                                          icon:[UIImage imageWithContentsOfFile:moreIconPath]
                                                                   clickHandler:^{
                                                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                                                           message: @"没有更多呢!"
                                                                                                                          delegate:nil
                                                                                                                 cancelButtonTitle: @"确定"
                                                                                                                 otherButtonTitles:nil];
                                                                       [alertView show];
                                                                       
                                                                   }];
    
    NSArray *shareList = [ShareSDK customShareListWithType:
                          [NSNumber numberWithInteger:ShareTypeSinaWeibo],
                          [NSNumber numberWithInteger:ShareTypeWeixiSession],
                          [NSNumber numberWithInteger:ShareTypeTencentWeibo],
                          [NSNumber numberWithInteger:ShareTypeQQ],
                          [NSNumber numberWithInteger:ShareTypeQQSpace],
                          more,
                          nil];
    
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                          oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                           qqButtonHidden:NO
                                                    wxSessionButtonHidden:NO
                                                   wxTimelineButtonHidden:NO
                                                     showKeyboardOnAppear:NO
                                                        shareViewDelegate:self
                                                      friendsViewDelegate:self
                                                    picViewerViewDelegate:self]
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"分享成功"));
                                //    [globalContext showAlertView:@"分享成功"];
                   
                                    [globalContext addStatusBarNotification:@"分享成功"];

                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    if([error errorCode] == -24002)
                                        
                                        [globalContext showAlertView:@"尚未安装QQ"];
                                    
                                    else if([error errorCode] == -6004)

                                         [globalContext showAlertView:@"尚未安装QQ空间"];

                                    else
                                        [globalContext showAlertView:[NSString stringWithFormat:@"错误码:%ld,错误描述:%@", [error errorCode], [error errorDescription]]];
                                    
                                }
                            }];
}

#pragma mark - ISSShareViewDelegate

- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(ShareType)shareType
{
    
    
    shareImage = [shareImage resizedImage:shareImage.size interpolationQuality: kCGInterpolationHigh];

    
    UIImageView *replaceView = [[UIImageView alloc] initWithFrame:CGRectMake(370, 50, 100,76)];
    [replaceView setImage:shareImage];
    
    NSArray  *subviews = [viewController.view subviews];
    
    UIView *view = subviews[0];
    
    [view addSubview:replaceView];
    

}

-(void)login:(id)sender{

   
}
-(void)addSettingView:(id) sender{

    setting  = [[settingViewController alloc] init];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    
    NSArray *subViews = [window subviews];
    
    [[subViews objectAtIndex:subViews.count-1] addSubview:setting.view];

    
}
-(void)addUITapGestureRecognizer:(NSNotification *)notification{

    UIView *view = [notification object];
    
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapRemoveStatusNotification:)]];

}
-(void)tapRemoveStatusNotification:(UIGestureRecognizer *)gestureRecognizer{
    
    __block UIView *view = [gestureRecognizer view];
    
    if(view){
        
        [UIView setAnimationsEnabled:true];
        
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                             view.frame = CGRectMake(0,-44,1024,44);
                             
                         }
                         completion:^(BOOL finished) {
                             
                             UILabel *label = (UILabel *)[view viewWithTag:56];
                             
                             NSString *key = label.text;
                             
                            [loginInfo.notificationQueue removeObjectForKey:key];
                             
                             [view removeFromSuperview];
                             view = nil;
                             
                          
                         }
         ];
        
    }
    
    
}
-(void)addFooterView{
    
    tabItemArray = [[NSMutableArray alloc] init];

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 695, 1024, 73)];
    [footerView setBackgroundColor:UIColorFromRGB(0x222222)];
    
  //  UIWindow* window = [UIApplication sharedApplication].keyWindow;
  //  [[NSMutableArray alloc] initWithObjects:@"app/shop",@"/plan/index",@"product/index",@"app/property",@"self/design",@"app/offline", nil];
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake((1024-115*loginInfo.defaultPermissionsMutableArray.count)/2, 0, 115*loginInfo.defaultPermissionsMutableArray.count, 73)];
  //  [mainView setBackgroundColor:[UIColor redColor]];
  
    for(int i=0; i<loginInfo.defaultPermissionsMutableArray.count;++i){
        int flag = [loginInfo.defaultPermissionsMutableArray[i] intValue];
        UIView *tabItemView = [[UIView alloc] initWithFrame:CGRectMake(i*115, 0, 115, 73)];
        tabItemView.tag = i;
        [tabItemView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabItemSelect:)]];
        
        NSString *path;
        NSString *name;
        
        
        UIImageView *imageView =[[UIImageView  alloc] initWithFrame:CGRectMake(41,11, 32, 32)];
        imageView.tag = i;
        
        
        [tabItemView addSubview:imageView];
        
        UILabel *tabItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 47
                                                                          , 115, 15)];
       
        tabItemLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
        tabItemLabel.textAlignment = NSTextAlignmentCenter;
        tabItemLabel.tag= flag;

        
        
        if(i!=0){
        
            [tabItemLabel setTextColor:UIColorFromRGB(0x999999)];
            
        switch (flag) {
            case 0:
                path = @"store.png";
                name = @"店铺展示";
                break;
            case 1:
                path = @"3d.png";
                 name = @"设计方案";
                break;
            case 2:
                path = @"product.png";
                 name = @"商品展示";
                break;
            case 3:
                path = @"location.png";
                 name = @"楼盘和户型  ";
                break;
            case 4:
                path = @"diy.png";
                 name = @"自主设计 ";
                break;
            case 5:
                path = @"pic.png";
                name = @"家居美图";
                break;
            case 6:
                path = @"download.png";
                 name = @"离线缓存";
                break;
            default:
                break;
        }
        }
        
        else{
        
            [tabItemLabel setTextColor:UIColorFromRGB(0xffffff)];

            
            switch (flag) {
                case 0:
                    path = @"store-hover.png";
                    name = @"店铺展示";
                    break;
                case 1:
                    path = @"3d-hover.png";
                     name = @"设计方案";
                    break;
                case 2:
                    path = @"product-hover.png";
                    name = @"商品展示";
                    
                    break;
                case 3:
                    path = @"location-hover.png";
                    name = @"楼盘和户型  ";
                    break;
                case 4:
                    path = @"diy-hover.png";
                     name = @"自主设计 ";
                    break;
                case 5:
                    path = @"pic-hover.png";
                    name = @"家居美图";
                    break;
                case 6:
                    path = @"download-hover.png";
                     name = @"离线缓存";
                    break;
                default:
                    break;
            }

        }
        
        NSString *searchString = [[NSBundle mainBundle]pathForResource:path ofType:@""];
        UIImage *image = [UIImage imageWithContentsOfFile:searchString];
        [imageView setImage:image];
        image = nil;
        
        [tabItemLabel setText:name];
        [tabItemView addSubview:tabItemLabel];
        
        [mainView addSubview:tabItemView];
        
        [tabItemArray addObject:tabItemView];
        
    }

    
  //  [mainView setCenter:footerView.center];
    [footerView addSubview:mainView];
    [tabBarController.view addSubview:footerView];
}
-(void)tabItemSelect:(UIGestureRecognizer *)sender{
    
    UIView *superView = [sender view];

    for(int i =0;i<tabItemArray.count;i++){
    
        UIView *view =tabItemArray[i];
        NSArray *subViews = [view subviews];
        
        UIImageView *button = subViews[0];
        
        UILabel *label = subViews[1];
        
        if(i== superView.tag){
          
            [label setTextColor:[UIColor whiteColor]];
            
            NSString *path;
            
            int flag = label.tag;
            switch (flag) {
                case 0:
                    path = @"store-hover.png";
                    break;
                case 1:
                    path = @"3d-hover.png";
                    break;
                case 2:
                    path = @"product-hover.png";
                    
                    break;
                case 3:
                    path = @"location-hover.png";
                    break;
                case 4:
                    path = @"diy-hover.png";
                    break;
                case 5:
                    path = @"pic-hover.png";
                    break;
                case 6:
                    path = @"download-hover.png";
                    break;
                default:
                    break;
            }
            
            NSString *searchString = [[NSBundle mainBundle]pathForResource:path ofType:@""];
            UIImage *image = [UIImage imageWithContentsOfFile:searchString];
            
            [button setImage:image];
            image = nil;
            
        }
        else{
         [label setTextColor:UIColorFromRGB(0x999999)];
            
            NSString *path;
            
            int flag = label.tag;
            switch (flag) {
                case 0:
                    path = @"store.png";
                    break;
                case 1:
                    path = @"3d.png";
                    break;
                case 2:
                    path = @"product.png";
                  
                    break;
                case 3:
                    path = @"location.png";
                    break;
                case 4:
                    path = @"diy.png";
                    break;
                case 5:
                    path = @"pic.png";
                    break;
                case 6:
                    path = @"download.png";
                    break;
                default:
                    break;
            }
            
            NSString *searchString = [[NSBundle mainBundle]pathForResource:path ofType:@""];
            UIImage *image = [UIImage imageWithContentsOfFile:searchString];
            
            [button setImage:image];

        }
    }
    
    [tabBarController setSelectedIndex:superView.tag];
}
@end
