//
//  housesViewController.m
//  brandv1.2
//
//  Created by Apple on 14-8-16.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "housesViewController.h"
#import "Define.h"
#import "AFNetworking.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "globalContext.h"
#import "collocationViewController.h"
#import "MapAnnotation.h"
#import "housesMultilRowViewController.h"
#import "typeSearchTableViewController.h"

@interface housesViewController ()
@end

@implementation housesViewController
@synthesize housesDetail;
@synthesize locationManager;
NSMutableArray *housesAllData;
NSArray *housescategory;
int housesPageIndex=0;
NSString *housessearchField =@"";
LoginInfo *loginInfo;
NSString *housesSearchName;
NSDictionary *collocationDataTemp;
UIScrollView *housesScrollView;
NSString *housesReLoad = @"0";
housesMultilRowViewController *housesTypeSearch;
typeSearchTableViewController *_housesSingalTypeSearch;
UIPopoverController *housesPopController;
UIPopoverController *citySelectPopController;
UIPopoverController *provinceSelectPopController;
NSMutableArray *allHousesData;
NSMutableArray *allAnnotations;
NSMutableArray *showAllAnnotations;
NSMutableArray *tempHousesSearchType;
NSMutableArray *editHousesSearchType;
NSMutableArray *allCity;
int level = 0;
NSString *selectCode = @"";
NSString *sizeSelectCode = @"";

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
    // Do any additional setup after loading the view from its nib.
    
 //   [self.view setBackgroundColor:UIColorFromRGB(0xf1f1f1)];

    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    loginInfo.houseSearch = @"";
    
    [loginInfo addObserver:self forKeyPath:@"brand_logo_app" options:NSKeyValueObservingOptionNew context:nil];
    [globalContext settingBrandLogo:self.brandLogo nameLabel:self.brandNameLabel];
    
    [self getHousesType:nil];
    
    self.totalCount.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
    self.housesButtonAction.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
    self.menuButton1.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
    self.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17.0f];
    [self.housesButtonAction setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [self.totalCount setTextColor:UIColorFromRGB(0x666666)];
    [self.topBarBackView setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
    self.topBarTitleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:18.0f];
    self.searchButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0f];
    
    self.topBarTitleLabel.userInteractionEnabled = YES;
    [self.topBarTitleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showConidition:)]];
    
    self.searchText.delegate = self;
    
    self.searchCenterMainView.layer.cornerRadius = 5;
    self.mainTitleLabel.clipsToBounds = YES;
    self.mainTitleLabel.layer.cornerRadius = 5;
    self.searchTrueButton.layer.cornerRadius = 5;
    
    self.privinceSelectButton.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.privinceSelectButton.layer.borderWidth = 1;
    self.privinceSelectButton.layer.cornerRadius = 5;
    
    self.citySelectButton.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.citySelectButton.layer.borderWidth = 1;
    self.citySelectButton.layer.cornerRadius = 5;
    
    self.searchFieldBackView.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.searchFieldBackView.layer.borderWidth = 1;
    self.searchFieldBackView.layer.cornerRadius = 5;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(housesUpdateTotalCount:) name:@"housesUpdateTotalCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadView:) name:@"unloadView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goHousesCollocation:) name:@"goHousesCollocation" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeHousesDetail:) name:@"removeHousesDetail" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchHouses:) name:@"searchHouses" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeProvinceSelect:) name:@"changeProvinceSelect" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCitySelect:) name:@"changeCitySelect" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAreaSelect:) name:@"changeAreaSelect" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSizeSelect:) name:@"changeSizeSelect" object:nil];
    
