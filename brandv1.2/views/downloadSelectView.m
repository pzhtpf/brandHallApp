//
//  downloadSelectView.m
//  brandv1.2
//
//  Created by Apple on 14/12/17.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "downloadSelectView.h"
#import "Define.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"
#import "globalContext.h"
#import "UIImage+Helpers.h"

@implementation downloadSelectView
@synthesize downloadPlanSelectAllData;
UITableView *table ;
NSMutableArray *housesData;
NSArray *productImg;
NSMutableArray *downloadPlan;
LoginInfo *loginInfo;

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
    downloadPlanSelectAllData = [[NSMutableArray alloc] init];
    
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,self.frame.size.height)];
    
    table.delegate = self;
    table.dataSource = self;
    [table setBackgroundColor:[UIColor clearColor]];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self addSubview: table];
}
-(void)configView:(NSMutableArray *)allData{
    
    //  [table removeFromSuperview];
    housesData = [[NSMutableArray alloc] initWithObjects:nil];
    downloadPlan = [[NSMutableArray alloc] initWithObjects:nil];
    
    downloadPlanSelectAllData = allData;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    int x = 0;
    int y = 0;
    int row = 0;
    
    // int eachViewHeight = uiView.frame.size.height/2-10;
    int  eachViewWidth  = (table.frame.size.width -51)/4;
    int eachViewHeight = eachViewWidth*1.1;
    
    UIView *uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,table.frame.size.width,eachViewHeight*2+20)];
    [uiView setBackgroundColor:[UIColor clearColor]];
    [housesData addObject:uiView];
    
    for(int i=0;i<allData.count;i++){
        
        NSDictionary *temp =allData[i];
        
        if(i!=0 &&i%4==0){
            y++;
            x=0;
        }
        
        if(i!=0 &&i%8==0){
            x=0;
            y=0;
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,table.frame.size.width,eachViewHeight*2+20)];
            [tempView setBackgroundColor:[UIColor clearColor]];
            
            [housesData addObject:tempView];
            row++;
            
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x*(eachViewWidth+16),y*(eachViewHeight+17), eachViewWidth, eachViewHeight)];
        
        [view setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView * imageView =[[UIImageView alloc] init];
        imageView.frame = CGRectMake(5,5, eachViewWidth,125);
        
        
        [UIImage loadFromURL:[temp objectForKey:@"localImageName"] callback: ^(UIImage *image){
            
            image = [image resizedCenterImage:imageView.frame.size interpolationQuality:kCGInterpolationLow];
            [imageView setImage:image];
        }];
        
        [view addSubview:imageView];
        
        imageView.userInteractionEnabled = YES;
         imageView.tag =[[temp objectForKey:@"planId"] intValue];
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onHousesTap:)]];
        
        
        UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake(5,140, (eachViewWidth-20)/2,25)];
        [name setBackgroundColor:[UIColor clearColor]];
        //  name.font=[name.font fontWithSize:12];
        name.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
        [name setText:[NSString stringWithFormat:@"  %@",[temp objectForKey:@"name"]]];
         [name setTextColor:UIColorFromRGB(0x777777)];
        [view addSubview:name];
        name = nil;
        
        UILabel *goodsCount =[[UILabel alloc] initWithFrame:CGRectMake(eachViewWidth/2-5,140,eachViewWidth/2+10,25)];
        [goodsCount setBackgroundColor:[UIColor clearColor]];
        goodsCount.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
          [goodsCount setTextColor:UIColorFromRGB(0xb7b7b7)];
        
        NSString *countStr = [temp objectForKey:@"goodsCount"];
        
        [goodsCount setText:[NSString stringWithFormat:@"可搭配产品%@款",countStr]];
        goodsCount.textAlignment = NSTextAlignmentRight;
        
        NSMutableAttributedString *text =
        [[NSMutableAttributedString alloc]
         initWithAttributedString: goodsCount.attributedText];
        
        [text addAttribute:NSForegroundColorAttributeName
                     value:UIColorFromRGB(0xff553e)
                     range:NSMakeRange(5, countStr.length)];
        [goodsCount setAttributedText: text];
        
        [view addSubview:goodsCount];
        goodsCount = nil;

        
        double total = [[temp objectForKey:@"total"] longLongValue];
        
        UILabel *totalCaptiy =[[UILabel alloc] initWithFrame:CGRectMake(eachViewWidth/2-5,160,eachViewWidth/2+10,25)];
        [totalCaptiy setBackgroundColor:[UIColor clearColor]];
        totalCaptiy.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
        [totalCaptiy setTextColor:UIColorFromRGB(0xb2b2b2)];
        totalCaptiy.textAlignment = NSTextAlignmentRight;
        
        
        NSString *totalStr = [NSString stringWithFormat:@"%0.1f",total/1024.0/1024.0];
        
        [totalCaptiy setText:[NSString stringWithFormat:@"%@M",totalStr]];
        [view addSubview:totalCaptiy];
        totalCaptiy = nil;
        
        [housesData[row] addSubview:view];
        
        x++;
        
    }
    
   downloadPlan= [housesData copy];
    
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
    return [downloadPlan count];
    // return 34;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIView *view = downloadPlan[indexPath.row];
    
    NSArray *allViews = [view subviews];
    
    if(allViews.count<=5){
        
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
    if(indexPath.row<= downloadPlan.count-1)
    {
        [cell.contentView addSubview:downloadPlan[indexPath.row]];
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

- (void)onHousesTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
    NSLog(@"%ld",(long)view.tag);
    
    NSString *planId = [NSString stringWithFormat:@"%d",view.tag];
    NSDictionary *id = [[NSDictionary alloc] initWithObjectsAndKeys:planId,@"id", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToDownloadCollocation" object:id];
}


@end
