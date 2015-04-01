//
//  housesListView.m
//  brandv1.2
//
//  Created by Apple on 14-11-12.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "housesListDetail.h"
#import "UIImageView+AFNetworking.h"
#import "Define.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"
#import "globalContext.h"

@implementation housesListDetail

@synthesize housesListDetailAllData;
UITableView *housesListTable ;
NSMutableArray *housesListDetailData;
LoginInfo *loginInfo;
int housesListDetailPageIndex = 0;

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
    loginInfo.housesListSearch = @"";
    housesListDetailAllData = [[NSMutableArray alloc] init];
    
    housesListTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,self.frame.size.height)];
    
    housesListTable.delegate = self;
    housesListTable.dataSource = self;
    [housesListTable setBackgroundColor:[UIColor clearColor]];
    housesListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - housesListTable.bounds.size.height, self.frame.size.width,housesListTable.bounds.size.height)];
		view.delegate = self;
		[housesListTable addSubview:view];
		_refreshHeaderView = view;
		view = nil;
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    
    [self addSubview: housesListTable];
    
    [_refreshHeaderView egoRefreshStartLoading:housesListTable];
    
    NSString *loading = [[NSBundle mainBundle]pathForResource:@"loading2.jpg" ofType:@""];
    UIImage *loadingImage = [UIImage imageWithContentsOfFile:loading];
    UIImageView *imageLoading = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, housesListTable.frame.size.width, housesListTable.frame.size.height)];
    imageLoading.tag =456;
    [imageLoading setImage:loadingImage];
    [housesListTable addSubview:imageLoading];
    
    [self getMessageList:@"1"];
}
-(void)configView:(NSMutableArray *)allData{
    
    //  [table removeFromSuperview];
    housesListDetailData = [[NSMutableArray alloc] initWithObjects:nil];
    
    housesListDetailAllData = allData;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    int x = 0;
    int y = 0;
    int row = 0;
    
    // int eachViewHeight = uiView.frame.size.height/2-10;
    int  eachViewWidth  = (self.frame.size.width -51)/4;
    int eachViewHeight = eachViewWidth+63;
    
    UIView *uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2+20)];
    [uiView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
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
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2+20)];
            [tempView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            
            [housesListDetailData addObject:tempView];
            row++;
            
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x*(eachViewWidth+16),y*(eachViewHeight+17), eachViewWidth, eachViewHeight)];
        
        //  [view setBackgroundColor:UIColorFromRGB(0xdddddd)];
        [view setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView * imageView =[[UIImageView alloc] init];
        imageView.frame = CGRectMake(10, 10, eachViewWidth-20,eachViewWidth-20);
        
        // NSString *path = [imageUrl stringByAppendingString:[temp objectForKey:@"image"]];
        
        NSString *path  = [NSString stringWithFormat:@"%@%@%@",imageUrl,[temp objectForKey:@"mapURL"],@"_300X300"];
        NSURL *url = [NSURL URLWithString:path];
        [imageView setImageWithURL:url size:CGSizeMake(eachViewWidth-20,eachViewHeight*0.8)];
        
        
        [view addSubview:imageView];
        
        imageView.userInteractionEnabled = YES;
        //  imageView.tag =[[temp objectForKey:@"id"] intValue];
        imageView.tag =i;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onHousesListTap:)]];
        
        UILabel *housesName =[[UILabel alloc] initWithFrame:CGRectMake(11,eachViewWidth-4, (eachViewWidth-20)/2,25)];
        housesName.font=[UIFont fontWithName:@"MicrosoftYaHei" size:15];
        [housesName setTextColor:UIColorFromRGB(0x191919)];
        
        
        UILabel *type =[[UILabel alloc] initWithFrame:CGRectMake((eachViewWidth-20)/2+8,eachViewWidth+30,(eachViewWidth-20)*0.3,20)];
        type.font=[UIFont fontWithName:@"MicrosoftYaHei" size:13];
        [type setTextColor:UIColorFromRGB(0xa4a4a4)];
        
        UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake(11,eachViewWidth+30,(eachViewWidth-20)/2,20)];
        name.font=[UIFont fontWithName:@"MicrosoftYaHei" size:13];
        [name setTextColor:UIColorFromRGB(0xa4a4a4)];
        
        UILabel *size =[[UILabel alloc] initWithFrame:CGRectMake((eachViewWidth-20)*0.81,eachViewWidth+30,(eachViewWidth-20)/2,20)];
        size.font=[UIFont fontWithName:@"MicrosoftYaHei" size:13];
        [size setTextColor:UIColorFromRGB(0xa4a4a4)];
        
        UILabel *count =[[UILabel alloc] initWithFrame:CGRectMake((eachViewWidth-20)/2+5,eachViewWidth-4,(eachViewWidth-20)/2,25)];
        count.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
        [count setTextColor:UIColorFromRGB(0xff553e)];
        [count setTextAlignment:NSTextAlignmentRight];
        
        NSString *priceText = [NSString stringWithFormat:@"%@个房间" ,[temp objectForKey:@"count"]];
        
        
        
        [count setText:priceText];
        // [price setTextColor:UIColorFromRGB(0xa4a4a4)];
        
        
        [name setText:[temp objectForKey:@"name"]];
        [type setText:[temp objectForKey:@"type"]];
        [size setText:[temp objectForKey:@"size"]];
        [housesName setText:[temp objectForKey:@"housesName"]];
        [type setBackgroundColor:[UIColor clearColor]];
        [housesName setBackgroundColor:[UIColor clearColor]];
        [count setBackgroundColor:[UIColor clearColor]];
        [view addSubview:housesName];
        housesName = nil;
        [view addSubview:type];
        type = nil;
        [view addSubview:count];
        count = nil;
        [view addSubview:name];
        name =  nil;
        [view addSubview:size];
        size =  nil;
        
        // [uiView addSubview:view];
        
        
        
        [housesListDetailData[row] addSubview:view];
        
        x++;
        
    }
    
    loginInfo.housesListDetailViewData = [housesListDetailData copy];
    
    [housesListTable reloadData];
    
    
    
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
    
    UIView *view = loginInfo.housesViewData[indexPath.row];
    
    NSArray *allViews = [view subviews];
    
    if(allViews.count<=4){
        
        return view.frame.size.height/2;
        
    }
    else{
        
        return view.frame.size.height;
    }
    
    
    return view.frame.size.height;
    // return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    if(indexPath.row<= loginInfo.housesViewData.count-1)
    {
        [cell.contentView addSubview:loginInfo.housesViewData[indexPath.row]];
    }
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

