//
//  DetailViewController.m
//  brandv1.2
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Apple. All rights reserved.
//
#include <math.h>
#import "DetailViewController.h"
#import "GoodsView.h"
#import "Define.h"
#import "AFNetworking.h"
#import "pageControl.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "DBHelper.h"
#import "globalContext.h"
#import "UIImageView+AFNetworking.h"
#import "loginViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize pageController = _pageController;
@synthesize goods;
@synthesize pModel = _pModel;
@synthesize mySegmentedControl;
float view0Height=0;
float view1Height=0 ;
float view2Height = 0;
float view3Height = 0;
NSDictionary *data;
NSDictionary *rootDic;
pageControl *pagecontrol;
NSArray *allData;
LoginInfo *loginInfo;
NSString *descriptionStr =@"";
NSMutableArray *detailDataArray;
int selectedIndex = 0;
float beginX = 0;
int planId;
int mainInfoViewY = 525;
NSMutableArray *huxingImageViewArray;
loginViewController *loginController;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initDescriptionView:) name:@"initDescriptionView" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [mySegmentedControl setHidden:true];
    
    self.collocationButton.layer.cornerRadius =5;
    self.detailButton.layer.cornerRadius =5;
    self.collocationButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
    [self.collocationButton setBackgroundColor:UIColorFromRGB(0x588CC7)];
    self.detailButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
    [self.detailButton setBackgroundColor:UIColorFromRGB(0x5ba83a)];
    self.mainViewBack.layer.cornerRadius = 5;
    self.huxingLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0f];
    self.mainPlanName.font =  [UIFont boldSystemFontOfSize:18.0];
    self.mainPlanName.font =  [UIFont fontWithName:@"MicrosoftYaHei-Bold" size:18.0f];
    
    [mySegmentedControl setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MicrosoftYaHei" size:14.0f], UITextAttributeFont, nil];
    [mySegmentedControl setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    loginInfo.collocationType = 1;
    
    self.back.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:16.0f];
    self.detailTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17.0f];
    
    [self.backView  addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backMessage:)]];
    UIPanGestureRecognizer *swipeRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [self.backView addGestureRecognizer:swipeRight];
    
    self.mainViewScroll.delegate = self;
   
    [self initViewAnimation];
}
-(void)initViewAnimation{
    
    
    self.mainViewBack.frame = CGRectMake(self.mainViewBack.frame.origin.x, 768, self.mainViewBack.frame.size.width, self.mainViewBack.frame.size.height);
    [self.backView setBackgroundColor:[UIColor clearColor]];
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         [self.backView setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.7]];
                         
                         CGRect  endFrame =  self.mainViewBack.frame;
                         endFrame.origin.y =10;
                         self.mainViewBack.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated

{
    
    [super viewDidAppear:animated];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        NSString *description = self.descriptionTextView.text;
//        
//        [self initDescriptionView:description];
//        
//    });
}
-(void)viewDidDisappear:(BOOL)animated{

 [super viewDidDisappear:YES];
    
   selectedIndex = 0;
    pagecontrol = nil;
}

