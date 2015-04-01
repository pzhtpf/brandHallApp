
//  collocationViewController.m
//  brandv1.2
//
//  Created by Apple on 14-7-30.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "collocationViewController.h"
#import "AFNetworking.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "Define.h"
#import "typeSearchTableViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "UIImage+Resize.h"
#import "UIImageView+AFNetworking.h"
#import "globalContext.h"
#import "LSBGetDegress.h"
#import "DBHelper.h"
#import "UIImage+Helpers.h"

@interface collocationViewController ()

@end
@implementation collocationViewController
@synthesize tapGesture;
@synthesize myscrollview;
@synthesize collocationData;
UIScrollView  *elementscrollview;
UITapGestureRecognizer *imageGesture;
int selected= 0;
@synthesize ElementsList;
@synthesize hotPic;
int planId;
@synthesize elements;
@synthesize elementsGoods;
int selected;
UIView *bottomView;
float width;
float height = 768;
// UIView *saveView;
LoginInfo *loginInfo;
typeSearchTableViewController *typeSearchCollocation;
UIPopoverController  *popControllerCollocation;
UIAlertView *alertView;
UIButton *style;
UIView *upView;
@synthesize goods;
NSString *spaceId;
bool collocation;
UIView *collocationView;
int addIndex =0;
int indexCount = 0;
int  _speedX ,_speedY;
UIImage *unSelected;
UIImage *selectedImage;
NSMutableArray *history;
int historyIndex = 0;
bool firstRevocation = true;
bool isHigh = true;
float lastDegress = 0;
NSMutableArray *allDaPicImage;
NSMutableDictionary *offlineAllElements;
NSDictionary *planAllData;
UIButton *backButton;
UIViewController *login;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    loginInfo.loadingName = @"goToCollocationLoading";
    loginInfo.isMirror = false;
    firstRevocation = true;
    isHigh = true;
    loginInfo.hideArray = [[NSMutableArray alloc] initWithObjects:@"隐藏硬装",@"隐藏家居",@"隐藏配饰",@"隐藏全部",nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addIndex:) name:loginInfo.loadingName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSwitchImage:) name:@"switchImage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeHide:) name:@"changeHideStatus" object:nil];
    
    NSString *hotimagepath = [[NSBundle mainBundle]pathForResource:@"unSelected.png" ofType:@""];
    unSelected = [UIImage imageWithContentsOfFile:hotimagepath];
    unSelected= [unSelected resizedImage:unSelected.size interpolationQuality: kCGInterpolationHigh];
    
    NSString *hotimagepath1 = [[NSBundle mainBundle]pathForResource:@"边框.png" ofType:@""];
    selectedImage = [UIImage imageWithContentsOfFile:hotimagepath1];
    selectedImage = [selectedImage resizedImage:selectedImage.size interpolationQuality: kCGInterpolationHigh];
    
  //  NSLog(@"%d",[globalContext GettingTheWiFiSignalStrength]);
     self.planId = [collocationData objectForKey:@"id"];
    
    planAllData = [DBHelper getDataFromPlanTable:[self.planId intValue]];
    
    [self initView:collocationData];
}
-(void)addIndex:(id)sender{
    addIndex++;
    
    if (addIndex == [elements count]) {
        [loginInfo.progressBarView removeFromSuperview];
        addIndex = 0;
    }
}

