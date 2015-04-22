//
//  downFirstPageViewController.m
//  brandv1.2
//
//  Created by Apple on 14-11-12.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "downFirstPageViewController.h"
#import "housesListView.h"
#import "Define.h"
#import "typeSearchTableViewController.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "downloadDetail.h"
#import "DBHelper.h"
#import "downloading.h"
#import "globalContext.h"

@interface downFirstPageViewController ()

@end

@implementation downFirstPageViewController

housesListView *_housesListView;
NSString *housesListReload = @"0";
typeSearchTableViewController *downloadFirstPageTypeSearch;
UIPopoverController *downloadFirstPagePopController;
LoginInfo *loginInfo;
downloadDetail *_downloadDetail;
CGRect originFrame;
downloading *_downloading;
NSDictionary *collocationDataTempPlan;
NSString *roomValue =@"全部空间";
NSString *areaValue = @"全部尺寸";
@synthesize collocation;

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
    
    loginInfo = [[StockData getSingleton] valueForKey:@"loginInfo"];
    loginInfo.downloadType = 3;
    loginInfo.progressArray = [[NSMutableDictionary alloc] init];
    loginInfo.housesClassicSearch = @"";
    [loginInfo addObserver:self forKeyPath:@"brand_logo_app" options:NSKeyValueObservingOptionNew context:nil];
    [globalContext settingBrandLogo:self.brandLogo nameLabel:self.brandNameLabel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLogin:) name:@"reLogin" object:nil];
    [globalContext setUserHead:self.accountButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(housesListUpdateTotalCount:) name:@"housesListUpdateTotalCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeSearch:) name:@"sizeSearch" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(classicSizeSearch:) name:@"classicSizeSearch" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToHousesListDetail:) name:@"goToHousesListDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadCount:) name:@"updateDownloadCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeHousesListDetail:) name:@"removeHousesListDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToCollocation:) name:@"goToDownloadCollocation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadToLogin:) name:@"downloadToLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDownloadingView:) name:@"removeDownloadingView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadedOrderByType:) name:@"downloadedOrderByType" object:nil];
    
    _housesListView = [[housesListView alloc] initWithFrame:CGRectMake(16,96, 992,612)];   //ios7 tabBar's height is 64
    
    [self.searchText addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    self.searchText.returnKeyType = UIReturnKeySearch;
    self.searchText.delegate = self;
    
    [self.view addSubview:_housesListView];
    
    [self.mySegmented addTarget:self action:@selector(selected:) forControlEvents:UIControlEventValueChanged];
    
    self.orderByTextLabel.userInteractionEnabled = YES;
    [self.orderByTextLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(oederByAction:)]];
    
    [self.classSizeButton setHidden:true];

    [DBHelper getDataFromPlanTable:0];
    
    [self setLabelTextAndWidth:@"无"];
    
    [self judgeHousesType];
    loginInfo.mySegmented = self.mySegmented;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"brand_logo_app"] && object == loginInfo) {
        [globalContext settingBrandLogo:self.brandLogo nameLabel:self.brandNameLabel];
        
    }
}
-(void)reLogin:(id)sender{

        [globalContext setUserHead:self.accountButton];
}
-(void)judgeHousesType{
    
    //    type   ＝ 1           1，只拥有户型列表
    //    2，只拥有经典样板间
    //    3，两者都拥有
    //    4，两者都没有
    
    if(loginInfo.housesType ==3){
        
        //
        
        [self.mySegmented  setTintColor:UIColorFromRGB(0x2b2b2b)];
        
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MicrosoftYaHei" size:14.0f], UITextAttributeFont, nil];
        [self.mySegmented setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    
        [self.mySegmented setHidden:false];
    }
    else{

        [self.mySegmented setHidden:true];

    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)updateDownloadCount:(NSNotification *)notification{
   
    if(loginInfo.dataFromPlanTable){
    
        [self.downloaded setTitle:[NSString stringWithFormat:@"本地缓存(%d)",loginInfo.dataFromPlanTable.count] forState:UIControlStateNormal];
    }
}
-(void)downloadedOrderByType:(NSNotification *)notification{

    NSArray *typeArray = @[@"名称",@"面积",@"房间数量",@"上架时间"];
    
    if(loginInfo.downloadType==1)
        typeArray = @[@"名称",@"面积",@"产品数量",@"上架时间"];
    
    int selectIndex = [[notification object] intValue];
    
    NSString *name = typeArray[selectIndex];
    
    [self setLabelTextAndWidth:name];
    
   if(_housesListView)
       [_housesListView downloadOrderByType:selectIndex];

}
-(void)housesListUpdateTotalCount:(NSNotification *)totalCount{
    
    NSString *total = [NSString stringWithFormat:@"%d个户型样板间",[[totalCount object] intValue]];
    
    if(loginInfo.downloadType == 1){
    
        total = [NSString stringWithFormat:@"%d个经典样板间",[[totalCount object] intValue]];
    }
    
    [self.taotalCount setText:total];
    
    self.taotalCount.numberOfLines = 1;
    self.taotalCount.adjustsFontSizeToFitWidth = YES;
    self.taotalCount.lineBreakMode = NSLineBreakByClipping;
    
    
}
- (void)sizeAction:(id)sender {
    
    if(!downloadFirstPageTypeSearch || !downloadFirstPagePopController){
    downloadFirstPageTypeSearch = [[typeSearchTableViewController alloc] init];
    
    downloadFirstPagePopController = [[UIPopoverController alloc] initWithContentViewController:downloadFirstPageTypeSearch];
 
    downloadFirstPagePopController.delegate=self;
        
    }
    
    downloadFirstPageTypeSearch.view.frame = CGRectMake(0, 0, 110, 200);
   downloadFirstPagePopController.popoverContentSize = CGSizeMake(110,200);
    
    if(loginInfo.downloadType ==3)
    [downloadFirstPageTypeSearch initView:6];
    else
    [downloadFirstPageTypeSearch initView:7];
    
    [downloadFirstPagePopController presentPopoverFromRect:((UIView *)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}
- (IBAction)sizeButtonAction:(id)sender {
    
//  [self.sizeButton sendActionsForControlEvents:UIControlEventTouchUpInside];

}
- (IBAction)downloadedAction:(id)sender {
    
//    _downloading = nil;
    if(!_downloading){
    _downloading = [[downloading alloc] init];
    _downloading.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self.view addSubview:_downloading.view];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                _downloading.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                         
                     }
                     completion:^(BOOL finished) {
                        
                     }
     ];
    }

}

-(void)selected:(id)sender{
    
    UISegmentedControl* control = (UISegmentedControl*)sender;
    NSString *total = [NSString stringWithFormat:@"%d个户型样板间",0];
    
    roomValue =@"全部空间";
    areaValue = @"全部尺寸";
    
    switch (control.selectedSegmentIndex) {
        case 0: loginInfo.downloadType =3;
            total = [NSString stringWithFormat:@"%d个户型样板间",0];
            [self.classSizeButton setHidden:true];
             [self.searchText setHidden:true];
            [self.searchBack setHidden:true];
            [self.sizeButton setTitle:@"全部面积" forState:UIControlStateNormal];
            loginInfo.housesListSearch = @"";
            break;
        case 1:
           loginInfo.downloadType =1;
            total = [NSString stringWithFormat:@"%d个经典样板间",0];
            [self.classSizeButton setHidden:false];
            [self.searchText setHidden:true];
            [self.searchBack setHidden:true];
            [self.sizeButton setTitle:@"全部空间" forState:UIControlStateNormal];
            [self.classSizeButton setTitle:@"全部尺寸" forState:UIControlStateNormal];
            loginInfo.housesListSearch = @"";
            break;
        default:
           
            break;
    }

    [self setLabelTextAndWidth:@"无"];
    
    if(_housesListView){
        
        [self.taotalCount setText:total];
        [_housesListView changeTypeReload];
    }

}
-(void)setLabelTextAndWidth:(NSString *)name{

    CGSize constraint1 = CGSizeMake(2800,21);
    CGSize size1 = [name sizeWithFont:[UIFont fontWithName:@"MicrosoftYaHei" size:12.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.dropArrowButton setFrame:CGRectMake(self.orderByTextLabel.frame.origin.x+size1.width+5, self.dropArrowButton.frame.origin.y, self.dropArrowButton.frame.size.width, self.dropArrowButton.frame.size.height)];
    
    [self.orderByTextLabel setText:name];
}
-(void)textFieldDidChange:(UITextField *)theTextField{

    if(![theTextField.text isEqual: @""]){
        
        loginInfo.housesListSearch = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",@"keyword",self.searchText.text];;
        
        housesListReload = @"3";
    }
    else{
      loginInfo.housesListSearch = @"";
    }

}
-(void)sizeSearch:(NSNotification *)notification{
    
    [downloadFirstPagePopController dismissPopoverAnimated:YES];
  
    NSString *value = [notification object];
    [self.sizeButton setTitle:value forState:UIControlStateNormal];
    
    if(loginInfo.downloadType == 3){
//    if(![value isEqualToString:@"全部面积"])
    loginInfo.housesListSearch =  [NSString stringWithFormat:@"{\"%@\":\"%@\"}",@"area",value];
 //   else
   //      loginInfo.housesListSearch = @"";
    }
    else{
        
        if(![value isEqualToString:@"全部空间"]){
        
            for (NSDictionary *temp in loginInfo.classicPlanSearchType) {
                NSString *name = [temp objectForKey:@"name"];
                if([name isEqualToString:value]){
                  
                    value = [temp objectForKey:@"code"];
                    roomValue = value;
                    break;
                }
            }
        
        }
            
         loginInfo.housesListSearch =  [NSString stringWithFormat:@"{\"%@\":\"%@\",\"%@\":\"%@\"}",@"room",value,@"area",areaValue];
    }
    
    housesListReload = @"2";
    
    if(_housesListView){
        
        [_housesListView getMessageList:@"1"];
    }

}
-(void)classicSizeSearch:(NSNotification *)notification{
    
    
    [downloadFirstPagePopController dismissPopoverAnimated:YES];
    
    NSString *value = [notification object];
    [self.classSizeButton setTitle:value forState:UIControlStateNormal];
    areaValue = value;
    
    loginInfo.housesListSearch =  [NSString stringWithFormat:@"{\"%@\":\"%@\",\"%@\":\"%@\"}",@"area",value,@"room",roomValue];
  
    housesListReload = @"2";
    
    if(_housesListView){
        
        [_housesListView getMessageList:@"1"];
    }

    
}
-(void)goToHousesListDetail:(NSNotification *)notification{
    if(_downloadDetail == nil){
    
        _downloadDetail = [[downloadDetail alloc] init];
    
    }
    
    NSMutableArray *data  = [notification object];
    
    originFrame = CGRectMake([data[2] intValue], [data[3] intValue], 215, 215);
    
    _downloadDetail.view.frame = CGRectMake(0,0, 1024, 768);
    if(data.count==7){
        
        [_downloadDetail initCGRect:originFrame data:data[1] downloadStatus:data[6] image:nil];
        
    }
    if(data.count==8){
        
        [_downloadDetail initCGRect:originFrame data:data[1] downloadStatus:data[6] image:data[7]];
        
    }
    else{
    
          [_downloadDetail initCGRect:originFrame data:data[1] downloadStatus:nil image:nil];
    }
    
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    
    
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    
    NSArray *subViews = [window subviews];
    
   [[subViews objectAtIndex:subViews.count-1] addSubview:_downloadDetail.view];
    
  //  [self.view addSubview:_downloadDetail.view];
    
}
-(void)removeHousesListDetail:(NSNotification *)notification{

    [_downloadDetail.view removeFromSuperview];
    _downloadDetail = nil;
    
}

-(void)goToCollocation:(NSNotification*) notification{
    
    loginInfo.isOfflineMode = true;
    collocationDataTempPlan = [notification object];
    [self performSegueWithIdentifier:@"goToDownloadCollocation" sender:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeDownloadDetailView" object:nil];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goToDownloadCollocation"]) //"goView2"是SEGUE连线的标识
    {
        collocationViewController *theSegue = segue.destinationViewController;
        theSegue.collocationData = collocationDataTempPlan;
    }
}

-(void)downloadToLogin:(NSNotification *) notification{

    UIViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
    [self presentViewController:login animated:YES completion:nil];
}
-(void)removeDownloadingView:(NSNotification *) notification{
  //  [_downloading.view removeFromSuperview];
  //  _downloading.view = nil;
    _downloading = nil;
}
- (IBAction)classSizeButtonAction:(id)sender {
    
   

}
- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    [self updateDownloadCount:nil];
    
}
- (IBAction)AccountAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goUserCentre" object:nil];
}

