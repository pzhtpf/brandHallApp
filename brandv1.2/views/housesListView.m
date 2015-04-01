
//  housesListView.m
//  brandv1.2
//
//  Created by Apple on 14-11-12.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "housesListView.h"
#import "UIImageView+AFNetworking.h"
#import "Define.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"
#import "globalContext.h"

@implementation housesListView

@synthesize housesListAllData;
@synthesize housesListTable;
NSMutableArray *housesListData;
LoginInfo *loginInfo;
int housesListPageIndex = 0;
int row = 0;
NSMutableDictionary *allTempView;

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
    housesListAllData = [[NSMutableArray alloc] init];
    
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
    
  
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:@"updateView" object:nil];
    
    
    if(loginInfo.housesType==1 || loginInfo.housesType==3)
        loginInfo.downloadType =3;
    
    else if(loginInfo.housesType==2)
        loginInfo.downloadType =1;
    
    [self changeTypeReload];
}
-(void)changeTypeReload{
    
    housesListAllData =  [[NSMutableArray alloc] initWithObjects:nil];

    housesListData = [[NSMutableArray alloc] initWithObjects:nil];
    allTempView = [[NSMutableDictionary alloc] init];

    
    loginInfo.downloadListViewData = [[NSMutableArray alloc] init];
    
    [housesListTable reloadData];
//    [_refreshHeaderView egoRefreshStartLoading:housesListTable];
    
    if(![housesListTable viewWithTag:456]){
    NSString *loading = [[NSBundle mainBundle]pathForResource:@"gezlife.png" ofType:@""];
    UIImage *loadingImage = [UIImage imageWithContentsOfFile:loading];
    UIImageView *imageLoading = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,367,86)];
    imageLoading.tag =456;
    [imageLoading setImage:loadingImage];
    [imageLoading setCenter:housesListTable.center];
    [housesListTable addSubview:imageLoading];
    }
    
    //    type   ＝ 1           1，只拥有户型列表
    //    2，只拥有经典样板间
    //    3，两者都拥有
    //    4，两者都没有

        
    [self getMessageList:@"1"];
}
-(void)updateView:(NSNotification *)notification{

    if(allTempView){
    
        NSArray *keys = [allTempView allKeys];
        for (NSString *id in keys) {
            NSDictionary *temp9 = [loginInfo.dataFromPlanTable objectForKey:id];
            NSString *downloadStatusStr = @"";
            NSDictionary *data2 = nil;
            if(temp9){
                NSArray *data1= [temp9 objectForKey:@"data"];
                data2 = data1[0];
                int status = [[data1[0] objectForKey:@"status"] integerValue];
                switch (status) {
                    case 0:
                        downloadStatusStr = @"暂停中...";
                        
                        break;
                    case 1:
                        downloadStatusStr = @"排队中...";
                        break;
                    case 2:
                        downloadStatusStr = @"下载中...";
                        break;
                    case 3:
                        downloadStatusStr = @"已下载";
                        break;
                    default:
                        break;
                }
                
                }
            
                
                UIView *label = [allTempView objectForKey:id];
                
                NSArray *tempArray = [[NSArray alloc] initWithObjects:label,downloadStatusStr,data2, nil];
                
                [self performSelectorInBackground:@selector(updateabel:) withObject:tempArray];
          
        }
    
    }
    
}
-(void)updateabel:(NSArray *)tempArray{
    UIView *view = tempArray[0];
    UILabel *label = (UILabel *)[view viewWithTag:-1];
    NSString *str = tempArray[1];
   [label setText:str];
    
    if([view viewWithTag:-2]&& tempArray.count>2){
       NSDictionary *temp8 = tempArray[2];
        if(temp8){
        int nowVersion = [[temp8 objectForKey:@"nowVersion"] integerValue];
        int latestVersion = [[temp8 objectForKey:@"latestVersion"] integerValue];
        if(nowVersion == latestVersion)
            [[view viewWithTag:-2] removeFromSuperview];
        }
    }
    

}
-(void)configView:(NSMutableArray *)allData{
    
    //  [table removeFromSuperview];
    if(!housesListData)
    housesListData = [[NSMutableArray alloc] initWithObjects:nil];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    int x = 0;
    int y = 0;
    
    // int eachViewHeight = uiView.frame.size.height/2-10;
    int  eachViewWidth  = (self.frame.size.width -51)/4;
    int eachViewHeight = eachViewWidth+63;
    
    UIView *uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2+20)];
    [uiView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [housesListData addObject:uiView];
    
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
            
            [housesListData addObject:tempView];
            
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x*(eachViewWidth+16),y*(eachViewHeight+17), eachViewWidth, eachViewHeight)];
        
      //  [view setBackgroundColor:UIColorFromRGB(0xdddddd)];
        [view setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView * imageView =[[UIImageView alloc] init];
        imageView.frame = CGRectMake(10, 10, eachViewWidth-20,eachViewWidth-20);
        
        // NSString *path = [imageUrl stringByAppendingString:[temp objectForKey:@"image"]];
        
        NSString *path  = [NSString stringWithFormat:@"%@%@%@",imageUrl,[temp objectForKey:@"mapURL"],@"_300X300"];
        NSURL *url = [NSURL URLWithString:path];
        [imageView setCenterImageWithURL:url size:CGSizeMake(eachViewWidth-20,eachViewWidth-20)];
        
        
        [view addSubview:imageView];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame: CGRectMake(0,eachViewWidth-9, eachViewWidth,1)];
        [lineLabel setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
        [view addSubview:lineLabel];
        
        
        imageView.userInteractionEnabled = YES;
        imageView.tag =[[temp objectForKey:@"id"] intValue];
      //  imageView.tag =(housesListData.count-1)*8+i;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onHousesListTap:)]];
        
        UILabel *housesName =[[UILabel alloc] initWithFrame:CGRectMake(11,eachViewWidth-5, (eachViewWidth-20)/2,20)];
        housesName.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [housesName setTextColor:UIColorFromRGB(0x2B2B2B)];
        
        
        UILabel *type =[[UILabel alloc] initWithFrame:CGRectMake(11,eachViewWidth+15,(eachViewWidth-20)*0.78,20)];
        type.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [type setTextColor:UIColorFromRGB(0x2B2B2B)];
        
        UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake((eachViewWidth)/2+5,eachViewWidth-5,(eachViewWidth-20)/2,20)];
        name.font=[UIFont fontWithName:@"MicrosoftYaHei" size:13];
        [name setTextColor:UIColorFromRGB(0x2B2B2B)];
        
        UILabel *size =[[UILabel alloc] initWithFrame:CGRectMake((eachViewWidth-20)*0.81,eachViewWidth+15,(eachViewWidth-20)/2,20)];
        size.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [size setTextColor:UIColorFromRGB(0x2B2B2B)];
        
        UILabel *count =[[UILabel alloc] initWithFrame:CGRectMake(11,eachViewWidth+35,(eachViewWidth-20)/2,25)];
        count.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [count setTextColor:UIColorFromRGB(0xff553e)];
        [count setTextAlignment:NSTextAlignmentLeft];
        
        NSString *countString = [temp objectForKey:@"count"];
        NSString *priceText = [NSString stringWithFormat:@"%@个房间" ,countString];
        
        
        
        [count setText:priceText];
        // [price setTextColor:UIColorFromRGB(0xa4a4a4)];
        
        
        [name setText:[temp objectForKey:@"name"]];
        [type setText:[temp objectForKey:@"type"]];
        [size setText:[NSString stringWithFormat:@"%@m²",[temp objectForKey:@"size"]]];
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
        
    
        [allTempView setValue:view forKey:[temp objectForKey:@"id"]];

        [housesListData[housesListData.count-1] addSubview:view];
        
        x++;
        
    }
    
    loginInfo.downloadListViewData = [housesListData copy];
    
    [housesListTable reloadData];
    
    
    
}