-(void)initNativeView{
    
    upView =[[UIView alloc] initWithFrame:CGRectMake(0,728,1024,40)];
    // [upView setBackgroundColor:[UIColorFromRGB(0xffffff) colorWithAlphaComponent:0.5]];
    
    UIButton *up = [[UIButton alloc] initWithFrame:CGRectMake(984,0, 40, 40)];
    NSString *upString = [[NSBundle mainBundle]pathForResource:@"上.png" ofType:@""];
    UIImage *upImage = [UIImage imageWithContentsOfFile:upString];
    [up setBackgroundImage:upImage forState:UIControlStateNormal];
    [up addTarget:self action:@selector(showView:) forControlEvents:UIControlEventTouchUpInside];
    [upView addSubview:up];
    upImage = nil;
    
    bottomView =[[UIView alloc] initWithFrame:CGRectMake(0,768,1024 ,200)];
    
    elementscrollview= [[UIScrollView alloc] initWithFrame:CGRectMake(0,40,1024,160)];
    elementscrollview.directionalLockEnabled = YES; //只能一个方向滑动
    elementscrollview.pagingEnabled = NO; //是否翻页
    elementscrollview.backgroundColor = [UIColor whiteColor];
    elementscrollview.showsVerticalScrollIndicator =NO; //垂直方向的滚动指示
    elementscrollview.indicatorStyle = UIScrollViewIndicatorStyleDefault;//滚动指示的风格
     elementscrollview.showsHorizontalScrollIndicator = YES;//水平方向的滚动指示
//     [elementscrollview flashScrollIndicators];
    // myscrollview.delegate = self;
    
    UIView *typeView =[[UIView alloc] initWithFrame:CGRectMake(0,2,1024,40)];
    [typeView setBackgroundColor:[UIColorFromRGB(0xffffff) colorWithAlphaComponent:0.5]];
    
    UIButton *c = [[UIButton alloc] initWithFrame:CGRectMake(984,0, 40, 40)];
    NSString *downString = [[NSBundle mainBundle]pathForResource:@"下.png" ofType:@""];
    UIImage *downImage = [UIImage imageWithContentsOfFile:downString];
    [c setBackgroundImage:downImage forState:UIControlStateNormal];
    [c addTarget:self action:@selector(hideView:) forControlEvents:UIControlEventTouchUpInside];
    downImage = nil;
    
    UISearchBar *searchBar  = [[UISearchBar alloc] initWithFrame:CGRectMake(110,5, 180, 30)];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    }
    
    UIButton *brand = [[UIButton alloc] initWithFrame:CGRectMake(300,5, 180, 30)];
    [brand setEnabled:false];
  //  UIImage *img = [UIImage imageNamed:@"搜索.png"];
    NSString *searchString = [[NSBundle mainBundle]pathForResource:@"搜索.png" ofType:@""];
    UIImage *img = [UIImage imageWithContentsOfFile:searchString];
    brand.tag = 1;
    
    [brand setBackgroundImage:img forState:UIControlStateNormal];
    [brand setTitle:@"品牌／品牌系列" forState:UIControlStateNormal];
    
    [searchBar setAlpha:0.7];
    [searchBar setBackgroundColor:[UIColor blackColor]];
    
    [searchBar.layer setCornerRadius:5];
    
    UIButton *all = [[UIButton alloc] initWithFrame:CGRectMake(490,5, 180, 30)];
    [all setBackgroundImage:img forState:UIControlStateNormal];
    [all setEnabled:false];
    all.tag = 2;
    [all setTitle:@"全部品类" forState:UIControlStateNormal];
    
    style = [[UIButton alloc] initWithFrame:CGRectMake(680,5, 180, 30)];
    style.tag = 3;
    [style setEnabled:false];
    [style setBackgroundImage:img forState:UIControlStateNormal];
    [style setTitle:@"全部风格" forState:UIControlStateNormal];
    
    typeSearchCollocation = [[typeSearchTableViewController alloc] init];
    
    typeSearchCollocation.view.frame = CGRectMake(0, 0, 180, 30);
    
    popControllerCollocation = [[UIPopoverController alloc] initWithContentViewController:typeSearchCollocation];
    popControllerCollocation.delegate=self;
    
    [brand addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [all addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [style addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [typeView  addSubview:brand];
    [typeView  addSubview:all];
    [typeView  addSubview:style];
    [typeView  addSubview:c];
   [typeView  addSubview:searchBar];
    
    [bottomView addSubview: typeView];
    [bottomView addSubview: elementscrollview];
    img = nil;
    
}
- (void)searchAction:(id)sender {
    
    UIButton *x =sender;
    int tag = (int)x.tag;
    
    CGRect frame = CGRectMake(620, 570, 180, 30);
    
    switch (tag) {
        case 1:
            frame = CGRectMake(300, 570, 180, 30);
            break;
        case 2:
            frame = CGRectMake(490, 570, 180, 30);
            break;
        case 3:
            frame = CGRectMake(680, 570, 180, 30);
            break;
        case 5:
            frame = CGRectMake(50,255, 1, 1);
            break;
        default:
            break;
    }
    [typeSearchCollocation initView:tag];
    
    if(tag == 5){
        popControllerCollocation.popoverContentSize = CGSizeMake(110,180);
        [popControllerCollocation presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
    else{
        popControllerCollocation.popoverContentSize = CGSizeMake(180,130);
        [popControllerCollocation presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"%@",@"didReceiveMemoryWarning");
}
-(void)initView:(NSDictionary *)data{
    
    collocation = false;
    addIndex = 0;
    
    height = 768;
    
    //  spaceId = [data[0] objectForKey:@"space_id"];
    [self initSaveView];

    [self backButton];
    
    [self releaseMemory:data];
    
}
-(void)releaseMemory:(NSDictionary *)data{
    
    [loginInfo.progressBarView setTip:@"正在加载......"];
    [self.view insertSubview:loginInfo.progressBarView belowSubview:backButton];
    
    [self initNativeView];
    
    if([[data objectForKey:@"data"] isKindOfClass:[NSArray class]]){
        
          NSThread *threadHot1 = [[NSThread alloc]initWithTarget:self selector:@selector(initgoodsView:) object:data];
          [threadHot1 start];
     //   [self initgoodsView:data];
    }
    else{
        
           NSThread *threadHot2 = [[NSThread alloc]initWithTarget:self selector:@selector(getInitGoods:) object:[data objectForKey:@"id"]];
           [threadHot2 start];
        
    }
    
    if(!loginInfo.isOfflineMode){
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"id":[data objectForKey:@"id"]};
        
        [manager POST:[BASEURL stringByAppendingString:initCollocationApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
          //  NSLog(@"JSON: %@", responseObject);
    
            NSDictionary *rootDic = responseObject;
    
            NSThread *threadHot = [[NSThread alloc]initWithTarget:self selector:@selector(addView:) object:rootDic];
            [threadHot start];
         ///   [self addView:rootDic];
    
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        
            [loginInfo.progressBarView removeFromSuperview];
    
        }];
    }
    else{
        
          NSDictionary *rootDic =  [DBHelper getDataToDefaultTable:self.planId angle:@"A1"];
        
          NSThread *threadHot = [[NSThread alloc]initWithTarget:self selector:@selector(addView:) object:rootDic];
          [threadHot start];
    }
}
-(void)getInitGoods:(NSString *)planId{
    
    if(!loginInfo.isOfflineMode){
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"id":planId};
    
        [manager POST:[BASEURL stringByAppendingString: getPlanProductApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
          //   NSLog(@"JSON: %@", responseObject);
    
            NSDictionary *rootDic = responseObject;
    
            if([rootDic isKindOfClass:[NSDictionary class]]){
           /// NSThread *threadHot = [[NSThread alloc]initWithTarget:self selector:@selector(initgoodsView:) object:rootDic];
           ///     [threadHot start];
                [self initgoodsView:rootDic];
            }
    
    
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [loginInfo.progressBarView removeFromSuperview];
    
        }];
    }
    else{
    
        NSMutableArray *dataArray = [DBHelper  getDefaultByPlanId:[self.planId intValue]];
        NSDictionary *temp = [[NSDictionary alloc] initWithObjectsAndKeys:dataArray,@"data", nil];
        if(temp)
        [self initgoodsView:temp];
        
    }
}
-(void)initgoodsView:(NSDictionary *)temp{
    
    goods = [temp objectForKey:@"data"];
    
    CGSize newSize = CGSizeMake((goods.count)*151,0);
    [elementscrollview setContentSize:newSize];
    
    for(int i=0;i<goods.count;i++){
        
        UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(10+i*150,10, 140, 140)];
        view.image = unSelected;
        
        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(2,2, 136, 136)];
        [view addSubview:imageView1];
        
        UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake(2, 109, 136, 12)];
        [name setBackgroundColor:[UIColor clearColor]];
        name.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0f];
        [name setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.5]];
        
        NSString *nameStr =[NSString stringWithFormat:@" %@",[goods[i] objectForKey:@"name"]];
        
        if([nameStr isEqualToString:@" 未知信息"]){
        
             nameStr = @" 此商品暂无信息";
        }

        
        [name setText:nameStr];
        [name setTextColor:[UIColor whiteColor]];
        
        NSString *dispriceStr = [goods[i] objectForKey:@"disprice"];
        float dispriceFloat = [dispriceStr floatValue];
        
        if(dispriceFloat>0){
            
        UILabel *disprice =[[UILabel alloc] initWithFrame:CGRectMake(2, 121, 65, 15)];
        [disprice setBackgroundColor:[UIColor clearColor]];
        disprice.font= [UIFont fontWithName:@"MicrosoftYaHei" size:9.0f];;
        [disprice setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.5]];
        [disprice setText:[NSString stringWithFormat:@" ¥%@",dispriceStr]];
        [disprice setTextColor:[UIColor whiteColor]];
        [view addSubview:disprice];
            
        NSString *priceString = [goods[i] objectForKey:@"price"];
        float priceFloat = [priceString floatValue];
            
        if(priceFloat == 0){
        
                disprice.frame = CGRectMake(2,121, 136, 18);

        }
            
       else{
           
        UILabel *price =[[UILabel alloc] initWithFrame:CGRectMake(67, 121, 71, 15)];
        [price setBackgroundColor:[UIColor clearColor]];
        price.font= [UIFont fontWithName:@"MicrosoftYaHei" size:9.0f];
        [price setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.5]];
        [price setText:[NSString stringWithFormat:@" ¥%@", [goods[i] objectForKey:@"price"]]];
        [price setTextColor:[UIColor whiteColor]];
        
        UIImageView *lineView1 = [[UIImageView alloc] initWithFrame:CGRectMake(70, 126,50, 5)];
        NSString *imagepath1 = [[NSBundle mainBundle]pathForResource:@"line.png" ofType:@""];
        UIImage *imageLine1 = [UIImage imageWithContentsOfFile:imagepath1];
        lineView1.image = imageLine1;
        imageLine1 = nil;
            
        [view addSubview:price];
        price = nil;
        [view addSubview:lineView1];
        lineView1 = nil;
         }
        }
        
        else{
        
            name.frame =CGRectMake(2, 121, 136, 18);
        }
        
        
        if (!loginInfo.isOfflineMode) {
        
        NSString *path = [imageUrl stringByAppendingString:[goods[i] objectForKey:@"image"]];
        NSURL *url = [NSURL URLWithString:path];
        
        [imageView1 setImageWithURL:url size:CGSizeMake(136, 136)];
      ///  [imageView1 sd_setImageWithURL:url size:CGSizeMake(0, 0)];
        }
        else{
        
            [UIImage loadFromURL:[goods[i] objectForKey:@"image"] callback: ^(UIImage *image){
                
                [imageView1 setImage:image];
                image = nil;
            }];
        
        }
        
        imageView1.tag=i+1;
        imageView1.userInteractionEnabled = YES;
        //[imageView1 addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)]];
        imageView1 = nil;
        [view addSubview:name];
        name = nil;
        
        [elementscrollview addSubview:view];
        view = nil;
    }
    
}

