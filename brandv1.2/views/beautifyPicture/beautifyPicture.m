//
//  beautifyPicture.m
//  brandv1.2
//
//  Created by Apple on 15/3/6.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "beautifyPicture.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"
#import "Define.h"
#import "globalContext.h"
#import "MACircleProgressIndicator.h"
#import "beautifyPictureDetailViewController.h"

@implementation beautifyPicture
NSMutableArray *bpDataCollocation;
LoginInfo *loginInfo;
NSString *bpSearchField = @"";
int bpPageIndex = 0;
UIScrollView *bpScrollView;
MACircleProgressIndicator *bpIndicator;
bool bpEndDragging = false;
UIActivityIndicatorView *bpLoadingView;
UIActivityIndicatorView *bpLoadingMoreView;
float bpMessageLastEGOY =0;
bool bpMessageLoadMoreFlag = false;
int bpMessageX = 0;
NSString *searchText;
beautifyPictureDetailViewController *_beautifyPictureDetailViewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        
    }
    return self;
}
-(void)initView{
    
    bpDataCollocation = [[NSMutableArray alloc] initWithObjects:nil];
    
    
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    loginInfo.bpAllData = [[NSMutableArray alloc] init];
    
    searchText = @"";
    
    bpLoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    bpLoadingView.frame = CGRectMake(13,319, 21.0f, 21.0f);
    [bpLoadingView startAnimating];
    [bpLoadingView setHidden:true];
    [self addSubview:bpLoadingView];
    
    bpIndicator = [[MACircleProgressIndicator alloc] initWithFrame:CGRectMake(13,319,21,21)];
    bpIndicator.color = UIColorFromRGB(0x666666);
    bpIndicator.value = 0.0;
    [self addSubview:bpIndicator];
    [bpIndicator setHidden:true];
    
    bpScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,self.frame.size.height)];
    bpScrollView.contentSize = CGSizeMake(self.frame.size.width+1, 0);
    bpScrollView.delegate = self;
    [self addSubview:bpScrollView];
    [self addLoadingView];
    
    [self getMessageList:@"1" searchText:@""];
}
-(void)addLoadingView{
    
    NSString *loading = [[NSBundle mainBundle]pathForResource:@"gezlife.png" ofType:@""];
    UIImage *loadingImage = [UIImage imageWithContentsOfFile:loading];
    UIImageView *imageLoading = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,367,86)];
    imageLoading.tag =456;
    [imageLoading setImage:loadingImage];
    [imageLoading setCenter:bpScrollView.center];
    [bpScrollView addSubview:imageLoading];
    
}
-(void)restoreScrcollView:(id)sender{
    [UIView setAnimationsEnabled:true];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    bpScrollView.contentInset = UIEdgeInsetsMake(0.0f,0.0f,0.0f, 0.0f);
    [UIView commitAnimations];
    
    //    [indicator setHidden:false];
    [bpLoadingView setHidden:true];
}
- (void)egoRefreshScrollViewDataSourceLoadMoreDidFinished{
    
     bpMessageLoadMoreFlag = false;
    [bpLoadingMoreView removeFromSuperview];
    
    [bpScrollView setContentSize:CGSizeMake(bpScrollView.contentSize.width-40,0)];
    
    
}

-(void)configView:(NSMutableArray *)allData{
    
    //   loginInfo.bpAllData = allData;
    
    if(!bpDataCollocation)
        bpDataCollocation = [[NSMutableArray alloc] initWithObjects:nil];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    int y = 0;
    
    int eachViewHeight = 215;
    int  eachViewWidth  = 276;
    
    for(int i=0;i<allData.count;i++){
        
        NSDictionary *temp =allData[i];
        
        if(i!=0 &&i%3==0){
            y=0;
            bpMessageX++;
        }
        
        
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(bpMessageX*(eachViewWidth+2),y*(eachViewHeight+2), eachViewWidth, eachViewHeight)];
        [view setBackgroundColor:[UIColor whiteColor]];
        
        
        
        UIImageView * imageView =[[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, eachViewWidth, eachViewHeight);
        
        
        [view addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        imageView.tag =[[temp objectForKey:@"id"] intValue];
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)]];
        
     //   NSString *path = [NSString stringWithFormat:@"%@%@",imageUrl,[temp objectForKey:@"image"]];
        NSString *path = [NSString stringWithFormat:@"%@%@%@",imageUrl,[temp objectForKey:@"image"],@"_300X200"];
        
