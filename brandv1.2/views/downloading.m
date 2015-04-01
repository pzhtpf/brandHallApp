//
//  downloading.m
//  brandv1.2
//
//  Created by Apple on 14-11-19.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "downloading.h"
#import "UIImageView+AFNetworking.h"
#import "Define.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"
#import "globalContext.h"
#import "DBHelper.h"
#import "DAProgressOverlayView.h"
#import "UIImage+Helpers.h"
#import "downloadSelectView.h"
#import "LDProgressView.h"

@interface downloading ()

@end

@implementation downloading
LoginInfo *loginInfo;
UIImage *stopImage;
UIImage *waitImage;
UIImage *unselectImg;
UIImage *selectImg;
NSMutableDictionary *allSelect;
bool isEdit = false;
NSMutableDictionary *buttonDictionary;
UIAlertView *alertView;
UIImageView  *blue_bar;
UIImageView  *yellow_bar;
UIImageView  *gray_bar;
UIImageView *imageMapView;
NSString *mapName;
downloadSelectView *_downloadSelectView;
bool isTouching = true;
NSMutableDictionary *downDloadingDViewData ;
NSMutableArray *orderKey ;
NSMutableArray *headerArray;
int atTopIndex = -1;
UIView *headerView;
UILabel *headerTimeLabel;
NSMutableDictionary *isEditArray;

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
    
    self.delete.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];//MicrosoftYaHei为字体的名称，此处为微软雅黑字体
    self.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17];
    self.complete.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];
    self.clear.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];
    [self.clear setHidden:true];
    [self.delete setHidden:true];
    self.back.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0f];
    
    self.totalCaptiy.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14];
    self.otherApp.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14];
    self.thisApp.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14];
    self.remainApp.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14];
    self.totalText.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14];
    
    self.planSelectHousesName .font = [UIFont fontWithName:@"MicrosoftYaHei" size:17];
    [self.planSelectHousesName setTextColor:UIColorFromRGB(0x686868)];
    self.planSelectAddress .font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
    [self.planSelectAddress setTextColor:UIColorFromRGB(0x686868)];
    self.planSelectCounts .font = [UIFont fontWithName:@"MicrosoftYaHei" size:17];
    self.planSelectSize .font = [UIFont fontWithName:@"MicrosoftYaHei" size:17];
    self.planSelectGoodCount.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17];
    
    self.totalText.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14];
    
    [self.totalText setTextColor:UIColorFromRGB(0xa4a4a4)];
    
    self.planSelectMainView.layer.cornerRadius = 5;
    self.mapView.layer.cornerRadius = 5;
   
    self.searchText.delegate = self;
    self.searchText.returnKeyType = UIReturnKeySearch;
    
    self.downloadingTable.dataSource = self;
    self.downloadingTable.delegate = self;
//    self.downloadingTable.sc
    [self.downloadingTable setBackgroundColor:[UIColor clearColor]];

    loginInfo = [[StockData getSingleton] valueForKey:@"loginInfo"];
    loginInfo.isTouching = true;
    
    if(!loginInfo.downloadedImage)
        loginInfo.downloadedImage = [[NSMutableDictionary alloc] init];
    
    
    self.deleteBackView.frame = CGRectMake(0, -44, 1024, 44);
    [self.view addSubview:self.deleteBackView];
    
    [self usedSpaceAndfreeSpace];
    
 //   NSLog(@"%@",loginInfo.dataFromPlanTable);
    
    NSString *stopPath = [[NSBundle mainBundle]pathForResource:@"stop.png" ofType:@""];
    NSString *waitPath = [[NSBundle mainBundle]pathForResource:@"wait.png" ofType:@""];
    
    stopImage= [UIImage imageWithContentsOfFile:stopPath];
    waitImage= [UIImage imageWithContentsOfFile:waitPath];
    
    NSString *searchString = [[NSBundle mainBundle]pathForResource:@"unselect.png" ofType:@""];
    unselectImg = [UIImage imageWithContentsOfFile:searchString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:@"updateDownloadingView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postAddGesture:) name:@"postAddGesture" object:nil];
    
    [self updateView:nil];
    
}
-(void)updateView:(id)sender{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(loginInfo.dataFromPlanTable.count==0)
        [DBHelper getDataFromPlanTable:0];
        
        if(loginInfo.dataFromPlanTable.count == 0){
            
            NSString *searchString = [[NSBundle mainBundle]pathForResource:@"noDownloadTip.png" ofType:@""];
            UIImage  *noDownloadImg = [UIImage imageWithContentsOfFile:searchString];
            UIImageView *noDownloadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, noDownloadImg.size.width/2, noDownloadImg.size.height/2)];
            [noDownloadImageView setCenter:self.view.center];
            [noDownloadImageView setImage:noDownloadImg];
            [self.view addSubview:noDownloadImageView];
            noDownloadImg = nil;
        }

      //  [self configView:[loginInfo.dataFromPlanTable allKeys]];
        [self orderByDownloadTime:loginInfo.dataFromPlanTable];
        
    });

   
}
-(void)addHeaderView{

    if(!headerView){
    
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0,93, 1024, 25)];
        headerTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0,1024,25)];
        [headerTimeLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [headerTimeLabel setBackgroundColor:[UIColor clearColor]];
        [headerTimeLabel setTextColor:UIColorFromRGB(0x2b2b2b)];
        
        UIButton *select = [[UIButton alloc] initWithFrame:CGRectMake(1024-57, 0, 40, 25)];
        [select setTitle:@"选择" forState:UIControlStateNormal];
        [select setTitleColor:UIColorFromRGB(0x2ca1f1) forState:UIControlStateNormal];
        select.tag =10;
        select.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
        
        headerTimeLabel.font=[UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
        [headerView addSubview:headerTimeLabel];
        [headerView addSubview:select];
        [headerView setBackgroundColor:UIColorFromRGB(0xd7d7d7)]; //your background color...

    }
    
    NSString *string = orderKey[atTopIndex];

    [headerTimeLabel setText:string];

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(scrollView.tag!=1){
    
    if(scrollView.contentOffset.y>0){
    
    NSUInteger sectionNumber = [[self.downloadingTable indexPathForCell:[[self.downloadingTable visibleCells] objectAtIndex:0]] section];
    
    if(atTopIndex != sectionNumber){
    
        atTopIndex = sectionNumber;
        
        [self addHeaderView];
        if(sectionNumber ==0){
            headerView.alpha = 0;
            [self.view addSubview:headerView];
            
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionTransitionFlipFromLeft
                             animations:^{
                                 
                                 headerView.alpha = 1;
                                 
                             }
                             completion:^(BOOL finished) {
                                 
                                                             }
             ];

        }
        
    }
    }
    else{
    
        atTopIndex = -1;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                             headerView.alpha = 0;
                             
                             
                         }
                         completion:^(BOOL finished) {
                             
                             [headerView removeFromSuperview];
                         }
         ];
    }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if(scrollView.tag !=1){
    
    float y = scrollView.contentOffset.y;
    
    if(y==0){
        
        atTopIndex = -1;
        
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                              headerView.alpha = 0;
                             
                             
                         }
                         completion:^(BOOL finished) {
                             
                               [headerView removeFromSuperview];
                         }
         ];
    }
    }
}
    
    