//    //显示用户位置
//    loginInfo.housesMapView.showsUserLocation = YES;
//    //是否可滑动
//    loginInfo.housesMapView.scrollEnabled = YES;
//    //是否可放大缩小
//    loginInfo.housesMapView.zoomEnabled = YES;
//    loginInfo.housesMapView.delegate = self;
    
    [self statLocationManager];

}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"brand_logo_app"] && object == loginInfo) {
        [globalContext settingBrandLogo:self.brandLogo nameLabel:self.brandNameLabel];
        
    }
}
-(void)initAnimation{
    
    if(allHousesData && ![allHousesData isKindOfClass:[NSNull class]]){
    
    self.mainSearchView.frame = CGRectMake(0, 0, 1024, 768);

    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    
    NSArray *subViews = [window subviews];
    
    [[subViews objectAtIndex:subViews.count-1] addSubview:self.mainSearchView];
    
    self.searchMainBack.alpha = 0;
    self.searchCenterMainView.frame = CGRectMake(self.searchCenterMainView.frame.origin.x, 768, self.searchCenterMainView.frame.size.width, self.searchCenterMainView.frame.size.height);
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         self.searchMainBack.alpha = 0.7;
                         
                         CGRect  endFrame =  self.searchCenterMainView.frame;
                         endFrame.origin.y = 100;
                         self.searchCenterMainView.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
    }
    else{
        
        [globalContext showAlertView:@"抱歉，楼盘数量为0"];
    }
}
-(void)statLocationManager
{
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
    [locationManager requestWhenInUseAuthorization]; // Add This Line
    }
    
    locationManager.distanceFilter = kCLDistanceFilterNone; //whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
}
-(void)getMessageList{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDictionary *parameters = @{@"search":loginInfo.houseSearch};
    
    [manager POST:[BASEURL stringByAppendingString: getHousesListApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
       //  NSLog(@"JSON: %@", responseObject);
        
        [loginInfo.progressBarView removeFromSuperview];
        
         allHousesData = [responseObject objectForKey:@"data"];
        
        if([allHousesData isKindOfClass:[NSArray class]]){
            
            allAnnotations = [[NSMutableArray alloc] init];
            
            [self addAllAnnotation];
        
            }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        [loginInfo.progressBarView removeFromSuperview];
         [globalContext showAlertView:@"网络异常"];

    }];
    
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
     if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [locationManager requestWhenInUseAuthorization]; // Add This Line
        [locationManager startUpdatingLocation];
}
-(void)unloadView:(NSNotification *)sender{
    
    housessearchField= @"";
    housesPageIndex =0;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"housesUpdateTotalCount" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeHousesDetail" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"searchHouses" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"unloadView" object:nil];
    
}
-(void)goHousesCollocation:(NSNotification *)sender{
    
    collocationDataTemp = [sender object];
    [self performSegueWithIdentifier:@"goHousesCollocation" sender:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeDetail" object:nil];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goHousesCollocation"]) //"goView2"是SEGUE连线的标识
    {
        collocationViewController *theSegue = segue.destinationViewController;
        theSegue.collocationData = collocationDataTemp;
    }
}
-(void)housesUpdateTotalCount:(NSNotification *)totalCount{

    housesReLoad = @"0";
    
    NSString *total = [NSString stringWithFormat:@"共%@个户型",[totalCount object]];
    
    [self.totalCount setText:total];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    housesDetail = nil;
}
- (void)onTap:(UIGestureRecognizer *)gestureRecognizer{
    
   // [self goToHousesDetail];
}
-(void)goToHousesDetail:(NSMutableArray *)data {
    
//    [self performSegueWithIdentifier:@"test" sender:self];

   // housesDetail = nil;
  
    if(loginInfo.housesdetailcontroller == nil){
     
        housesDetail = [[housesDetailController alloc] init];
        housesDetail.view.frame = CGRectMake(0,768, self.view.frame.size.width, self.view.frame.size.height);
      
        loginInfo.housesdetailcontroller = housesDetail;
        [self.view addSubview:loginInfo.housesdetailcontroller.view];
        
    }
    
    [loginInfo.housesdetailcontroller initView:data];
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         CGRect endFrame= housesDetail.view.frame;
                         endFrame.origin.y= 0;
                         loginInfo.housesdetailcontroller.view.frame=endFrame;

                     }
                     completion:^(BOOL finished) {
                         
                         [self removeHousesMapView];                     }
     ];

}
-(void)goDetail:(UIButton *) view{

    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObject:[NSNumber numberWithInt:(int)view.tag]];
    
    
    for(NSDictionary *temp in allHousesData){
        if([[temp objectForKey:@"id"] intValue] == view.tag){
            
            [data addObject:temp];
            [self goToHousesDetail:data];
            break;
        }
    }
    
}
-(void)removeHousesDetail:(NSNotification *) sender{
    [loginInfo.housesdetailcontroller.view removeFromSuperview];
    loginInfo.housesdetailcontroller = nil;
    housesDetail = nil;
    
    [self addHousesMapView];
}
-(void)getHousesType:(id)sender{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:[BASEURL stringByAppendingString:getHousesTypeApi] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //    NSLog(@"JSON: %@", responseObject);
        
        NSArray *rootArray = responseObject;
        
        if([rootArray isKindOfClass:[NSArray class]]){
            
            loginInfo.housesSearchType = rootArray;
             tempHousesSearchType = [rootArray mutableCopy];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        
    }];
    
  }

