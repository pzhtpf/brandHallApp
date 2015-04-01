//
//  messageView.m
//  brandv1.2
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "productMessageView.h"
#import "UIImageView+AFNetworking.h"
#import "Define.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"
#import "globalContext.h"

@implementation productMessageView
@synthesize data;
@synthesize table;
NSArray *productImg;
LoginInfo *loginInfo;
NSString *productSearchField = @"";
NSMutableArray *allData;
int pageIndex = 0;
float lastY =0;
NSMutableDictionary *allViewsDictionary;
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
    allData = [[NSMutableArray alloc] init];
    loginInfo.productData = [[NSMutableArray alloc] init];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,self.frame.size.height)];
    table.delegate = self;
    table.dataSource = self;
    [table setBackgroundColor:[UIColor clearColor]];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - table.bounds.size.height, self.frame.size.width,table.bounds.size.height)];
		view.delegate = self;
		[table addSubview:view];
		_refreshHeaderView = view;
		view = nil;
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    
    [self addSubview: table];
    
  //  [_refreshHeaderView egoRefreshStartLoading:table];
    
    NSString *loading = [[NSBundle mainBundle]pathForResource:@"gezlife.png" ofType:@""];
    UIImage *loadingImage = [UIImage imageWithContentsOfFile:loading];
    UIImageView *imageLoading = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,367,86)];
    imageLoading.tag =456;
    [imageLoading setImage:loadingImage];
    [imageLoading setCenter:table.center];
    [table addSubview:imageLoading];
    
    [self getMessageList:@"1"];
    
}