-(void)orderByDownloadTime:(NSDictionary *)dataArgs{

    downDloadingDViewData = [[NSMutableDictionary alloc] init];
    headerArray = [[NSMutableArray alloc] init];
    buttonDictionary= [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *keys = [dataArgs allKeys];
    
    for (int i = 0;i<keys.count;i++) {
        
        NSDictionary *temp = [dataArgs objectForKey:keys[i]];
        NSString *downloadTime = [temp objectForKey:@"downloadTime"];
        if(downloadTime.length == 0)
            downloadTime = @"未知时间";
        
        NSMutableArray *dataArray = [dataDictionary objectForKey:downloadTime];
        
        if(!dataArray)
        {
            dataArray = [[NSMutableArray alloc] init];
            [dataDictionary setValue:dataArray forKey:downloadTime];
        }
        
        [dataArray addObject:keys[i]];
    }
    
    NSArray *allkeys = [dataDictionary allKeys];
    
    for (NSString *key in allkeys) {
        
        [self configView:[dataDictionary objectForKey:key] key:key];
    }
    
    orderKey = [[downDloadingDViewData allKeys] mutableCopy];
    
    for(int i=0; i<orderKey.count;++i){
        for(int j=(int)orderKey.count-1;j>i;--j){
            
         //   orderKey[j] > orderKey[j-1]
            
            if([orderKey[j] compare:orderKey[j-1] options:NSCaseInsensitiveSearch | NSNumericSearch] ==1){
                NSNumber *temp = orderKey[j];
                orderKey[j] = orderKey[j-1];
                orderKey[j-1] = temp;
            }
        }
    }
    
    [self.downloadingTable reloadData];
}
-(void)configView:(NSMutableArray *)allData key:(NSString *)key{
    
    //  [table removeFromSuperview];
   NSMutableArray *downloadingData = [[NSMutableArray alloc] initWithObjects:nil];
    
    if(!loginInfo.progressArray)
    loginInfo.progressArray = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
    
    [self.downloadingTable setBackgroundColor:[UIColor clearColor]];
    
    int x = 0;
    int y = 0;
    int row = 0;
    
    // int eachViewHeight = uiView.frame.size.height/2-10;
    int  eachViewWidth  = 156;
    int eachViewHeight = 188;
    
    UIView *uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.downloadingTable.frame.size.width,eachViewHeight)];
    [uiView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [downloadingData addObject:uiView];
    
    for(int i=0;i<allData.count;i++){
        
        NSDictionary *temp =[loginInfo.dataFromPlanTable objectForKey:allData[i]];
        NSArray *dataPlan = [temp objectForKey:@"data"];
        
        if(i!=0 &&i%6==0){
            x=0;
            y=0;
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.downloadingTable.frame.size.width,eachViewHeight)];
           [tempView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            
            [downloadingData addObject:tempView];
            row++;
            
        }
        
        int housesId = [[temp objectForKey:@"housesId"] intValue];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(17+x*(eachViewWidth+11),y*(eachViewHeight+5), eachViewWidth, eachViewHeight)];
        view.tag = housesId;
        
        UIImageView * imageView =[[UIImageView alloc] init];
        imageView.frame = CGRectMake(0,0, eachViewWidth,117);
        
        [view addSubview:imageView];
        
     
        if([loginInfo.downloadedImage  objectForKey:[temp objectForKey:@"housesId"]])
            imageView.image = [loginInfo.downloadedImage  objectForKey:[temp objectForKey:@"housesId"]];
        
        else{
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
            [activityIndicator setCenter:imageView.center];
            [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            [activityIndicator startAnimating];
            [imageView addSubview:activityIndicator];
        
        [UIImage loadFromURL:[dataPlan[0] objectForKey:@"localImageName"] callback: ^(UIImage *image){
            
            image = [image resizedCenterImage:imageView.frame.size interpolationQuality:kCGInterpolationLow];
            [loginInfo.downloadedImage setValue:image forKey:[temp objectForKey:@"housesId"]];
            [imageView setImage:image];
            [activityIndicator stopAnimating];
             activityIndicator.hidden = YES;
        }];
        
        }
      
        
        UIButton *unselect = [[UIButton alloc] initWithFrame:CGRectMake(126,87,25,25)];
        [unselect setImage:unselectImg forState:UIControlStateNormal];
        unselect.tag = [[temp objectForKey:@"housesId"] intValue];
        [unselect addTarget:self action:@selector(selectPlan:) forControlEvents:UIControlEventTouchUpInside];
        [unselect setHidden:!isEdit];
        [view addSubview:unselect];
        [buttonArray addObject:unselect];
        
        imageView.userInteractionEnabled = YES;
        imageView.tag = housesId;
       [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goToDetail:)]];
        
