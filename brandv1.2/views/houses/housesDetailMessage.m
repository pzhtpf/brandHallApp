//
//  housesDetailMessage.m
//  brandv1.2
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "housesDetailMessage.h"
#import "UIImageView+AFNetworking.h"
#import "Define.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"

@implementation housesDetailMessage
@synthesize housesId;
@synthesize housesTypeValue;
@synthesize housesName;
@synthesize allIndexArray;
NSArray *productImg;
NSMutableArray *productImgs;
LoginInfo *loginInfo;
NSMutableArray *detailAllData;
NSDictionary *mapData;
NSMutableArray *allTableArray;
NSMutableArray *allTableOfViewArray;
NSMutableArray *refreshTableHeaderViewArray;

NSArray *allHuXing;
NSArray *mapArray;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        
    }
    return self;
}
-(void)initView{
    
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    detailAllData = [[NSMutableArray alloc] init];
    
    [self setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
   
}
-(void)setHousesId:(NSString *)housesIdParams housesName:(NSString *)housesNameParams{

    housesId = housesIdParams;
    
    housesName = housesNameParams;
    
///   [self getMessageList:@"1"];
 ///   [self getAllMessageList:nil];


}
-(void)setHousesType:(NSArray *)housesTypeParams housesId:(NSString *)housesIdParams housesName:(NSString *)housesNameParams mainScrollView:(UIScrollView *)mainScrollView{

    
    loginInfo.houseSearch = housesTypeValue;
    
    housesId = housesIdParams;
    
    housesName = housesNameParams;
    
    detailAllData = [[NSMutableArray alloc] initWithObjects:housesTypeParams, nil];
    
    mapArray = housesTypeParams;
    
    [self getAllMessageList:mainScrollView mapArray:housesTypeParams];

    
}
-(void)configView:(NSMutableArray *)allData index:(int) index{
   
    NSMutableArray *singalDetailData = allTableOfViewArray[index];
    productImgs = [[NSMutableArray alloc] initWithObjects:nil];
    
    int x = 0;
    int y = 0;
    
    // int eachViewHeight = uiView.frame.size.height/2-10;
    int  eachViewWidth  = 168;
    int eachViewHeight = 183;
    
    UIView *uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2+10)];
    [uiView setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
    [singalDetailData addObject:uiView];
    
    productImgs = allData;
    
    
    for(int i=1;i<allData.count;i++){
        
        NSDictionary *temp =allData[i];
        
        if(i!=1 &&i%2==1){
            y++;
            x=0;
        }
        
        if(i!=1 &&i%4==1){
            x=0;
            y=0;
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2+10)];
            [tempView setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
            
            [singalDetailData addObject:tempView];
            
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20+x*(eachViewWidth+15),10+y*(eachViewHeight+4), eachViewWidth, eachViewHeight)];
        [view setBackgroundColor:[UIColor clearColor]];
        
        UIImageView * imageView =[[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, eachViewWidth,126);
        
      //  NSLog(@"%@",temp);
        
      //  NSString *path = [imageUrl stringByAppendingString:[temp objectForKey:@"image"]];
        
        NSString *path  = [NSString stringWithFormat:@"%@%@_300X200",imageUrl,[temp objectForKey:@"image"]];
//        NSArray *names = [path componentsSeparatedByString:@"."];
//        path = [NSString stringWithFormat:@"%@_thumb.%@",path,names[names.count-1]];
        
        NSURL *url = [NSURL URLWithString:path];
        [imageView setCenterImageWithURL:url size:imageView.frame.size];

        [view addSubview:imageView];
        
        
        UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake(0,130,eachViewWidth/2,20)];
        name.font=[UIFont fontWithName:@"MicrosoftYaHei" size:10.0f];
        [name setTextColor:UIColorFromRGB(0x2b2b2b)];
        
   
            if([[temp objectForKey:@"rooms"] integerValue]>0){
                UIImage *image =[UIImage imageNamed:@"LOGOhuxing.png"];
                UIImageView * imageView =[[UIImageView alloc] initWithImage:image];
                imageView.frame = CGRectMake(0,0,40,40);
                [view addSubview:imageView];
            }
            
            NSString *sizeString = [temp objectForKey:@"size"];
            if(![sizeString isKindOfClass:[NSNull class]]){
                if(sizeString.length ==0 || [sizeString isEqualToString:@"<null>"]){
                    sizeString = @"面积未知";
                    
                }
            }
            else{
            
              sizeString = @"面积未知";
            }
            
            
            NSString *styleString = [temp objectForKey:@"style"];
            if(![styleString isKindOfClass:[NSNull class]]){
                if(styleString.length ==0 || [styleString isEqualToString:@"<null>"]){
                    styleString = @"样式未知";
                    
                }
            }
            else{
            
                styleString = @"样式未知";
            }
            
            NSString *sizeAndStyle = [NSString stringWithFormat:@"%@m²    %@" ,sizeString,styleString];
            UILabel *sizeAndstyle =[[UILabel alloc] initWithFrame:CGRectMake(eachViewWidth/2+2,134, (eachViewWidth-20)/2-2,20)];
            sizeAndstyle.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
            [sizeAndstyle setTextColor:UIColorFromRGB(0x2b2b2b)];
            [sizeAndstyle setText:sizeAndStyle];
            
        //    [view addSubview:sizeAndstyle];
        //    sizeAndstyle = nil;
            
            imageView.userInteractionEnabled = YES;
            imageView.tag =[[temp objectForKey:@"id"] intValue];
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProductTap:)]];
          
             [name setText:[temp objectForKey:@"name"]];
            