- (IBAction)settingAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addSettingView" object:sender];
}

- (IBAction)areaIconAction:(id)sender {
    
    if(!downloadFirstPageTypeSearch){
        downloadFirstPageTypeSearch = [[typeSearchTableViewController alloc] init];
        
        downloadFirstPagePopController = [[UIPopoverController alloc] initWithContentViewController:downloadFirstPageTypeSearch];
        
        downloadFirstPagePopController.delegate=self;
        
    }
    
    downloadFirstPageTypeSearch.view.frame = CGRectMake(0, 0, 110, 200);
    downloadFirstPagePopController.popoverContentSize = CGSizeMake(110,200);
    
    if(loginInfo.downloadType ==3)
        [downloadFirstPageTypeSearch initView:6];
    else{
        
        [downloadFirstPageTypeSearch initView:7];
    }
    
    [downloadFirstPagePopController presentPopoverFromRect:((UIView *)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)sizeIconAction:(id)sender {
    
    if(!downloadFirstPageTypeSearch){
        
        
        downloadFirstPageTypeSearch = [[typeSearchTableViewController alloc] init];
        
        downloadFirstPagePopController = [[UIPopoverController alloc] initWithContentViewController:downloadFirstPageTypeSearch];
        
        downloadFirstPagePopController.delegate=self;
    }
    
    downloadFirstPageTypeSearch.view.frame = CGRectMake(0, 0, 110, 200);
    downloadFirstPagePopController.popoverContentSize = CGSizeMake(110,200);
    [downloadFirstPageTypeSearch initView:8];
    
    [downloadFirstPagePopController presentPopoverFromRect:((UIView *)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

- (IBAction)searchTitleAction:(id)sender {
                         
                         if(self.searchBack.isHidden){
                             self.searchBack.hidden = false;
                             self.searchText.hidden = false;
                             [self.searchText becomeFirstResponder];
                         }
                         else{
                             
                             self.searchBack.hidden = true;
                             self.searchText.hidden = true;
                             self.searchText.text = @"";
                            loginInfo.housesListSearch = @"";
                             housesListReload = @"3";

                             [self.searchText resignFirstResponder];
                             
                         }
                         
    
}

- (IBAction)oederByAction:(id)sender {
    
    if(!downloadFirstPageTypeSearch){
    
   downloadFirstPageTypeSearch = [[typeSearchTableViewController alloc] init];
    
    downloadFirstPagePopController = [[UIPopoverController alloc] initWithContentViewController:downloadFirstPageTypeSearch];

    downloadFirstPagePopController.delegate=self;
    
    }
    
    downloadFirstPageTypeSearch.view.frame = CGRectMake(0, 0, 110, 130);
    downloadFirstPagePopController.popoverContentSize = CGSizeMake(110,130);

    if(loginInfo.downloadType==3)
    [downloadFirstPageTypeSearch initView:13];
    else
    [downloadFirstPageTypeSearch initView:14];
    
    [downloadFirstPagePopController presentPopoverFromRect:self.orderByTextLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(self.searchText.text.length>0){
        
        loginInfo.housesListSearch = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",@"keyword",self.searchText.text];;
        
        housesListReload = @"3";
        
        if(_housesListView){
            
            [_housesListView getMessageList:@"1"];
        }

        
    }
    
    return  [self.searchText resignFirstResponder];
}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    
    self.searchText.text = @"";
    
    loginInfo.housesListSearch = @"";
    
    housesListReload = @"3";
    
    if(_housesListView){
        
        [_housesListView getMessageList:@"1"];
    }

    return [self.searchText resignFirstResponder];
}
@end