-(void)addView:(NSDictionary *)temp{
    
    myscrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,1024,768)];
    myscrollview.directionalLockEnabled = YES; //只能一个方向滑动
    myscrollview.pagingEnabled = NO; //是否翻页
    myscrollview.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //  myscrollview.showsVerticalScrollIndicator =NO; //垂直方向的滚动指示
    //  myscrollview.indicatorStyle = UIScrollViewIndicatorStyleWhite;//滚动指示的风格
    //  myscrollview.showsHorizontalScrollIndicator = NO;//水平方向的滚动指示
    myscrollview.minimumZoomScale = 0.6;
    myscrollview.maximumZoomScale = 3.0;
    myscrollview.delegate = self;
    // imageView = [[ImageView alloc]initWithFrame:CGRectMake(0,0,1024,500)];
    // [myscrollview addSubview:imageView];
    NSArray *data =[temp objectForKey:@"plan"];
    
    elements =[data[0] objectForKey:@"data"];
    self.angle = [data[0] objectForKey:@"angle"];
    
    NSString *maopei = [data[0] objectForKey:@"pic"];
    
    UIImage *maopeiImage ;
    
    if(!loginInfo.isOfflineMode){
    
    NSString *path = [imageUrl stringByAppendingString:maopei];
    if(!isHigh){
     
        path = [path stringByAppendingString:@"_thumb.png"];
    }
    NSURL *url = [NSURL URLWithString:path];
    
    maopeiImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    }
    
    else{
    
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString * path = [NSString stringWithFormat:@"%@/%@", documentsDirectoryPath,maopei];
        
        maopeiImage = [UIImage imageWithContentsOfFile:path];
    
    }
    
    
    if(maopeiImage !=nil){
  
         width = maopeiImage.size.width*height/maopeiImage.size.height;

        if(width<1024){
            width =1024 ;
            height = maopeiImage.size.height*width/maopeiImage.size.width;
        }
        collocationView = [[UIView alloc] initWithFrame:CGRectMake(0,0,width,height)];
        
        [collocationView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
        
        
        UIImageView *maopeiImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,width,height)];
        CGSize newSize = CGSizeMake(width,height);
        [myscrollview setContentSize:newSize];

        
        if(maopeiImage)
        {
            
      
            maopeiImage = [maopeiImage resizedImage:maopeiImage.size interpolationQuality: kCGInterpolationLow];
            [maopeiImageview setImage:maopeiImage];
            maopeiImage = nil;
        }
        
        
        maopeiImageview.tag = 0;

       [collocationView addSubview:maopeiImageview];
        
        [myscrollview addSubview:collocationView];

        
    //   [self initmaopei:nil];
        
        NSThread *removeThread = [[NSThread alloc] initWithTarget:self selector:@selector(initmaopei:) object:[NSNumber numberWithInt:(int)[elements count]]];
        removeThread.name = @"loadComplete";
        [removeThread start];
        
    }
    else{
        
        [self showAlertView:@"毛坯房图片为空，加载失败"];
        [loginInfo.progressBarView removeFromSuperview];
    }
    
}


-(void)downloadImage:(NSArray*) array{
    
    NSString *name = array[0];
 
    UIImage *image = [loginInfo.allDownloadedImage objectForKey:name];
    
    if (!image) {
        
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/%@", documentsDirectoryPath,name];
    image = [UIImage imageWithContentsOfFile:path];
    if(image){
        
//           if(!loginInfo.allDownloadedImage)
//            loginInfo.allDownloadedImage = [[NSMutableDictionary alloc] init];
//        
//        [loginInfo.allDownloadedImage setValue:image forKey:name];
        
    NSArray *dataArray = [[NSArray alloc] initWithObjects:image,array[1], nil];
    [self performSelectorOnMainThread:@selector(updateUI:) withObject:dataArray waitUntilDone:YES];
    }
    else{
        NSLog(@"%@",name);
   //  [[imageView superview] removeFromSuperview];
    }
    }
    else{
    
        NSArray *dataArray = [[NSArray alloc] initWithObjects:image,array[1], nil];
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:dataArray waitUntilDone:YES];
    }
}
-(void)updateUI:(NSArray*) array{
    
    UIImageView *imageView = array[1];
    UIImage *image = array[0];
 
    image = [image resizedImage:image.size interpolationQuality: kCGInterpolationLow];
    
   [imageView setImage:image];
   image = nil;
  [self addIndex:nil];
}


-(void)initmaopei:(id)sender{
    
    hotPic = [[NSMutableArray alloc] initWithArray:elements];
    allDaPicImage = [[NSMutableArray alloc] init];
    
    
//    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
    
    for(int i =0;i<[elements count];i++){
        NSDictionary *temp =elements[i];
        
        [self initHotPic:i path:[temp objectForKey:@"hot_pic"]];
        
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,width,height)];
        
        imageview.tag = i+1;
        
        NSString *dapei_pic_path = [temp objectForKey:@"dapei_pic"];
        
        if(!loginInfo.isOfflineMode){
        
        NSString *path = [imageUrl stringByAppendingString:dapei_pic_path];
        if(!isHigh)
        {
        path = [path stringByAppendingString:@"_thumb.png"];
        }
        NSURL *url = [NSURL URLWithString:path];
        [imageview setImageWithURL:url size:CGSizeMake(67, 0)];
        }
        
        else{
            
//            NSArray *temp = [[NSArray alloc] initWithObjects:dapei_pic_path,imageview, nil];
//            
//            NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self
//                                                                                   selector:@selector(downloadImage:)
//                                                                                  object:temp];
//            
//            [queue addOperation:operation];
            
//            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
//            dispatch_group_async(group,queue, ^{

            [UIImage loadFromURL:dapei_pic_path callback: ^(UIImage *image){
                
                [imageview setImage:image];
                image = nil;
            //    dispatch_semaphore_signal(semaphore);
                
                [self addIndex:nil];
                
            }];
            
//                
//                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//                NSString *furl = [NSString stringWithFormat:@"%@/%@",documentsDirectory,dapei_pic_path];
//                UIImage *image = [UIImage imageWithContentsOfFile:furl];
//                image = [image resizedImage:image.size interpolationQuality: kCGInterpolationLow];
//                [imageview setImage:image];
//                
//                dispatch_semaphore_signal(semaphore);
//
//                [self addIndex:nil];
//            });
        
        }
        
        [collocationView addSubview:imageview];
        }
   
    if(!loginInfo.isOfflineMode){
    UIView *typeView = [self.view viewWithTag:123];

        UIView *button = [typeView viewWithTag:12];
        if([button isKindOfClass:[UIButton class]])
        {
            UIButton *temp = (UIButton *)button;
            [temp  setEnabled:true];
        }
    }
    
    bottomView.tag = 110;
    
    [self.view insertSubview:myscrollview belowSubview:[self.view viewWithTag:123]];
    [self.view insertSubview:upView belowSubview:[self.view viewWithTag:123]];
    [self.view insertSubview:bottomView belowSubview:[self.view viewWithTag:123]];
    
    