-(void)initView:(int)id{
    
    [loginInfo.progressBarView setTip:@"正在加载......"];
    [self.view addSubview:loginInfo.progressBarView];
 
    planId = id;
    
    mainInfoViewY = 525;
    
    [self threadMethod:[NSNumber numberWithInt: id]];

}
-(void)threadMethod:(NSNumber *)planId{

    if(loginInfo.isOfflineMode){
        
        [self prepareOfflineData:[planId intValue]];
    }
    else
    {
        [self getDetailRequest:planId];
    }

}
-(void)getDetailRequest:(NSNumber *)planId{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSDictionary *parameters = @{@"id":planId};
    
    [manager POST:[BASEURL stringByAppendingString: planDetailApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
     //   NSLog(@"JSON: %@", responseObject);
        
        
        NSDictionary *tempData = responseObject;
        NSMutableArray *rootArray = [tempData objectForKey:@"data"];
        
        [self setFavoriteImage:self.favoriteButton status:[[tempData objectForKey:@"favorite"] intValue]];
        
        allData = [rootArray copy];
        
        [self getMessage:rootArray];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [loginInfo.progressBarView removeFromSuperview];
    }];


}
-(void)prepareOfflineData:(int)id{

    NSMutableArray *dataArray = [DBHelper  getDetailByHousesId:id];
    
    [self getMessage:dataArray];
}
-(void)getMessage:(NSMutableArray *)array{
    
  
    
        data = array[0];
    
        [self.back setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        [self.statusBar setBackgroundColor:UIColorFromRGB(0xf1f1f1)];
        
        [mySegmentedControl addTarget:self action:@selector(selected:) forControlEvents:UIControlEventValueChanged];
    
        NSString *name = [data objectForKey:@"name"];
        if([name isKindOfClass:[NSString class]] && name.length>0){
            [self.fName setText:name];
            [self.mainPlanName setText:name];
        }
        else{
            
            [self.fName setText:@"名称未知"];
            [self.mainPlanName setText:@"名称未知"];
        }
    
        NSString *style = [data objectForKey:@"style"];
        if([style isKindOfClass:[NSString class]] && style.length>0){
            [self.style setText:style];
            mainInfoViewY = mainInfoViewY + 100;
        }
        else{
            
            [self.style setText:@"风格未知"];
        }
    
        // [self.size setText:[NSString stringWithFormat:@"房间尺寸：%@*%@*%@",[data objectForKey:@"length"],[data objectForKey:@"width"],[data objectForKey:@"height"]]];
        [self.size setText:[NSString stringWithFormat:@"%@ x %@(mm)",[data objectForKey:@"length"],[data objectForKey:@"width"]]];
        
        descriptionStr = [data objectForKey:@"description"];
        if([descriptionStr isKindOfClass:[NSString class]] && descriptionStr.length>0){
            [self.descriptionTextView setHidden:false];
        }
        else{
            descriptionStr = @"描述未知";
            [self.descriptionTextView setHidden:true];
        }
    
     self.descriptionTextView.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];
     [self performSelector:@selector(initDescriptionView:) withObject:descriptionStr afterDelay:0.3];
    
       self.authorName.font = [UIFont fontWithName:@"MicrosoftYaHei" size:16.0f];
        NSString *authorName = [data objectForKey:@"authorName"];
        if([authorName isKindOfClass:[NSString class]] && authorName.length>0){
            [self.authorName setText:authorName];
        }
        else{
            
            [self.authorName setText:@"作者未知"];
        }
        
        NSArray *arrayTemp = [data objectForKey:@"data"];
        
       [self initGoods:arrayTemp];
        
        NSMutableArray *dataDetail = [NSMutableArray arrayWithArray:array];
        
        [self initPageView:dataDetail];
        [self initPageControl:dataDetail];
        
        [loginInfo.progressBarView removeFromSuperview];

    
 //   [self performSelectorInBackground:@selector(initDescriptionView:) withObject:descriptionStr];
    
 //   [self performSelector:@selector(initGoods:) withObject:arrayTemp afterDelay:0.1];

    
}

-(void)initDescriptionView:(NSString *) data{

    
    [self.descriptionTextView setText:descriptionStr];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 7) {
    
        _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y+30, _scrollView.frame.size.width, _scrollView.frame.size.height);
    }
    
    CGSize titleSize = [data sizeWithFont:self.descriptionTextView.font];
    float height = titleSize.width*titleSize.height/308;
    height = height > 30?height:30;
    