//        UIView *info = [[UIView alloc]initWithFrame:CGRectMake(0,120,150, 30)];
//        [info setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.5]];
//        
        UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake(0,125,156, 15)];
        [name setBackgroundColor:[UIColor clearColor]];
        name.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [name setTextColor:UIColorFromRGB(0x2b2b2b)];
        
        UILabel *downloaded =[[UILabel alloc] initWithFrame:CGRectMake(0,145,85, 15)];
        [downloaded setBackgroundColor:[UIColor clearColor]];
        downloaded.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
        [downloaded setTextColor:UIColorFromRGB(0xb2b2b2)];
        
    //    if(dataPlan.count>1){
        if(housesId != [[dataPlan[0] objectForKey:@"planId"] intValue]){
            
            NSString *houseName = [temp objectForKey:@"housesName"];
            NSArray *houseNames = [houseName componentsSeparatedByString:@";"];
            
            [name setText:[NSString stringWithFormat:@"%@",houseNames[0]]];
            int count = 0;
            int status = 3;
            
            for(NSDictionary *temp3 in dataPlan){
            
                int tempStatus = [[temp3 objectForKey:@"status"] intValue];
                
                if( tempStatus ==3)
                    count++;
                
               else if(tempStatus ==0)
                    status =status==1?1:0;
                
               else if(tempStatus ==1)
                   status =status==2?2:1;
                
               else if(tempStatus ==2)
                   status = 2;
            }
            downloaded.frame = CGRectMake(0,145,180, 15);
            [downloaded setText:[NSString stringWithFormat:@"已下载%d个样板间",count]];
            downloaded.tag = 65;
            [view addSubview:name];
            
         //   name.alpha = 0;   //暂且隐藏
            
     //       downloaded.alpha = 0;   //暂且隐藏
            
            [view addSubview:downloaded];
            
            
            if(status<2)
            [self addWaitView:view status:status tag:[allData[i] intValue]];
            else if(status == 2){
                    [self addProgressingViewMethod:[temp objectForKey:@"housesId"] view:view type:0 status:2];
            }
           
            if(status !=3){
                
                UIView *tempView = [loginInfo.progressArray objectForKey:[temp objectForKey:@"housesId"]];
                if(tempView){
                    UIView *temp2View  = [tempView viewWithTag:99];
                    if(temp2View)
                        [view addSubview:temp2View];
                }
                
                [loginInfo.progressArray setValue:view forKey:[temp objectForKey:@"housesId"]];

            }
            
        }
        else{
        
            [name setText:[NSString stringWithFormat:@"%@",[dataPlan[0] objectForKey:@"name"]]];
            
            int nowVersion = [[dataPlan[0] objectForKey:@"nowVersion"] intValue];
            int latestVersion = [[dataPlan[0] objectForKey:@"latestVersion"] intValue];
            if(nowVersion<latestVersion && [[dataPlan[0] objectForKey:@"status"] intValue]==3)     //已有更新,添加更新的样式
            {
                
                NSString *huxingPath = [[NSBundle mainBundle]pathForResource:@"new.png" ofType:@""];
                UIImage *huxingPathImage = [UIImage imageWithContentsOfFile:huxingPath];
                UIImageView *updateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(eachViewWidth-35,5,35,35)];
                [updateImageView setImage:huxingPathImage];
                updateImageView.tag=64;
                [view addSubview:updateImageView];
                
                updateImageView = nil;
                
                UIButton *updateButton = [[UIButton alloc] initWithFrame:CGRectMake(eachViewWidth-47, 131, 52, 27)];
                NSString *updateButtonImagePath = [[NSBundle mainBundle]pathForResource:@"update.png" ofType:@""];
                UIImage *updateButtonImage = [UIImage imageWithContentsOfFile:updateButtonImagePath];
                [updateButton setImage:updateButtonImage forState:UIControlStateNormal];
                updateButton.tag =[[temp objectForKey:@"housesId"] intValue];
                [updateButton addTarget:self action:@selector(updateMethod:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:updateButton];
            }
            else        //没有更新,添加没有更新的样式
            {
            UILabel *goodsCount =[[UILabel alloc] initWithFrame:CGRectMake(0,145,110, 15)];
                
         //   goodsCount.alpha = 0;   //暂且隐藏
                
            [goodsCount setBackgroundColor:[UIColor clearColor]];
            goodsCount.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
            [goodsCount setTextColor:UIColorFromRGB(0x9d9d9d)];
            
            NSString *countStr = [dataPlan[0] objectForKey:@"goodsCount"];
            
            [goodsCount setText:[NSString stringWithFormat:@"可搭配产品：%@件",countStr]];
            goodsCount.textAlignment = NSTextAlignmentLeft;
            
            NSMutableAttributedString *text =
            [[NSMutableAttributedString alloc]
             initWithAttributedString: goodsCount.attributedText];
            
            [text addAttribute:NSForegroundColorAttributeName
                         value:UIColorFromRGB(0xff553e)
                         range:NSMakeRange(6, countStr.length)];
            [goodsCount setAttributedText: text];
            
            [view addSubview:goodsCount];
            goodsCount = nil;
                
            double total = [[dataPlan[0] objectForKey:@"total"] longLongValue];
                
                UILabel *totalCaptiy =[[UILabel alloc] initWithFrame:CGRectMake(110,145,46,15)];
                [totalCaptiy setBackgroundColor:[UIColor clearColor]];
                totalCaptiy.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
                [totalCaptiy setTextColor:UIColorFromRGB(0xb2b2b2)];
                totalCaptiy.textAlignment = NSTextAlignmentRight;
                
             //    totalCaptiy.alpha = 0;   //暂且隐藏
                
                NSString *totalStr = [NSString stringWithFormat:@"%0.1f",total/1024.0/1024.0];
                
                [totalCaptiy setText:[NSString stringWithFormat:@"%@M",totalStr]];
                [view addSubview:totalCaptiy];
                totalCaptiy = nil;
            
            if([[dataPlan[0] objectForKey:@"status"] integerValue] !=3){

                UIView *tempView = [loginInfo.progressArray objectForKey:[temp objectForKey:@"housesId"]];
                if(tempView){
                 UIView *temp2View  = [tempView viewWithTag:99];
                    if(temp2View){
                        NSArray *subViews = [temp2View subviews];
                        UIView *viewWait = subViews[0];
                        [viewWait addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startDownload:)]];
                        [view addSubview:temp2View];
                    }
                }
                  
                [self addDOwnloadProgressLabel:dataPlan[0] view:view houseId:[temp objectForKey:@"housesId"]];
            }
            }
            // 0  暂停
            // 1  排队中
            // 2  正在下载
            // 3 下载完毕
            
            int status = [[dataPlan[0] objectForKey:@"status"] intValue];
            if(status <2)
             [self addWaitView:view status:status tag:[allData[i] intValue]];
            else if(status == 2){
                [self addProgressingViewMethod:[temp objectForKey:@"housesId"] view:view type:0 status:2];
            }

        }

     //    name.alpha = 0;   //暂且隐藏
        [view addSubview:name];
        name = nil;
        downloaded = nil;
       
        
        [downloadingData[row] addSubview:view];
        
        x++;
        
    }
    
  //  loginInfo.downloadingViewData = [downloadingData copy];
    
    [downDloadingDViewData setValue:[downloadingData copy] forKey:key];
    [buttonDictionary setValue:buttonArray forKey:key];
    
  //  [self.downloadingTable reloadData];
    
    
    
}
-(void)addDOwnloadProgressLabel:(NSMutableDictionary *)data view:(UIView *)view houseId:(NSString *)houseId{
    
    UILabel *downloaded =[[UILabel alloc] initWithFrame:CGRectMake(0,158,85, 15)];
    [downloaded setBackgroundColor:[UIColor clearColor]];
    downloaded.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
    [downloaded setTextColor:UIColorFromRGB(0xb2b2b2)];
     downloaded.frame = CGRectMake(0,158,180, 15);
    
    double remain = [[data objectForKey:@"remain"] longLongValue];
    double total = [[data objectForKey:@"total"] longLongValue];
    NSString *per = [NSString stringWithFormat:@"%0.1f％",(total-remain)/total*100];
    
    [downloaded setText:[NSString stringWithFormat:@" 已下载%@",per]];
    downloaded.tag = 61;
  
    downloaded.alpha = 0;  //暂且隐藏
    
    [view addSubview:downloaded];
    [loginInfo.progressArray setValue:view forKey:houseId];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    
    return [orderKey count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
 //   return [loginInfo.downloadingViewData count];
    NSArray *data = [downDloadingDViewData objectForKey:orderKey[section]];
    
    return data.count;
    // return 34;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
        return 35;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,35)];
    /* Create custom view to display section header... */
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, tableView.frame.size.width,25)];
        [label setFont:[UIFont boldSystemFontOfSize:14]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:UIColorFromRGB(0x2b2b2b)];
    
    
        UIButton *select = [[UIButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width-57, 0, 40, 25)];
        [select setTitle:@"选择" forState:UIControlStateNormal];
        [select setTitleColor:UIColorFromRGB(0x2ca1f1) forState:UIControlStateNormal];
        select.tag = section;
       select.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
      [select addTarget:self action:@selector(showSelect:) forControlEvents:UIControlEventTouchUpInside];
  //  [select addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goToDetail:)]];
    
    
    
        NSString *string =[NSString stringWithFormat:@"%@", orderKey[section]];
        
        /* Section header is in 0th index... */
        [label setText:string];
        label.font=[UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
        [view addSubview:label];
        [view addSubview:select];
        [view setBackgroundColor:[UIColor clearColor]]; //your background color...
    
    if(section==0){
        [label setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
        
        UILabel *labelColor = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,17,25)];
        [labelColor setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
        [view addSubview:labelColor];
        
        }
    
       [headerArray addObject:view];
    
    return view;
}
-(void)showSelect:(UIButton *)select{
    
    if(!isEditArray)
        isEditArray = [[NSMutableDictionary alloc] init];
    
    if([isEditArray objectForKey:orderKey[select.tag]]){
       [select setTitle:@"选择" forState:UIControlStateNormal];
        [isEditArray removeObjectForKey:orderKey[select.tag]];
        
        NSArray *buttonArray = [buttonDictionary objectForKey:orderKey[select.tag]];
        
        for (UIButton *button in buttonArray) {
            [button setHidden:true];
        }
    }
    else{
      [select setTitle:@"取消" forState:UIControlStateNormal];
      [isEditArray setValue:@"isEdit" forKey:orderKey[select.tag]];
        
        NSArray *buttonArray = [buttonDictionary objectForKey:orderKey[select.tag]];
        
        for (UIButton *button in buttonArray) {
            [button setHidden:false];
        }
    }
    
    if(isEditArray.count>0){
        
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                             self.deleteBackView.frame = CGRectMake(0,0, 1024,44);
                             
                         }
                         completion:^(BOOL finished) {
                             
                         }
         ];
    
    }
    else if(isEditArray.count ==0){
        
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionTransitionFlipFromLeft
                         animations:^{
                             
                             self.deleteBackView.frame = CGRectMake(0,-44, 1024,44);
                             
                         }
                         completion:^(BOOL finished) {
                            
                           //  [self.deleteBackView removeFromSuperview];
                         }
         ];
        
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSArray *data = [downDloadingDViewData objectForKey:orderKey[indexPath.section]];
//    
//    UIView *view = data[indexPath.row];
//    
//    NSArray *allViews = [view subviews];
//    
//    if(allViews.count<=6){
//        
//        return view.frame.size.height/2+4;
//        
//    }
//    else{
//        
//        return view.frame.size.height+4;
//    }
    
    return 175;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    