-(void)configClassicPlanView:(NSMutableArray *)allData{
    
    //  [table removeFromSuperview];
    
    if(!housesListData){
    housesListData = [[NSMutableArray alloc] initWithObjects:nil];
    allTempView = [[NSMutableDictionary alloc] init];
    row = 0;
    }
    
  //  housesListAllData = allData;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    int x = 0;
    int y = 0;
   // int row = 0;
    
    // int eachViewHeight = uiView.frame.size.height/2-10;
    int  eachViewWidth  = 158;
    int eachViewHeight =  190;
    
    UIView *uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2)];
    [uiView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [housesListData addObject:uiView];
    
    for(int i=0;i<allData.count;i++){
        
        NSDictionary *temp =allData[i];
        
        if(i!=0 &&i%6==0){
            y++;
            x=0;
        }
        
        if(i!=0 &&i%12==0){
            x=0;
            y=0;
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2)];
            [tempView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            
            [housesListData addObject:tempView];
            row++;
            
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x*(eachViewWidth+10),y*(eachViewHeight+10), eachViewWidth, eachViewHeight)];
        
        //  [view setBackgroundColor:UIColorFromRGB(0xdddddd)];
      //  [view setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView * imageView =[[UIImageView alloc] init];
        imageView.frame = CGRectMake(0,0, eachViewWidth,117);
        
        // NSString *path = [imageUrl stringByAppendingString:[temp objectForKey:@"image"]];
        
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        NSString *path  = [NSString stringWithFormat:@"%@%@_300X200",imageUrl,[temp objectForKey:@"imageUrl"]];
//        NSArray *names = [path componentsSeparatedByString:@"."];
//        path = [NSString stringWithFormat:@"%@_thumb.%@",path,names[names.count-1]];
        
        NSURL *url = [NSURL URLWithString:path];
        [imageView setCenterImageWithURL:url size:CGSizeMake(eachViewWidth,117)];
       // [imageView setImageWithURL:url size:CGSizeMake(eachViewWidth-20,eachViewHeight*0.7)];
        
        [view addSubview:imageView];
        
        imageView.userInteractionEnabled = YES;
        
        if(![[temp objectForKey:@"id"] isKindOfClass:[NSNull class]])
        imageView.tag =[[temp objectForKey:@"id"] intValue];
        
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onHousesClassicListTap:)]];
        
        CGSize constraint1 = CGSizeMake(2800,30);
        CGSize size1 = [[temp objectForKey:@"name"] sizeWithFont:[UIFont fontWithName:@"MicrosoftYaHei" size:13.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
        
        UILabel *housesName =[[UILabel alloc] initWithFrame:CGRectMake(0,122,size1.width,15)];
        housesName.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [housesName setTextColor:UIColorFromRGB(0x131313)];
        
        UILabel *size =[[UILabel alloc] initWithFrame:CGRectMake(0,142,158,15)];
        size.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [size setTextColor:UIColorFromRGB(0x131313)];
        
        UILabel *count =[[UILabel alloc] initWithFrame:CGRectMake(0,162,158,15)];
        count.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [count setTextColor:UIColorFromRGB(0xa6aaae)];
       // [count setTextAlignment:NSTextAlignmentRight];
        
        UILabel *downloadStatus =[[UILabel alloc] initWithFrame:CGRectMake(eachViewWidth-45,122,45,15)];
        downloadStatus.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [downloadStatus setTextColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        downloadStatus.tag = -1;
        NSString *downloadStatusStr = @"";
        
        NSDictionary *temp9 = [loginInfo.dataFromPlanTable objectForKey:[temp objectForKey:@"id"]];
        if(temp9){
            NSArray *data1= [temp9 objectForKey:@"data"];
            int status = [[data1[0] objectForKey:@"status"] integerValue];
            switch (status) {
                case 0:
                    downloadStatusStr = @"暂停中...";

                    break;
                case 1:
                    downloadStatusStr = @"排队中...";
                    break;
                case 2:
                     downloadStatusStr = @"下载中...";
                    break;
                case 3:
                     downloadStatusStr = @"已下载";
                    break;
                default:
                    break;
            }
          //  [downloadStatus setTextAlignment:NSTextAlignmentRight];
            
            
            int nowVersion = [[data1[0] objectForKey:@"nowVersion"] integerValue];
            int latestVersion = [[data1[0] objectForKey:@"latestVersion"] integerValue];
            if(nowVersion<latestVersion)     //已有更新
            {
            
                NSString *huxingPath = [[NSBundle mainBundle]pathForResource:@"new.png" ofType:@""];
                UIImage *huxingPathImage = [UIImage imageWithContentsOfFile:huxingPath];
                UIImageView *updateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(eachViewWidth-35, 0,35,35)];
                [updateImageView setImage:huxingPathImage];
                updateImageView.tag = -2;
                [view addSubview:updateImageView];
            }
            
        }        
        
        [downloadStatus setText:downloadStatusStr];
        [view addSubview:downloadStatus];
        downloadStatus= nil;
        
        
        NSString *countString = [temp objectForKey:@"goodsCount"];
        NSString *countStr = [NSString stringWithFormat:@"可搭配产品：%@件" ,countString];
        
        
        [count setText:countStr];
        // [price setTextColor:UIColorFromRGB(0xa4a4a4)];
        NSMutableAttributedString *text =
        [[NSMutableAttributedString alloc]
         initWithAttributedString: count.attributedText];
        
        [text addAttribute:NSForegroundColorAttributeName
                     value:UIColorFromRGB(0xff553e)
                     range:NSMakeRange(6, countString.length)];
        [count setAttributedText: text];

        
        
        NSString *sizeStr = [NSString stringWithFormat:@"(%@x%@mm)",[temp objectForKey:@"length"],[temp objectForKey:@"width"]];
        
     //   [name setText:[temp objectForKey:@"name"]];
      //  [type setText:[temp objectForKey:@"type"]];
        [size setText:sizeStr];
        [housesName setText:[temp objectForKey:@"name"]];
     //   [type setBackgroundColor:[UIColor clearColor]];
        [housesName setBackgroundColor:[UIColor clearColor]];
        [count setBackgroundColor:[UIColor clearColor]];
        [view addSubview:housesName];
        housesName = nil;
    //    [view addSubview:type];
     //   type = nil;
        [view addSubview:count];
        count = nil;
    //    [view addSubview:name];
   //     name =  nil;
        [view addSubview:size];
        size =  nil;
        
        // [uiView addSubview:view];
        
        [allTempView setValue:view forKey:[temp objectForKey:@"id"]];
        
        [housesListData[housesListData.count-1] addSubview:view];
        
        x++;
        
    }
    
    loginInfo.downloadListViewData = [housesListData copy];
    
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
    return [loginInfo.downloadListViewData count];
    // return 34;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIView *view = loginInfo.downloadListViewData[indexPath.row];
    
    NSArray *allViews = [view subviews];
    
    if(loginInfo.downloadType ==3){
    
    if(allViews.count<=4){
        
        return view.frame.size.height/2+15;
        
    }
    else{
        
        return view.frame.size.height+15;
    }
    
    }
    else{
    
        if(allViews.count<=6){
            
            return view.frame.size.height/2+20;
            
        }
        else{
            
            return view.frame.size.height+20;
        }
    
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    if(indexPath.row<= loginInfo.downloadListViewData.count-1)
    {
        [cell.contentView addSubview:loginInfo.downloadListViewData[indexPath.row]];
    }
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

- (void)onHousesListTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
 //   NSLog(@"%ld",(long)view.tag);
    
    CGPoint point = [gestureRecognizer locationInView:self.superview];
    
    CGRect ptGlobal = [view.superview convertRect:view.frame toView:nil];
    
    NSDictionary *temp = [[NSDictionary alloc] init];
    for ( NSDictionary *temp1 in housesListAllData) {
        int tempPlanId = [[temp1 objectForKey:@"id"] intValue];
        if(tempPlanId == view.tag){
            temp = temp1;
            break;
        }
    }
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObject:[NSNumber numberWithInt:(int)view.tag]];     //1
    [data addObject:temp];           //2
    [data addObject:[NSNumber numberWithInt:point.x]];   //3    X
    [data addObject:[NSNumber numberWithInt:point.y]];   //4    Y
    [data addObject:[NSNumber numberWithInt:ptGlobal.size.width]];   //5    width
    [data addObject:[NSNumber numberWithInt:ptGlobal.size.height]];   //6   height
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHousesListDetail" object:data];
}
-(void)onHousesClassicListTap:(UIGestureRecognizer *)gestureRecognizer
{
     UIImageView *view = (UIImageView *)[gestureRecognizer view];
    CGPoint point = [gestureRecognizer locationInView:self.superview];
    
    NSDictionary *temp = [[NSDictionary alloc] init];
    for ( NSDictionary *temp1 in housesListAllData) {
        int tempPlanId = [[temp1 objectForKey:@"id"] intValue];
        if(tempPlanId == view.tag){
            temp = temp1;
            break;
        }
    }
    
    CGRect ptGlobal = [view.superview convertRect:view.frame toView:nil];
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObject:[NSNumber numberWithInt:(int)view.tag]];     //1
    [data addObject:temp];           //2
    [data addObject:[NSNumber numberWithInt:point.x]];   //3    X
    [data addObject:[NSNumber numberWithInt:point.y]];   //4    Y
    [data addObject:[NSNumber numberWithInt:ptGlobal.size.width]];   //5    width
    [data addObject:[NSNumber numberWithInt:ptGlobal.size.height]];   //6   height
    
    UIView *superView = [view superview];
    UILabel *label = (UILabel *)[superView viewWithTag:-1];
    NSString *downloadStatusStr = @"";
    if(label.text.length>0)
        downloadStatusStr = label.text;
    if([superView viewWithTag:-2])
         downloadStatusStr = @"更新";
    
    [data addObject:downloadStatusStr];   //7   downloadStatus
    
   if(view.image)
    [data addObject:view.image];    //8 image
   
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHousesListDetail" object:data];

}

