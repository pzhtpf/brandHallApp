//
//  downloadDetail.m
//  brandv1.2
//
//  Created by Apple on 14-11-13.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "downloadDetail.h"
#import "Define.h"
#import "housesListDetail.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"
#import "globalContext.h"
#import "downloadPlanDetail.h"
#import "DBHelper.h"
#import "downloadImage.h"
#import "AsyncImageDownloader.h"
#import "loginViewController.h"
#import "typeSearchTableViewController.h"

@interface downloadDetail ()

@end

@implementation downloadDetail
@synthesize detailAllView;
CGRect originFrame;
UIView *temp ;
housesListDetail *_housesListDetail;
@synthesize housesListDetailAllData;
NSMutableArray *housesListDetailData;
LoginInfo *loginInfo;
NSDictionary *dataArgs;
int totalCount = 0;
NSMutableDictionary *allSelect;
NSMutableArray *allImageView;
UIImage *selectImg;
UIImage *unselectImg;
int closeType = 0;
double totalCapticy = 0;
NSMutableArray *dataMutableArray ;
NSMutableArray *singalDataMutableArray;
downloadPlanDetail  *_downloadPlanDetail;
UIView  *blue_bar;
UIView  *yellow_bar;
UIView  *gray_bar;
int downloadPageCount = 8;
int downloadPageIndex = 0;
UIImageView *imageMapView;
NSString *downloadStatus = @"";
NSMutableDictionary *selectView;
NSMutableDictionary *updateViewArray;
loginViewController *loginController;
float lastSwipeLocationY = 67;
typeSearchTableViewController *typeSearchDownloadDetail;
UIPopoverController *popControllerDownloadDetail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isHidden = YES;
        _canMove = NO;
        _height = 88.0f;
        _padding = 0.0f;
        _animationDuration = 0.1f;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.housesListDetailTable.bounds.size.height, self.housesListDetailTable.frame.size.width,self.housesListDetailTable.bounds.size.height)];
        view.delegate = self;
        
        [self.housesListDetailTable addSubview:view];
        _refreshHeaderView = view;
        view = nil;
    }
    
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [self.housesListDetailTable reloadData];
    
    [_refreshHeaderView egoRefreshStartLoading:self.housesListDetailTable];
    
    if(!selectView)
        selectView = [[NSMutableDictionary alloc] init];
  
    self.detailAllView.layer.cornerRadius = 5;
    self.detailTitleLabel.clipsToBounds = YES;
    self.detailTitleLabel.layer.cornerRadius = 5;
    self.mapView.layer.cornerRadius = 5;
    
    self.planDetailView.layer.cornerRadius = 5;
    self.planDetailTitleLabel.clipsToBounds = YES;
    self.planDetailTitleLabel.layer.cornerRadius = 5;
    self.planStartDownLoad.layer.cornerRadius = 5;
    
    self.huxingTitleLabel.clipsToBounds = YES;
    self.huxingTitleLabel.layer.cornerRadius = 5;
    self.huxingTitleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:18.0f];
    
    [self.label18 setTextColor:UIColorFromRGB(0x0091ff)];
    self.label18.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17.0f];//
    
    [self.label916 setTextColor:UIColorFromRGB(0x0091ff)];
    self.label916.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17.0f];//
    
    [self.housesListLabel setTextColor:UIColorFromRGB(0x686868)];
    self.housesListLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];//

    self.startDownload.layer.cornerRadius = 5;

     self.selectAll.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];//
    
    [self.previewMapButton setTitleColor:UIColorFromRGB(0xff553e) forState:UIControlStateNormal];
    
    self.previewMapButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0f];//
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MicrosoftYaHei" size:14.0f], UITextAttributeFont, nil];
    [self.segmented setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    
    [self.planDetailSegmented setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    
     [self.planDetailSegmented setSelectedSegmentIndex:1];
     [self.segmented setSelectedSegmentIndex:1];
    
    [self.selectAll setTitleColor:UIColorFromRGB(0x686868) forState:UIControlStateNormal];
    self.selectAll.tag = 0;
    
    [self.otherView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMethod:)]];
    
    self.housesListDetailTable.delegate = self;
    self.housesListDetailTable.dataSource = self;
    [self.housesListDetailTable setBackgroundColor:[UIColor clearColor]];
    
    [self.button18 setHidden:true];
    [self.button916 setHidden:true];
    [self.label18 setHidden:true];
    [self.label916 setHidden:true];
    
    [self usedSpaceAndfreeSpace:0 total:totalCapticy];
    
    NSString *searchString = [[NSBundle mainBundle]pathForResource:@"unselect.png" ofType:@""];
    unselectImg = [UIImage imageWithContentsOfFile:searchString];
    
    updateViewArray = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHousesView:) name:@"updateHousesView" object:nil];

    [DBHelper createDownloadTabel];
    
}
-(void)updateHousesView:(NSNotification *)notification{
    
    if(updateViewArray){
    NSString *housesId = [dataArgs objectForKey:@"id"];
    NSArray *tempData = [[loginInfo.dataFromPlanTable objectForKey:housesId] objectForKey:@"data"];
    
    for(NSDictionary *temp in tempData){
    
        NSString *planId = [temp objectForKey:@"planId"];
        int status = [[temp objectForKey:@"status"] intValue];
        UIView *view = [updateViewArray objectForKey:planId];
        if(view){
        
            NSString *statusStr = @"";
            switch (status) {
                case 0:
                    statusStr = @"暂停中...";
                    break;
                case 1:
                    statusStr = @"排队中...";
                    break;
                case 2:
                    statusStr = @"下载中...";
                    break;
                case 3:
                    statusStr = @"已下载";
                    break;
                default:
                    break;
            }
            UILabel *status = (UILabel *)[view viewWithTag:68];
            NSArray *tempArray = [[NSArray alloc] initWithObjects:status,statusStr, nil];
            
            [self performSelectorInBackground:@selector(updateabel:) withObject:tempArray];
          //  [status setText:statusStr];
        }
    }
    }
}
-(void)updateabel:(NSArray *)data{
    UILabel *label = data[0];
    NSString *statusStr = data[1];
    [label setText:statusStr];
}
-(void)initCGRect:(CGRect)frame data:(NSDictionary *)data downloadStatus:(NSString *)downloadStatusArgs image:(UIImage *)image{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNormalOrHighAction:) name:@"setNormalOrHigh" object:nil];
    UIPanGestureRecognizer *swipeDown = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(barViewWasSwiped:)];
    [self.planProductDetail addGestureRecognizer:swipeDown];
    
    [detailAllView setHidden:true];
    
    dataArgs = data;
    
    [self.planStartDownLoad setTitle:@"开始下载" forState:UIControlStateNormal];
    
    [self.planStartDownLoad setEnabled:true];
    [self.planStartDownLoad setBackgroundColor:UIColorFromRGB(0x3a5697)];
    [self.planStartDownLoad setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    
    if(loginInfo.downloadType == 3){
        
       
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [activityIndicator setCenter:self.housesListDetailTable.center];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.tag = 134;
        [self.housesListDetailTable addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
    
    [self getHousesListDetailMessage:[data objectForKey:@"id"]];
    
    [self.housesIcon setImageWithURL:[NSURL URLWithString:[imageUrl stringByAppendingString:[data objectForKey:@"housesImageURL"]]] size:self.housesIcon.frame.size];
    
    [self.housesAddress setText:[NSString stringWithFormat:@"(%@)",[data objectForKey:@"housesAddress"]]];
    
    [self.housesName setText:[data objectForKey:@"housesName"]];
    
    NSString *nameTypeSizeString = [NSString stringWithFormat:@"%@    %@    (%@m²)",[data objectForKey:@"name"],[data objectForKey:@"type"],[data objectForKey:@"size"]];
    
    [self.nameTypeSize setText:nameTypeSizeString];
    
    NSString *countString = [NSString stringWithFormat:@"%d个样板间    可搭配素材%d款",[[data objectForKey:@"count"] intValue],0];

    [self.count setText:countString];
        
        
        originFrame = frame;
        
        CGRect frame1 =  detailAllView.frame;
        
        
        temp = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 0, 0)];
        
        [temp setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView *gezlifeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.housesIcon.frame.origin.x, self.housesIcon.frame.origin.y, self.housesIcon.frame.size.width, self.housesIcon.frame.size.height)];
        
        if(!image){
            NSString *searchString = [[NSBundle mainBundle]pathForResource:@"icon_80x80.png" ofType:@""];
            UIImage *img = [UIImage imageWithContentsOfFile:searchString];
            [gezlifeIcon setImage:img];
        }
        else{
            
            gezlifeIcon.frame = CGRectMake(self.planDetailImageView.frame.origin.x, self.planDetailImageView.frame.origin.y, self.planDetailImageView.frame.size.width, self.planDetailImageView.frame.size.height);
            [gezlifeIcon setImage:image];
        }
        
        [temp addSubview:gezlifeIcon];
        
        [self.view insertSubview:temp atIndex:1];
        
        [UIView setAnimationsEnabled:YES];
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                             temp.frame =frame1;
                             self.otherView.alpha = 0.7;
                             
                         }
                         completion:^(BOOL finished) {
                             
                             [self loadComplete];
                             
                             
                         }
         ];
        
    }
    else{
        
    //    [self.planDetailView setHidden:true];
        
        downloadStatus = downloadStatusArgs;
        
       [self.planStartDownLoad setEnabled:false];
        
        if(downloadStatus.length>0){
        
            [self.planStartDownLoad setBackgroundColor:UIColorFromRGB(0xcbcbcb)];
            [self.planStartDownLoad setTitleColor:UIColorFromRGB(0x8e8e8e) forState:UIControlStateNormal];
            [self.planStartDownLoad setTitle:downloadStatus forState:UIControlStateNormal];
        }
      
       
        
        [self addClassicView:data image:image];
    }
    


 }