//    if(indexPath.row<= loginInfo.downloadingViewData.count-1)
//    {
    
      NSArray *data = [downDloadingDViewData objectForKey:orderKey[indexPath.section]];
      [cell.contentView addSubview:data[indexPath.row]];
   //     [cell.contentView addSubview:loginInfo.downloadingViewData[indexPath.row]];
//    }
    // cell.textLabel.text = @"weff";
    cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}
-(void)updateGetData:(NSString *)planId data:(NSMutableDictionary *)data{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":planId,@"angle":@"A1"};
    
    
    [manager POST:[BASEURL stringByAppendingString: getClassicDataApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //    NSLog(@"JSON: %@", responseObject);
        
        NSMutableDictionary *temp = responseObject;
        
        NSArray *dataArray = [data objectForKey:@"data"];
        for (NSMutableDictionary *temp5 in dataArray) {
            NSString *tempId= [NSString stringWithFormat:@"%@",[temp5 objectForKey:@"planId"]];
            if([tempId isEqualToString:planId]){
            
                [temp5 setValue:[temp objectForKey:@"productAllData"] forKey:@"productAllData"];
                [temp5 setValue:[temp objectForKey:@"defaultData"] forKey:@"defaultData"];

            }
        }
        
        [data setValue:@"0" forKey:@"nowStart"];
        [loginInfo.downloadList setValue:data forKey:[data objectForKey:@"housesId"]];
        
        if(loginInfo.isDownloadComplete){
            
            [globalContext startDownloadThread];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        
    }];

}
-(void)updateMethod:(id)sender{

    UIButton *updateButton = (UIButton *)sender;
    NSString *housesId = [NSString stringWithFormat:@"%d",(int)updateButton.tag];
    UIView *view = [updateButton superview];
    
    NSMutableDictionary *temp = [loginInfo.dataFromPlanTable objectForKey:housesId];
    NSArray *tempArray = [temp objectForKey:@"data"];
    NSMutableDictionary *temp2 = tempArray[0];
    
    for (NSMutableDictionary *temp5 in tempArray) {
        
        int nowVersion = [[temp5 objectForKey:@"nowVersion"] intValue];
        int latestVersion = [[temp5 objectForKey:@"latestVersion"] intValue];
        if(nowVersion<latestVersion)     //已有更新,添加更新的样式
        {
            [temp5 setValue:@"0" forKey:@"updateStatus"];
            [temp5 setValue:[temp5 objectForKey:@"total"] forKey:@"remain"];
            
            [self updateGetData:[temp5 objectForKey:@"planId"] data:temp];
            
            temp2 = temp5;
        }
    }
    
    
    [updateButton setHidden:true];
    [[view viewWithTag:64] setHidden:true];
    
    
    
    
    [self addDOwnloadProgressLabel:temp2 view:view houseId:housesId];
    
    if(loginInfo.isDownloadComplete){
    
        [temp2 setValue:@"2" forKey:@"status"];
        
        [self addProgressingViewMethod:housesId view:[loginInfo.progressArray objectForKey:housesId] type:1 status:2];
    }
    else{
       [temp2 setValue:@"1" forKey:@"status"];
        [self addWaitView:view status:2 tag:(int )updateButton.tag];
    }
}
-(void)addProgressingViewMethod:(NSString *)housesId view:(UIView *)tempView type:(int) type status:(int)status{
    
    NSDictionary *tempData = [loginInfo.dataFromPlanTable objectForKey:housesId];
    NSArray *dataArray = [tempData objectForKey:@"data"];
    float total = 0;
    float remain = 0;
    
    for(NSDictionary *temp in dataArray){
    
        remain = remain + [[temp objectForKey:@"remain"] longLongValue];
        total =  total+[[temp objectForKey:@"total"] longLongValue];
    }

        if(tempView){
            
            if(![tempView viewWithTag:99]){
                UIView *temp2View = [tempView viewWithTag:62];
                if(temp2View){
                    [temp2View removeFromSuperview];
                }

                
                UIView *temp = [[UIView alloc] initWithFrame:CGRectMake(0,0,156,117)];
                temp.tag = 99;

                
                LDProgressView *progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(0,0,156,117)];
                progressView.borderRadius = @4;
                progressView.type = LDProgressSolid;
                progressView.tag = [housesId intValue];
                progressView.color = UIColorFromRGB(0x6682c3);
                [progressView setAnimate:0];
                
                if(status ==0){
                    
                 progressView.tip =@"暂停";
                
                }
                else{
                   progressView.tip =@"";
                }
                
                progressView.progress = (total-remain)/total;
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,80,156,20)];
                
                if(type==0)
                [label setText:@"下载中"];
                
                else if(type==1)
                    [label setText:@"更新中"];
                
                label.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13];
                [label setTextColor:[UIColor whiteColor]];
                label.textAlignment = NSTextAlignmentCenter;
                
                [progressView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startDownload:)]];
                [temp addSubview:progressView];
                
                        NSArray *subViews= [tempView subviews];
                        for(UIView *tempView1 in subViews){
                            if([tempView1 isKindOfClass:[UIButton class]]){
                
                                [tempView insertSubview:temp belowSubview:tempView1];
                                break;
                            }
                        
                        }
            
                if(!loginInfo.progressArray)
                    loginInfo.progressArray = [[NSMutableDictionary alloc] init];
                
                [loginInfo.progressArray setValue:tempView forKey:housesId];
                
            }

            else{
            
                UIView *view = [tempView viewWithTag:99];
                
                NSArray *subViews = [view subviews];
                
                LDProgressView *tempProgress = (LDProgressView *)subViews[0];
                
                if(status ==0){
                    
                    tempProgress.tip =@"暂停";
                    
                }
                else{
                    tempProgress.tip =@"";
                }
                
                tempProgress.progress = (total-remain)/total;
            }
    }
    
    
}
-(void)addWaitView:(UIView *)view status:(int)status tag:(int)tag{

//    UIView *tempView = [loginInfo.progressArray objectForKey:[NSString stringWithFormat:@"%d",tag]];
//    UIView *downloaded = [tempView viewWithTag:99];
//    
//    if(!downloaded){
//    
//        [self addWaitViewMethod:view status:status tag:tag];
//    }
//    else{
//    
//        [view addSubview:downloaded];
//        view.tag = tag;
//        view.userInteractionEnabled = YES;
//        NSArray *subViews = [downloaded subviews];
//        UIView *progressView = subViews[0];
//        [progressView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startDownload:)]];
//    }
    
      [self addWaitViewMethod:view status:status tag:tag];
    
    
    [loginInfo.progressArray setValue:view forKey:[NSString stringWithFormat:@"%d",tag]];

}