//    if(loginInfo.isOfflineMode){
//        
//       [loginInfo.progressBarView removeFromSuperview];
//    
//    }
    
}
-(void)backButton{
     backButton = [[UIButton alloc] initWithFrame:CGRectMake(20,20, 30, 30)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
}
-(void)initHotPic:(int)index path:(NSString *)path{
    NSArray *array = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:index],path, nil];
      NSThread *threadHot1 = [[NSThread alloc]initWithTarget:self selector:@selector(getHotPic:) object:array];
      [threadHot1 start];
  //  [self getHotPic:array];
    
}
-(void)getHotPic:(NSArray *)array{
    //    NSString *hotimagepath = [loginInfo.serverUrl stringByAppendingString:[temp objectForKey:@"hot_pic"]];
    
    UIImage *hotimage ;
    int index = [array[0] intValue];
    
    if(!loginInfo.isOfflineMode){
    
    NSString *hotimagepath = [imageUrl stringByAppendingString:array[1]];
    hotimagepath = [hotimagepath stringByAppendingString:@"_S400"];
    
    NSURL *hotimagepathUrl = [NSURL URLWithString:hotimagepath];
    
    hotimage = [UIImage imageWithData:[NSData dataWithContentsOfURL:hotimagepathUrl]];
    }
    
    else{
    
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString * path = [NSString stringWithFormat:@"%@/%@", documentsDirectoryPath,array[1]];
        
        hotimage = [UIImage imageWithContentsOfFile:path];
        
    }
    
    if(hotimage != nil){

        hotPic[index] = hotimage;
    }
    else{
        
        hotPic[index] = @"没有hot_pic";
        
    }
    
}
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return collocationView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}
-(void)initSaveView{
    UIView *view =[[UIView alloc] initWithFrame:CGRectMake(0,150, 50, 370)];
    // [view setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
    [view setBackgroundColor:[UIColor clearColor]];
    view.tag = 123;
    
    UIImageView *bg =[[UIImageView alloc] initWithFrame:CGRectMake(0,0, 50, 370)];
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"left.png" ofType:@""];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    [bg setImage:image];
    image = nil;
    [view addSubview:bg];
    
    UIButton *save = [[UIButton alloc] initWithFrame:CGRectMake(10,10, 30, 30)];
    [save setBackgroundImage:[UIImage imageNamed:@"1撤销1.png"] forState:UIControlStateNormal];
    [save addTarget:self action:@selector(revocation:) forControlEvents:UIControlEventTouchUpInside];
    [save setEnabled:false];
    save.tag = 10;
    [view addSubview:save];
    
    UIButton *hide = [[UIButton alloc] initWithFrame:CGRectMake(10,50, 30, 30)];
    [hide setBackgroundImage:[UIImage imageNamed:@"2返回1.png"] forState:UIControlStateNormal];
     [hide addTarget:self action:@selector(recover:) forControlEvents:UIControlEventTouchUpInside];
    [hide setEnabled:false];
    hide.tag = 11;
    [view addSubview:hide];
    
    UIButton *a = [[UIButton alloc] initWithFrame:CGRectMake(10,90, 30, 30)];
    [a setBackgroundImage:[UIImage imageNamed:@"3隐藏1.png"] forState:UIControlStateNormal];
    // [a setEnabled:false];
    a.tag = 5;
    [a addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:a];
    
    UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(10,130, 30, 30)];
    [b setBackgroundImage:[UIImage imageNamed:@"4.下载1.png"] forState:UIControlStateNormal];
    [b addTarget:self action:@selector(captureView:) forControlEvents:UIControlEventTouchUpInside];
    [b setEnabled:false];
    [view addSubview:b];
    
    UIButton *c = [[UIButton alloc] initWithFrame:CGRectMake(10,170, 30, 30)];
  //  [c setBackgroundImage:[UIImage imageNamed:@"5.普清1.png"] forState:UIControlStateNormal];
    [c setBackgroundImage:[UIImage imageNamed:@"高.png"] forState:UIControlStateNormal];
    [c addTarget:self action:@selector(highOrNormal:) forControlEvents:UIControlEventTouchUpInside];
    c.tag = 12;
    
    if(loginInfo.isOfflineMode){
        [c setEnabled:false];
     
        NSArray *dataArray = [[planAllData objectForKey:self.planId] objectForKey:@"data"];
        if(dataArray.count>0){
        NSDictionary *temp = dataArray[0];
        int isHigh  = [[temp objectForKey:@"isHigh"] intValue];
        if (isHigh==0) {
            [c setBackgroundImage:[UIImage imageNamed:@"5.普清1.png"] forState:UIControlStateNormal];
        }
        }
    }
    
    [view addSubview:c];
    
    UIButton *d = [[UIButton alloc] initWithFrame:CGRectMake(10,210, 30, 30)];
    [d setBackgroundImage:[UIImage imageNamed:@"6.镜像1.png"] forState:UIControlStateNormal];
    [d addTarget:self action:@selector(mirror:) forControlEvents:UIControlEventTouchUpInside];
    // [d setEnabled:false];
    [view addSubview:d];
    
    UIButton *e = [[UIButton alloc] initWithFrame:CGRectMake(10,250, 30, 30)];
    [e setBackgroundImage:[UIImage imageNamed:@"7.保存1.png"] forState:UIControlStateNormal];
    [e addTarget:self action:@selector(captureView:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:e];
    
    UIButton *f = [[UIButton alloc] initWithFrame:CGRectMake(10,290, 30, 30)];
    [f setBackgroundImage:[UIImage imageNamed:@"8.帮助1.png"] forState:UIControlStateNormal];
    [f addTarget:self action:@selector(showView:) forControlEvents:UIControlEventTouchUpInside];
    [f setEnabled:false];
    [view addSubview:f];
    
    UIButton *g = [[UIButton alloc] initWithFrame:CGRectMake(10,330, 30, 30)];
    [g setBackgroundImage:[UIImage imageNamed:@"9.菜单1.png"] forState:UIControlStateNormal];
    [g addTarget:self action:@selector(showCollocationList:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:g];
   // [g setEnabled:false];
    
    [self.view addSubview:view];
    
}
-(void)showCollocationList:(id)sender{
   // if(loginInfo.allMessage.count>0){
        [self saveCollocation:nil];
    
        [self performSegueWithIdentifier:@"goCollocationList" sender:self];
        
  //  }
  //  else{
        
 //       [self showAlertView:@"搭配列表为空"];
 //   }
    
}
- (void)showView:(id)sender{
    
    [UIView setAnimationsEnabled:YES];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         CGRect frame= myscrollview.frame;
                         frame.size.height= 568;
                         myscrollview.frame=frame;
                         
                         
                         CGRect endFrame= bottomView.frame;
                         if(endFrame.origin.y != 568)
                         {
                             // CGPoint point = myscrollview.contentOffset;
                             //  myscrollview.contentOffset = CGPointMake(point.x,point.y+200);
                             float scaleY = 568/collocationView.frame.size.height;
                             float scaleX = 1024/collocationView.frame.size.width;
                             
                             myscrollview.zoomScale = scaleX<scaleY?scaleX:scaleY;
                             
                         }
                         
                         
                         endFrame.origin.y= 568;
                         bottomView.frame=endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         CGRect endFrame= bottomView.frame;
                         if(endFrame.origin.y != 568)
                         {
                             [self resetScroll];
                         }
                     }
     ];
    
    
    
}