//    
   [UIView animateWithDuration:0.3f
                         delay:0.0f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        
    
                         CGRect endFrame=  self.descriptionTextView.frame;
                         endFrame.size.height=height;
                         self.descriptionTextView.frame = endFrame;
                         
                         CGRect goodsView=  self.goodsView.frame;
                         goodsView.origin.y= endFrame.origin.y+endFrame.size.height+10;
                        self.goodsView.frame = goodsView;
                        [mySegmentedControl setHidden:false];
                        
                    }
                     completion:^(BOOL finished) {
                         [mySegmentedControl setHidden:false];
                     }
    ];
    
}
-(void)initPageControl:(NSMutableArray *)array{
    
    huxingImageViewArray = [[NSMutableArray alloc] init];
    
    NSArray *subViews = [self.huxingScrollView subviews];
    
    for (int i= 0;i<subViews.count; i++) {
        if(i>1)
            [subViews[i] removeFromSuperview];
    }
    
    if(detailDataArray.count>1){
        
      self.huxingScrollView.hidden = false;
    
    for (int i = 0; i<detailDataArray.count; i++) {
        
        NSDictionary *temp = detailDataArray[i];
        
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(86+i*73, 0, 60, 60)];
        
        imageview.userInteractionEnabled = YES;
        [imageview addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSelectPlanTap:)]];
        imageview.tag = i;

        
        if (i==0) {
            imageview.layer.borderWidth = 1;
            imageview.layer.borderColor = [UIColor redColor].CGColor;
        }
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(86+i*73, 60, 60,20)];
        
        NSString *path = [imageUrl stringByAppendingString:[temp objectForKey:@"image"]];
        NSURL *pathUrl = [NSURL URLWithString:path];
        
        [imageview setCenterImageWithURL:pathUrl size:imageview.frame.size];
        
        [name setText:[temp objectForKey:@"name"]];
        
        name.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0f];
        name.textAlignment = NSTextAlignmentCenter;
        
        [self.huxingScrollView addSubview:imageview];
         [self.huxingScrollView addSubview:name];
        
        [huxingImageViewArray addObject:imageview];
       }
        
        [self.huxingScrollView setContentSize:CGSizeMake((detailDataArray.count+1)*73, 0)];
        
        if((detailDataArray.count+1)*73<640){
            [self.huxingScrollView setFrame:CGRectMake(320-((detailDataArray.count+1)*73)/2, self.huxingScrollView.frame.origin.y,(detailDataArray.count+1)*73, self.huxingScrollView.frame.size.height)];
            [self.huxingImageView setFrame:CGRectMake(13, 0, 60, 60)];
        }
        
        mainInfoViewY = mainInfoViewY+ 90;
    }
    else{
    
        self.huxingScrollView.hidden = true;
    }
    
    
    self.mainInfoView.frame = CGRectMake(0, mainInfoViewY, 640, 100);
    [self.mainViewScroll addSubview:self.mainInfoView];
    
    self.mainGoodsView.frame = CGRectMake(0, mainInfoViewY+100, 640, self.mainGoodsView.frame.size.height);
    
    [self.mainViewScroll addSubview:self.mainGoodsView];
    
    [self.mainViewScroll setContentSize:CGSizeMake(0,mainInfoViewY+98+self.mainGoodsView.frame.size.height)];

 //   int counts = (int)[array count];

//    if(!pagecontrol){
//    pagecontrol = [[pageControl alloc] initWithFrame:CGRectMake(0,382,500, 20)];
//    [self.mainViewScroll addSubview:pagecontrol];
//    }
//        
//    [pagecontrol setPageCount:counts];
    

}
-(void)onSelectPlanTap:(UIGestureRecognizer *)recognizer{

    UIView *view = [recognizer view];
    
    if(view.tag != selectedIndex){
    
        selectedIndex = view.tag;
        
         NSDictionary *temp = allData[selectedIndex];
        [pagecontrol setSelected:selectedIndex];
        [self initGoods:[temp objectForKey:@"data"]];
        goods = temp;
        
        
        CWPageController *initialViewController =
        [_pModel viewControllerAtIndex:selectedIndex];
        NSArray *viewControllers =
        [NSArray arrayWithObject:initialViewController];
        [_pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:NO
                                 completion:^(BOOL f){}];
        
        
        
        [self changePlanBack];
    
    }
    
  
}
-(void)pageChanged:(int)index{
    
 
    
  //  if(rootDic == nil){
       
     //   rootDic = [self getDataDictionary];
    
  //  }
  //  NSArray *arrayTemp = [rootDic objectForKey:@"data"];
    
    int count = 0;
    
    for(NSDictionary *temp in allData){
        
        if([[temp objectForKey:@"id"] intValue] == index){
            
            selectedIndex = count;
            [pagecontrol setSelected:count];
            [self initGoods:[temp objectForKey:@"data"]];
            goods = temp;
            break;
        }
        count++;
    }

    [self changePlanBack];
}
-(void)changePlanBack{

    for (int j =0; j<huxingImageViewArray.count; j++) {
        
        UIImageView *imageView = huxingImageViewArray[j];
        
        if(selectedIndex != j){
            imageView.layer.borderWidth = 0;
        }
        else{
            
            imageView.layer.borderWidth = 1;
            imageView.layer.borderColor = [UIColor redColor].CGColor;
            
        }
    }


}