-(void)loadComplete{

    if(loginInfo.downloadType == 3)
    [detailAllView setHidden:false];
    else
    [self.planDetailView setHidden:false];
    
    [UIView animateWithDuration:0.7f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         temp.alpha =0;
                         
                     }
                     completion:^(BOOL finished) {
                         [temp removeFromSuperview];
                         temp = nil;
                     }
     ];


}
- (IBAction)closeAction:(id)sender {
    [self closeMethod:nil];
}
-(void)closeMethod:(id) sender{

    if(closeType == 0 ){
        
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                             CGRect  endFrame =  detailAllView.frame;
                             endFrame.origin.y = 768;
                             detailAllView.frame = endFrame;
                             self.otherView.alpha = 0;
                             
                         }
                         completion:^(BOOL finished) {
                            
                             
                             [[NSNotificationCenter defaultCenter] postNotificationName:@"removeHousesListDetail" object:nil];
                             [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateHousesView" object:nil];
                             
                             [detailAllView removeFromSuperview];
                             detailAllView = nil;
                             temp = nil ;
                             _housesListDetail = nil;
                             housesListDetailAllData = nil;
                             housesListDetailData = nil;
                             dataArgs = nil;;
                             totalCount = 0;
                             allSelect = nil;
                             allImageView = nil;
                             selectImg = nil;
                             unselectImg = nil;
                             closeType = 0;
                             totalCapticy = 0;
                             dataMutableArray  = nil;
                             [blue_bar removeFromSuperview];
                             blue_bar = nil;
                             [yellow_bar removeFromSuperview];
                             yellow_bar = nil;
                             [gray_bar removeFromSuperview];
                             gray_bar = nil;
                             selectView = nil;
                             loginInfo.housesListDetailViewData = [[NSMutableArray alloc] init];
                             [self.housesListDetailTable reloadData];
                             downloadPageIndex = 0;

                             
                         }
         ];
        
    }
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)previewMapAction:(id)sender {
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:self.mapZoom.center];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.tag = 134;
    [self.mapZoom addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(previewMapMethod:) object:activityIndicator];
    [thread start];