-(void)searchHouses:(NSNotification *)notification{

    NSIndexPath *indexPath = [notification object];
    
    NSDictionary *temp = loginInfo.housesSearchType[indexPath.section];
    
    NSString *searchField = [temp objectForKey:@"searchField"];
    NSArray *typeItems = [temp objectForKey:@"typeItems"];
    NSString *typeItem = [typeItems[indexPath.row] objectForKey:@"code"];
    
    housesSearchName = [typeItems[indexPath.row] objectForKey:@"name"];;
    
    housessearchField = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",searchField,typeItem];
    
    loginInfo.houseSearch = housessearchField;
    
    housesReLoad = @"2";


}

- (void)viewDidAppear:(BOOL)animated{
 
    [super viewDidAppear:YES];
    loginInfo.collocationType =2;
    
    [self addHousesMapView];
}
- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    [self removeHousesMapView];
    
}
-(void)removeHousesMapView{
    switch (loginInfo.housesMapView .mapType) {
        case MKMapTypeHybrid:
        {
            loginInfo.housesMapView .mapType = MKMapTypeStandard;
        }
            
            break;
        case MKMapTypeStandard:
        {
            loginInfo.housesMapView .mapType = MKMapTypeHybrid;
        }
            
            break;
        default:
            break;
    }
    [loginInfo.housesMapView removeAnnotations:showAllAnnotations];
    loginInfo.housesMapView.showsUserLocation = NO;
    loginInfo.housesMapView.zoomEnabled = false;
    loginInfo.housesMapView.delegate = nil;
    [loginInfo.housesMapView removeFromSuperview];
    loginInfo.housesMapView = nil;
}
-(void)addHousesMapView{

    if(!loginInfo.housesMapView && !loginInfo.housesdetailcontroller){
        
        loginInfo.housesMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 44, 1024, 651)];
        
        //显示用户位置
        loginInfo.housesMapView.showsUserLocation = YES;
        //是否可滑动
        loginInfo.housesMapView.scrollEnabled = YES;
        //是否可放大缩小
        loginInfo.housesMapView.zoomEnabled = YES;
        loginInfo.housesMapView.delegate = self;
        
        [self statLocationManager];
        
        [self.view addSubview:loginInfo.housesMapView];
        
        if(!showAllAnnotations || [showAllAnnotations isKindOfClass:[NSNull class]] || showAllAnnotations.count==0)
        [self addAllAnnotation];
        else{
        [loginInfo.housesMapView addAnnotations:showAllAnnotations];
        [self searchLocation:showAllAnnotations[0]];

        }
    }
    
    if(!allAnnotations || [allAnnotations isKindOfClass:[NSNull class]] || allAnnotations.count==0)
        [self getMessageList];

}
- (IBAction)searchButtonAction:(id)sender {
    
    [self initAnimation];
}

- (IBAction)searchIconAction:(id)sender {
    
    
    [self initAnimation];
}

- (IBAction)accountAction:(id)sender {
    
   [[NSNotificationCenter defaultCenter] postNotificationName:@"goUserCentre" object:nil];
}

- (IBAction)settingAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addSettingView" object:nil];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
   [self searchMethod];
    
    return  [self.searchText resignFirstResponder];
}