//        NSArray *names = [path componentsSeparatedByString:@"."];
//        path = [NSString stringWithFormat:@"%@_thumb.%@",path,names[names.count-1]];
        
        NSURL *pathUrl = [NSURL URLWithString:path];
        
        [imageView setCenterImageWithURL:pathUrl size:CGSizeMake(eachViewWidth-10, eachViewHeight)];
        //  [imageView setImageWithURL:pathUrl size:CGSizeMake(eachViewWidth-10, eachViewHeight*0.7)];
        
        [bpScrollView addSubview:view];
        
        y++;
        
    }
    
    bpMessageX = [self getTotalRow];
    
    int count = [self getTotalRow];
    
    if(count*276+(count-1)*2>1024)
        bpScrollView.contentSize = CGSizeMake(count*276+(count-1)*2,0);
    else
        bpScrollView.contentSize = CGSizeMake(1025,0);
    
    
    
    
}
-(int)getTotalRow{
    
    int getTotalRow = 0;
    
    int count = loginInfo.bpAllData.count;
    
    getTotalRow = count/3;
    
    if(count%3!=0)
        getTotalRow++;
    
    return  getTotalRow;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float x = scrollView.contentOffset.x;
    
    float value = x/-100;
    
    
    if(!bpEndDragging && bpIndicator.value<value){
        
        NSLog(@"%f",value);
        bpIndicator.value = value;
    }
    else if(bpEndDragging && bpIndicator.value>value){
        
        bpIndicator.value = value;
    }
    
    
    
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [bpLoadingView setHidden:true];
    [bpIndicator setHidden:false];
    bpEndDragging = false;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    bpEndDragging = true;
    
    if(bpIndicator.value>=0.9){
        
        CGFloat offset = MAX(scrollView.contentOffset.x * -1, 0);
        offset = MIN(offset,48);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        scrollView.contentInset = UIEdgeInsetsMake(0.0f,offset,0.0f, 0.0f);
        [UIView commitAnimations];
        
        [bpIndicator setHidden:true];
        [bpLoadingView setHidden:false];
        [self getMessageList:@"1" searchText:searchText];
    }
    
    
    CGPoint offset = scrollView.contentOffset;
    
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.x + bounds.size.width - inset.right;
    float h = size.width;
    float reload_distance = 10;
    if(y > h + reload_distance && offset.x-bpMessageLastEGOY>100&&h>300)
    {
        
        //Put your load more data method here...
        if(!bpMessageLoadMoreFlag){
            bpMessageLoadMoreFlag = true;
            
            bpLoadingMoreView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            bpLoadingMoreView.frame = CGRectMake(scrollView.contentSize.width+10,319, 21.0f, 21.0f);
            [bpLoadingMoreView startAnimating];
            [scrollView addSubview:bpLoadingMoreView];
            
            //   scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentSize.height-40,0.0f, 0.0f, 0.0f);
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width+40,0)];
            [UIView commitAnimations];
            
            bpMessageLastEGOY = offset.x;
            
            [self getMessageList:@"0" searchText:searchText];
        }
        
    }
    else if (offset.x<bpMessageLastEGOY){
        
        bpMessageLastEGOY = offset.x;
    }
    
    
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    bpIndicator.value = 0;
}
- (void)onTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
 //   NSLog(@"%ld",(long)view.tag);
    
    _beautifyPictureDetailViewController = [[beautifyPictureDetailViewController alloc] init];
    _beautifyPictureDetailViewController.view.frame = CGRectMake(0,768, 1024, 768);
    
    for(NSDictionary  *temp in loginInfo.bpAllData){
        
        int id = [[temp objectForKey:@"id"] intValue];
        
        if(id==view.tag){
            
            [_beautifyPictureDetailViewController initView:temp];
            break;
        }
    }
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    NSArray *subViews = [window subviews];
    
    [subViews[subViews.count-1] addSubview:_beautifyPictureDetailViewController.view];
    
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                          _beautifyPictureDetailViewController.view.frame = CGRectMake(0,0,1024, 768);
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];

    
}