-(void)initGoods:(NSArray *)goodsArgs{
    
   
     NSArray *allView =[self.scrollView subviews];
      for(UIView *view in allView){
      [view removeFromSuperview];
  }
    
 //   NSString *authorName = [data objectForKey:@"name"];
 //   [self.authorName setText:authorName];
    
   // NSArray *goods = [data objectForKey:@"data"];
    
    NSMutableArray *type0 = [[NSMutableArray alloc] init];
    NSMutableArray *type1 = [[NSMutableArray alloc] init];
    NSMutableArray *type2 = [[NSMutableArray alloc] init];
    NSMutableArray *type3 = [[NSMutableArray alloc] init];
    
   float  totalPrice = 0;
    
    for(NSDictionary *temp in goodsArgs){
        
        totalPrice = totalPrice + [[temp objectForKey:@"disprice"] floatValue];
        
        switch ([[temp objectForKey:@"type"] intValue]) {
            case 0:
                [type0 addObject:temp];
                break;
            case 1:
                [type1 addObject:temp];
                break;
            case 2:
                [type2 addObject:temp];
                break;
            case 3:
                [type3 addObject:temp];
                break;
            default:
                break;
        }
    }

    [self.totalGoodsCount setText:[NSString stringWithFormat:@"%d件",goodsArgs.count]];
    [self.totalPriceLabel setText:[NSString stringWithFormat:@"RMB %f",totalPrice]];
    
    view0Height = [self viewHeight:(int)[type0 count]];
    view1Height = [self viewHeight:(int)[type1 count]];
    view2Height = [self viewHeight:(int)[type2 count]];
    view3Height = [self viewHeight:(int)[type3 count]];
    
    if([type0 count]>0){
    GoodsView *view0 =[[GoodsView alloc] initWithFrame:CGRectMake(0, 0,606, view0Height)];
    [view0 initView:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0],type0, nil]];
    [self.scrollView addSubview:view0];
        view0 = nil;
    }
    else{
        [mySegmentedControl setEnabled:NO forSegmentAtIndex:0];
        [self.firstButton setEnabled:false];

    }
    
    if([type1 count]>0){
    GoodsView *view1 =[[GoodsView alloc] initWithFrame:CGRectMake(0, 20+view0Height,606, view1Height)];
    [view1 initView:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1],type1, nil]];
     [self.scrollView addSubview:view1];
        view1 = nil;
    }
    else{
        [mySegmentedControl setEnabled:NO forSegmentAtIndex:1];
        [self.secondButton setEnabled:false];
    }
    
    if([type2 count]>0){
    GoodsView *view2 =[[GoodsView alloc] initWithFrame:CGRectMake(0, 30+view0Height+view1Height,606, view2Height)];
    [view2 initView:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:2],type2, nil]];
     [self.scrollView addSubview:view2];
        view2 = nil;
    }
    else{
       [mySegmentedControl setEnabled:NO forSegmentAtIndex:2];
       [self.thridButton setEnabled:false];

    }
    
    if([type3 count]>0){
    GoodsView *view3 =[[GoodsView alloc] initWithFrame:CGRectMake(0,  40+view0Height+view1Height+view2Height,606, view3Height)];
    [view3 initView:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:3],type3, nil]];
     [self.scrollView addSubview:view3];
        view3 = nil;
    }
    else{
        [mySegmentedControl setEnabled:NO forSegmentAtIndex:3];
        [self.fourButton setEnabled:false];

    }
    
    self.scrollView.directionalLockEnabled = YES; //只能一个方向滑动
    self.scrollView.pagingEnabled = NO; //是否翻页
   //   self.scrollView.backgroundColor = [UIColor blackColor];
      self.scrollView.showsVerticalScrollIndicator =NO; //垂直方向的滚动指示
      self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;//滚动指示的风格
      self.scrollView.showsHorizontalScrollIndicator = NO;//水平方向的滚动指示
      self.scrollView.delegate = self;
    CGSize newSize = CGSizeMake(0,view0Height+view1Height+view2Height+view3Height+60);
    [self.scrollView setContentSize:newSize];
    
}
-(float)viewHeight:(int)length{
    if(length>0){
    int row = length/4;
    if(length%4!=0){
        row++;
    }
    
    float heigth = row*230+40;
    return  heigth;
    }
    else return  0;
}

- (IBAction)back:(id)sender {
    
    [self backMessage:sender];
}