//    [self.mapImageView setImageWithURL:[NSURL URLWithString:[imageUrl stringByAppendingString:[dataArgs objectForKey:@"mapURL"]]] size:detailAllView.frame.size];
    
 
}
-(void)previewMapMethod:(UIActivityIndicatorView *)sender{
    
    NSString *urlString = [imageUrl stringByAppendingString:[dataArgs objectForKey:@"mapURL"]];
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
    
    //810,570
    int width = 810;
    int height = 810*image.size.height/570;
    if(height>570){
        
        height = 570;
        width = 570*image.size.width/810;
    }
    
   imageMapView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    self.mapZoom.contentSize = self.mapZoom.frame.size;
    
    [imageMapView setImage:image];
    [imageMapView setCenter:self.mapZoom.center];
    [self.mapZoom addSubview:imageMapView];
    
    self.mapZoom.minimumZoomScale = 0.5;
    self.mapZoom.maximumZoomScale = 3.0;
    self.mapZoom.delegate = self;
    
    [detailAllView addSubview:self.mapView];
    
    [sender removeFromSuperview];
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return imageMapView ;
}
- (IBAction)button18Action:(id)sender {
    
    downloadPageIndex = 0;
    [self.label18 setHidden:false];
    [self.label916 setHidden:true];
    [self getHousesListDetailMessage:nil];
}
- (IBAction)button916Action:(id)sender {
    
    downloadPageIndex = 1;
    [self.label18 setHidden:true];
    [self.label916 setHidden:false];
    [self getHousesListDetailMessage:nil];
}
- (IBAction)selectAllButton:(id)sender {
    
  //  fff
    if(!selectImg){
        NSString *searchString = [[NSBundle mainBundle]pathForResource:@"select_red.png" ofType:@""];
        selectImg = [UIImage imageWithContentsOfFile:searchString];
        allSelect = [[NSMutableDictionary alloc] init];
    }
    
    for(int i =0;i< loginInfo.housesListDetailViewData.count;i++){
        UIView *tempView =  loginInfo.housesListDetailViewData[i];
        NSArray *allViews = [tempView subviews];
        for(int j=0;j<allViews.count;j++){
        
            UIView *temp2View = allViews[j];
             NSArray *allSubViews = [temp2View subviews];
            for(UIView *button in allSubViews){
                if([button isKindOfClass:[UIButton class]]){
                
                  UIButton  *button1 = (UIButton *)button;
                    
                    if(self.selectAll.tag ==0 ){
                  
                    NSString *key = [NSString stringWithFormat:@"%d",(int)button1.tag];
                    [allSelect setValue:housesListDetailAllData[button1.tag] forKey:key];
                    [selectView setValue:[button1 superview] forKey:[NSString stringWithFormat:@"%d",(int)button1.tag]];
                    [button1 setImage:selectImg forState:UIControlStateNormal];
                    }
                    
                    else{
                  
                        [button1 setImage:unselectImg forState:UIControlStateNormal];
                    
                    }
                    
                }
            }
        
        }
    }
    
    if(self.selectAll.tag ==0 ){
        
        self.selectAll.tag =1;
        [self.selectAll setTitle:@"取消全选" forState:UIControlStateNormal];
   
    }
    
    else{
        allSelect = [[NSMutableDictionary alloc] init];
        self.selectAll.tag =0;
        [self.selectAll setTitle:@"全选" forState:UIControlStateNormal];
        
    }

    
       [self getDataMutableArray];
}
- (IBAction)startDownload:(id)sender {

    
    if([globalContext isLogin] && loginInfo.userName.length>0){
    
    if(allSelect && allSelect.count>0){
        if(loginInfo.enableDownload ==1)
        {
        [self prepareDataToDownload:dataMutableArray];
        [self startDownLoadAnimation];
        }
            else
            {
                [globalContext showAlertView:@"您没有下载权限"];
            }
           }
    else{
    
        [globalContext showAlertView:@"请选择要下载的样板间"];
    }
    }
    else{
        UIAlertView  *alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 111;
        [alertView show];
    }
}
-(void)prepareDataToDownload:(NSMutableArray *)data{
    
    [UIView setAnimationsEnabled:YES];
    
    NSMutableDictionary *dataArray = [[NSMutableDictionary alloc] init];
    
    
    NSArray *keys = [allSelect allKeys];
    
        if(loginInfo.downloadType == 1){
    
        NSString *imageUrl1 =  [dataArgs objectForKey:@"imageUrl"];
        NSArray *names = [imageUrl1 componentsSeparatedByString:@"/"];
        NSString *name = [NSString stringWithFormat:@"planTable%@",names[names.count-1]];
        if(self.planDetailImageView.image !=nil){
            NSData* data = UIImagePNGRepresentation(self.planDetailImageView.image);
            [downloadImage saveImage:name image:data];
        
        }
    }
    
        else{
        
            int i = 0;
            
            for(NSString *key in keys){
                
                NSDictionary *temp3 = data[i];
                int goodscount = [[[temp3 objectForKey:@"productAllData"] objectForKey:@"productCount"] integerValue];
                [temp3 setValue:[NSString stringWithFormat:@"%d",goodscount] forKey:@"goodsCount"];
                i++;
                
                int index = [key intValue];
                
                NSDictionary *temp1 = housesListDetailAllData[index];
                NSString *imageUrl1 =  [temp1 objectForKey:@"imageUrl"];
                NSArray *names = [imageUrl1 componentsSeparatedByString:@"/"];
                NSString *name = [NSString stringWithFormat:@"planTable%@",names[names.count-1]];
                [self captureView:allImageView[index] name:name];
            }
            

        
        }
    
    NSString *housesId =[dataArgs objectForKey:@"id"];
    [dataArray setValue:@"1" forKey:@"nowStart"];
    [dataArray setValue:@"A1" forKey:@"angle"];
    
    NSDate *dateTemp = [[NSDate alloc] init];
    NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
    
    [dateFormat1 setDateFormat:@"yyyy年MM月dd日"];

    NSString  *dateString = [dateFormat1 stringFromDate:dateTemp];
    
    [dataArray setValue:dateString forKey:@"downloadTime"];
    
    if(loginInfo.downloadType == 3){
    [dataArray setValue:[NSNumber numberWithInteger:[self.segmented selectedSegmentIndex]] forKey:@"isHigh"];
    [dataArray setValue:housesId forKey:@"housesId"];
        
        NSString *housesImageURL =  [dataArgs objectForKey:@"housesImageURL"];
        NSArray *housesImageURLnames = [housesImageURL componentsSeparatedByString:@"/"];
        NSString *housesImageURLname = [NSString stringWithFormat:@"housesImage%@",housesImageURLnames[housesImageURLnames.count-1]];
        
        if(self.housesIcon.image){       //下载楼盘的图标
        
            NSData* data = UIImagePNGRepresentation(self.housesIcon.image);
            [downloadImage saveImage:housesImageURLname image:data];
        }
        else{
             housesImageURL = [imageUrl stringByAppendingString:housesImageURL];
             [self downloadImage:housesImageURLname path:housesImageURL];
        }
        
      NSString *urlString = [imageUrl stringByAppendingString:[dataArgs objectForKey:@"mapURL"]];
      NSArray *housesMapnames = [urlString componentsSeparatedByString:@"/"];
      NSString *housesMapname = [NSString stringWithFormat:@"housesMap%@",housesMapnames[housesMapnames.count-1]];
     [self downloadImage:housesMapname path:urlString];

        
    NSString *housesName =  [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@",[dataArgs objectForKey:@"housesName"],self.housesAddress.text,self.nameTypeSize.text,self.count.text,housesImageURLname,housesMapname];
        
    [dataArray setValue:housesName forKey:@"housesName"];
    }
    else{
        
        [dataArray setValue:[dataArgs objectForKey:@"id"] forKey:@"housesId"];
        [dataArray setValue:[dataArgs objectForKey:@"name"] forKey:@"housesName"];
        [dataArray setValue:[NSNumber numberWithInteger:[self.planDetailSegmented selectedSegmentIndex]] forKey:@"isHigh"];
    }

        
    [dataArray setValue:data forKey:@"data"];
    //  [dataArray setValue:[NSNumber numberWithInt:1] forKey:@"status"];
    
    //  [DBHelper saveDataToPlanTable:dataArray];
    
    //  [DBHelper getDataFromPlanTable:0];
    
    if(!loginInfo.downloadList)
        loginInfo.downloadList = [[NSMutableDictionary alloc] init];
    
    [loginInfo.downloadList setValue:dataArray forKey:housesId];
    [loginInfo.dataFromPlanTable setValue:dataArray forKey:housesId];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateView" object:nil];
    
    if(loginInfo.isDownloadComplete){
        
        [globalContext addProgressingViewMethod:housesId];
        
        [globalContext startDownloadThread];
    }
    
    [allSelect removeAllObjects];
  }
-(void)downloadImage:(NSString *)name path:(NSString *)path{
    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"name",path,@"path",nil];

    AsyncImageDownloader *downloader = [[AsyncImageDownloader alloc] initWithMediaURL:path data:data tempData:nil successBlock:^(UIImage *image,NSDictionary *data,NSDictionary *dataTemp){
        
        NSLog(@"%@",@"楼盘图片下载成功!");
        
    } failBlock:^(NSError *error){
        
       NSLog(@"%@",@"楼盘图片下载失败!");
        
    }];
    
    [downloader startDownload];

}
-(void)configDetailView:(NSMutableArray *)allData{
    
    //  [table removeFromSuperview];
    
    if(!housesListDetailAllData){
    
    housesListDetailData = [[NSMutableArray alloc] initWithObjects:nil];
    
    housesListDetailAllData = allData;

    allImageView  = [[NSMutableArray alloc] init];
    }
    
    int x = 0;
    int y = 0;
    int row = 0;
    
    // int eachViewHeight = uiView.frame.size.height/2-10;
    int  eachViewWidth  = (self.housesListDetailTable.frame.size.width -51)/4;
    int eachViewHeight = 160;
    
    UIView *uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.housesListDetailTable.frame.size.width,eachViewHeight*2+20)];
    [uiView setBackgroundColor:UIColorFromRGB(0xe1e1e1)];
    [housesListDetailData addObject:uiView];
    
    for(int i=0;i<allData.count;i++){
        
        NSDictionary *temp =allData[i];
        
        if(i!=0 &&i%4==0){
            y++;
            x=0;
        }
        
        if(i!=0 &&i%8==0){
            x=0;
            y=0;
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.housesListDetailTable.frame.size.width,eachViewHeight*2+20)];
            [tempView setBackgroundColor:[UIColor clearColor]];
            
            [housesListDetailData addObject:tempView];
            row++;
            
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x*(eachViewWidth+16),y*(eachViewHeight+17), eachViewWidth, eachViewHeight)];
        
        [view setBackgroundColor:UIColorFromRGB(0xe1e1e1)];
      //  [view setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView * imageView =[[UIImageView alloc] init];
        imageView.frame = CGRectMake(5,5, eachViewWidth,115);
        
        // NSString *path = [imageUrl stringByAppendingString:[temp objectForKey:@"image"]];
        
        NSString *path  = [NSString stringWithFormat:@"%@%@_300X200",imageUrl,[temp objectForKey:@"imageUrl"]];
        NSURL *url = [NSURL URLWithString:path];
     //   [imageView setImageWithURL:url size:CGSizeMake(eachViewWidth,eachViewHeight*0.8)];
        [imageView setCenterImageWithURL:url size:CGSizeMake(eachViewWidth,115)];
        
        [allImageView addObject:imageView];
        
        [view addSubview:imageView];
        
        imageView.userInteractionEnabled = YES;
        //  imageView.tag =[[temp objectForKey:@"id"] intValue];
        imageView.tag =i;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onDownloadDetailTap:)]];
        
        UILabel *housesName =[[UILabel alloc] initWithFrame:CGRectMake(5,120,eachViewWidth-10,20)];
        housesName.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [housesName setTextColor:UIColorFromRGB(0x131313)];
        
        
        UILabel *count =[[UILabel alloc] initWithFrame:CGRectMake(5,140,eachViewWidth-10,20)];
        count.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [count setTextColor:UIColorFromRGB(0xa6aaae)];
        [count setTextAlignment:NSTextAlignmentLeft];
        
      //  NSString *countString = [temp objectForKey:@"goodsCount"];
        int goodscount = 0;
        id productCountObject = [[temp objectForKey:@"productAllData"] objectForKey:@"productCount"];
        
        if(![productCountObject isKindOfClass:[NSNull class]])
            
         goodscount = [productCountObject integerValue];
        
        NSString *countString = [NSString stringWithFormat:@"%d",goodscount];
        
        totalCount = totalCount + goodscount;
        
        NSString *priceText = [NSString stringWithFormat:@"可搭配产品：%d件" ,goodscount];
        
        
        
        [count setText:priceText];
        // [price setTextColor:UIColorFromRGB(0xa4a4a4)];
        
        NSMutableAttributedString *text =
        [[NSMutableAttributedString alloc]
         initWithAttributedString: count.attributedText];
        
        [text addAttribute:NSForegroundColorAttributeName
                     value:UIColorFromRGB(0xff543e)
                     range:NSMakeRange(6, countString.length)];
        [count setAttributedText: text];
        
        NSString  *houseId =[dataArgs objectForKey:@"id"];
        NSDictionary *temp9 = [loginInfo.dataFromPlanTable objectForKey:houseId];
        BOOL downloaded = false;
        int status = 4;
        
        if(temp9){
        
            NSArray *tempArray = [temp9 objectForKey:@"data"];
            for (NSDictionary *temp4 in tempArray) {
                NSString *tempPlanId = [temp4 objectForKey:@"planId"];
                NSString *id = [temp objectForKey:@"planId"];
                if([tempPlanId isEqualToString:id]){
                    status = [[temp4 objectForKey:@"status"] intValue];
                    downloaded = true;
                    break;
                }
            }
        }
        
        if(!downloaded){
        UIButton *unselect = [[UIButton alloc] initWithFrame:CGRectMake(132,92, 24,24)];
        [unselect setImage:unselectImg forState:UIControlStateNormal];
        unselect.tag = i;
        [unselect addTarget:self action:@selector(selectPlan:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:unselect];
        unselect = nil;
        }
        
        NSString *statusStr = @"";
        switch (status) {
            case 0:
                statusStr = @"暂停中...";
                break;
            case 1:
                statusStr = @"排队中...";
                break;
            case 2:
                statusStr = @"下载中...";
                break;
            case 3:
                statusStr = @"已下载";
                break;
            default:
                break;
        }
        
        UILabel *statusLabel =[[UILabel alloc] initWithFrame:CGRectMake(eachViewWidth/2-5,120,eachViewWidth/2+10,20)];
        statusLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [statusLabel setTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        [statusLabel setTextAlignment:NSTextAlignmentRight];
        statusLabel.tag = 68;
        [statusLabel setText:statusStr];
        [view addSubview:statusLabel];
        
        
        [housesName setText:[temp objectForKey:@"name"]];
        [housesName setBackgroundColor:[UIColor clearColor]];
        [count setBackgroundColor:[UIColor clearColor]];
        [view addSubview:housesName];
        housesName = nil;
        [view addSubview:count];
        count = nil;
        
        [updateViewArray setValue:view forKey:[temp objectForKey:@"planId"]];
        [housesListDetailData[housesListDetailData.count-1] addSubview:view];
        
        x++;
        
    }
    
    NSString *countString = [NSString stringWithFormat:@"%d个样板间    可搭配素材%d款",[[dataArgs objectForKey:@"count"] intValue],totalCount];
    
    [self.count setText:countString];
    
 //   unselectImg = nil;
    loginInfo.housesListDetailViewData = [housesListDetailData copy];
    
    [self.housesListDetailTable reloadData];
    
    
    
}
-(void)selectPlan:(id)sender{
    
    UIButton *temp = (UIButton *)sender;
    UIView *view = [temp superview];
    
    if(!selectImg){
    NSString *searchString = [[NSBundle mainBundle]pathForResource:@"select_red.png" ofType:@""];
    selectImg = [UIImage imageWithContentsOfFile:searchString];
    allSelect = [[NSMutableDictionary alloc] init];
    }
    
    NSString *key = [NSString stringWithFormat:@"%d",(int)temp.tag];
    
    if(![allSelect objectForKey:key]){
        
        [selectView setValue:view forKey:key];
        [allSelect setValue:housesListDetailAllData[temp.tag] forKey:key];
        [temp setImage:selectImg forState:UIControlStateNormal];
    }
    else{
        [temp setImage:unselectImg forState:UIControlStateNormal];
        [allSelect removeObjectForKey:key];
        [selectView removeObjectForKey:key];
     }
    
    [self getDataMutableArray];
    
}
-(void)getDataMutableArray{

    totalCapticy = 0;
    
    if(allSelect && allSelect.count>0){
        
        
        dataMutableArray = [[NSMutableArray alloc] init];
        
        NSArray *keys = [allSelect allKeys];
        
        for(NSString *key in keys){
            
            
            
            NSDictionary *temp2 = [allSelect objectForKey:key];
            NSArray *temp3 = [[temp2 objectForKey:@"productAllData"] objectForKey:@"elementData"];
            
            double total = [self getTotal:temp3];
            
            NSMutableDictionary *temp5 =[[NSMutableDictionary alloc] initWithDictionary:temp2];
            [temp5 setValue:[NSString stringWithFormat:@"%f",total] forKey:@"remain"];
            [temp5 setValue:[NSString stringWithFormat:@"%f",total] forKey:@"total"];
            [temp5 setValue:[NSNumber numberWithInt:1] forKey:@"status"];
            
            [temp5 setValue:[temp5 objectForKey:@"version"] forKey:@"nowVersion"];
            [temp5 setValue:[temp5 objectForKey:@"version"] forKey:@"latestVersion"];
            
            NSString *imageUrl1 =  [temp5 objectForKey:@"imageUrl"];
            NSArray *names = [imageUrl1 componentsSeparatedByString:@"/"];
            NSString *name = [NSString stringWithFormat:@"planTable%@",names[names.count-1]];
            
            [temp5 setValue:name forKey:@"localImageName"];
            
            [dataMutableArray addObject:temp5];
            totalCapticy = totalCapticy +total;
        }
    }
    [self usedSpaceAndfreeSpace:0 total:totalCapticy];

}
-(void)captureView:(UIImageView *)view name:(NSString *)name{
 
    UIImage *image = view.image;
    NSData* data = UIImagePNGRepresentation(image);
    [downloadImage saveImage:name image:data];
}
-(double)getTotal:(NSArray *)temp3{
    double total = 0;
    
    for(NSDictionary *temp4 in temp3){
        
        NSString *dapei_pic_ize = [temp4 objectForKey:@"dapei_pic_ize"];
        NSString *hot_pic_size = [temp4 objectForKey:@"hot_pic_size"];
        NSString *image_url_size = [temp4 objectForKey:@"image_url_size"];
        NSString *product_image_url_size = [[temp4 objectForKey:@"productData"] objectForKey:@"product_image_url_size"];
        
        if(![dapei_pic_ize isKindOfClass:[NSNull class]])
            total = total +[dapei_pic_ize longLongValue];
        
        if(![hot_pic_size isKindOfClass:[NSNull class]])
            total = total +[hot_pic_size longLongValue];
        
        if(![image_url_size isKindOfClass:[NSNull class]])
            total = total +[image_url_size longLongValue];
        
        if(![product_image_url_size isKindOfClass:[NSNull class]])
            total = total +[product_image_url_size longLongValue];
        
    }
    return total;

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [loginInfo.housesListDetailViewData count];
    // return 34;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIView *view = loginInfo.housesListDetailViewData[indexPath.row];
    
    NSArray *allViews = [view subviews];
    
    if(allViews.count<=4){
        
        return view.frame.size.height/2;
        
    }
    else{
        
        return view.frame.size.height;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    if(indexPath.row<= loginInfo.housesListDetailViewData.count-1)
    {
        [cell.contentView addSubview:loginInfo.housesListDetailViewData[indexPath.row]];
    }
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}
-(void)getHousesListDetailMessage:(id)sender{
    
    NSString *reload = sender;
    
    if([reload isEqualToString:@"1"]){
        
        housesListDetailAllData = [[NSMutableArray alloc] initWithObjects:nil];
        [updateViewArray removeAllObjects];
        downloadPageIndex = 0;
        [_refreshHeaderView egoRefreshStartLoading:self.housesListDetailTable];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":[dataArgs objectForKey:@"id"],@"angle":@"A1",@"pageIndex":[NSNumber numberWithInt: downloadPageIndex],@"pageCount":[NSNumber numberWithInt:downloadPageCount]};

    
    [manager POST:[BASEURL stringByAppendingString: getHousesListDetailApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
     //   NSLog(@"JSON: %@", responseObject);
        
        downloadPageIndex ++;
        
        if(![reload isEqualToString:@"1"]){
        
         [self doneLoadMoreData];
        }
        
        NSMutableDictionary *temp = [responseObject mutableCopy];
        NSArray *array = [temp objectForKey:@"data"];
        
//        int totalCount = 0;
//        
//        id countObject = [temp objectForKey:@"totalCount"];
//        
//        if(![countObject isKindOfClass:[NSNull class]]){
//           totalCount = [countObject intValue];
//        
//        if(totalCount>8){
//        
//            [self.button18 setHidden:false];
//            [self.button916 setHidden:false];
//            if(downloadPageIndex == 0){
//            [self.label18 setHidden:false];
//            [self.label916 setHidden:true];
//            }
//            if(downloadPageIndex == 1){
//            [self.label18 setHidden:true];
//            [self.label916 setHidden:false];
//            }
//        }
//        }
        if([array isKindOfClass:[NSArray class]]){
            
            [housesListDetailAllData  addObjectsFromArray:array];
            
            [self configDetailView:[array mutableCopy]];
            [[self.housesListDetailTable viewWithTag:134] removeFromSuperview];
            
        }
        
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        

        if(![reload isEqualToString:@"1"]){
            
            [self doneLoadMoreData];
        }
       
         [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
    }];
    
    
}

-(void)addClassicView:(NSDictionary *)data image:(UIImage *)image{
    
    [self initDownloadDetailView:data image:nil];
    
    self.planDetailView.frame = CGRectMake(0,768,1024,768);
    [self.view addSubview:self.planDetailView];
    
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         self.planDetailView.frame = CGRectMake(0,0,1024,768);
                     }
                     completion:^(BOOL finished) {
                         
                         
                     }
     ];

    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(339.0f,339.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:self.productPreviewView.center];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.tag = 134;
    [self.productPreviewView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    NSMutableDictionary *temp = (NSMutableDictionary *)data;
   [self getClassicDetailData:temp];
    
//    NSThread *getClassicDetailDataThread = [[NSThread alloc] initWithTarget:self selector:@selector(getClassicDetailData:) object:temp];
//    [getClassicDetailDataThread start];
}
-(void)getClassicDetailData:(NSMutableDictionary *)data{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":[data objectForKey:@"id"],@"angle":@"A1"};
    
    
    [manager POST:[BASEURL stringByAppendingString: getClassicDataApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
       //    NSLog(@"JSON: %@", responseObject);
        
        NSMutableDictionary *temp = responseObject;
        
        NSMutableDictionary *temp2 = [[NSMutableDictionary alloc] initWithDictionary:data];
        
        [temp2 setValue:[temp objectForKey:@"productAllData"] forKey:@"productAllData"];
        [temp2 setValue:[temp objectForKey:@"defaultData"] forKey:@"defaultData"];
       
        if(downloadStatus.length>0){
        if(![downloadStatus isEqualToString:@"更新"]){
            
            [self.planStartDownLoad setEnabled:false];
        }
        else{
        
            [self.planStartDownLoad setEnabled:true];

        }
        }
        else{
        
            [self.planStartDownLoad setEnabled:true];

        }
        
        [self addDownloadPlanDetail:temp2];
        [[self.planDetailView viewWithTag:134] removeFromSuperview];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        
    }];

}
-(void)initDownloadDetailView:(NSDictionary *)data image:(UIImage *)image{
    
  //  self.planDetailImageView.frame = CGRectMake(20, 29, 120, 80);
    
    if(image){
        image = [image resizedCenterImage:self.planDetailImageView.frame.size interpolationQuality:kCGInterpolationHigh];
        [self.planDetailImageView setImage:image];
    }
    else{
//    NSString *stopPath = [[NSBundle mainBundle]pathForResource:@"downloadPlacehoder.png" ofType:@""];
//    UIImage  *placeholderImage= [UIImage imageWithContentsOfFile:stopPath];
        
    [self.planDetailImageView setImageWithURL:[NSURL URLWithString:[imageUrl stringByAppendingString:[data objectForKey:@"imageUrl"]]] size:CGSizeMake(0, 0)];

    }
    self.planName.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17.0f];
    self.planSize.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
    [self.planSize setTextColor:UIColorFromRGB(0x686868)];
    self.startDownload.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];

    
    [self.planName setText:[data objectForKey:@"name"]];
    
    NSString *timeStamp = [data objectForKey:@"latestUpdateTime"];
    
    NSDate *dateTime = [NSDate  dateWithTimeIntervalSince1970:[timeStamp longLongValue]];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    
    NSString *sizeStr = [NSString stringWithFormat:@"%@X%@mm",[data objectForKey:@"length"],[data objectForKey:@"width"]];
    [self.planSize setText:sizeStr];
    
    
    int count = 0;
    
    if(loginInfo.downloadType == 1){
        
        count = [[data objectForKey:@"goodsCount"] intValue];

           }
    else{
    
      count = [[[data objectForKey:@"productAllData"] objectForKey:@"productCount"] intValue];
    }
    
    NSString *tempCount = [NSString stringWithFormat:@"%d",count];
    
    NSString *goodCountStr = [NSString stringWithFormat:@"可搭配产品：%@件",tempCount];
    [self.goodsCount setText:goodCountStr];
    
//    NSMutableAttributedString *text =[[NSMutableAttributedString alloc] initWithAttributedString: self.goodsCount.attributedText];
//    
//    [text addAttribute:NSForegroundColorAttributeName
//                 value:UIColorFromRGB(0xff553e)
//                 range:[goodCountStr rangeOfString:tempCount]];
//    [self.goodsCount setAttributedText: text];
    

    
    [self.latestUpdateTime setText:[NSString stringWithFormat:@"最后更新时间：%@",[formatter stringFromDate:dateTime]]];
    
     [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    [self.planDetailTime setText:[formatter stringFromDate:dateTime]];
}
- (void)onDownloadDetailTap:(UIGestureRecognizer *)gestureRecognizer
{
    
    closeType = 1;
    
    UIImageView *view = (UIImageView *)[gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
    
    UIView *superView = [view superview];
    UILabel *statusLabel = (UILabel *)[superView viewWithTag:68];
    if(statusLabel)
        downloadStatus = statusLabel.text;
    
    if(downloadStatus.length>0){
        
        [self.planStartDownLoad setEnabled:false];
        [self.planStartDownLoad setBackgroundColor:UIColorFromRGB(0xcbcbcb)];
        [self.planStartDownLoad setTitleColor:UIColorFromRGB(0x8e8e8e) forState:UIControlStateNormal];
        [self.planStartDownLoad setTitle:downloadStatus forState:UIControlStateNormal];
    }
    
    NSDictionary *data = housesListDetailAllData[view.tag];
    
    
    [self initDownloadDetailView:data image:nil];
    
    [self addPlanDetailView:data];
}
-(void)addDownloadPlanDetail:(NSMutableDictionary *)data{

    NSMutableArray *temp3 = [[data objectForKey:@"productAllData"] objectForKey:@"elementData"];
    
    double singalTemp = [self getTotal:temp3];
    [self usedSpaceAndfreeSpace:1 total:singalTemp];
    
    singalDataMutableArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *temp5 =[[NSMutableDictionary alloc] initWithDictionary:data];
    [temp5 setValue:[NSString stringWithFormat:@"%f",singalTemp] forKey:@"remain"];
    [temp5 setValue:[NSString stringWithFormat:@"%f",singalTemp] forKey:@"total"];
    
    [temp5 setValue:[NSNumber numberWithInt:1] forKey:@"status"];
    
    if(loginInfo.downloadType == 1){
    [temp5 setValue:[temp5 objectForKey:@"id"] forKey:@"planId"];
    }
    [temp5 setValue:[temp5 objectForKey:@"version"] forKey:@"nowVersion"];
    [temp5 setValue:[temp5 objectForKey:@"version"] forKey:@"latestVersion"];
    
    NSString *imageUrl1 =  [temp5 objectForKey:@"imageUrl"];
    NSArray *names = [imageUrl1 componentsSeparatedByString:@"/"];
    NSString *name = [NSString stringWithFormat:@"planTable%@",names[names.count-1]];
    
    [temp5 setValue:name forKey:@"localImageName"];
    
    [singalDataMutableArray addObject:temp5];
    
    _downloadPlanDetail = [[downloadPlanDetail alloc] initWithFrame:CGRectMake(19,50,986,470)];
    [self.productPreviewView addSubview:_downloadPlanDetail];
    [_downloadPlanDetail configView:temp3];


}
-(void)addPlanDetailView:(NSDictionary *)data{
    
    self.planDetailView.frame = CGRectMake(0, self.planDetailView.frame.size.height, self.planDetailView.frame.size.width, self.planDetailView.frame.size.height);
    [self.view addSubview:self.planDetailView];
 //   [self getDetailRequest:[data objectForKey:@"planId"]];
  
    [self addDownloadPlanDetail:(NSMutableDictionary *)data];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         self.planDetailView.frame = CGRectMake(0, 0, self.planDetailView.frame.size.width, self.planDetailView.frame.size.height);

                         
                     }
                     completion:^(BOOL finished) {
                       
                     }
     ];
    

}

