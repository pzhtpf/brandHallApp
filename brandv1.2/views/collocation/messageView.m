//
//  messageView.m
//  brandv1.2
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "messageView.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"
#import "Define.h"
#import "globalContext.h"
#import "MACircleProgressIndicator.h"

@implementation messageView
NSMutableArray *dataCollocation;
LoginInfo *loginInfo;
NSString *planProductSearchField = @"";
int planPageIndex = 0;
float planLastY =0;
UIScrollView *scrollView;
MACircleProgressIndicator *indicator;
bool planEndDragging = false;
UIActivityIndicatorView *loadingView;
UIActivityIndicatorView *loadingMoreView;
float messageLastEGOY =0;
bool messageLoadMoreFlag = false;
int messageX = 0;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        
    }
    return self;
}
-(void)initView{
    
    dataCollocation = [[NSMutableArray alloc] initWithObjects:nil];
    
    
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    loginInfo.planViewData = [[NSMutableArray alloc] init];

    
    loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingView.frame = CGRectMake(13,319, 21.0f, 21.0f);
    [loadingView startAnimating];
    [loadingView setHidden:true];
    [self addSubview:loadingView];
    
    indicator = [[MACircleProgressIndicator alloc] initWithFrame:CGRectMake(13,319,21,21)];
    indicator.color = UIColorFromRGB(0x666666);
    indicator.value = 0.0;
    [self addSubview:indicator];
    [indicator setHidden:true];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,self.frame.size.height)];
    scrollView.contentSize = CGSizeMake(self.frame.size.width+1, 0);
    scrollView.delegate = self;
    [self addSubview:scrollView];
    [self addLoadingView];
    
    [self getMessageList:@"1"];
}
-(void)addLoadingView{
    
    NSString *loading = [[NSBundle mainBundle]pathForResource:@"gezlife.png" ofType:@""];
    UIImage *loadingImage = [UIImage imageWithContentsOfFile:loading];
    UIImageView *imageLoading = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,367,86)];
    imageLoading.tag =456;
    [imageLoading setImage:loadingImage];
    [imageLoading setCenter:scrollView.center];
    [scrollView addSubview:imageLoading];

}
-(void)restoreScrcollView:(id)sender{
    [UIView setAnimationsEnabled:true];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    scrollView.contentInset = UIEdgeInsetsMake(0.0f,0.0f,0.0f, 0.0f);
    [UIView commitAnimations];
    
//    [indicator setHidden:false];
    [loadingView setHidden:true];
}
- (void)egoRefreshScrollViewDataSourceLoadMoreDidFinished{
    
    messageLoadMoreFlag = false;
    [loadingMoreView removeFromSuperview];
    
    [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width-40,0)];
 
    
}

-(void)configView:(NSMutableArray *)allData{
    
    //   loginInfo.planViewData = allData;
    
    if(!dataCollocation)
        dataCollocation = [[NSMutableArray alloc] initWithObjects:nil];
    
    [self setBackgroundColor:[UIColor clearColor]];

    int y = 0;
    
    int eachViewHeight = 215;
    int  eachViewWidth  = 276;
    
    
    NSString *huxingPath = [[NSBundle mainBundle]pathForResource:@"LOGOhuxing.png" ofType:@""];
    UIImage *huxingPathImage = [UIImage imageWithContentsOfFile:huxingPath];
    
    for(int i=0;i<allData.count;i++){
        
        NSDictionary *temp =allData[i];
        
        if(i!=0 &&i%3==0){
            y=0;
           messageX++;
        }
        
        
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(messageX*(eachViewWidth+2),y*(eachViewHeight+2), eachViewWidth, eachViewHeight)];
        [view setBackgroundColor:[UIColor whiteColor]];
        
        
        
        UIImageView * imageView =[[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, eachViewWidth, eachViewHeight);
        
        
        [view addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        imageView.tag =[[temp objectForKey:@"id"] intValue];
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)]];
        
    
        
        NSArray *rooms = [temp objectForKey:@"rooms"];
        if([rooms isKindOfClass:[NSArray class]] && rooms.count>0){
            
          if([rooms count] >1){
                
                UIImageView * imageViewHuXing =[[UIImageView alloc] initWithImage:huxingPathImage];
                imageViewHuXing.frame = CGRectMake(0, 0, 60, 60);
                [view addSubview:imageViewHuXing];
                imageViewHuXing = nil;
              
          }
            
        }
        
        NSString *path = [NSString stringWithFormat:@"%@%@_S400",imageUrl,[temp objectForKey:@"image"]];
        //    NSString *path = [NSString stringWithFormat:@"%@%@%@",imageUrl,[temp objectForKey:@"image"],@"_300X200"];
        