-(void)addWaitViewMethod:(UIView *)view status:(int)status tag:(int)tag{

//    UIView *temp = [[UIView alloc] initWithFrame:CGRectMake(0,0,156,117)];
//    [temp setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.5]];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,57,60)];
//    NSString *imagepath1 = @"";
//    
//    if(status == 1 || status==2 ||status==0){
//        if(status ==1)
//            imagepath1=[[NSBundle mainBundle]pathForResource:@"wait.png" ofType:@""];
//        
//        else if(status ==0){
//            imagepath1=[[NSBundle mainBundle]pathForResource:@"stop.png" ofType:@""];
//        }
//        
//        UIImage *imageLine1 = [UIImage imageWithContentsOfFile:imagepath1];
//        [imageView setImage:imageLine1];
//        [imageView setCenter:temp.center];
//        [temp addSubview:imageView];
//        temp.tag = 62;
//        imageView.tag = tag;
//        imageView.userInteractionEnabled = YES;
//        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startDownload:)]];
//      //  [view addSubview:temp];
//        NSArray *subViews= [view subviews];
//        for(UIView *tempView in subViews){
//            if([tempView isKindOfClass:[UIButton class]]){
//            
//                [view insertSubview:temp belowSubview:tempView];
//                break;
//            }
//        
//        }
//    }
//    
//    else if(status ==2){
//        
//        [self addProgressingViewMethod:[NSString stringWithFormat:@"%d",tag] view:view type:0];
//    }

    [self addProgressingViewMethod:[NSString stringWithFormat:@"%d",tag] view:view type:0 status:status];

    
}
-(void)postAddGesture:(NSNotification *)notification{

    UIGestureRecognizer *gestureRecognizer =[notification object];

    [self startDownload:gestureRecognizer];
}
-(void)startDownload:(UIGestureRecognizer *)gestureRecognizer
{
    // 0  暂停
    // 1  排队中
    // 2  正在下载
    // 3 下载完毕
  //  if( loginInfo.isTouching ){
        loginInfo.isTouching  = false;
    
    UIView *temp1View = [gestureRecognizer view];
    
    NSString *key = [NSString stringWithFormat:@"%d",(int)temp1View.tag];
    
    NSDictionary *temp =[loginInfo.dataFromPlanTable objectForKey:key];
    
    NSArray *dataPlan = [temp objectForKey:@"data"];
    
    UIView *superView = [[temp1View superview] superview];
   
    for(NSDictionary *temp1 in dataPlan){
        
        NSMutableDictionary *dataUpdate = [[NSMutableDictionary alloc] initWithDictionary:temp1];
        [dataUpdate setValue:[temp objectForKey:@"housesId"] forKey:@"housesId"];
        [dataUpdate setValue:[temp objectForKey:@"housesName"] forKey:@"housesName"];
    
        int status = [[temp1 objectForKey:@"status"] intValue];
        
        if(status ==3)
            continue;
        else if(status == 0){
            
            if(loginInfo.downloadList.count>0){
             status = 1;
//            if([temp1View isKindOfClass:[UIImageView class]]){
//                
//               UIImageView *tempView = (UIImageView *)temp1View;
//               [tempView setImage:waitImage];
//                
//            }

            }
            else{

             status = 2;
            
            }
            
            [self addProgressingViewMethod:[temp objectForKey:@"housesId"] view:superView type:0 status:status];
            
            [temp1 setValue:[NSNumber numberWithInt:status] forKey:@"status"];
            
            [loginInfo.downloadList setValue:[loginInfo.dataFromPlanTable objectForKey:key] forKey:key];
            
            
            [dataUpdate setValue:[NSNumber numberWithInt:status] forKey:@"status"];
            [DBHelper updatePlanTable:dataUpdate];
            
             if(loginInfo.isDownloadComplete){
                [globalContext startDownloadThread];
             }

        }
       else if(status == 1){
            
             status = 0;
//            if([temp1View isKindOfClass:[UIImageView class]]){
//             UIImageView *tempView = (UIImageView *)temp1View;
//            [tempView setImage:stopImage];
//             }
//            else{
//                status = 2;
//            }
    
        [self addProgressingViewMethod:[temp objectForKey:@"housesId"] view:superView type:0 status:status];
           
         [temp1 setValue:[NSNumber numberWithInt:status] forKey:@"status"];
            
            
          [loginInfo.downloadList removeObjectForKey:key];
          UIView *tempView4 = [temp1View superview];
          [loginInfo.progressArray setValue:tempView4 forKey:key];
           
           [dataUpdate setValue:[NSNumber numberWithInt:status] forKey:@"status"];
           [DBHelper updatePlanTable:dataUpdate];

        }
       else if(status == 2){
            status = 0;
         
        //    UIView *superView = [[temp1View superview] superview];
        //  [[superView viewWithTag:99]  removeFromSuperview];
            [self addWaitViewMethod:superView status:status tag:[key intValue]];
            
            [loginInfo.progressArray setValue:superView forKey:key];
            
            [temp1 setValue:[NSNumber numberWithInt:status] forKey:@"status"];

            [loginInfo.downloadList removeObjectForKey:key];
           
           if(loginInfo.downloadList.count ==0){
               
               [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelDownloadThread" object:nil];
           }
           
            loginInfo.isRedownload = true;
            
           [dataUpdate setValue:[NSNumber numberWithInt:status] forKey:@"status"];
            [DBHelper updatePlanTable:dataUpdate];
    
        }
        
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateView" object:nil];

    }
       // isTouching = true;
  //  }
}
-(void)saveDownloadThread:(NSMutableDictionary *)temp{

    [globalContext saveDownloadData:temp];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    
    [self backMethod];
}
-(void)backMethod{


    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         self.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                         
                     }
                     completion:^(BOOL finished) {
                         [self.downloadingTable removeFromSuperview];
                         self.downloadingTable = nil;
                         [self.view removeFromSuperview];
                         self.view = nil;
                         isEdit = false;
                         stopImage = nil;
                         waitImage = nil;
                         unselectImg = nil;
                         selectImg = nil;
                         allSelect = nil;
                         buttonDictionary = nil;
                         alertView = nil;
                         //   loginInfo.progressArray = nil;
                         isEditArray = nil;
                         alertView = nil;
                         [blue_bar removeFromSuperview];
                         blue_bar = nil;
                         [yellow_bar removeFromSuperview];
                         yellow_bar = nil;
                         [gray_bar removeFromSuperview];
                         gray_bar = nil;
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"removeDownloadingView" object:nil];
                         [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateDownloadingView" object:nil];
                         [[NSNotificationCenter defaultCenter] removeObserver:self name:@"postAddGesture" object:nil];
                         
                     }
     ];
    

}
-(void)goToDetail:(UIGestureRecognizer *)gestureRecognizer{
    
    UIView *view = [gestureRecognizer view];
    
    NSString *housesId = [NSString stringWithFormat:@"%d",(int)view.tag];
    
    NSDictionary *temp = [loginInfo.dataFromPlanTable objectForKey:housesId];

    NSString *downTime =[temp objectForKey:@"downloadTime"];
    
    if (![isEditArray objectForKey:downTime]) {
        
        NSArray *data = [temp objectForKey:@"data"];
        NSString *planId = [data[0] objectForKey:@"planId"];
    
        if(data.count ==1 && [housesId isEqualToString:planId]){
        NSDictionary *id = [[NSDictionary alloc] initWithObjectsAndKeys:housesId,@"id", nil];
            
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToDownloadCollocation" object:id];
        }
        
        else{
            
            [self.view addSubview:self.planSelectView];
            
            if(!_downloadSelectView){
            
                _downloadSelectView = [[downloadSelectView alloc] initWithFrame:CGRectMake(-400,150, 810,380)];
                [self.planSelectMainView addSubview:_downloadSelectView];
                
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionTransitionFlipFromLeft
                                 animations:^{
                                     
                                     _downloadSelectView.frame = CGRectMake(20,150, 810,380);
                                     
                                 }
                                 completion:^(BOOL finished) {
                                     
                                 }
                 ];
                
                NSMutableArray *array = [temp objectForKey:@"data"];
                
                int  totalCount = 0;
                
                for(NSDictionary *tempData in array){
                
                    totalCount = totalCount +[[tempData objectForKey:@"goodsCount"] intValue];
                }
                NSString *totalCountStr = [NSString stringWithFormat:@"%d",totalCount];
                NSString *goodsCountString = [NSString stringWithFormat:@"可搭配素材%d款",totalCount];
                [self.planSelectGoodCount setText:goodsCountString];
                
                NSMutableAttributedString *text =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: self.planSelectGoodCount.attributedText];
                
                [text addAttribute:NSForegroundColorAttributeName
                             value:UIColorFromRGB(0xff553e)
                             range:NSMakeRange(5, totalCountStr.length)];
                [self.planSelectGoodCount setAttributedText: text];

                
                NSString *countString = [NSString stringWithFormat:@"%d个样板间",(int)array.count];
                [self.planSelectCounts setText:countString];
                
                [_downloadSelectView configView:array];
            }
            
            NSString *housesName = [temp objectForKey:@"housesName"];
            NSArray *names = [housesName componentsSeparatedByString:@";"];
            [self.planSelectHousesName setText:names[0]];
            [self.planSelectAddress setText:names[1]];
            [self.planSelectSize setText:names[2]];
          
             mapName = names[5];
            
            [UIImage loadFromURL:names[4] callback: ^(UIImage *image){
                
                image = [image resizedCenterImage:self.planSelectImageView.frame.size interpolationQuality:kCGInterpolationLow];
                [self.planSelectImageView setImage:image];
            }];
        }
    
        
    }
    else{
   
        NSArray *allkeys =[buttonDictionary allKeys];
        for (NSString *key in allkeys) {
            NSArray *buttonArray = [buttonDictionary objectForKey:key];
            for (UIButton *button in buttonArray) {
                if(button.tag == view.tag){
                    [self selectPlan:button];
                    break;
                }
            }

        }
    }
    
}