-(void)initPageView:(NSMutableArray *)detailData {
    
    detailDataArray = detailData;
    
    
    if(_pageController){
    
        [_pageController.view removeFromSuperview];
    
    }

   // NSMutableArray *image = [[NSMutableArray alloc] initWithObjects:[data objectForKey:@"photoUrl"],[data objectForKey:@"id"], goods,nil];
    
  //  NSMutableArray *detailData = [[NSMutableArray alloc] initWithObjects:image, nil];
    _pModel = [[CWPageModel alloc] init];
    [_pModel createContentPages:detailData];
    
    
    NSDictionary *options =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                forKey: UIPageViewControllerOptionSpineLocationKey];
    
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                      navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                    options:options];
    _pageController.delegate = self;
    
    CWPageController *initialViewController =
    [_pModel viewControllerAtIndex:0];
    NSArray *viewControllers =
    [NSArray arrayWithObject:initialViewController];
    [_pageController setDataSource:_pModel];
    
    [_pageController setViewControllers:viewControllers
                              direction:UIPageViewControllerNavigationDirectionReverse
                               animated:NO
                             completion:^(BOOL f){}];
    [self addChildViewController:_pageController];
    _pageController.view.frame = CGRectMake(0,37,640,480);
    [self.mainViewScroll addSubview:_pageController.view];
    [_pageController didMoveToParentViewController:self];
    
  

};
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
    if(completed)
    {
        
      UIView *temp  = [[pageViewController.viewControllers objectAtIndex:0] view];
        
        NSArray *allViews =[temp subviews];
        for(UIView *x in allViews){
            if([x isKindOfClass:[UIScrollView class]]){
    
                [self pageChanged:x.tag];
                break;
                
            }
        
        }
        
    }
}