-(void)usedSpaceAndfreeSpace:(int)type total:(double)total{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSFileManager* fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
    NSString  * str= [NSString stringWithFormat:@"已占用%0.1fG/剩余%0.1fG",([totalSpace longLongValue] - [freeSpace longLongValue])/1024.0/1024.0/1024.0,[freeSpace longLongValue]/1024.0/1024.0/1024.0];
    NSLog(@"--------%@",str);
    
    NSString *nowNeed = [NSString stringWithFormat:@"%0.1fM",(total)/1024.0/1024.0];


    NSString *remainStr = [NSString stringWithFormat:@"%0.1fG",[freeSpace longLongValue]/1024.0/1024.0/1024.0-(total/1024.0/1024.0/1024.0)];
    
    NSString  * strX= [NSString stringWithFormat:@"当前下载需要：%@，剩余空间：%@",nowNeed,remainStr];
    
    NSMutableAttributedString *text;
    
    if(type == 0)
    {
    [self.capticy setText:strX];
      text  =[[NSMutableAttributedString alloc] initWithAttributedString: self.capticy.attributedText];
        

    }
    else{
        
        strX = [NSString stringWithFormat:@"文件大小：%@",nowNeed];
        
        [self.planCapticy setText:strX];
        text  =[[NSMutableAttributedString alloc] initWithAttributedString: self.planCapticy.attributedText];
    }
    
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:UIColorFromRGB(0xff553e)
                 range:[strX rangeOfString:nowNeed]];
    [text addAttribute:NSForegroundColorAttributeName
                 value:UIColorFromRGB(0xff553e)
                 range:[strX rangeOfString:remainStr]];
    
    if(type == 0)
    {
       [self.capticy setAttributedText: text];
    }
    else{
        
    //   [self.planCapticy setAttributedText: text];
    }
    
    double thisTotal = [DBHelper getTotal]+total;
   
    double otherTotal = [totalSpace longLongValue]-[freeSpace longLongValue]-thisTotal;
    
    
    double otherWidth = otherTotal/[totalSpace longLongValue]*540;
    
    double thisWidth =  (otherTotal + thisTotal)/[totalSpace longLongValue]*540;
    
    if(!blue_bar){
        
        gray_bar = [[UIView alloc] initWithFrame:CGRectMake(20,639,540, 20)];
        [gray_bar setBackgroundColor:UIColorFromRGB(0xcccccc)];
        gray_bar.layer.cornerRadius = 5;
        [self.detailAllView addSubview:gray_bar];
        
        yellow_bar = [[UIView alloc] initWithFrame:CGRectMake(20,639,0,20)];
        [yellow_bar setBackgroundColor:UIColorFromRGB(0xf2ac00)];
         yellow_bar.layer.cornerRadius = 5;
        [self.detailAllView addSubview:yellow_bar];
        
        blue_bar = [[UIView alloc] initWithFrame:CGRectMake(20,639,0,20)];
        [blue_bar setBackgroundColor:UIColorFromRGB(0x617dbd)];
        blue_bar.layer.cornerRadius = 5;
        [self.detailAllView addSubview:blue_bar];
    }
    
    if(type!=0){
 
//        gray_bar = [[UIImageView alloc] initWithFrame:CGRectMake(20,639,540, 20)];
//        [gray_bar setBackgroundColor:UIColorFromRGB(0xcccccc)];
//        gray_bar.layer.cornerRadius = 5;
//        [self.planDetailView addSubview:gray_bar];
//        
//        yellow_bar = [[UIImageView alloc] initWithFrame:CGRectMake(20,639,0, 20)];
//        [yellow_bar setBackgroundColor:UIColorFromRGB(0xf2ac00)];
//        yellow_bar.layer.cornerRadius = 5;
//        [self.planDetailView addSubview:yellow_bar];
//        
//        blue_bar = [[UIImageView alloc] initWithFrame:CGRectMake(20,639,0, 20)];
//        [blue_bar setBackgroundColor:UIColorFromRGB(0x617dbd)];
//        blue_bar.layer.cornerRadius = 5;
//        [self.planDetailView addSubview:blue_bar];
    
    }
    
    [UIView animateWithDuration:0.7f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
               
                         
                         CGRect newFrame = blue_bar.frame;
                         newFrame.size.width = otherWidth;
                         blue_bar.frame = newFrame;
                         
                         CGRect newFrame1 = yellow_bar.frame;
                         newFrame1.size.width = thisWidth;
                         yellow_bar.frame = newFrame1;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         
                         
                     }
     ];
    
}
- (IBAction)mapViewBackAction:(id)sender {
    [self.mapView removeFromSuperview];
    [imageMapView removeFromSuperview];
    imageMapView = nil;
}
- (IBAction)planStartDownLoadAction:(id)sender {

    if([globalContext isLogin] && loginInfo.userName.length>0){
    
        if(loginInfo.enableDownload==1){
        [self prepareDataToDownload:singalDataMutableArray];
            [self.planStartDownLoad setEnabled:false];
            [self.planStartDownLoad setTitle:@"正在下载" forState:UIControlStateNormal];
            [self.planStartDownLoad setBackgroundColor:UIColorFromRGB(0xcbcbcb)];
            [self.planStartDownLoad setTitleColor:UIColorFromRGB(0x8e8e8e) forState:UIControlStateNormal];
            [self planStartDownLoadAnimation];
        }
        else
        [globalContext showAlertView:@"您没有下载权限"];
    }
    else{
        
      UIAlertView  *alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
     alertView.tag = 110;
     [alertView show];
        
    }
}
-(void)planStartDownLoadAnimation{
    
//    UIImageView *tempView = [[UIImageView alloc] initWithFrame:self.planDetailImageView.frame];
//    [tempView setImage:self.planDetailImageView.image];
//    [self.view addSubview:tempView];
//    
//    [UIView animateWithDuration:0.7
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         // Shrink!
//                         tempView.transform = CGAffineTransformMakeScale(0.2, 0.2);
//                         tempView.frame = CGRectMake(908,70, tempView.frame.size.width,tempView.frame.size.height);
//                      //   sourceViewController.view.center = self.targetPoint;
//                     }
//                     completion:^(BOOL finished){
//                         
//                         [tempView removeFromSuperview];
//                         
//
//                                          }];
    
    
      [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownloadCount" object:nil];
     [globalContext addStatusBarNotification:@"已添加至缓存"];
    
    
}
-(void)startDownLoadAnimation{
    
    if(selectView){
        
    NSArray *keys = [selectView allKeys];
        
        int count = 0;
        
    for (NSString *key in keys) {
        
        [self performSelector:@selector(startDownLoadAnimationMethod:) withObject:key afterDelay:0.3*count];
        count++;

           }
    }
    
}
-(void)startDownLoadAnimationMethod:(NSString *)key{

    UIView *view = [selectView objectForKey:key];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    NSArray *subViews = [view subviews];
    
    for (UIView *tempView in subViews) {
        if([tempView isKindOfClass:[UIImageView class]]){
            
            UIImageView *temp2View = (UIImageView *)tempView;
            imageView.frame = view.frame;
            imageView.frame = CGRectMake(112+view.frame.origin.x, 244+view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            imageView.image = temp2View.image;
        }
        if([tempView isKindOfClass:[UIButton class]]){
        
            [tempView removeFromSuperview];
            
        }
    }
    
    [self.view addSubview:imageView];
    
    [UIView animateWithDuration:0.7
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Shrink!
                         imageView.transform = CGAffineTransformMakeScale(0.10, 0.10);
                         imageView.frame = CGRectMake(908,70, imageView.frame.size.width,imageView.frame.size.height);
                         //   sourceViewController.view.center = self.targetPoint;
                     }
                     completion:^(BOOL finished){
                         
                         [imageView removeFromSuperview];
                         [selectView removeObjectForKey:key];
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownloadCount" object:nil];

                     }];


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
- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    downloadPageIndex = 0;
    housesListDetailAllData = [[NSMutableArray alloc] initWithObjects:nil];
    housesListDetailData = [[NSMutableArray alloc] initWithObjects:nil];
    
    [self getHousesListDetailMessage:@"1"];
    
    _reloading = YES;
    
}
- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.housesListDetailTable];
    
}