-(void)updateProgressView:(NSNotification *)notification{


}
- (IBAction)clearAction:(id)sender {
    
    alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"是否确定要清空样板间，可能会造成样板间搭配不可使用" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 112;
    [alertView show];
 
}

- (IBAction)deleteAction:(id)sender {
    
    if(allSelect.count>0){
    
    alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"是否确定要删除样板间，可能会造成样板间搭配不可使用" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 111;
    [alertView show];
        
    }
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{

        if(buttonIndex == 0){
          
        }
        else{
            
            NSArray * temp5;
            
            if(alertView.tag ==112){
            
            temp5 = [loginInfo.dataFromPlanTable allKeys];
                
            [loginInfo.progressBarView setTip:@"正在清空......"];
                loginInfo.isDownloadComplete = true;
            }
            
            else{
                
                [loginInfo.progressBarView setTip:@"正在删除......"];
                temp5 = [allSelect allKeys];
            }
            
            [self.view addSubview:loginInfo.progressBarView];
            
            NSThread *deleteThread = [[NSThread alloc] initWithTarget:self selector:@selector(deleteMethod:) object:temp5];
            [deleteThread start];
            
        }
}
-(void)deleteMethod:(NSArray *)keys{
    for (NSString *housesId in keys) {
        
        if([DBHelper deleteByHousesId:housesId])
        {
            [loginInfo.dataFromPlanTable removeObjectForKey:housesId];
            [loginInfo.downloadList removeObjectForKey:housesId];
            [allSelect removeObjectForKey:housesId];
            [self updateView:nil];
            
//            NSArray *allKeys = [downDloadingDViewData allKeys];
//            
//            bool flag = false;
//            
//            for (NSString *key in allKeys) {
//                
//                NSMutableArray *array = [downDloadingDViewData objectForKey:key];
//                
//                for (UIView *view in array) {
//                    
//                    NSMutableArray *allViews = [[view subviews] mutableCopy];
//                    
//                    for (UIView *view1 in allViews) {
//                        
//                        NSLog(@"%d,,,%d",view1.tag,[housesId intValue]);
//                        
//                        if([housesId intValue] == view1.tag){
//                            
//                         //   [allViews removeObject:view1];
//                            [view1 removeFromSuperview];
//                            flag = true;
//                            break;
//                        }
//                        
//                    }
//                   if(flag)
//                       break;
//                }
//                
//                if(flag)
//                    break;
//            }
//
//            [self.downloadingTable reloadData];
        }
    }
    
    NSString *deleteStr = [NSString stringWithFormat:@"删除(%d)",[allSelect count]];
    [self.delete setTitle:deleteStr forState:UIControlStateNormal];
    [self usedSpaceAndfreeSpace];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownloadCount" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateView" object:nil];
    [loginInfo.progressBarView removeFromSuperview];
    
    if(loginInfo.downloadList.count==0){
    
        loginInfo.isDownloadComplete = true;
    }

}
- (IBAction)completeAction:(id)sender {
    
    if(!isEdit){
    
        [self.delete setHidden:false];
        [self.clear setHidden:false];
        [self.complete setTitle:@"完成" forState:UIControlStateNormal];
        isEdit = true;
    }
    else{
        [self.delete setHidden:true];
        [self.clear setHidden:true];
        [self.complete setTitle:@"编辑" forState:UIControlStateNormal];
        isEdit = false;
    
    }
    
}
-(void)selectPlan:(id)sender{
    
    UIButton *temp = (UIButton *)sender;
    
    if(!selectImg){
        NSString *searchString = [[NSBundle mainBundle]pathForResource:@"select_red.png" ofType:@""];
        selectImg = [UIImage imageWithContentsOfFile:searchString];
        allSelect = [[NSMutableDictionary alloc] init];
    }
    
    NSString *key = [NSString stringWithFormat:@"%d",temp.tag];
    
    if(![allSelect objectForKey:key]){
        
        [allSelect setValue:key forKey:key];
        [temp setImage:selectImg forState:UIControlStateNormal];
    }
    else{
        [temp setImage:unselectImg forState:UIControlStateNormal];
        [allSelect removeObjectForKey:key];
    }

    NSString *deleteStr = [NSString stringWithFormat:@"删除(%d)",[allSelect count]];
    [self.delete setTitle:deleteStr forState:UIControlStateNormal];
    
    NSString *topDeleteStr = [NSString stringWithFormat:@"已选择%d套方案",[allSelect count]];
    [self.deleteTitleLabel setText:topDeleteStr];
}
-(void)usedSpaceAndfreeSpace{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSFileManager* fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
    NSString  * str= [NSString stringWithFormat:@"已占用%0.1fG/剩余%0.1fG",([totalSpace longLongValue] - [freeSpace longLongValue])/1024.0/1024.0/1024.0,[freeSpace longLongValue]/1024.0/1024.0/1024.0];
    NSLog(@"--------%@",str);
    
  //  NSString *nowNeed = [NSString stringWithFormat:@"%0.1fM",(total)/1024.0/1024.0];
    
    
 //   NSString *remainStr = [NSString stringWithFormat:@"%0.1fG",[freeSpace longLongValue]/1024.0/1024.0/1024.0-(total/1024.0/1024.0/1024.0)];
    
 //   NSString  * strX= [NSString stringWithFormat:@"当前下载需要%@，剩余空间%@",nowNeed,remainStr];
    
    NSString  * totalStr= [NSString stringWithFormat:@"%0.1fGB",[totalSpace longLongValue]/1024.0/1024.0/1024.0];
    [self.totalCaptiy setTextColor:UIColorFromRGB(0xa4a4a4)];
    [self.totalCaptiy setText:totalStr];
    
    double thisTotal = [DBHelper getTotal];
    NSString  * thisTotalStr= [NSString stringWithFormat:@"本程序：%0.1fMB",thisTotal/1024.0/1024.0];
    [self.thisApp setTextColor:UIColorFromRGB(0xa4a4a4)];
    [self.thisApp setText:thisTotalStr];

    NSString  * freeStr= [NSString stringWithFormat:@"剩余空间：%0.1fGB",[freeSpace longLongValue]/1024.0/1024.0/1024.0];
    [self.remainApp setTextColor:UIColorFromRGB(0xa4a4a4)];
    [self.remainApp setText:freeStr];
    
    double otherTotal = [totalSpace longLongValue]-[freeSpace longLongValue]-thisTotal;
    
    
    double otherWidth = otherTotal/[totalSpace longLongValue]*939;
    
    double thisWidth =  (otherTotal + thisTotal)/[totalSpace longLongValue]*939;
    
    NSString  * otherStr= [NSString stringWithFormat:@"其他程序：%0.1fGB",otherTotal/1024.0/1024.0/1024.0];
    [self.otherApp setTextColor:UIColorFromRGB(0xa4a4a4)];
    [self.otherApp setText:otherStr];
    
    NSString *downloadTipString = [NSString stringWithFormat:@"离线缓存已使用%0.1fMB，剩余空间%0.1fGB",thisTotal/1024.0/1024.0,[freeSpace longLongValue]/1024.0/1024.0/1024.0];
    [self.downloadTipLabel setText:downloadTipString];
//    if(!blue_bar){
//    
//        NSString *blue_bar_path = [[NSBundle mainBundle]pathForResource:@"bar_blue.png" ofType:@""];
//        UIImage *blueImage = [UIImage imageWithContentsOfFile:blue_bar_path];
//        
//        NSString *yellow_bar_path = [[NSBundle mainBundle]pathForResource:@"bar_yellow.png" ofType:@""];
//        UIImage *yellowImage = [UIImage imageWithContentsOfFile:yellow_bar_path];
//        
//        NSString *gray_bar_path = [[NSBundle mainBundle]pathForResource:@"bar_gray.png" ofType:@""];
//        UIImage *grayImage = [UIImage imageWithContentsOfFile:gray_bar_path];
//        
//        gray_bar = [[UIImageView alloc] initWithFrame:CGRectMake(65, 628, 939, 9)];
//        [gray_bar setImage:grayImage];
//        grayImage = nil;
//        [self.view addSubview:gray_bar];
//        
//        yellow_bar = [[UIImageView alloc] initWithFrame:CGRectMake(65, 628,0, 9)];
//        [yellow_bar setImage:yellowImage];
//        yellowImage = nil;
//        [self.view addSubview:yellow_bar];
//        
//        blue_bar = [[UIImageView alloc] initWithFrame:CGRectMake(65, 628,0, 9)];
//        [blue_bar setImage:blueImage];
//        blueImage = nil;
//        [self.view addSubview:blue_bar];
//    }
//    
//    [UIView animateWithDuration:0.7f
//                          delay:0.0f
//                        options:UIViewAnimationOptionTransitionFlipFromLeft
//                     animations:^{
//                   
//                         
//                         
//                         CGRect newFrame = blue_bar.frame;
//                        newFrame.size.width = otherWidth;
//                         blue_bar.frame = newFrame;
//                         
//                        CGRect newFrame1 = yellow_bar.frame;
//                         newFrame1.size.width = thisWidth;
//                         yellow_bar.frame = newFrame1;
//                         
//                     }
//                     completion:^(BOOL finished) {
//                         
//                         
//                         
//                     }
//     ];
    
}