//            NSString *descriptionString = [temp objectForKey:@"description"];
//              if(![descriptionString isKindOfClass:[NSNull class]]){
//                  if(descriptionString.length ==0){
//                    descriptionString = @"描述未知";
//                  
//                  }
//                  
//             [description setText:descriptionString];
//              }
        
            NSString *buildNameString =[temp objectForKey:@"bulidName"];
            
            if(![buildNameString isKindOfClass:[NSNull class]]){
            UILabel *buildName =[[UILabel alloc] initWithFrame:CGRectMake(0,150, eachViewWidth,15)];
            buildName.font=[UIFont fontWithName:@"MicrosoftYaHei" size:10.0f];
            [buildName setTextColor:UIColorFromRGB(0x2b2b2b)];
            [buildName setText:[temp objectForKey:@"bulidName"]];
           [view addSubview:buildName];
            buildName = nil;
            }
            
            NSString *createTimeString =[temp objectForKey:@"create_time"];
            
            if(![createTimeString isKindOfClass:[NSNull class]]){
            
            UILabel *createTime =[[UILabel alloc] initWithFrame:CGRectMake(eachViewWidth/2+2,155, eachViewWidth/2-20,15)];
            createTime.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
            
            
           NSDate *dateTime = [NSDate  dateWithTimeIntervalSince1970:[createTimeString longLongValue]];
                
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            [formatter setDateFormat:@"yyyy/MM/dd"];
            
           [createTime setText:[formatter stringFromDate:dateTime]];
            
          
         //   [view addSubview:createTime];
         //   createTime = nil;
            }
     //   }
       
       [view addSubview:name];
        name = nil;
     //   [view addSubview:description];
     //   description = nil;
        
        [singalDetailData[singalDetailData.count-1] addSubview:view];
        
        x++;
        
    }
    
    [allTableArray[index] reloadData];
    
    
    
}
-(void)addMapView:(NSDictionary *)data index:(int) index{

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,390,300)];
    [view setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20,0, 350, 262)];
    
    NSString *path  = [NSString stringWithFormat:@"%@%@",imageUrl,[data objectForKey:@"image"]];
    NSArray *names = [path componentsSeparatedByString:@"."];
    path = [NSString stringWithFormat:@"%@_thumb.%@",path,names[names.count-1]];
    
    NSURL *url = [NSURL URLWithString:path];
    [imageView setCenterImageWithURL:url size:imageView.frame.size];
    
    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(20,270,350,20)];
    info.textColor = UIColorFromRGB(0x2b2b2b);
    info.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
    
    mapData = data;
    
    NSString *infoString = [NSString stringWithFormat:@"%@ %@ %@m²",housesName,[data objectForKey:@"include"],[data objectForKey:@"size"]];
    
    info.textAlignment = NSTextAlignmentCenter;
    
    [info setText:infoString];
    
    [view addSubview:imageView];
    [view addSubview:info];
    
    [allTableOfViewArray[index] addObject:view];
    
    

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [allTableOfViewArray[tableView.tag] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row ==0 ){
    
        return 300;
    }
    
    else{
    
    UIView *view = allTableOfViewArray[tableView.tag][indexPath.row];
    
    NSArray *allViews = [view subviews];
    
    if(allViews.count<=2){
    
        return view.frame.size.height/2;

    }
    else{
        
        return view.frame.size.height;
    }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    [cell.contentView addSubview:allTableOfViewArray[tableView.tag][indexPath.row]];
    // cell.textLabel.text = @"weff";
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)onProductTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
  //  NSLog(@"%ld",(long)view.tag);
    
    loginInfo.collocationType = 2;
    
    loginInfo.isOfflineMode = false;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHousesTestDetail" object:[NSNumber numberWithLong:view.tag]];

}