- (void)doneLoadMoreData{
    
    //  model should call this when its done loading
    [_refreshHeaderView egoRefreshScrollViewDataSourceLoadMoreDidFinished:self.housesListDetailTable];
    
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerLoadMore:(EGORefreshTableHeaderView*)view{
    
    [self getHousesListDetailMessage:@"0"];
}
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    _refreshHeaderView = nil;
}
- (IBAction)planDetailBackAction:(id)sender {
    
 //   else if(closeType == 1){
    
    
        closeType = 0;
        [_downloadPlanDetail removeFromSuperview];
        _downloadPlanDetail = nil;
        singalDataMutableArray = nil;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                             [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setNormalOrHigh" object:nil];
                             
                             if(loginInfo.downloadType == 1){
         
                                 self.planDetailView.frame = CGRectMake(0,self.planDetailView.frame.size.height, self.planDetailView.frame.size.width, self.planDetailView.frame.size.height);
                                 self.otherView.alpha = 0;
                             }
                             else{
                             
                                  self.planDetailView.frame = CGRectMake(0,self.planDetailView.frame.size.height, self.planDetailView.frame.size.width, self.planDetailView.frame.size.height);
                             
                             }
                             
                         }
                         completion:^(BOOL finished) {
                             [self.planDetailView removeFromSuperview];
                              self.planDetailImageView.image = nil;
                             
                             if(loginInfo.downloadType == 1){

                             [self.view removeFromSuperview];
                             }
                            
                         }
         ];
 //   }
    
    totalCapticy = 0;

}