-(void)selected:(id)sender{
    
    UISegmentedControl* control = (UISegmentedControl*)sender;
    switch (control.selectedSegmentIndex) {
        case 0:
          //  self.scrollView.contentOffset = CGPointMake(0,0);
            [self.scrollView setContentOffset: CGPointMake(0,0) animated:YES];
            break;
        case 1:
           // self.scrollView.contentOffset = CGPointMake(0,view0Height);
             [self.scrollView setContentOffset: CGPointMake(0,view0Height) animated:YES];
            break;
        case 2:
            if(view2Height>0){
            // self.scrollView.contentOffset = CGPointMake(0,view0Height+view1Height);
                 [self.scrollView setContentOffset:CGPointMake(0,view0Height+view1Height) animated:YES];
            }
            break;
        case 3:
            if(view3Height>0){
           // self.scrollView.contentOffset = CGPointMake(0,view0Height+view1Height+view2Height);
                 [self.scrollView setContentOffset: CGPointMake(0,view0Height+view1Height+view2Height) animated:YES];
            }
            break;
        default:
         //    self.scrollView.contentOffset = CGPointMake(0,0);
             [self.scrollView setContentOffset: CGPointMake(0,0) animated:YES];
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender{
    //executes when you scroll the scrollView
    
    CGPoint point = sender.contentOffset;
    
    if(sender.tag ==1){
    
    if(point.y>=view0Height+view1Height+view2Height && view3Height>0){
        
        [mySegmentedControl setSelectedSegmentIndex:3];
        [self selectButton:3];
    }
    else if(point.y>=view0Height+view1Height && view2Height>0){
        
        [mySegmentedControl setSelectedSegmentIndex:2];
        [self selectButton:2];
    }
   else if(point.y>=view0Height && view1Height>0){
    
        [mySegmentedControl setSelectedSegmentIndex:1];
        [self selectButton:1];
    }
   else{
       [mySegmentedControl setSelectedSegmentIndex:0];
       [self selectButton:0];
   }
 }
    else if(sender.tag ==0){
    
       float y = self.mainGoodsView.frame.origin.y;
        
        if(point.y>=y){

          CGPoint bottomOffset = CGPointMake(0,y);
          [self.mainViewScroll setContentOffset:bottomOffset animated:NO];
        }
    }
}

- (IBAction)backIcon:(id)sender {
    
    [self backMessage:sender];
}

-(void)backMessage:(id) sender{
    

    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         [self.backView setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0]];
                         
                         CGRect  endFrame =  self.mainViewBack.frame;
                         endFrame.origin.y = 768;
                         self.mainViewBack.frame = endFrame;
                     }
                     completion:^(BOOL finished) {
                         
                         pagecontrol = nil;
                         selectedIndex = 0;
                         [_pageController.view removeFromSuperview];
                         _pageController.view = nil;
                         [self.view removeFromSuperview];
                         self.view = nil;
                         if(!loginInfo.isOfflineMode)
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"removeDetailView" object:nil];
                         else
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeDownloadDetailView" object:nil];
   
                     }
     ];

}
- (IBAction)collocationButtonAction:(id)sender {
    
    if(selectedIndex<detailDataArray.count){
    
        NSDictionary *temp = detailDataArray[selectedIndex];
        
       [[NSNotificationCenter defaultCenter] postNotificationName:@"goToCollocation" object:temp];
    }
}
- (IBAction)detailButtonAction:(id)sender {
//    
//    self.detailScrollView.frame = CGRectMake(262,768, 500, 768);
//    self.detailScrollView.layer.cornerRadius = 5;
//    
//    [self.view addSubview:self.detailScrollView];
//    
//    [UIView setAnimationsEnabled:true];
//    [UIView animateWithDuration:0.3f
//                          delay:0.0f
//                        options:UIViewAnimationOptionTransitionFlipFromLeft
//                     animations:^{
//                         
//                         CGRect  endFrame =  self.detailScrollView.frame;
//                         endFrame.origin.y = -200;
//                         self.detailScrollView.frame = endFrame;
//                     }
//                     completion:^(BOOL finished) {
//                       
//                     }
//     ];
    
    CGPoint bottomOffset = CGPointMake(0,mainInfoViewY+100);
    [self.mainViewScroll setContentOffset:bottomOffset animated:YES];
    
}
- (IBAction)detailBackAction:(id)sender {
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         CGRect  endFrame =  self.detailScrollView.frame;
                         endFrame.origin.y = 768;
                         self.detailScrollView.frame = endFrame;
                     }
                     completion:^(BOOL finished) {
                         
                         [ self.detailScrollView removeFromSuperview];
                     }
     ];

}
- (void)swipeRight:(UIPanGestureRecognizer*)recognizer
{
    CGPoint swipeLocation = [recognizer locationInView:self.backView];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        beginX = swipeLocation.x;
        
        return;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        return;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if(swipeLocation.x>beginX)   {
        
            [self switchPlan:true];
        }
        else{
   
            [self switchPlan:false];
        }
        
        beginX = 0;
        
        return;
    }
}
-(void)switchPlan:(BOOL) isNext{

    for (int i =0;i<loginInfo.planViewData.count;i++) {
        NSDictionary *temp = loginInfo.planViewData[i];
        int id = [[temp objectForKey:@"id"] intValue];
        if(id == planId){
            
            if(isNext){
              
                if(i<loginInfo.planViewData.count-1){
                i++;
                planId = [[loginInfo.planViewData[i] objectForKey:@"id"] intValue];
                [self initView:planId];
                }
                else
                    [globalContext showAlertView:@"已经是最后一个了"];
            }
            else if(!isNext){
                if(i>0){
                i--;
                planId = [[loginInfo.planViewData[i] objectForKey:@"id"] intValue];
                [self initView:planId];
                }
                else
                      [globalContext showAlertView:@"已经是第一个了"];
            }
            break;
        }
    }
}
- (IBAction)firstAction:(id)sender {
    
    [self selectButton:0];
    [self.mySegmentedControl setSelectedSegmentIndex:0];
    [self selected:self.mySegmentedControl];
    
}
- (IBAction)secondAction:(id)sender {
    
    [self selectButton:1];
    [self.mySegmentedControl setSelectedSegmentIndex:1];
    [self selected:self.mySegmentedControl];
}
- (IBAction)thridAction:(id)sender {
    
    [self selectButton:2];
    [self.mySegmentedControl setSelectedSegmentIndex:2];
      [self selected:self.mySegmentedControl];
}
- (IBAction)fourAction:(id)sender {
    [self selectButton:3];
    [self.mySegmentedControl setSelectedSegmentIndex:3];
    [self selected:self.mySegmentedControl];
}
-(void)selectButton:(int)index{

    [self.firstButton setBackgroundColor:[UIColor clearColor]];
    [self.secondButton setBackgroundColor:[UIColor clearColor]];
    [self.thridButton setBackgroundColor:[UIColor clearColor]];
    [self.fourButton setBackgroundColor:[UIColor clearColor]];
    
    [self.firstButton setTitleColor:UIColorFromRGB(0x909090) forState:UIControlStateNormal];
    [self.secondButton setTitleColor:UIColorFromRGB(0x909090) forState:UIControlStateNormal];
    [self.thridButton setTitleColor:UIColorFromRGB(0x909090) forState:UIControlStateNormal];
    [self.fourButton setTitleColor:UIColorFromRGB(0x909090) forState:UIControlStateNormal];
 
    switch (index) {
        case 0:
                [self.firstButton setTitleColor:UIColorFromRGB(0x2b2b2b) forState:UIControlStateNormal];
                [self.firstButton setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
            break;
        case 1:
            [self.secondButton setTitleColor:UIColorFromRGB(0x2b2b2b) forState:UIControlStateNormal];
            [self.secondButton setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
            break;
        case 2:
            [self.thridButton setTitleColor:UIColorFromRGB(0x2b2b2b) forState:UIControlStateNormal];
            [self.thridButton setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
            break;
        case 3:
            [self.fourButton setTitleColor:UIColorFromRGB(0x2b2b2b) forState:UIControlStateNormal];
            [self.fourButton setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
            break;
            
        default:
            break;
    }
}
- (IBAction)favoriteAction:(id)sender {
    //类型：1商品2方案3案例图
    
    if ([globalContext isLogin]) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *parameters = @{@"id":[NSNumber numberWithInt:planId],@"type":[NSNumber numberWithInt:2],@"status":[NSNumber numberWithInt:(int)self.favoriteButton.tag]};
        
        [manager POST:[BASEURL stringByAppendingString: changeFavoriteApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //  NSLog(@"JSON: %@", responseObject);
            
            NSDictionary *temp = responseObject;
            
            NSString *flagString = [temp objectForKey:@"flag"];
            
            if([flagString isEqualToString:@"true"]){
                
                if(self.favoriteButton.tag==2)
                    
                    [self setFavoriteImage:sender status:1];
                
                
                else if(self.favoriteButton.tag==1)
                    
                    [self setFavoriteImage:sender status:2];
                
            }
            else{
                
                if(self.favoriteButton.tag==2){
                    
                    [globalContext addStatusBarNotification:@"收藏失败"];
                    
                }
                else{
                    
                    [globalContext addStatusBarNotification:@"取消收藏失败"];
                }
            }
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"Error: %@", error);
            
            if(self.favoriteButton.tag==2){
                
                [globalContext addStatusBarNotification:@"网络异常，收藏失败"];
                
            }
            else{
                
                [globalContext addStatusBarNotification:@"网络异常，取消收藏失败"];
            }
            
            
        }];
        
    }
    else{
        
        UIAlertView  *alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 111;
        [alertView show];
    }
}
-(void)setFavoriteImage:(UIButton *)favoriteButton status:(int)status{
    
    if(status==1){
        
        NSString *favoritePathString = [[NSBundle mainBundle]pathForResource:@"redHeart.png" ofType:@""];
        UIImage *favorite = [UIImage imageWithContentsOfFile:favoritePathString];
        [favoriteButton setImage:favorite forState:UIControlStateNormal];
        favorite = nil;
    }
    
    else if(status==2){
        
        NSString *noFavoritePathString = [[NSBundle mainBundle]pathForResource:@"heart.png" ofType:@""];
        UIImage *noFavorite = [UIImage imageWithContentsOfFile:noFavoritePathString];
        [favoriteButton setImage:noFavorite forState:UIControlStateNormal];
        noFavorite = nil;
    }
    
    favoriteButton.tag = status;
}
-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0){
        
    }
    else{
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLogin" object:nil];
        UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
        loginController = [st instantiateViewControllerWithIdentifier:@"login"];
        [self.view addSubview:loginController.view];
        
        st = nil;
    }
    
    
    
}
- (IBAction)shareAction:(id)sender {
    
    UIView *temp  = [[_pageController.viewControllers objectAtIndex:0] view];
    
    UIImage *image;
    
    NSArray *allViews =[temp subviews];
    for(UIView *x in allViews){
        if([x isKindOfClass:[UIScrollView class]]){
            
            NSArray *subViews  = [x subviews];
            UIImageView *temp = subViews[0];
            image = temp.image;
            
            break;
            
        }
        
    }
    
    if(image){
    
    NSArray  *data  =[[NSArray alloc] initWithObjects:sender,image,self.mainPlanName.text,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addShareView" object:data];
        
    }
    
    else{
    
        [globalContext showAlertView:@"正在加载图片，请稍候..."];
    }
}

- (IBAction)moreAction:(id)sender {
    
     [globalContext showAlertView:@"没有更多呢！"];
}
@end
