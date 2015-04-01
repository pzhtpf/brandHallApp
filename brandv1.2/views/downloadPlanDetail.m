//
//  downloadPlanDetail.m
//  brandv1.2
//
//  Created by Apple on 14-11-17.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "downloadPlanDetail.h"
#import "UIImageView+AFNetworking.h"
#import "Define.h"
#import "UIImage+Resize.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"
#import "globalContext.h"

@implementation downloadPlanDetail
@synthesize downloadPlanDetailAllData;
UITableView *table ;
NSMutableArray *housesData;
NSArray *productImg;
NSMutableArray *productImgs;
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
    downloadPlanDetailAllData = [[NSMutableArray alloc] init];
    
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
    productImgs = [[NSMutableArray alloc] initWithObjects:nil];
    
    downloadPlanDetailAllData = allData;
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    int x = 0;
    int y = 0;
    int row = 0;
    
    // int eachViewHeight = uiView.frame.size.height/2-10;
    int  eachViewWidth  = 155;
    int eachViewHeight = 230;
    
    UIView *uiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2+20)];
    [uiView setBackgroundColor:[UIColor clearColor]];
    [housesData addObject:uiView];
    
    for(int i=0;i<allData.count;i++){
        
        NSDictionary *temp =allData[i];
        NSDictionary *productData = [temp objectForKey:@"productData"];
        
      //  NSLog(@"%@",temp);
        
        if(i!=0 &&i%6==0){
            y++;
            x=0;
        }
        
        if(i!=0 &&i%12==0){
            x=0;
            y=0;
            UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,eachViewHeight*2+20)];
            [tempView setBackgroundColor:[UIColor clearColor]];
            
            [housesData addObject:tempView];
            row++;
            
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x*(eachViewWidth+14),y*(eachViewHeight+12), eachViewWidth, eachViewHeight)];
        
        [view setBackgroundColor:[UIColor clearColor]];
        
        UIImageView * imageView =[[UIImageView alloc] init];
        imageView.frame = CGRectMake(0,0, eachViewWidth,155);
        
        // NSString *path = [imageUrl stringByAppendingString:[temp objectForKey:@"image"]];
        
        NSString *path = @"";
        
     //   if(![[productData objectForKey:@"product_image_url"] isEqualToString:@"0"])
   //         path  = [NSString stringWithFormat:@"%@%@",imageUrl,[productData objectForKey:@"product_image_url"]];

    //    else
            path  = [NSString stringWithFormat:@"%@%@_300X300",imageUrl,[temp objectForKey:@"image_url"]];

        
        
        NSURL *url = [NSURL URLWithString:path];
        [imageView setImageWithURL:url size:CGSizeMake(eachViewWidth,155)];
        
        
        [view addSubview:imageView];
        
        imageView.userInteractionEnabled = YES;
      //  imageView.tag =[[temp objectForKey:@"id"] intValue];
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onHousesTap:)]];
        
        UIView *info = [[UIView alloc]initWithFrame:CGRectMake(0,165,155, 30)];
      //  [info setBackgroundColor:[UIColorFromRGB(0x000000) colorWithAlphaComponent:0.5]];
        
        UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 15)];
        [name setBackgroundColor:[UIColor clearColor]];
      //  name.font=[name.font fontWithSize:12];
        name.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [name setTextColor:UIColorFromRGB(0x2b2b2b)];
        
        NSString *nameStr = [productData objectForKey:@"name"];
        if([nameStr isEqualToString:@"未知信息"]){
        
           nameStr = @"此商品暂无信息";
        }
        
         [name setText:[NSString stringWithFormat:@"%@",nameStr]];
        
        NSString *dispriceStr = [productData objectForKey:@"disprice"];
        
        if(![dispriceStr isEqualToString:@"未知信息"]){
        
        UILabel *disprice =[[UILabel alloc] initWithFrame:CGRectMake(0,19,150,20)];
        [disprice setBackgroundColor:[UIColor clearColor]];
       // disprice.font=[disprice.font fontWithSize:10];
         disprice.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
        [disprice setTextColor:UIColorFromRGB(0x2b2b2b)];
        [disprice setText:[NSString stringWithFormat:@"RMB %@",dispriceStr]];
            
            NSMutableAttributedString *text =
            [[NSMutableAttributedString alloc]
             initWithAttributedString: disprice.attributedText];
            
            [text addAttribute:NSForegroundColorAttributeName
                         value:UIColorFromRGB(0xff553e)
                         range:NSMakeRange(4, dispriceStr.length)];
            [disprice setAttributedText: text];
    
            
       float dispriceFloat = [dispriceStr floatValue];
            
        if(dispriceFloat ==0){
            
            dispriceStr = @"暂无价格";
            [disprice setText:[NSString stringWithFormat:@"%@",dispriceStr]];

        }
            
        else{
          
        [info addSubview:disprice];
            
         NSString *priceStr = [productData objectForKey:@"price"];
        float priceFloat = [priceStr floatValue];
       
            if(priceFloat!=0){
            
        UILabel *price =[[UILabel alloc] initWithFrame:CGRectMake(0,42,150, 15)];
        [price setBackgroundColor:[UIColor clearColor]];
       // price.font=[price.font fontWithSize:10];
        price.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
        [price setTextColor:UIColorFromRGB(0xa6aaae)];
        [price setText:[NSString stringWithFormat:@"市场价：RMB %@", [productData objectForKey:@"price"]]];
        

            
        [info addSubview:price];
        price = nil;
        }
 
        }
            
        }
        else{
        
            info.frame = CGRectMake(0,165, 150, 15);
        }
        
        [info addSubview:name];
        [imageView addSubview:info];
        // [uiView addSubview:view];
        
        
        
        [housesData[row] addSubview:view];
        
        x++;
        
    }
    
    loginInfo.housesViewData = [housesData copy];
    
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
    return [loginInfo.housesViewData count];
    // return 34;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIView *view = loginInfo.housesViewData[indexPath.row];
    
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

- (void)onHousesTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
    NSLog(@"%ld",(long)view.tag);
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObject:[NSNumber numberWithInt:view.tag]];
    
    
    for(NSDictionary *temp in downloadPlanDetailAllData){
        if([[temp objectForKey:@"id"] intValue] == view.tag){
            
            [data addObject:temp];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHousesDetail" object:data];
            break;
        }
    }
}

@end