-(void)configView:(NSMutableArray *)allData{
    
    //  [table removeFromSuperview];
 //   loginInfo.productAllData = allData;
    
    if(!allViewsDictionary){
      allViewsDictionary = [[NSMutableDictionary alloc] init];
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    int x = 0;
    int y = 0;
    int row = 0;
    
    // int eachViewHeight = uiView.frame.size.height/2-10;
    int  eachViewWidth  =(self.frame.size.width-50)/4;
    int eachViewHeight = 315;
    
    UIView *uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2+20)];
    [uiView setBackgroundColor:[UIColor whiteColor]];
    [data addObject:uiView];

    for(int i=0;i<allData.count;i++){
        
        @autoreleasepool {
            
            NSDictionary *temp =allData[i];
            
            if(i!=0 &&i%4==0){
                y++;
                x=0;
            }
            
            if(i!=0 &&i%8==0){
                x=0;
                y=0;
                UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(10, 0,self.frame.size.width,eachViewHeight*2+20)];
                [tempView setBackgroundColor:[UIColor whiteColor]];
                
                [data addObject:tempView];
                row++;
                
            }
            
            
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10+x*(eachViewWidth+10),y*(eachViewHeight+10), eachViewWidth, eachViewHeight)];
            
            [view setBackgroundColor:UIColorFromRGB(0xffffff)];
            productImg = [temp objectForKey:@"product_img"];
            

            UIImageView * imageView =[[UIImageView alloc] init];
            imageView.frame = CGRectMake(0,0, eachViewWidth,eachViewHeight*0.7);
            
            
            if([productImg count]>0){
                productImg = [productImg mutableCopy];
            //    NSString *path = [imageUrl stringByAppendingString:productImg[0]];
                  NSString *path = [NSString stringWithFormat:@"%@%@_300X300",imageUrl,productImg[0]];
                
                NSURL *url = [NSURL URLWithString:path];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [imageView setImageWithURL:url size:CGSizeMake(0,0)];
              //[imageView setCenterImageWithURL:url size:CGSizeMake(eachViewWidth-20,eachViewHeight*0.8)];
            }
            
            [view addSubview:imageView];
            //  NSString  *path =@"http://image.gezlife.com/";
            //  path = [path stringByAppendingString:[temp objectForKey:@"photoUrl"]];
            
            //  NSURL* url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            //  [imageView setImageWithURL:url];
            //  imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.userInteractionEnabled = YES;
            imageView.tag =[[temp objectForKey:@"product_id"] intValue];
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProductTap:)]];
            
            UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake(10,220, eachViewWidth-20,20)];
            name.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];//
            [name setTextColor:UIColorFromRGB(0x2b2b2b)];
            
            
            UILabel *price =[[UILabel alloc] initWithFrame:CGRectMake(10,260, eachViewWidth/2,25)];
            price.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
            [price setTextColor:UIColorFromRGB(0x2b2b2b)];
            
            UILabel *oriPrice =[[UILabel alloc] initWithFrame:CGRectMake(10,280, eachViewWidth-20,25)];
             oriPrice.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
            
            NSString *priceString = [temp objectForKey:@"promote_price"];
            
            NSString *priceText = [NSString stringWithFormat:@"RMB %@" ,priceString];
            
            
            NSString *descriptionString = [temp objectForKey:@"description"];
            
            if(![descriptionString isKindOfClass:[NSString class]] || descriptionString.length==0){
                
            //    descriptionString = @"描述未知";
                
                price.frame = CGRectMake(10,240, eachViewWidth-20,20);
                oriPrice.frame =  CGRectMake(10,260, eachViewWidth-20,20);
            }
            else{
                
                
                UILabel *description =[[UILabel alloc] initWithFrame:CGRectMake(10,240, eachViewWidth-20,20)];
                description.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
                [description setTextColor:UIColorFromRGB(0x2b2b2b)];
                [description setText:descriptionString];
                [description setBackgroundColor:[UIColor clearColor]];
                [view addSubview:description];
                description = nil;
                
                
            }
            

            
            
            if([priceString floatValue]==0){
                
                price.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
                priceText = @"暂无信息";
                [price setText:priceText];
            }
            else{
            
                [price setText:priceText];
                
                NSMutableAttributedString *text =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: price.attributedText];
                
                [text addAttribute:NSForegroundColorAttributeName
                             value:UIColorFromRGB(0xff553e)
                             range:NSMakeRange(4, priceString.length)];
                [price setAttributedText: text];
                
                
                NSString *shopPriceString = [temp objectForKey:@"shop_price"];
                
                if([shopPriceString floatValue]!=0){
                    
                    NSString *oriPriceText = [NSString stringWithFormat:@"市场价: RMB %@" ,[temp objectForKey:@"shop_price"]];
                    
                    [oriPrice setText:oriPriceText];
                    [oriPrice setTextColor:UIColorFromRGB(0xa6aaae)];
                    
                    [view addSubview:oriPrice];
                    oriPrice = nil;
                    
                }
            }
            
      
            
            
      
            
            
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, eachViewHeight-1, eachViewWidth, 1)];
            [lineLabel setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
            [view addSubview:lineLabel];
            
            [name setText:[temp objectForKey:@"product_name"]];
            [name setBackgroundColor:[UIColor clearColor]];
            [price setBackgroundColor:[UIColor clearColor]];
            [oriPrice setBackgroundColor:[UIColor clearColor]];
            [view addSubview:name];
            name = nil;
            [view addSubview:price];
            price = nil;
            
            [allViewsDictionary setValue:view forKey:[temp objectForKey:@"product_id"]];
            
            [data[data.count-1] addSubview:view];
            
            x++;
        }
    }
    
    loginInfo.productViewData = [data copy];
  //  [table reloadData];
    
    
    
}
-(void)orderByType:(int)type{
    
    for (int i=0; i< loginInfo.productData.count; i++) {
        
        for(int j=(int) loginInfo.productData.count-1;j>i;--j){
            
            NSString *now =@"";
            NSString *before = @"";
            
            if(type==0){
                
                now =[globalContext toPinYin:[loginInfo.productData[j] objectForKey:@"product_name"]];
                before = [globalContext toPinYin:[loginInfo.productData[j-1] objectForKey:@"product_name"]];
                
                if([now compare:before options:NSCaseInsensitiveSearch | NSNumericSearch] !=1){
                    NSDictionary *temp = loginInfo.productData[j];
                    loginInfo.productData[j] =  loginInfo.productData[j-1];
                    loginInfo.productData[j-1] = temp;
                }

            }
           else if(type==1){
                
               int now = [[loginInfo.productData[j] objectForKey:@"promote_price"] intValue];
               int before = [[loginInfo.productData[j-1] objectForKey:@"promote_price"] intValue];
               
               if(now>before){
               
                   NSDictionary *temp = loginInfo.productData[j];
                   loginInfo.productData[j] =  loginInfo.productData[j-1];
                   loginInfo.productData[j-1] = temp;
               }
            }
            else if(type==2){
                
                now = [globalContext toPinYin:[loginInfo.productData[j] objectForKey:@"description"]];
                before = [globalContext toPinYin:[loginInfo.productData[j-1] objectForKey:@"description"]];
                
                if([now compare:before options:NSCaseInsensitiveSearch | NSNumericSearch] !=1){
                    NSDictionary *temp = loginInfo.productData[j];
                    loginInfo.productData[j] =  loginInfo.productData[j-1];
                    loginInfo.productData[j-1] = temp;
                }

            }
            
            
        }
        
    }
 
   data = [[NSMutableArray alloc] initWithObjects:nil];
    
    int x = 0;
    int y = 0;
    
    int  eachViewWidth  =(self.frame.size.width-50)/4;
    int eachViewHeight = 315;
    
    UIView *uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2+20)];
    [uiView setBackgroundColor:[UIColor whiteColor]];
    [data addObject:uiView];
    
    for(int z=0;z<loginInfo.productData.count;z++){
        
        @autoreleasepool {
            
            NSDictionary *temp =loginInfo.productData[z];
            
            if(z!=0 &&z%4==0){
                y++;
                x=0;
            }
            
            if(z!=0 &&z%8==0){
                x=0;
                y=0;
                
                UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(10, 0,self.frame.size.width,eachViewHeight*2+20)];
                [tempView setBackgroundColor:[UIColor whiteColor]];
                
                [data addObject:tempView];
                
            }
            
            UIView *view = [allViewsDictionary objectForKey:[temp objectForKey:@"product_id"]];
            view.frame = CGRectMake(10+x*(eachViewWidth+10),y*(eachViewHeight+10), eachViewWidth, eachViewHeight);
            
            [data[data.count-1] addSubview:view];
            
            x++;
            
       
        }
    }
    
    loginInfo.productViewData = [data copy];
    [table reloadData];


}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [loginInfo.productViewData  count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIView *view = loginInfo.productViewData [indexPath.row];
    
    NSArray *allViews = [view subviews];
    
    if(allViews.count<=3){
        
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
    if(indexPath.row <= loginInfo.productViewData.count-1 )
    {
        [cell.contentView addSubview:loginInfo.productViewData [indexPath.row]];
    }
    
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
    
    NSMutableArray *dataTemp = [[NSMutableArray alloc] init];
    [dataTemp addObject:[NSNumber numberWithInt:view.tag]];
    
    for(NSDictionary *temp in loginInfo.productData){
        if([[temp objectForKey:@"product_id"] intValue] == view.tag){
            
            [dataTemp addObject:[temp objectForKey:@"product_img"]];
            break;
        }
    }
    
    loginInfo.collocationType = 3;
    loginInfo.isOfflineMode = false;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToProductDetail" object:dataTemp];
    
    
}

-(void)getMessageList:(id)sender{
    //
    NSString *reload = sender;
    
    if([reload isEqualToString:@"1"]){
    
        pageIndex = 0;
        loginInfo.productAllData  = [[NSMutableArray alloc] init];
        data = [[NSMutableArray alloc] init];
        loginInfo.productViewData = [[NSMutableArray alloc] init];
    }
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
        NSNumber *pageIndexNSNumber = [NSNumber numberWithInt:pageIndex];
        NSNumber *pageCountNSNumber = [NSNumber numberWithInt:8];
    
        NSDictionary *parameters = @{@"pageIndex":pageIndexNSNumber,@"pageCount":pageCountNSNumber,@"search":loginInfo.productSearch};
    
        [manager POST:[BASEURL stringByAppendingString:getProductListApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
         //   NSLog(@"JSON: %@", responseObject);
            
            [[table viewWithTag:456] removeFromSuperview];
    
            NSDictionary *rootArray = responseObject;
    
                if([reload isEqualToString:@"1"]){
                    
                    allData = [[NSMutableArray alloc] init];
                    loginInfo.productData = [[NSMutableArray alloc] init];
                   [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
    
                }
                else{
                    
                    [self doneLoadMoreData];
                }
    
            NSArray *singal = [rootArray objectForKey:@"data"];
    
            if([singal isKindOfClass:[NSArray class]]){
    
    
                if(singal.count>0){
                    bool flag = true;
                    NSDictionary * temp = singal[0];
                    int id = [[temp objectForKey:@"product_id"] intValue];
                    for (NSDictionary *t in loginInfo.productData) {
                        if([[t objectForKey:@"product_id"] intValue] ==id){
    
                            flag =false;
                            break;
                        }
                    }
                    if(flag){
                        [loginInfo.productData addObjectsFromArray:singal];
                        pageIndex++;
                        NSMutableArray *tempSingal = [singal mutableCopy];
                        [self configView:tempSingal];
                    }
    
                        }
    
                NSString  *totalCount = [rootArray objectForKey:@"totalCount"];
                if([totalCount isKindOfClass:[NSString class]]){
                if([totalCount intValue] >0){
    
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTotalCount" object:[NSString stringWithString:[rootArray objectForKey:@"totalCount"]]];
    
                }
                else{
                
                    if (![reload isEqualToString:@"1"])
                    [globalContext showAlertView:@"没有此类商品"];
                }
                }
            }
    
            else{
                
                  if (![reload isEqualToString:@"1"])
                [globalContext showAlertView:@"没有此类商品"];
            }

            
            [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
    
            [table reloadData];
    
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
    pageIndex = 0;
    lastY = 0;
    [self getMessageList:@"1"];
    
	_reloading = YES;
	
}
-(void)initProductIndex:(id)sender{
    
    pageIndex = 0;
    lastY = 0;
    
}
- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:table];
	
}

- (void)doneLoadMoreData{
	
	//  model should call this when its done loading
	[_refreshHeaderView egoRefreshScrollViewDataSourceLoadMoreDidFinished:table];
	
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    }
- (void)egoRefreshTableHeaderDidTriggerLoadMore:(EGORefreshTableHeaderView*)view{
	
	  [self getMessageList:@"0"];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
   // NSArray *views = [table subviews];
	
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