-(void)getAllMessageList:(UIScrollView *)sender mapArray:(NSArray *)mapArray{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSNumber *pageIndexNSNumber = [NSNumber numberWithInt:0];
    NSNumber *pageCountNSNumber = [NSNumber numberWithInt:4];
    
    NSDictionary *parameters = @{@"id":housesId,@"pageIndex":pageIndexNSNumber,@"pageCount":pageCountNSNumber,@"housesType":@""};
    
    [manager POST:[BASEURL stringByAppendingString: getHousesDetailApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
     //   NSLog(@"JSON: %@", responseObject);
        
        allTableArray = [[NSMutableArray alloc] init];
        allTableOfViewArray = [[NSMutableArray alloc] init];
        refreshTableHeaderViewArray = [[NSMutableArray alloc] init];
        allIndexArray = [[NSMutableArray alloc] init];
        
        NSArray *rootArray = responseObject;
        allHuXing = responseObject;
        
        for (int i = 0; i<rootArray.count; i++) {
            
            NSMutableArray *singalViewArray = [[NSMutableArray alloc] init];
            
            [allTableOfViewArray addObject:singalViewArray];
            
            [allIndexArray addObject:[NSNumber numberWithInt:1]];
            
            NSDictionary *tempDictionary = rootArray[i];
            
            NSArray *tempArray = [tempDictionary objectForKey:@"data"];
            
            UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake(i*391,20,390,self.frame.size.height-25)];
            tempTableView.delegate = self;
            tempTableView.dataSource = self;
            [tempTableView setBackgroundColor:[UIColor clearColor]];
            tempTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tempTableView.tag = i;
            
            
            EGORefreshTableHeaderView *eGORefreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f-tempTableView.bounds.size.height,390,tempTableView.bounds.size.height)];
            eGORefreshTableHeaderView.delegate = self;
            [eGORefreshTableHeaderView refreshLastUpdatedDate];
            eGORefreshTableHeaderView.tag = i;
            [tempTableView addSubview:eGORefreshTableHeaderView];
            
            [refreshTableHeaderViewArray addObject:eGORefreshTableHeaderView];
            
            [self addSubview:tempTableView];
            
            UILabel *rightLine = [[UILabel alloc] initWithFrame:CGRectMake((i+1)*390,20,1, self.frame.size.height-25)];
            [rightLine setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
            [self addSubview:rightLine];
            
            [allTableArray addObject:tempTableView];
            
            NSMutableArray *tempMutableArray = [tempArray mutableCopy];
            [tempMutableArray insertObject:mapArray[i] atIndex:0];
            
            [self addMapView:mapArray[i] index:i];
            
            [self configView:tempMutableArray index:i];
        }
        
        if(sender)
            sender.contentSize = CGSizeMake((rootArray.count+1)*390, 0);
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,(rootArray.count+1)*390, self.frame.size.height);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
    }];
    
    
}