- (IBAction)planSelectCloseAction:(id)sender {
    [self mapBackAction:nil];
    [_downloadSelectView removeFromSuperview];
    _downloadSelectView = nil;
    [self.planSelectView removeFromSuperview];
}
- (IBAction)mapBackAction:(id)sender {
    [imageMapView removeFromSuperview];
    imageMapView.image = nil;
    imageMapView = nil;
    [self.mapView removeFromSuperview];
}

- (IBAction)mapPreviewAction:(id)sender {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:self.mapScrollView.center];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.tag = 134;
    [self.mapScrollView addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(previewMapMethod:) object:activityIndicator];
    [thread start];
   
    
    
}
-(void)previewMapMethod:(UIActivityIndicatorView *)sender{
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *furl = [NSString stringWithFormat:@"%@/%@",documentsDirectory,mapName];
    UIImage *image = [UIImage imageWithContentsOfFile:furl];
    
    //810,570
    int width = 810;
    int height = 810*image.size.height/570;
    if(height>570){
        
        height = 570;
        width = 570*image.size.width/810;
    }
    
    if(!imageMapView){
    imageMapView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.mapScrollView addSubview:imageMapView];
    }

    imageMapView.frame = CGRectMake(0, 0, width, height);
    self.mapScrollView.contentSize = self.mapScrollView.frame.size;
    
    [imageMapView setImage:image];
    [imageMapView setCenter:self.mapScrollView.center];
    
    self.mapScrollView.minimumZoomScale = 0.5;
    self.mapScrollView.maximumZoomScale = 3.0;
    self.mapScrollView.delegate = self;
    
    [self.planSelectMainView addSubview:self.mapView];
    
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