- (IBAction)showConidition:(id)sender {
 
    if(allHousesData && ![allHousesData isKindOfClass:[NSNull class]]){
    
    if(!housesPopController && !housesTypeSearch){
        
        housesTypeSearch = [[housesMultilRowViewController alloc] init];
        
        housesTypeSearch.view.backgroundColor = UIColorFromRGB(0xf4f4f4);
        
        housesPopController = [[UIPopoverController alloc] initWithContentViewController:housesTypeSearch];
        housesPopController.delegate=self;
        
        if(editHousesSearchType.count ==0)
            [self editHousesSearchTypeMethod];
        
        housesTypeSearch.view.frame = CGRectMake(0, 0,260,288);
        [housesPopController setPopoverContentSize:CGSizeMake(260,288) animated:YES];
        
        [housesTypeSearch initView:editHousesSearchType type:2];
    }
    
    if(tempHousesSearchType){
        
        [housesPopController presentPopoverFromRect:self.topBarTitleLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    else{
        
        [globalContext showAlertView:@"没有筛选条件可选"];
    }
        
    }

    else{
    
       [globalContext showAlertView:@"抱歉，楼盘数量为0"];
    }

}

-(void)editHousesSearchTypeMethod{

    editHousesSearchType = [tempHousesSearchType mutableCopy];
    
    for (int i =0; i<editHousesSearchType.count; i++) {
        
        NSArray *typeItems = [editHousesSearchType[i] objectForKey:@"typeItems"];
        
        NSDictionary *item = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"全部%@",[editHousesSearchType[i] objectForKey:@"typeName"]],@"name",@"",@"code", nil];
        
        NSMutableArray *all = [[NSMutableArray alloc] initWithObjects:item, nil];
        
        [all addObjectsFromArray:typeItems];
        
        NSMutableDictionary *tempItem = [editHousesSearchType[i] mutableCopy];
        
        [tempItem setObject:all forKey:@"typeItems"];
        
        editHousesSearchType[i] = tempItem;
        
    }
}
//定位成功后执行这个代理
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  
    if (locations.count)
    {
        CLLocation * location = (CLLocation *)[locations objectAtIndex:0];
        NSLog(@"latitude = %f",location.coordinate.latitude);
        NSLog(@"longitude = %f",location.coordinate.longitude);
        
        //根据经纬度范围显示
        loginInfo.housesMapView.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.0045f, 0.0045f));
        //根据距离范围显示
        loginInfo.housesMapView.region = MKCoordinateRegionMakeWithDistance(location.coordinate, 85000, 85000);
    }
    [locationManager stopUpdatingLocation];
}
//获取经纬度失败时候调用的代理方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error = %@",error);
}

//移动、缩放地图
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"mapView region Will ChangeAnimated");
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"mapView region Did ChangeAnimated");
}

#pragma mark -------------------------
#pragma mark 地图加载

//移动、缩放地图重新开始加载地图
//mapView将要开始加载地图时候调用的代理
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    NSLog(@"mapView Will Start Loading Map");
    
}
//mapView加载完地图时调用的方法
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    NSLog(@"mapView Did Finish Loading Map");
 
    
    //  //一起添加
    //  NSArray * annotations = [NSArray arrayWithObjects:lanouAnnotation,shangdiAnnotation, nil];
    //  [mapView addAnnotations:annotations];
    
}
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    
}

#pragma mark -------------------------
#pragma mark 注解视图

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{

}
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    MKAnnotationView * result = nil;
    if([annotation isKindOfClass:[MapAnnotation class]] == NO)
    {
        return result;
    }
    
    if([mapView isEqual:loginInfo.housesMapView] == NO)
    {
        return result;
    }
    
    
    MapAnnotation *senderAnnotation = (MapAnnotation *)annotation;
    NSString * pinReusableIdentifier = @"test";
    MKAnnotationView * annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinReusableIdentifier];
    if(annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:senderAnnotation reuseIdentifier:pinReusableIdentifier];
        
        [annotationView setCanShowCallout:YES];
    }
    
    CGSize constraint1 = CGSizeMake(2800,25);
    CGSize size1 = [senderAnnotation.title sizeWithFont:[UIFont fontWithName:@"MicrosoftYaHei" size:14.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = button;
    button.tag = [senderAnnotation.id intValue];
    NSLog(@"%@",senderAnnotation.id);
    [button addTarget:self action:@selector(goDetail:) forControlEvents:UIControlEventTouchUpInside];
    
    annotationView.opaque = NO;
 //   annotationView.animatesDrop = YES;
    annotationView.draggable = YES;
    annotationView.selected = YES;
  //  annotationView.calloutOffset = CGPointMake(size1.width/2,0);
    annotationView.canShowCallout=YES;
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,size1.width+20,25)];
    
    annotationView.frame = CGRectMake(annotationView.frame.origin.x, annotationView.frame.origin.y, size1.width+20,25);
    
    [testLabel setText:senderAnnotation.title];
    [testLabel setBackgroundColor:UIColorFromRGB(0Xf2666e)];
    [testLabel setTextColor:[UIColor whiteColor]];
    testLabel.textAlignment = NSTextAlignmentCenter;
    testLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];
    testLabel.clipsToBounds = YES;
    testLabel.layer.cornerRadius = 2;
    
    [annotationView addSubview:testLabel];
    
 //   annotationView.frame = CGRectMake(0, 0, 60, 40);
    