- (void)hideView:(id)sender{
    
    [UIView setAnimationsEnabled:YES];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         CGRect frame= myscrollview.frame;
                         frame.size.height= 768;
                         myscrollview.frame=frame;
                         myscrollview.zoomScale = 1.0;
                         
                         CGRect endFrame= bottomView.frame;
                         endFrame.origin.y= 768;
                         bottomView.frame=endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         [self resetScroll];
                     }
     ];
    
    
    
}
-(void)resetScroll{
    
    if(myscrollview.subviews.count>0){
    
    UIView *subView = [myscrollview.subviews objectAtIndex:0];
    CGFloat offsetX = MAX((myscrollview.bounds.size.width - myscrollview.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((myscrollview.bounds.size.height - myscrollview.contentSize.height) * 0.5, 0.0);
    subView.center = CGPointMake(myscrollview.contentSize.width * 0.5 + offsetX,
                                 myscrollview.contentSize.height * 0.5 + offsetY);
    }
    
}

- (void)captureView:(id)sender{
    
    if([globalContext isLogin]){
    
    [loginInfo.progressBarView setTip:@"正在保存......"];
     [self.view insertSubview:loginInfo.progressBarView belowSubview:backButton];
    
    
    NSThread *threadHot = [[NSThread alloc]initWithTarget:self selector:@selector(getPic:) object:nil];
    [threadHot start];
    }
    
    else{
    
        alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请登陆" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"确定", nil];
        alertView.tag = 127;
        [alertView show];
    
   }
    
    //    [self performSelectorOnMainThread:@selector(getPic:)
    //                           withObject:nil
    //                        waitUntilDone:true];
    
    
}
-(void)getPic:(id)sender{
    
    UIGraphicsBeginImageContextWithOptions(collocationView.bounds.size, collocationView.opaque, 0.0f);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 7) {
        [collocationView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    else{
        [collocationView drawViewHierarchyInRect:collocationView.bounds afterScreenUpdates:NO];
    }
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(img,nil,nil,nil);
    
    img = nil;
    [loginInfo.progressBarView removeFromSuperview];
   // [globalContext showAlertView:@"搭配图已保存至本地相册"];
    [globalContext addStatusBarNotification:@"搭配图已保存至本地相册"];
}
-(void)getElementsList:(NSArray *)array{
    
    //   [self.view addSubview:progress.view];
    
    elementsGoods = array;
    
    
    for (NSObject * subview in [[elementscrollview subviews] copy]) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)subview removeFromSuperview];
        }
    }

  //  elementscrollview.translatesAutoresizingMaskIntoConstraints = NO;
   [elementscrollview setShowsHorizontalScrollIndicator:YES];
    CGSize newSize = CGSizeMake((array.count)*151,0);
    [elementscrollview setContentSize:newSize];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    for(int i=0;i<array.count;i++){
        
        UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(10+i*150,10, 140, 140)];
        
        if([self.selectedDaPeiImagePath isEqualToString:[array[i] objectForKey:@"dapei"]]){
    
          //  view.image = selectedImage;
            
            self.elemenSelected = [NSNumber numberWithInt:i+1];
            
            if ( [self.elemenSelected intValue] <self.elemensArray.count) {
                
                int x = i+2;
                self.elemenSelected = [NSNumber numberWithInt:x];
            }
            else{
                
                self.elemenSelected = [NSNumber numberWithInt:1];
            }
        }
        
//        else{
//          //  unSelected= [unSelected resizedImage:view.frame.size interpolationQuality: kCGInterpolationHigh];
//          //  view.backgroundColor = [UIColor colorWithPatternImage:unSelected];
//            view.image = unSelected;
//        }
        
        
        UIImageView *imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(2,2, 136, 136)];
        
        UIView *info = [[UIView alloc]initWithFrame:CGRectMake(2,108, 136, 30)];
        [info setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.5]];
        
        UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake(0,0, 130, 15)];
        [name setBackgroundColor:[UIColor clearColor]];
        name.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0f];
        NSString *nameStr = [array[i] objectForKey:@"name"];
        if([nameStr isEqualToString:@"未知信息"]){
            
            nameStr = @" 此商品暂无信息";
        }

        
        [name setText:[NSString stringWithFormat:@" %@",nameStr]];
        [name setTextColor:[UIColor whiteColor]];
        
        NSString *dispriceStr = [array[i] objectForKey:@"disprice"];
        float dispriceFloat = [dispriceStr floatValue];
        
        if(dispriceFloat>0){
        
        UILabel *disprice =[[UILabel alloc] initWithFrame:CGRectMake(0, 15, 60, 15)];
        [disprice setBackgroundColor:[UIColor clearColor]];
        disprice.font= [UIFont fontWithName:@"MicrosoftYaHei" size:9.0f];
        [disprice setTextColor:[UIColor whiteColor]];
        [disprice setText:[NSString stringWithFormat:@"  ¥%@",dispriceStr]];
         
       NSString *priceString = [array[i] objectForKey:@"price"];
       float priceFloat = [priceString floatValue];
            
        if(priceFloat == 0){
          
            disprice.frame = CGRectMake(0, 15, 130, 15);
        }
            
        else{
            
        UILabel *price =[[UILabel alloc] initWithFrame:CGRectMake(65, 15, 65, 15)];
        [price setBackgroundColor:[UIColor clearColor]];
        price.font = [UIFont fontWithName:@"MicrosoftYaHei" size:9.0f];
        [price setTextColor:[UIColor whiteColor]];
        [price setText:[NSString stringWithFormat:@"  ¥%@", dispriceStr]];
        
        UIImageView *lineView1 = [[UIImageView alloc] initWithFrame:CGRectMake(70, 22, 55, 5)];
        NSString *imagepath1 = [[NSBundle mainBundle]pathForResource:@"line.png" ofType:@""];
        UIImage *imageLine1 = [UIImage imageWithContentsOfFile:imagepath1];
        lineView1.image = imageLine1;
        imageLine1 = nil;
            
            
        [info addSubview:price];
        price = nil;
        [info addSubview:lineView1];
        lineView1 = nil;
            }
            
            
            [info addSubview:disprice];
            disprice = nil;
        }
        
        else{
        
            info.frame = CGRectMake(2,123, 136,15);
        }
        
        
        if(!loginInfo.isOfflineMode){
        
        NSString  *path =[array[i] objectForKey:@"thumb"];
        path = [imageUrl stringByAppendingString:path];
        NSURL *url = [NSURL URLWithString:path];
        [imageView1 setImageWithURL:url size:CGSizeMake(280, 280)];
       
        }
        else{
            
         //   [imageView1 loadlocalImage:[array[i] objectForKey:@"thumb"] size:imageView1.frame.size setCenter:false];
            
            NSArray *tempArray = [[NSArray alloc] initWithObjects:[array[i] objectForKey:@"thumb"],imageView1, nil];
            
        
                
            NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self
                                                                                   selector:@selector(downloadImage:)
                                                                                     object:tempArray];
            
            [queue addOperation:operation];


        }
        
        imageView1.tag=i+1;
        view.tag=i+1;
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)]];
        [view addSubview:imageView1];
        [info addSubview:name];
        [view addSubview:info];
        
        [elementscrollview addSubview:view];
        
        
    }
   // [elementscrollview setBackgroundColor:[UIColor blackColor]];
   // [loginInfo.progressBarView removeFromSuperview];
  //  elementscrollview.showsHorizontalScrollIndicator = YES;//水平方向的滚动指示
 //   [elementscrollview flashScrollIndicators];
    
    
    [self switchImage:self.elemenSelected ];
    
    
}

- (void)onTap:(UIGestureRecognizer *)gestureRecognizer
{
    
    
    [loginInfo.progressBarView setTip:@"正在加载......"];
     [self.view insertSubview:loginInfo.progressBarView belowSubview:backButton];
       UIView *view = gestureRecognizer.view;
    
        NSThread *switchImageThread = [[NSThread alloc] initWithTarget:self selector:@selector(switchImage:) object:[NSNumber numberWithLong:view.tag]];
       [switchImageThread start];
    
}