-(void)getMessageList:(id)sender{
    
    if(loginInfo.housesType ==0){
    
        [globalContext judgeHousesList];
        
    }
    
    NSString *reload = sender;
    
    if([reload isEqualToString:@"1"]){
        
        housesListData = [[NSMutableArray alloc] initWithObjects:nil];
        allTempView = [[NSMutableDictionary alloc] init];
        housesListPageIndex = 0;
        [_refreshHeaderView refreshLastUpdatedDate];
        
        [housesListTable reloadData];
        
    //    [_refreshHeaderView egoRefreshStartLoading:housesListTable];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSNumber *pageIndexNSNumber = [NSNumber numberWithInt:housesListPageIndex];
    NSNumber *pageCountNSNumber = [NSNumber numberWithInt:8];
    
     if(loginInfo.downloadType==1)
         pageCountNSNumber = [NSNumber numberWithInt:24];
    
    NSDictionary *parameters = @{@"pageIndex":pageIndexNSNumber,@"pageCount":pageCountNSNumber,@"search":loginInfo.housesListSearch,@"type":[NSNumber numberWithInt:loginInfo.downloadType ]};
    
    [manager POST:[BASEURL stringByAppendingString: getDownloadHousesListApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
     //    NSLog(@"JSON: %@", responseObject);
        
        [[housesListTable viewWithTag:456] removeFromSuperview];
        
        NSDictionary *rootArray = responseObject;
        
        if([reload isEqualToString:@"1"]){
            
            housesListAllData = [[NSMutableArray alloc] init];
            
        }
        else{
            
            [self doneLoadMoreData];
        }
        
        NSArray *singal = [rootArray objectForKey:@"data"];
        
        if([singal isKindOfClass:[NSArray class]]){
            
            housesListPageIndex++;
            
            [housesListAllData addObjectsFromArray:singal];
            NSMutableArray *tempSingal = [singal mutableCopy];
            
            if(loginInfo.downloadType==3)
            [self configView:tempSingal];
            else
            [self configClassicPlanView:tempSingal];
            
            NSNumber  *totalCount = [rootArray objectForKey:@"totalCount"];
            if([totalCount isKindOfClass:[NSNumber class]]){
                if([totalCount intValue] >0){
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"housesListUpdateTotalCount" object:totalCount];
                    
                }
                else {
                    
                    if(loginInfo.downloadType==3){
                        [globalContext showAlertView:@"没有此类户型列表"];
                        
                    }
                    else{
                        [globalContext showAlertView:@"没有此类样板间"];
                    }

                }
            }
            
        }
        else{
        
            if(loginInfo.downloadType==3){

                if(housesListAllData.count>0)
                [globalContext showAlertView:@"已加载全部户型列表"];
                else
                 [globalContext showAlertView:@"没有此类户型列表"];
            }
            else{

            if(housesListAllData.count>0)
            [globalContext showAlertView:@"已加载全部经典样板间"];
                
            else
                [globalContext showAlertView:@"没有此类经典样板间"];

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

-(void)downloadOrderByType:(int)type{
    
    for (int i=0; i< housesListAllData.count; i++) {
        
        for(int j=(int)housesListAllData.count-1;j>i;--j){
            
            NSString *now =@"";
            NSString *before = @"";
            
            if(type==0){
                
                if(loginInfo.downloadType==1){
                now =[globalContext toPinYin:[housesListAllData[j] objectForKey:@"name"]];
                before = [globalContext toPinYin:[housesListAllData[j-1] objectForKey:@"name"]];
                }
                else{
                    now =[globalContext toPinYin:[housesListAllData[j] objectForKey:@"housesName"]];
                    before = [globalContext toPinYin:[housesListAllData[j-1] objectForKey:@"housesName"]];
                
                }
                
                if([now compare:before options:NSCaseInsensitiveSearch | NSNumericSearch] !=1){
                    NSDictionary *temp = housesListAllData[j];
                    housesListAllData[j] =  housesListAllData[j-1];
                    housesListAllData[j-1] = temp;
                }
            }
            else if(type==1){
                
              int  now = 0;
              int  before = 0;
                
            if(loginInfo.downloadType==1){
            
                now = [[housesListAllData[j] objectForKey:@"length"] intValue]*[[housesListAllData[j] objectForKey:@"width"] intValue];
                before = [[housesListAllData[j-1] objectForKey:@"length"] intValue]*[[housesListAllData[j-1] objectForKey:@"width"] intValue];

            }
            else{
            
                now  = [[housesListAllData[j] objectForKey:@"size"] intValue];
                before  = [[housesListAllData[j-1] objectForKey:@"size"] intValue];

            }
                
                if(now>before){
                    
                    NSDictionary *temp = housesListAllData[j];
                    housesListAllData[j] =  housesListAllData[j-1];
                    housesListAllData[j-1] = temp;
                    
                }

                
            }
            else if(type==2){
                
              int  floatNow = 0;
              int  floatBefore = 0;
                
                if(loginInfo.downloadType==1){
                
                    floatNow = [[housesListAllData[j] objectForKey:@"goodsCount"] intValue];
                    floatBefore = [[housesListAllData[j-1] objectForKey:@"goodsCount"] intValue];
                }
                else{
                
                    
                    floatNow = [[housesListAllData[j] objectForKey:@"count"] intValue];
                    floatBefore = [[housesListAllData[j-1] objectForKey:@"count"] intValue];

                }
                
                if(floatNow>floatBefore){
                
                    NSDictionary *temp = housesListAllData[j];
                    housesListAllData[j] =  housesListAllData[j-1];
                    housesListAllData[j-1] = temp;
                
                }
            }
           else if(type==3){
                
                now =[housesListAllData[j] objectForKey:@"latestUpdateTime"];
                before = [housesListAllData[j-1] objectForKey:@"latestUpdateTime"];
                
                if([now compare:before options:NSCaseInsensitiveSearch | NSNumericSearch] ==1){
                    NSDictionary *temp = housesListAllData[j];
                    housesListAllData[j] =  housesListAllData[j-1];
                    housesListAllData[j-1] = temp;
                }
            }
            
        }
        
    }
    
    housesListData = [[NSMutableArray alloc] initWithObjects:nil];
    
    int x = 0;
    int y = 0;
    
    int  eachViewWidth  = 158;
    int eachViewHeight =  190;
    
    UIView *uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2)];
    
    if(loginInfo.downloadType ==3){    //下载类型为户型列表
        
        eachViewWidth  = (self.frame.size.width -51)/4;
        eachViewHeight = eachViewWidth+63;
        
        uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2+20)];
    }
    
    [uiView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [housesListData addObject:uiView];
    
    for(int z=0;z<housesListAllData.count;z++){
        
        @autoreleasepool {
            
            NSDictionary *temp =housesListAllData[z];
            
            
            
            if(z!=0 &&z%(loginInfo.downloadType==1?6:4)==0){
                y++;
                x=0;
            }
            
            if(z!=0 &&z%(loginInfo.downloadType==1?12:8)==0){
                x=0;
                y=0;
                
                UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2)];
                
                if(loginInfo.downloadType ==3)
                    tempView.frame = CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2+20);
  
                
                [tempView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
                
                [housesListData addObject:tempView];
                
            }
            
            UIView *view = [allTempView objectForKey:[temp objectForKey:@"id"]];
            
            if(loginInfo.downloadType ==3)
                view.frame = CGRectMake(x*(eachViewWidth+16),y*(eachViewHeight+17), eachViewWidth, eachViewHeight);
            else{
                view.frame = CGRectMake(x*(eachViewWidth+10),y*(eachViewHeight+10), eachViewWidth, eachViewHeight);
            }
            
            [housesListData[housesListData.count-1] addSubview:view];
            
            x++;
            
            
        }
    }
    
    loginInfo.downloadListViewData = [housesListData copy];
    [housesListTable reloadData];
    
    
}


- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    housesListPageIndex = 0;
    housesListData = [[NSMutableArray alloc] initWithObjects:nil];
    allTempView = [[NSMutableDictionary alloc] init];
    row = 0;
    
    [self getMessageList:@"1"];
    
	_reloading = YES;
	
}
-(void)initHousesIndex:(id)sender{
    
    housesListPageIndex = 0;
    
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