//    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search-icon.png"]];
//    annotationView.leftCalloutAccessoryView = imageView;
    
    result = annotationView;
    return result;
    
}

- (IBAction)privinceSelectAction:(id)sender {
    
    if(!_housesSingalTypeSearch || !provinceSelectPopController){
        
        
        _housesSingalTypeSearch = [[typeSearchTableViewController alloc] init];
        
        provinceSelectPopController = [[UIPopoverController alloc] initWithContentViewController:_housesSingalTypeSearch];
        
        provinceSelectPopController.delegate=self;
    }
    
    if(editHousesSearchType.count==0)
        [self editHousesSearchTypeMethod];
    
    NSArray *typeItems = [editHousesSearchType[0] objectForKey:@"typeItems"];
    
    _housesSingalTypeSearch.view.frame = CGRectMake(0, 0, 110,typeItems.count*32>300?300:typeItems.count*32);
    provinceSelectPopController.popoverContentSize = CGSizeMake(110,typeItems.count*32>300?300:typeItems.count*32);

    
    if(typeItems.count>0){
    
    [_housesSingalTypeSearch initViewWithData:17 data:[typeItems mutableCopy]];
    
    [provinceSelectPopController presentPopoverFromRect:CGRectMake(242,200,540,40) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    else{
    
        [globalContext showAlertView:@"正在加载省份..."];
    }
}
- (IBAction)citySelectAction:(id)sender {
    
    if(!citySelectPopController){
        
        
        _housesSingalTypeSearch = [[typeSearchTableViewController alloc] init];
        
    }
    
    citySelectPopController = [[UIPopoverController alloc] initWithContentViewController:_housesSingalTypeSearch];
    
    citySelectPopController.delegate=self;
    
    if(editHousesSearchType.count==0)
        [self editHousesSearchTypeMethod];
    
    NSArray *typeItems = [editHousesSearchType[0] objectForKey:@"typeItems"];
    
    
    NSDictionary *allCityname = @{@"name":@"全部城市",@"code":@""};
        
    allCity = [[NSMutableArray alloc] initWithObjects:allCityname, nil];
    
    if(self.privinceSelectButton.tag==0)
    
    for(NSDictionary *temp in typeItems){
    
        NSArray *temp1 = [temp objectForKey:@"parentcode"];
        
        [allCity addObjectsFromArray:temp1];
    }
    
    else{
       
        [allCity addObjectsFromArray:[typeItems[self.privinceSelectButton.tag] objectForKey:@"parentcode"]];
    }
    
    
    _housesSingalTypeSearch.view.frame = CGRectMake(0, 0, 110,allCity.count*32>300?300:allCity.count*32);
    citySelectPopController.popoverContentSize = CGSizeMake(110,allCity.count*32>300?300:allCity.count*32);
    
    if(allCity.count>0){
        
        [_housesSingalTypeSearch initViewWithData:18 data:allCity];
        
        [citySelectPopController presentPopoverFromRect:CGRectMake(242,250,540,40) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    else{
        
        [globalContext showAlertView:@"正在加载城市..."];
    }

}
-(void)changeProvinceSelect:(NSNotification *)notification{
   
    int select = [[notification object] intValue];
    
    self.privinceSelectButton.tag = select;
    
    if(select>0){
        
        level = 1;
        
         NSArray *typeItems = [editHousesSearchType[0] objectForKey:@"typeItems"];
         NSDictionary *temp = typeItems[select];
        [self.privinceSelectButton setTitle:[temp objectForKey:@"name"] forState:UIControlStateNormal];
        
        NSString *code = [temp objectForKey:@"code"];
        
        selectCode = code;

        [self.citySelectButton setTitle:@"全部城市" forState:UIControlStateNormal];
        
         showAllAnnotations = [self addAnnotationsByCode:code level:1];
         [loginInfo.housesMapView addAnnotations:showAllAnnotations];
       
     }
    else{
    
        level = 0;
        selectCode = @"";
        [self.privinceSelectButton setTitle:@"全部省份" forState:UIControlStateNormal];
        [self.citySelectButton setTitle:@"全部城市" forState:UIControlStateNormal];
        [self addAllAnnotation];
    }

    if(showAllAnnotations.count>0)
        [self searchLocation:showAllAnnotations[0]];
}
-(void)changeCitySelect:(NSNotification *)notification{
    
    NSDictionary  *select = [notification object];
    
    [self.citySelectButton setTitle:[select objectForKey:@"name"] forState:UIControlStateNormal];
    
    NSString *code = [select objectForKey:@"code"];
    
    selectCode = code;
    
    if(![code isEqualToString:@""]){
    
        level = 2;
        self.citySelectButton.tag = [code intValue];
        showAllAnnotations = [self addAnnotationsByCode:code level:2];
        [loginInfo.housesMapView addAnnotations:showAllAnnotations];
    }
    else{
    
        self.citySelectButton.tag = 0;
        
        if(self.privinceSelectButton.tag==0){
            level = 0;
           [self addAllAnnotation];
        }
       else{
       
           level = 1;
           NSArray *typeItems = [editHousesSearchType[0] objectForKey:@"typeItems"];
           NSDictionary *temp = typeItems[self.privinceSelectButton.tag];
           NSString *code = [temp objectForKey:@"code"];
           selectCode = code;
           showAllAnnotations = [self addAnnotationsByCode:code level:1];
           [loginInfo.housesMapView addAnnotations:showAllAnnotations];
       }
    }
    
    if(showAllAnnotations.count>0)
        [self searchLocation:showAllAnnotations[0]];
}
-(void)changeAreaSelect:(NSNotification *)notification{
    
    level = 3;
    
    NSDictionary  *select = [notification object];
    
    NSString *code = [select objectForKey:@"code"];
    
    selectCode = code;
    
    showAllAnnotations = [self addAnnotationsByCode:code level:3];
    [loginInfo.housesMapView addAnnotations:showAllAnnotations];
    
    if(showAllAnnotations.count>0)
        [self searchLocation:showAllAnnotations[0]];
}
-(void)changeSizeSelect:(NSNotification *)notification{
    
    NSDictionary  *select = [notification object];
    
    sizeSelectCode = [select objectForKey:@"code"];
    
    showAllAnnotations = [self addAnnotationsByCode:selectCode level:level];
    [loginInfo.housesMapView addAnnotations:showAllAnnotations];
    
    if(showAllAnnotations.count>0)
    [self searchLocation:showAllAnnotations[0]];
}
-(NSMutableArray *)addAnnotationsByCode:(NSString *)code level:(int)level{
    
    [loginInfo.housesMapView removeAnnotations:showAllAnnotations];
    
    NSMutableArray *cityAnnotation = [[NSMutableArray alloc] init];
    
    for (int i=0;i<allHousesData.count;i++) {
        
        NSDictionary *houseDictionary = allHousesData[i];
        
     //   NSLog(@"%@",houseDictionary);
        
        NSString *city_id;
        
        bool sizeFlag = true;
        bool codeFlag = true;
        
        if(![sizeSelectCode isEqualToString:@""]){
        
            sizeFlag = [self compareSize:[houseDictionary objectForKey:@"area"]];
        }
        if(level>0){
            
            if (level==1) {
                city_id = [houseDictionary objectForKey:@"province_id"];
            }
            else if (level==2) {
                city_id = [houseDictionary objectForKey:@"city_id"];
            }
            else{
                city_id = [houseDictionary objectForKey:@"region_id"];
            }

            
            codeFlag = [city_id isEqualToString:code];
        }
        
        if(codeFlag && sizeFlag){
            
            NSString *name = [houseDictionary objectForKey:@"name"];
            NSString *address = [houseDictionary objectForKey:@"address"];
            NSString *latitude = [houseDictionary objectForKey:@"latitude"];
            NSString *longitude = [houseDictionary objectForKey:@"longitude"];
            
            MapAnnotation  *lanouAnnotation = [[MapAnnotation alloc] initWithCoordinates:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]) title:name subTitle:address];
            
            lanouAnnotation.id = [houseDictionary objectForKey:@"id"];
            
            [cityAnnotation addObject:lanouAnnotation];
            
        }
    }
    
    return cityAnnotation;
}
-(BOOL)compareSize:(NSString *)size{
    BOOL flag = false;
    
    float sizeFloat = [size floatValue];
    
     NSArray *names = [sizeSelectCode componentsSeparatedByString:@"-"];
    
    if (names.count ==1) {
        names = [sizeSelectCode componentsSeparatedByString:@">"];
        
        if(sizeFloat>=[names[names.count-1] floatValue])
            flag = true;
    }
    else{
    
        if (sizeFloat>=[names[0] floatValue] && sizeFloat<=[names[names.count-1] floatValue])
            flag = true;
    }
    return flag;
}
- (IBAction)searchTrueAction:(id)sender {
    
    [self searchMethod];
    
}
-(void)searchMethod{

    if(self.searchText.text.length> 0)
    {
        [self closeSearchViewAction:nil];
        
        BOOL flag = false;
        
        [loginInfo.housesMapView removeAnnotations:showAllAnnotations];
        
        
        NSMutableArray *tempData = allAnnotations;
        
        if(self.citySelectButton.tag>0){
            NSString *code = [NSString stringWithFormat:@"%d",self.citySelectButton.tag];
            tempData = [self addAnnotationsByCode:code level:2];
        }
        else if(self.privinceSelectButton.tag>0){
            
            NSArray *typeItems = [editHousesSearchType[0] objectForKey:@"typeItems"];
            NSDictionary *temp = typeItems[self.privinceSelectButton.tag];
            
            NSString *code = [temp objectForKey:@"code"];
            
            tempData  = [self addAnnotationsByCode:code level:1];
        }
        
        
           [showAllAnnotations removeAllObjects];
        
            for (int i=0;i<tempData.count;i++) {
                
                MapAnnotation *annotation = tempData[i];
                
                NSString *name = annotation.title;
                
                if ([name rangeOfString:self.searchText.text options:NSCaseInsensitiveSearch].location != NSNotFound) {
                
                flag = true;
                    
                [showAllAnnotations addObject:annotation];
                    
            }
        }

        if(!flag){
            
            [globalContext showAlertView:@"抱歉，检索到0条记录！"];
        }
        else{
        
            MapAnnotation *annotation = showAllAnnotations[0];
            [self searchLocation:annotation];
            
            [loginInfo.housesMapView addAnnotations:showAllAnnotations];
        }
    }
    else{
        
        self.searchFieldBackView.layer.borderColor = [UIColor redColor].CGColor;
    }
}
-(void)searchLocation:(MapAnnotation *)annotation{

    CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    
    //根据经纬度范围显示
    loginInfo.housesMapView.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.0045f, 0.0045f));
    //根据距离范围显示
    loginInfo.housesMapView.region = MKCoordinateRegionMakeWithDistance(location.coordinate, 85000, 85000);
    [locationManager stopUpdatingLocation];


}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    
    self.searchText.text = @"";
    
    [loginInfo.housesMapView removeAnnotations:allAnnotations];
    
    [self addAllAnnotation];
    
    return [self.searchText resignFirstResponder];
}
-(void)addAllAnnotation{
    
    [loginInfo.housesMapView removeAnnotations:showAllAnnotations];

    allAnnotations = [[NSMutableArray alloc] init];
    
    if(allHousesData && ![allHousesData isKindOfClass:[NSNull class]]){
    
    for (int i=0;i<allHousesData.count;i++) {
        
        NSDictionary *houseDictionary = allHousesData[i];
        
        NSString *name = [houseDictionary objectForKey:@"name"];
        
        NSString *address = [houseDictionary objectForKey:@"address"];
        NSString *latitude = [houseDictionary objectForKey:@"latitude"];
        NSString *longitude = [houseDictionary objectForKey:@"longitude"];
        
        MapAnnotation  *lanouAnnotation = [[MapAnnotation alloc] initWithCoordinates:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]) title:name subTitle:address];
        
        lanouAnnotation.id = [houseDictionary objectForKey:@"id"];
        
        [allAnnotations addObject:lanouAnnotation];
        
        showAllAnnotations = [allAnnotations mutableCopy];
        
        [loginInfo.housesMapView addAnnotations:showAllAnnotations];
    }
 }
}
- (IBAction)closeSearchViewAction:(id)sender {
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         self.searchMainBack.alpha = 0;
                         
                         CGRect  endFrame =  self.searchCenterMainView.frame;
                         endFrame.origin.y = 768;
                         self.searchCenterMainView.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [self.mainSearchView removeFromSuperview];
                     }
     ];

}
@end