-(void)switchImage:(NSNumber *)sender{
    
    loginInfo.loadingName = @"switchImage";
    
    
    UIView *view = [elementscrollview viewWithTag:[sender intValue]]; // 这个view是手势所属的view，也就是增加手势的那个view
    
    
    if(history==nil){
        
        history = [[NSMutableArray alloc] init];
    }

    
    
    if(view.tag>0){
        
        collocation = true;
        

        UIImageView *imageView = (UIImageView *)[myscrollview viewWithTag:selected];
        
        if([imageView isKindOfClass:[UIImageView class]])
        {
            
            if(!loginInfo.isOfflineMode)
            {
                
                NSString  *path =[NSString stringWithFormat:@"%@%@",imageUrl,[elementsGoods[view.tag-1] objectForKey:@"dapei"]];
                
                if(!isHigh)
                {
                    path = [path stringByAppendingString:@"_thumb.png"];
                }
                
                NSURL  *url = [NSURL URLWithString:path];
                
                [imageView setImageWithURL:url size:CGSizeMake(66, 0)];
            }
            
            
            else if(loginInfo.isOfflineMode){
                
                //[imageView loadlocalImage:[elementsGoods[view.tag-1] objectForKey:@"dapei"] size:imageView.frame.size setCenter:false];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIImage loadFromURL:[elementsGoods[view.tag-1] objectForKey:@"dapei"] callback: ^(UIImage *image){
                    
                    [imageView setImage:image];
                    image = nil;
                    [loginInfo.progressBarView removeFromSuperview];

                }];
              });       
                
            }
        }

        
        for(int i =0;i<goods.count;i++){
            NSDictionary *a =goods[i];
            if([[a objectForKey:@"id"] isEqualToString:self.elementId]){
                
                goods = [goods mutableCopy];
                NSDictionary *temp1 =[goods[i] mutableCopy];
                NSDictionary *temp2 = [elementsGoods[view.tag-1] mutableCopy];
                NSDictionary *temp3 = [elements[selected-1] mutableCopy];
                elements = [elements mutableCopy];
                
                //   NSLog(@"%@",temp1);
                //   NSLog(@"%@",temp3);
                
                [temp1 setValue:[temp2 objectForKey:@"name"] forKey:@"name"];
                [temp1 setValue:[temp2 objectForKey:@"price"] forKey:@"price"];
                [temp1 setValue:[temp2 objectForKey:@"disprice"] forKey:@"disprice"];
                [temp1 setValue:[temp2 objectForKey:@"dapei"] forKey:@"image"];
                
                [temp3 setValue:[temp2 objectForKey:@"dapei"] forKey:@"dapei_pic"];
                NSLog(@"%@",temp3);
                
                
                NSDictionary *historyTemp = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             self.elementId,@"elementId",
                                             [NSNumber numberWithInt: selected],@"layer",
                                             [imageUrl stringByAppendingString:[elements[selected-1] objectForKey:@"dapei_pic"]],@"originUrl",
                                             [NSString stringWithFormat:@"%@%@",imageUrl,[elementsGoods[view.tag-1] objectForKey:@"dapei"]],@"nowUrl",
                                             [goods[i] mutableCopy],@"oriGoods",
                                             temp1,@"nowGoods",
                                             [elements[selected-1] mutableCopy],@"oriElements",
                                             temp3,@"nowElements",
                                             [NSNumber numberWithInt:i],@"goodsIndex",
                                             [NSNumber numberWithInt:selected-1],@"elementsIndex",
                                             nil];
                
                [history addObject:historyTemp];
                
                
                goods[i] = temp1;
                elements[selected-1] = temp3;
                
                break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

        
        UIView *typeView = [self.view viewWithTag:123];
        if(history.count>0){
            UIView *button = [typeView viewWithTag:10];
            if([button isKindOfClass:[UIButton class]])
            {
                UIButton *temp = (UIButton *)button;
                [temp  setEnabled:true];
            }
        
        }
        
        if(history.count>historyIndex && historyIndex != 0){
            UIView *button = [typeView viewWithTag:11];
            if([button isKindOfClass:[UIButton class]])
            {
                UIButton *temp = (UIButton *)button;
                [temp  setEnabled:true];
            }
            
        }
        });
        
    }
    
    else{
    
        [loginInfo.progressBarView removeFromSuperview];
    }
    
    NSArray *allView = [elementscrollview subviews];
    
    for (int i =0;i<[allView count];i++) {
        
        UIImageView *tempView = (UIImageView *)allView[i];
        [tempView setImage:unSelected];
        
    }
    
    if([view isKindOfClass:[UIImageView class]]){
        UIImageView  *tempview = (UIImageView *)view;
        [tempview setImage:selectedImage];
        
    }

    
}
-(void)removeSwitchImage:(id)sender{
    
    [loginInfo.progressBarView removeFromSuperview];
    
}
- (BOOL)pointInside:(NSMutableArray *)array {
    //Using code from http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    
    UIImage *image = array[0];
    CGPoint point = CGPointMake(0, 0);
    float x= [array[1] floatValue];
    float y= [array[2] floatValue];
    
    point.x = ((image.size.width*x)/width);
    point.y = ((image.size.height*y)/height);
    
    //    point.x = ((image.size.width*x)/collocationView.frame.size.width);
    //    point.y = ((image.size.height*y)/collocationView.frame.size.height);
    
    
    unsigned char pixel[1] = {0};
    CGContextRef context = CGBitmapContextCreate(pixel,1, 1, 8, 1, NULL,kCGImageAlphaOnly);
    UIGraphicsPushContext(context);
    [image drawAtPoint:CGPointMake(-point.x,-point.y)];
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGFloat alpha = pixel[0]/255.0f;
    BOOL transparent = alpha < 0.01f;
    image = nil;
    
    return !transparent;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    [loginInfo.progressBarView setTip:@"正在加载......"];
    [self.view insertSubview:loginInfo.progressBarView belowSubview:backButton];
    NSThread *thread5 = [[NSThread alloc] initWithTarget:self selector:@selector(threadMethod:) object:gestureRecognizer];
    [thread5 start];
    
  }
-(void)threadMethod:(UIGestureRecognizer *)gestureRecognizer{
    
    CGPoint currentPoint = [gestureRecognizer locationInView:collocationView];

    NSMutableArray *temp =nil;
    
    BOOL flagNoHotPic = true;
    
    for(int x= (int)hotPic.count-1;x>=0;x--){
        if([hotPic[x] isKindOfClass:[UIImage class]]){
            
            temp = [[NSMutableArray alloc] init];
            [temp addObject:hotPic[x]];
            [temp addObject:[NSNumber numberWithFloat:currentPoint.x]];
            [temp addObject:[NSNumber numberWithFloat:currentPoint.y]];
            bool flag = [self pointInside:temp];
            if(flag){
                flagNoHotPic = false;
                selected = x+1;
                
                NSDictionary *temp = elements[x];
             //   NSLog(@"%@",elements);
                
                
                if([self.elementId isEqualToString:[temp objectForKey:@"element_id"]]){
                    
                    
                    if ( [self.elemenSelected intValue] <self.elemensArray.count) {
                        
                        int x = [self.elemenSelected intValue]+1;
                        self.elemenSelected = [NSNumber numberWithInt:x];
                    }
                    else{
                        
                        self.elemenSelected = [NSNumber numberWithInt:1];
                    }
                    [self switchImage:self.elemenSelected ];
                }
                
                else{
                    
                    self.elementId = [temp objectForKey:@"element_id"];
                    self.selectedDaPeiImagePath = [temp objectForKey:@"dapei_pic"];
                    
                    
                    
                        NSThread *threadHot = [[NSThread alloc]initWithTarget:self selector:@selector(postElement:) object:[temp objectForKey:@"layer"]];
                        [threadHot start];
               //     [self postElement:[temp objectForKey:@"layer"]];
                }
                break;
            }
        }
    }
    
    if(flagNoHotPic){
    
    //    [globalContext showAlertView:@"该元素的热点区域加载失败"];
        [loginInfo.progressBarView removeFromSuperview];
    }

}
-(void)postElement:(NSString *)layer{
    
    if(!loginInfo.isOfflineMode){
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"planId":self.planId,@"layer":layer,@"angle":self.angle};
   
        [manager POST:[BASEURL stringByAppendingString:getCollocationElementApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
         //   NSLog(@"JSON: %@", responseObject);
    
            NSMutableArray *rootDic = responseObject;
            if([rootDic isKindOfClass:[NSArray class]]){
             self.elemensArray = rootDic;
             [self getElementsList:rootDic];
            }
           //  [self showView:nil];
    
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [loginInfo.progressBarView removeFromSuperview];
    
        }];
    }
    else{
    
        NSMutableArray *rootDic = [DBHelper getElement:self.planId layer:layer angle:self.angle];
 
            if([rootDic isKindOfClass:[NSArray class]]){
                self.elemensArray = rootDic;
                [self getElementsList:rootDic];
            }
        
        
       
    }
}
-(void)backAction:(id)sender{
    
    if(collocation){
        [self showSaveAlertView:@"是否保存此次搭配?"];
    }
    else{
        
        for (NSArray *temp in loginInfo.allMessage) {
            NSString *tempPlanId = temp[0];
            if([tempPlanId isEqualToString:self.planId]){
                [loginInfo.allMessage removeObject:temp];
                break;
            }
        }

        
        [self back];
        
    }
    
}
-(void)back{
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self removeCollocationView:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToCollocationLoading" object:nil];
        
    }];
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (tapGesture) {
        return YES;
    }
    return NO;
}
-(void)removeCollocationView:(id)sender{
        NSArray *array = [self.view subviews];
    
        for(UIView *view in array){
    
            [view removeFromSuperview];
        }

        NSArray *views = [collocationView subviews];
        for (int i =0;i< views.count;i++) {
            UIView *view = views[i];
            if([view isKindOfClass:[UIImageView class]]){
    
                UIImageView *imageView = (UIImageView *)view;
                imageView.image = nil;
                imageView = nil;
                [imageView removeFromSuperview];
            }
        }
        [myscrollview removeFromSuperview];
         myscrollview = nil;
        [bottomView removeFromSuperview];
         bottomView = nil;
    //  //   saveView = nil;
        [collocationView removeGestureRecognizer:tapGesture];
        tapGesture.delegate = nil;
        tapGesture = nil;
        [collocationView removeFromSuperview];
        collocationView = nil;
        [self.view removeFromSuperview];
         self.view = nil;
         collocationData = nil;
         elementscrollview = nil;
        imageGesture =nil;
        selected= 0;
        ElementsList = nil;
        hotPic= nil;
        elements = nil;
        elementsGoods =nil;
        typeSearchCollocation = nil;
        popControllerCollocation = nil;
        alertView = nil;
        style =nil;
        upView = nil;
       //  goods = nil;
        selectedImage = nil;
        unSelected = nil;
      loginInfo.loadingName = @"";
       history = nil;
       historyIndex = 0;
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToCollocationLoading" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"switchImage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeHideStatus" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"customerClearImageCache" object:nil];
    
}