- (void)onHousesListTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
    NSLog(@"%ld",(long)view.tag);
    
    CGPoint point = [gestureRecognizer locationInView:self.superview];
    
    CGRect ptGlobal = [view.superview convertRect:view.frame toView:nil];
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObject:[NSNumber numberWithInt:view.tag]];     //1
    [data addObject:housesListDetailAllData[view.tag]];           //2
    [data addObject:[NSNumber numberWithInt:point.x]];   //3    X
    [data addObject:[NSNumber numberWithInt:point.y]];   //4    Y
    [data addObject:[NSNumber numberWithInt:ptGlobal.size.width]];   //5    width
    [data addObject:[NSNumber numberWithInt:ptGlobal.size.height]];   //6   height
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHousesListDetail" object:data];
    
    //    for(NSDictionary *temp in housesListAllData){
    //        if([[temp objectForKey:@"id"] intValue] == view.tag){
    //
    //            [data addObject:temp];
    //            [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHousesListDetail" object:data];
    //            break;
    //        }
    //    }
    
    
    
    
}

-(void)getMessageList:(id)sender{
    
    NSString *reload = sender;
    
    if([reload isEqualToString:@"1"]){
        
        housesListDetailPageIndex = 0;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSNumber *pageIndexNSNumber = [NSNumber numberWithInt:housesListDetailPageIndex];
    NSNumber *pageCountNSNumber = [NSNumber numberWithInt:8];
    
    NSDictionary *parameters = @{@"pageIndex":pageIndexNSNumber,@"pageCount":pageCountNSNumber,@"search":loginInfo.housesListSearch};
    
    // getDownloadHousesListApi
    //  getHousesListApi
    
    [manager POST:[BASEURL stringByAppendingString: getDownloadHousesListApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        [[housesListTable viewWithTag:456] removeFromSuperview];
        
        NSDictionary *rootArray = responseObject;
        
        if([reload isEqualToString:@"1"]){
            
            housesListDetailAllData = [[NSMutableArray alloc] init];
            
        }
        else{
            
            [self doneLoadMoreData];
        }
        NSArray *singal = [rootArray objectForKey:@"data"];
        
        if([singal isKindOfClass:[NSArray class]]){
            
            [housesListDetailAllData addObjectsFromArray:singal];
            
            [self configView:housesListDetailAllData];
            
            housesListDetailPageIndex++;
            
            NSNumber  *totalCount = [rootArray objectForKey:@"totalCount"];
            if([totalCount isKindOfClass:[NSNumber class]]){
                if([totalCount intValue] >0){
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"housesListUpdateTotalCount" object:totalCount];
                    
                }
                else {
                    
                    [globalContext showAlertView:@"没有此类户型列表"];
                }
            }
            
        }
        
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        if([reload isEqualToString:@"1"]){
            
            [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
        }
        else{
            
            [self doneLoadMoreData];
        }
        
    }];
    
    
}

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    housesListDetailPageIndex = 0;
    [self getMessageList:@"1"];
    
	_reloading = YES;
	
}
-(void)initHousesIndex:(id)sender{
    
    housesListDetailPageIndex = 0;
    
}
- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:housesListTable];
	
}

- (void)doneLoadMoreData{
	
	//  model should call this when its done loading
	[_refreshHeaderView egoRefreshScrollViewDataSourceLoadMoreDidFinished:housesListTable];
	
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
	
    [self getMessageList:@"0"];
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
    
    _refreshHeaderView = nil;
}
@end