#pragma mark - UIGestureRecognizer handlers

- (void)barViewWasSwiped:(UIPanGestureRecognizer*)recognizer
{
    CGPoint swipeLocation = [recognizer locationInView:self.planProductDetail];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _canMove = YES;
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(swipebarWasSwiped:)]) {
                [self.delegate swipebarWasSwiped:self];
            }
        }
        return;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged && _canMove) {
        float maxYPosition = 100;
        
        if(swipeLocation.y<67){
          NSLog(@"%f",swipeLocation.y);
            
        if (700+swipeLocation.y > maxYPosition && swipeLocation.y<lastSwipeLocationY) {
          
            lastSwipeLocationY = swipeLocation.y;
            CGRect frame = CGRectMake(0,700+swipeLocation.y, self.planProductDetail.frame.size.width, self.planProductDetail.frame.size.height);
            [self.planProductDetail setFrame:frame];
        }
        }
        
        else{
        
            if (100+swipeLocation.y < 700 && swipeLocation.y>lastSwipeLocationY) {
             //   NSLog(@"%f",swipeLocation.y);
                lastSwipeLocationY = swipeLocation.y;
                CGRect frame = CGRectMake(0,100+swipeLocation.y, self.planProductDetail.frame.size.width, self.planProductDetail.frame.size.height);
                [self.planProductDetail setFrame:frame];
            }
        
        }
        
        return;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded && _canMove) {
        float pivotYPosition = 600;
          lastSwipeLocationY = 0;
        
        if(swipeLocation.y>0){
        
           pivotYPosition = 300;
        }
      
        _canMove = NO;
        [self completeAnimation:(self.planProductDetail.frame.origin.y < pivotYPosition)];
        return;
    }
}