-(void)showAlertView:(NSString *)message{     //显示提示框
    
    alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:message delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
    [alertView setMessage:message];
    alertView.tag = 110;
    [alertView show];
}
-(void)showSaveAlertView:(NSString *)message{     //显示提示框
    
    alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存，并退出",@"不保存，并退出", nil];
    [alertView setMessage:message];
    alertView.tag = 111;
    [alertView show];
}
-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self hideView:nil];
    
    if(alertView.tag == 111){
        if(buttonIndex == 2){
            
            for (NSArray *temp in loginInfo.allMessage) {
                NSString *tempPlanId = temp[0];
                if([tempPlanId isEqualToString:self.planId]){
                    [loginInfo.allMessage removeObject:temp];
                    break;
                }
            }
            [self back];
         }
        else if (buttonIndex == 1){
            
                  [loginInfo.progressBarView setTip:@"正在保存......"];
                   [self.view insertSubview:loginInfo.progressBarView belowSubview:backButton];
            
                  NSThread *saveCollocationThread = [[NSThread alloc] initWithTarget:self selector:@selector(saveCollocation:) object:nil];
                [saveCollocationThread start];
            
               [self back];
            
            
        }
    }
    
   else if(alertView.tag == 127){
        if(buttonIndex == 0){
           
        }
        else{
            
             login = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
          //  self.modalPresentationStyle = UIModalPresentationCurrentContext;
         //   [self presentViewController:login animated:NO completion:nil];
            
            [self.view addSubview:login.view];
            
       //    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLogin" object:nil];
            
        }
    }

    
}
-(void)saveCollocation:(id)sender{     //保存搭配
    
    if(loginInfo==nil){
        loginInfo = [[LoginInfo alloc] init];
    }
    
    UIGraphicsBeginImageContextWithOptions(collocationView.bounds.size, collocationView.opaque, 0.0f);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 7) {
        [collocationView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    else{
        [collocationView drawViewHierarchyInRect:collocationView.bounds afterScreenUpdates:NO];
    }
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    goods = [goods mutableCopy];
    
    NSArray *temp = [[NSArray alloc] initWithObjects:self.planId,img,[goods copy],nil];
    if(loginInfo.allMessage == nil){
        loginInfo.allMessage = [[NSMutableArray alloc] init];
        
    }
    else{
    
        for (NSArray *temp in loginInfo.allMessage) {
            NSString *tempPlanId = temp[0];
            if([tempPlanId isEqualToString:self.planId]){
                [loginInfo.allMessage removeObject:temp];
                break;
            }
        }
    }

    [loginInfo.allMessage addObject:temp];

    
    [[StockData getSingleton] setValue:loginInfo  forKey:@"loginInfo"];
    
}
-(void)mirror:(id)sender{               //镜像功能
    NSArray *views = [collocationView subviews];
    for (int i =0;i< views.count;i++) {
        UIView *view = views[i];
        if([view isKindOfClass:[UIImageView class]]){
            
            UIImageView *imageView = (UIImageView *)view;
            UIImage *image = imageView.image;
            if(image){
            UIImage *hotImage = nil;
            if(i<hotPic.count){
                hotImage = hotPic[i];
            }
            if(!loginInfo.isMirror){
                UIImage* flippedImage = [UIImage imageWithCGImage:image.CGImage
                                                            scale:image.scale
                                                      orientation:UIImageOrientationUpMirrored];
                
                if(hotImage != nil && [hotImage isKindOfClass:[UIImage class]]){
                    UIImage* flippedHotImage = [UIImage imageWithCGImage:hotImage.CGImage
                                                                   scale:hotImage.scale
                                                             orientation:UIImageOrientationUpMirrored];
                    hotPic[i] = flippedHotImage;
                    
                }
                
                [imageView setImage:flippedImage];
            }
            else{
                UIImage* flippedImage = [UIImage imageWithCGImage:image.CGImage
                                                            scale:image.scale
                                                      orientation:UIImageOrientationUp];
                if(hotImage != nil && [hotImage isKindOfClass:[UIImage class]]){
                    UIImage* flippedHotImage = [UIImage imageWithCGImage:hotImage.CGImage
                                                                   scale:hotImage.scale
                                                             orientation:UIImageOrientationUp];
                    hotPic[i] = flippedHotImage;
                }
                [imageView setImage:flippedImage];
            }
            }
        }
    }
    if(!loginInfo.isMirror){
        loginInfo.isMirror = true;
    }
    else{
        loginInfo.isMirror = false;
    }
    
}
-(void)changeHide:(NSNotification *)notification{     // 隐藏功能
    NSArray *data = [notification object];
    int index = [data[0] intValue];
    bool isHide = [data[1] boolValue];

    NSLog(@"%@",goods);
    
    for(int i =0;i<elements.count;i++){
        NSString *elementId = [elements[i] objectForKey:@"element_id"];
        for(int j =0;j<goods.count;j++){
            if([elementId isEqualToString:[goods[j] objectForKey:@"id"]]){
                
                if([[goods[i] objectForKey:@"type"] integerValue] == index ||index==3){
                    
                    UIView *viewTemp = [collocationView viewWithTag:i+1];
                    [viewTemp setHidden:isHide];
                }
                break;
            }
        }
    }
}
-(void)revocation:(id)sender{      //撤销操作
    
    loginInfo.loadingName = @"switchImage";
    
    [loginInfo.progressBarView setTip:@"正在撤销......"];
    [self.view insertSubview:loginInfo.progressBarView belowSubview:backButton];
    
    if(firstRevocation){
        firstRevocation = false;
        historyIndex = history.count-1;
    }
    
    [self revocationOrRecover:historyIndex isRecover:false];
    
    if(historyIndex>-1){
      historyIndex --;
        
        UIView *typeView = [self.view viewWithTag:123];
        if(history.count>0){
            UIView *button = [typeView viewWithTag:11];
            if([button isKindOfClass:[UIButton class]])
            {
                UIButton *temp = (UIButton *)button;
                [temp  setEnabled:true];
            }
            
        }

        
    }
    if(historyIndex<0){
    
        UIView *typeView = [self.view viewWithTag:123];
        if(history.count>0){
            UIView *button = [typeView viewWithTag:10];
            if([button isKindOfClass:[UIButton class]])
            {
                UIButton *temp = (UIButton *)button;
                [temp  setEnabled:false];
            }
            
        }

    }

}
-(void)recover:(id)sender{        //恢复操作
    
    loginInfo.loadingName = @"switchImage";
    
    [loginInfo.progressBarView setTip:@"正在恢复......"];
     [self.view insertSubview:loginInfo.progressBarView belowSubview:backButton];

    int count = history.count;
    if(historyIndex < count){
        historyIndex ++;
        [self revocationOrRecover:historyIndex isRecover:true];
        
        UIView *typeView = [self.view viewWithTag:123];
        if(history.count>0){
            UIView *button = [typeView viewWithTag:10];
            if([button isKindOfClass:[UIButton class]])
            {
                UIButton *temp = (UIButton *)button;
                [temp  setEnabled:true];
            }
            
        }
        
        
    }
    if(historyIndex == history.count-1){
        
        UIView *typeView = [self.view viewWithTag:123];
        if(history.count>0){
            UIView *button = [typeView viewWithTag:11];
            if([button isKindOfClass:[UIButton class]])
            {
                UIButton *temp = (UIButton *)button;
                [temp  setEnabled:false];
            }
            
        }
        
    }

}
-(void)revocationOrRecover:(int)historyIndex isRecover:(BOOL)flag{     //撤销，恢复操作

    NSDictionary *historyTemp = history[historyIndex];
    
    goods[[[historyTemp objectForKey:@"goodsIndex"] intValue]] = [historyTemp objectForKey:@"oriGoods"];
    goods[[[historyTemp objectForKey:@"elementsIndex"] intValue]] = [historyTemp objectForKey:@"oriElements"];
    
    UIImageView *imageView = (UIImageView *)[myscrollview viewWithTag:[[historyTemp objectForKey:@"layer"] intValue]];
    if([imageView isKindOfClass:[UIImageView class]])
    {
        NSURL *url;
        if(!flag){
            if(!loginInfo.isOfflineMode){
                
             url = [NSURL URLWithString:[historyTemp objectForKey:@"originUrl"]];
             [imageView setImageWithURL:url size:CGSizeMake(66, 0)];
            }
            else{
                
                NSArray *names = [[historyTemp objectForKey:@"originUrl"] componentsSeparatedByString:@"/"];
                
                [UIImage loadFromURL:names[names.count-1] callback:^(UIImage *image){
                
                    [imageView setImage:image];
                    image = nil;
                    [loginInfo.progressBarView removeFromSuperview];
                }];
            }
        }
        else{
            if(!loginInfo.isOfflineMode){
                
              url = [NSURL URLWithString:[historyTemp objectForKey:@"nowUrl"]];
              [imageView setImageWithURL:url size:CGSizeMake(66, 0)];
            }
            else{
            
                NSArray *names = [[historyTemp objectForKey:@"nowUrl"] componentsSeparatedByString:@"/"];

                
                [UIImage loadFromURL:names[names.count-1] callback:^(UIImage *image){
                    
                    [imageView setImage:image];
                    image = nil;
                    [loginInfo.progressBarView removeFromSuperview];

                }];

            }
        }
        
    }

}
-(void)highOrNormal:(id)sender{     //高清，普请操作
    
    [loginInfo.progressBarView setTip:@"正在切换......"];
     [self.view insertSubview:loginInfo.progressBarView belowSubview:backButton];

    for(int i =0;i<[elements count];i++){
        NSDictionary *temp =elements[i];
        
        
        NSString *path = [imageUrl stringByAppendingString:[temp objectForKey:@"dapei_pic"]];
        if(isHigh)
        {
          path = [path stringByAppendingString:@"_thumb.png"];
        }
        NSURL *url = [NSURL URLWithString:path];
        
        
        UIImageView *imageview = (UIImageView *)[myscrollview viewWithTag:i+1];

        [imageview setImageWithURL:url size:CGSizeMake(67, 0)];
        
    }
    
    if(!loginInfo.isOfflineMode){
    
    UIView *typeView = [self.view viewWithTag:123];
    
    UIView *button = [typeView viewWithTag:12];
    
    if(isHigh){
        isHigh = false;
        if([button isKindOfClass:[UIButton class]])
        {
            UIButton *temp = (UIButton *)button;
            [temp setBackgroundImage:[UIImage imageNamed:@"5.普清1.png"] forState:UIControlStateNormal];
                   }

    
    }
    else{
        isHigh = true;
        if([button isKindOfClass:[UIButton class]])
        {
            UIButton *temp = (UIButton *)button;
            [temp setBackgroundImage:[UIImage imageNamed:@"高.png"] forState:UIControlStateNormal];

        }
    }
    }
}
-(void)cancel:(float)sender{
    NSArray *views = [collocationView subviews];
    for (int i =0;i< views.count;i++) {
        UIView *imageView = views[i];
        //   UIView *imageView = [collocationView viewWithTag:indexCount];
        if([imageView isKindOfClass:[UIImageView class]]){
            UIImageView *imageView1= (UIImageView *)imageView;
            CALayer *layer = imageView1.layer;
            
            [UIView animateWithDuration:0.7f
                                  delay:0.0f
                                options:UIViewAnimationOptionTransitionFlipFromLeft
                             animations:^{
                                 
                                 CATransform3D tranform = CATransform3DIdentity;
                                 tranform.m34 = 1.0/100;
                                 CGFloat radiants = -(i+1)*sender* M_PI / 180.0f;
                                 tranform = CATransform3DRotate(tranform, radiants, 0.0f, 1.0f, 0.0f);
                                 layer.anchorPoint = CGPointMake(0.5, 0.5);
                                 layer.transform = tranform;
                                 layer.zPosition =i;
                                 
                                 
                             }
                             completion:^(BOOL finished) {
                                 indexCount++;
                                 //    [messageview configView:loginInfo.planViewData];
                             }
             ];
            
            
        }
    }
    // indexCount++;
    
}

-(void)getDegress{
    
    //召唤加速度传感器
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//
//        [LSBGetDegress getDegressWithBlock:^(CMAccelerometerData *latestAcc, NSError *error) {
//            
//            NSLog(@"%f",fabsf(latestAcc.acceleration.y-lastDegress));
//            if(fabsf(latestAcc.acceleration.y-lastDegress)>0.009){
//                lastDegress = latestAcc.acceleration.y;
//        //    NSLog(@"%f",latestAcc.acceleration.y);
//         //       NSArray *views = [collocationView subviews];
//          //  if(indexCount == views.count){
//                indexCount = 0;
//            if((latestAcc.acceleration.y>-0.1&&latestAcc.acceleration.y<0)){
//                [self cancel:latestAcc.acceleration.y];
//            }
//            else if((latestAcc.acceleration.y<0.1 && latestAcc.acceleration.y>0.02)){
//                [self cancel:latestAcc.acceleration.y];
//            }
//         //   }
//                                
//        }
//        }];
    
        
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIView setAnimationsEnabled:YES];
    [globalContext clearStatusNotification];
    [LSBGetDegress stopMotion];
}

@end