//        NSArray *names = [path componentsSeparatedByString:@"."];
//        path = [NSString stringWithFormat:@"%@_thumb.%@",path,names[names.count-1]];
        
        NSURL *pathUrl = [NSURL URLWithString:path];
        
        [imageView setCenterImageWithURL:pathUrl size:CGSizeMake(eachViewWidth-10, eachViewHeight)];
        //  [imageView setImageWithURL:pathUrl size:CGSizeMake(eachViewWidth-10, eachViewHeight*0.7)];
        
        [scrollView addSubview:view];
        
        y++;
        
    }
    
    messageX = [self getTotalRow];
    
    int count = [self getTotalRow];
    
    if(count*276+(count-1)*2>1024)
    scrollView.contentSize = CGSizeMake(count*276+(count-1)*2,0);
    else
    scrollView.contentSize = CGSizeMake(1025,0);

    
    huxingPathImage = nil;
    
    
}
-(int)getTotalRow{

    int getTotalRow = 0;
    
    int count = loginInfo.planViewData.count;
    
    getTotalRow = count/3;
    
    if(count%3!=0)
        getTotalRow++;

    return  getTotalRow;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float x = scrollView.contentOffset.x;
    
    float value = x/-100;
    
    
    if(!planEndDragging && indicator.value<value){
        
        NSLog(@"%f",value);
        indicator.value = value;
    }
    else if(planEndDragging && indicator.value>value){
        
        indicator.value = value;
    }
    
    
    
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
   [loadingView setHidden:true];
    [indicator setHidden:false];
    planEndDragging = false;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    planEndDragging = true;
    
    if(indicator.value>=0.9){
        
        CGFloat offset = MAX(scrollView.contentOffset.x * -1, 0);
        offset = MIN(offset,48);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(0.0f,offset,0.0f, 0.0f);
        [UIView commitAnimations];
        
        [indicator setHidden:true];
        [loadingView setHidden:false];
        [self getMessageList:@"1"];
    }
    
    
    CGPoint offset = scrollView.contentOffset;
    
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.x + bounds.size.width - inset.right;
    float h = size.width;
    float reload_distance = 10;
    if(y > h + reload_distance && offset.x-messageLastEGOY>100&&h>300)
    {
        
        //Put your load more data method here...
        if(!messageLoadMoreFlag){
            messageLoadMoreFlag = true;
            
            loadingMoreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            loadingMoreView.frame = CGRectMake(scrollView.contentSize.width+10,319, 21.0f, 21.0f);
            [loadingMoreView startAnimating];
            [scrollView addSubview:loadingMoreView];
            
            //   scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentSize.height-40,0.0f, 0.0f, 0.0f);
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width+40,0)];
            [UIView commitAnimations];
            
            messageLastEGOY = offset.x;
            
            [self getMessageList:@"0"];
        }
        
    }
    else if (offset.x<messageLastEGOY){
        
        messageLastEGOY = offset.x;
    }
    
 
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    indicator.value = 0;
}
- (void)onTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
    NSLog(@"%ld",(long)view.tag);
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObject:[NSNumber numberWithInt:(int)view.tag]];
    
    loginInfo.collocationType = 1;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToDetail" object:data];
}

-(void)getMessageList:(id)sender{
//    
    NSString *reload = sender;
    
    if([reload isEqualToString:@"1"]){
    
        messageX = 0;
        planPageIndex = 0;
        loginInfo.planViewData= [[NSMutableArray alloc] init];
        dataCollocation = [[NSMutableArray alloc] init];
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSNumber *pageIndexNSNumber = [NSNumber numberWithInt:planPageIndex];
    NSNumber *pageCountNSNumber = [NSNumber numberWithInt:12];
    
    NSDictionary *parameters = @{@"pageIndex":pageIndexNSNumber,@"pageCount":pageCountNSNumber,@"search":loginInfo.planSearch};
    
    [manager POST:[BASEURL stringByAppendingString: planMessageListApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *rootArray = responseObject;
        
      //  [[scrollView viewWithTag:456] removeFromSuperview];
        
        if([reload isEqualToString:@"1"]){
            
            for (UIView *view in [scrollView subviews]) {
                
                if(![view isKindOfClass:[UIImageView class]])
                [view removeFromSuperview];
            }
            
            loginInfo.planViewData = [[NSMutableArray alloc] init];
            [self performSelector:@selector(restoreScrcollView:) withObject:nil afterDelay:0.0];
        }
        else{
            
             [self egoRefreshScrollViewDataSourceLoadMoreDidFinished];
        }
        
        NSArray *singal = [rootArray objectForKey:@"data"];
        
        if([singal isKindOfClass:[NSArray class]]){
            
            if(singal.count>0){
                bool flag = true;
                NSDictionary * temp = singal[0];
                int id = [[temp objectForKey:@"id"] intValue];
                for (NSDictionary *t in loginInfo.planViewData) {
                    if([[t objectForKey:@"id"] intValue] ==id){
                    
                        flag =false;
                        break;
                    }
                }
                if(flag){
                  [loginInfo.planViewData addObjectsFromArray:singal];
                    NSMutableArray  *singalTemp = [singal mutableCopy];
                    
                    [self configView:singalTemp];
                    
                    planPageIndex++;
                }
            }
      
            
            NSNumber  *totalCount =[rootArray objectForKey:@"totalCount"];
            if([totalCount isKindOfClass:[NSNumber class]]){
                if([totalCount intValue] >0){
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"planUpdateTotalCount" object:[NSString stringWithFormat:@"%@",[rootArray objectForKey:@"totalCount"]]];
                    [[scrollView viewWithTag:456] setHidden:true];
                }
                else if([totalCount intValue] ==0){
                    [globalContext showAlertView:@"没有此类方案"];
                     [[scrollView viewWithTag:456] setHidden:false];
                }

            }
            
        }
        else{
        
              [globalContext showAlertView:@"没有此类方案"];
             [[scrollView viewWithTag:456] setHidden:false];
        }
        
        [indicator setHidden:true];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        [indicator setHidden:true];
        
        if([reload isEqualToString:@"1"]){
            
            [self performSelector:@selector(restoreScrcollView:) withObject:nil afterDelay:0.0];
        }
        else{
            
            [self egoRefreshScrollViewDataSourceLoadMoreDidFinished];
        }
        
    }];
    
    
}
-(void)initPlanIndex:(id)sender{

    planPageIndex = 0;
    planLastY = 0;
    
}
@end