-(void)getMessageList:(id)sender index:(int)index{
    
    NSString *reload = sender;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSNumber *pageIndexNSNumber = allIndexArray[index];
    NSNumber *pageCountNSNumber = [NSNumber numberWithInt:4];
    
    NSDictionary *temp = allHuXing[index];
    
    NSString *housesType = [temp objectForKey:@"houseType"];

    NSDictionary *parameters = @{@"id":housesId,@"pageIndex":pageIndexNSNumber,@"pageCount":pageCountNSNumber,@"housesType":housesType};
    
    [manager POST:[BASEURL stringByAppendingString: getHousesDetailApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //    NSLog(@"JSON: %@", responseObject);
        
        NSMutableArray *rootArray = [responseObject mutableCopy];
        
        if([reload isEqualToString:@"1"]){
            
            [rootArray insertObject:mapArray[index] atIndex:0];
            NSMutableArray *tempTableOfView = allTableOfViewArray[index];
            [tempTableOfView removeAllObjects];
            
            [self addMapView:mapArray[index] index:index];
        }
        else{
            
            [self doneLoadMoreData:index];
        }
        
        
        if(rootArray.count>0){
        
        [self configView:rootArray index:index];
        
        int pageIndex = [pageIndexNSNumber intValue];
        pageIndex++;
        allIndexArray[index] = [NSNumber numberWithInt:pageIndex];
        }
       
        [self doneLoadingTableViewData:index];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
           [self doneLoadingTableViewData:index];

    }];
    
    
}

- (void)reloadTableViewDataSource:(int)index{
    
    allIndexArray[index] = [NSNumber numberWithInt:0];
	
   [self getMessageList:@"1" index:index];
    
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData:(int)index{
	
	//  model should call this when its done loading
	_reloading = NO;
    
    EGORefreshTableHeaderView *_refreshHeaderView = refreshTableHeaderViewArray[index];
    UITableView *detailTable = allTableArray[index];
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:detailTable];
	
}

- (void)doneLoadMoreData:(int)index{
	
	//  model should call this when its done loading
    
    EGORefreshTableHeaderView *_refreshHeaderView = refreshTableHeaderViewArray[index];
    UITableView *detailTable = allTableArray[index];

	[_refreshHeaderView egoRefreshScrollViewDataSourceLoadMoreDidFinished:detailTable];
	
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSArray *subViews = [scrollView subviews];
    
    for (UIView *view in subViews) {
        if([view isKindOfClass:[EGORefreshTableHeaderView class]]){
            
            EGORefreshTableHeaderView *egoView = (EGORefreshTableHeaderView *)view;
            
            [egoView egoRefreshScrollViewDidScroll:scrollView];
            
            break;
        }
    }
    
}
- (void)egoRefreshTableHeaderDidTriggerLoadMore:(EGORefreshTableHeaderView*)view{
	
	  [self getMessageList:@"0" index:(int)view.tag];
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    NSArray *subViews = [scrollView subviews];
    
    for (UIView *view in subViews) {
        if([view isKindOfClass:[EGORefreshTableHeaderView class]]){
            
            EGORefreshTableHeaderView *egoView = (EGORefreshTableHeaderView *)view;
            
            [egoView egoRefreshScrollViewDidEndDragging:scrollView];
            
            break;
        }
    }
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
    [self reloadTableViewDataSource:view.tag];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
- (void)viewWillDisappear:(BOOL)animated{
    
}
@end