-(void)getMessageList:(id)sender searchText:(NSString *)searchArg{
    //
    NSString *reload = sender;
    
    searchText = searchArg;
    
    if([reload isEqualToString:@"1"]){
        
        bpMessageX = 0;
        bpPageIndex = 0;
        loginInfo.bpAllData= [[NSMutableArray alloc] init];
        bpDataCollocation = [[NSMutableArray alloc] init];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSNumber *pageIndexNSNumber = [NSNumber numberWithInt:bpPageIndex];
    NSNumber *pageCountNSNumber = [NSNumber numberWithInt:12];
    
    NSDictionary *parameters = @{@"pageIndex":pageIndexNSNumber,@"pageCount":pageCountNSNumber,@"search":searchText};
    
    [manager POST:[BASEURL stringByAppendingString:getCasesListApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
     //   NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *rootArray = responseObject;
        
        if([reload isEqualToString:@"1"]){
            
            for (UIView *view in [bpScrollView subviews]) {
                
                if(![view isKindOfClass:[UIImageView class]])
                    [view removeFromSuperview];
            }
            
            loginInfo.bpAllData = [[NSMutableArray alloc] init];
            [self performSelector:@selector(restoreScrcollView:) withObject:nil afterDelay:0.0];
        }
        else{
            
            [self egoRefreshScrollViewDataSourceLoadMoreDidFinished];
        }
        
        NSArray *singal = [rootArray objectForKey:@"data"];
        
        if([singal isKindOfClass:[NSArray class]]){
            
            [[bpScrollView viewWithTag:456] removeFromSuperview];
            
            if(singal.count>0){
                bool flag = true;
                NSDictionary * temp = singal[0];
                int id = [[temp objectForKey:@"id"] intValue];
                for (NSDictionary *t in loginInfo.bpAllData) {
                    if([[t objectForKey:@"id"] intValue] ==id){
                        
                        flag =false;
                        break;
                    }
                }
                if(flag){
                    [loginInfo.bpAllData addObjectsFromArray:singal];
                    NSMutableArray  *singalTemp = [singal mutableCopy];
                    
                    [self configView:singalTemp];
                    
                    bpPageIndex++;
                }
            }
            
            
            NSNumber  *totalCount =[rootArray objectForKey:@"totalCount"];
            if([totalCount isKindOfClass:[NSNumber class]]){
                if([totalCount intValue] >0){
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"planUpdateTotalCount" object:[NSString stringWithFormat:@"%@",[rootArray objectForKey:@"totalCount"]]];
                    [[bpScrollView viewWithTag:456] setHidden:true];
                }
                else if([totalCount intValue] ==0){
                    [globalContext showAlertView:@"没有此类美图"];
                    [[bpScrollView viewWithTag:456] setHidden:false];
                }
                
            }
            
        }
        else{
            
             if([reload isEqualToString:@"1"])
                 [self addLoadingView];
            
            [globalContext showAlertView:@"没有此类美图"];
            [[bpScrollView viewWithTag:456] setHidden:false];
        }
        
        [bpIndicator setHidden:true];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        [bpIndicator setHidden:true];
        
        if([reload isEqualToString:@"1"]){
            
            [self performSelector:@selector(restoreScrcollView:) withObject:nil afterDelay:0.0];
        }
        else{
            
            [self egoRefreshScrollViewDataSourceLoadMoreDidFinished];
        }
        
    }];
    
    
}
-(void)initPlanIndex:(id)sender{
    
    bpPageIndex = 0;
    
}

@end