- (IBAction)settingAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addSettingView" object:sender];

}

- (IBAction)accountAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLogin" object:nil];

}

- (IBAction)searchAction:(id)sender {
    
    float alpha = self.searchBorder.alpha;
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         if(alpha ==0){
                             self.searchBorder.alpha = 1;
                             self.searchText.hidden = false;
                             [self.searchText becomeFirstResponder];
                         }
                         else{
                             
                             self.searchBorder.alpha = 0;
                             self.searchText.hidden = true;
                             self.searchText.text = @"";
                             [self.searchText resignFirstResponder];
                             
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         
                         if(alpha !=0)
                             [self orderByDownloadTime:loginInfo.dataFromPlanTable];

                     }
     ];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(self.searchText.text.length>0){
        
        NSArray *keys = [loginInfo.dataFromPlanTable allKeys];
        NSMutableDictionary *dataArgs = [[NSMutableDictionary alloc] init];
        
        for (int i = 0;i<keys.count;i++) {
            
            NSDictionary *temp = [loginInfo.dataFromPlanTable objectForKey:keys[i]];
            NSString *name = [temp objectForKey:@"housesName"];
           
            if ([name rangeOfString:self.searchText.text options:NSCaseInsensitiveSearch].location != NSNotFound) {
            
                [dataArgs setValue:temp forKey:keys[i]];
            }
        }
        
        if(dataArgs.count>0)
            
              [self orderByDownloadTime:dataArgs];
        
        else{
        
            [globalContext showAlertView:@"检索结果为0"];
        }
    }
    else{
    
        [self orderByDownloadTime:loginInfo.dataFromPlanTable];
    }
    
    return  [self.searchText resignFirstResponder];
}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    
    self.searchText.text = @"";
    
   [self orderByDownloadTime:loginInfo.dataFromPlanTable];
    
    return [self.searchText resignFirstResponder];
}
- (IBAction)topCancelAction:(id)sender {
    
    [isEditArray removeAllObjects];
    [allSelect removeAllObjects];
    
    NSString *topDeleteStr = [NSString stringWithFormat:@"已选择%d套方案",[allSelect count]];
    [self.deleteTitleLabel setText:topDeleteStr];
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         self.deleteBackView.frame = CGRectMake(0, -44, 1024,44);
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
    
    for(UIView *view in headerArray){
        NSArray *subViews = [view subviews];
        
        for (UIView *subView in subViews) {
            if([subView isKindOfClass:[UIButton class]]){
                UIButton *temp = (UIButton *)subView;
                [temp setTitle:@"选择" forState:UIControlStateNormal];
                break;
            }
        }
    }
    
    NSArray *allKeys = [buttonDictionary allKeys];
    for (NSString *key in allKeys) {
        NSArray *buttonArray = [buttonDictionary objectForKey:key];
        for (UIButton *button in buttonArray) {
            
            [button setImage:unselectImg forState:UIControlStateNormal];
            [button setHidden:true];
            
        }
    }
}

- (IBAction)backIconAction:(id)sender {
    
      [self backMethod];
}
@end