#pragma mark - Private methods

- (void)completeAnimation:(BOOL)show
{
    _isHidden = !show;
 //   CGRect parentFrame = self.parentView.frame;
    CGRect goToFrame;
    if (show) {
        goToFrame = CGRectMake(0, 190, self.planProductDetail.frame.size.width, self.planProductDetail.frame.size.height);
    }
    else {
        goToFrame = CGRectMake(0, 700, self.planProductDetail.frame.size.width, self.planProductDetail.frame.size.height);
    }
    [UIView animateWithDuration:_animationDuration animations:^{
        [self.planProductDetail setFrame:goToFrame];
    } completion:^(BOOL finished){
        if (finished) {
            if (show) {
                [self.delegate swipeBarDidAppear:self];
                self.barBackLabel.alpha=0.95;
            }
            else if (!show) {
                [self.delegate swipeBarDidDisappear:self];
                self.barBackLabel.alpha=1.0;
            }
        }
    }];
}
- (IBAction)biaoAction:(id)sender {
    
    if(!typeSearchDownloadDetail){
        typeSearchDownloadDetail = [[typeSearchTableViewController alloc] init];
        
        popControllerDownloadDetail = [[UIPopoverController alloc] initWithContentViewController:typeSearchDownloadDetail];

        
    }
    
    typeSearchDownloadDetail.view.frame = CGRectMake(0, 0, 70,64);
    popControllerDownloadDetail.popoverContentSize = CGSizeMake(70,64);
    

    [typeSearchDownloadDetail initView:16];

    
    [popControllerDownloadDetail presentPopoverFromRect:((UIView *)sender).frame inView:self.productPreviewView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

}
-(void)setNormalOrHighAction:(NSNotification *) notification{

    int index = [[notification object] intValue];
    
    [self.planDetailSegmented setSelectedSegmentIndex:index];
    
    if(index == 0)
        [self.normalOrHigh setTitle:@"标清" forState:UIControlStateNormal];
    else
        [self.normalOrHigh setTitle:@"高清" forState:UIControlStateNormal];


}
- (IBAction)shareAction:(id)sender {
    
    NSArray  *data  =[[NSArray alloc] initWithObjects:sender,nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addShareView" object:data];
    
}

- (IBAction)accountAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLogin" object:nil];
}

- (IBAction)settingAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addSettingView" object:sender];
}
@end
