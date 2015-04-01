//
//  GoodsView.m
//  brandv1.2
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "GoodsView.h"
#import "UIImage+Resize.h"
#import "UIImageView+AFNetworking.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "Define.h"
#import "UIImage+Helpers.h"

@implementation GoodsView
LoginInfo *loginInfo;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)initView:(NSArray *)array{
    
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    
    NSMutableArray *data = array[1];
    
    int x = 0;
    int y = 0;
    
    int  eachViewWidth  = 144;
    int  eachViewHeight  = 230;
    
    
    UILabel *countLabel =[[UILabel alloc] initWithFrame:CGRectMake(0,0,140,20)];
    [countLabel setTextColor:UIColorFromRGB(0x999999)];
    countLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
    [self addSubview:countLabel];
    
    
    UILabel *priceTips =[[UILabel alloc] initWithFrame:CGRectMake(164,0,400,20)];
    [priceTips setTextColor:UIColorFromRGB(0x999999)];
    priceTips.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
    [self addSubview:priceTips];
    
    float ori = 0;
    float now = 0;
    
    //    img  = [img resizedImage:imgSize interpolationQuality: kCGInterpolationHigh];
    
//    dispatch_group_t group = dispatch_group_create();
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(6);
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    for(int i=0;i<data.count;i++){
        
        NSDictionary *temp =data[i];
        
        if(i!=0 &&i%4==0){
            y++;
            x=0;
        }
        
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(x*(eachViewWidth+10),50+y*eachViewHeight, eachViewWidth, eachViewHeight)];
        
        
        UIImageView * imageView =[[UIImageView alloc] init];
        
         imageView.frame = CGRectMake(0,0, eachViewWidth,eachViewWidth);
        
        if(!loginInfo.isOfflineMode){
        
        NSString *path = [imageUrl stringByAppendingString:[temp objectForKey:@"image"]];
        NSURL *pathUrl = [NSURL URLWithString:path];
        [imageView setImageWithURL:pathUrl size:CGSizeMake(eachViewWidth, eachViewWidth)];
        }
        else{
        

           [imageView loadlocalImage:[temp objectForKey:@"image"] size:imageView.frame.size setCenter:false];
            
        }
        
        imageView.userInteractionEnabled = YES;
        //  imageView.tag =[[temp objectForKey:@"id"] intValue];
        //   [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)]];
        [view addSubview:imageView];
        imageView = nil;
        
        UILabel *name =[[UILabel alloc] initWithFrame:CGRectMake(0,eachViewWidth+5, eachViewWidth,20)];
        name.font= [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
        [name setTextColor:UIColorFromRGB(0x2b2b2b)];
        
        NSString *nameStr = [temp objectForKey:@"name"];
        
        if([nameStr isEqualToString:@"未知信息"]){
         
            nameStr = @"此商品暂无信息";
        }
        
        [name setText:nameStr];
        
        NSString *dispriceStr = [temp objectForKey:@"disprice"];
        
        if(![dispriceStr isEqualToString:@"折扣未知"]){
        
        UILabel *disprice =[[UILabel alloc] initWithFrame:CGRectMake(0,eachViewWidth+25, eachViewWidth,20)];
        disprice.font=[UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
        [disprice setTextColor:UIColorFromRGB(0x2b2b2b)];
        NSString *dispriceString = [NSString stringWithFormat:@"RMB %@" ,dispriceStr];
        [disprice setText:dispriceString];
        [view addSubview:disprice];
      //  disprice = nil;
        
        float dispriceFloat = [dispriceStr floatValue];
            
        if(dispriceFloat == 0){
            
            dispriceStr = @"暂无价格";
            disprice.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
            NSString *dispriceString = [NSString stringWithFormat:@"%@" ,dispriceStr];
            [disprice setText:dispriceString];
            
            }
            
        else{
            
            NSMutableAttributedString *text =
            [[NSMutableAttributedString alloc]
             initWithAttributedString: disprice.attributedText];
            
            [text addAttribute:NSForegroundColorAttributeName
                         value:UIColorFromRGB(0xff553e)
                         range:NSMakeRange(4, dispriceStr.length)];
            [disprice setAttributedText: text];
            
        UILabel *price =[[UILabel alloc] initWithFrame:CGRectMake(0,eachViewWidth+45, eachViewWidth,20)];
        price.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
        [price setTextColor:UIColorFromRGB(0xa6aaae)];
        
        
        NSString *priceString = [NSString stringWithFormat:@"市场价：RMB %@" ,[temp objectForKey:@"price"]];
        [price setText:priceString];
        
        price.numberOfLines = 1;
        price.adjustsFontSizeToFitWidth = YES;
        price.lineBreakMode = NSLineBreakByClipping;
     
            
        ori = ori +[[temp objectForKey:@"price"] floatValue];
        now = now +[[temp objectForKey:@"disprice"] floatValue];
        
        
            
        
            [view addSubview:price];
            price = nil;
        
        }
            
        }
        else{
        
            name.frame = CGRectMake(5,eachViewWidth+20, eachViewWidth,20);
        }
        //  [description setText:[temp objectForKey:@"description"]];
        [view addSubview:name];
        name = nil;
        
        [self addSubview:view];
        view = nil;
        
        x++;
    }
    //    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
//    UILabel *nowPrices =[[UILabel alloc] initWithFrame:CGRectMake(0,25,eachViewWidth,20)];
//    nowPrices.font=[UIFont fontWithName:@"MicrosoftYaHei" size:16.0f];
//    NSString *nowPricesText = [NSString stringWithFormat:@"RMB %f",now];
//    [nowPrices setTextColor:[UIColor redColor]];
//    [nowPrices setText:nowPricesText];
//    [self addSubview:nowPrices];
//    nowPrices = nil;
//    
//    UILabel *orginalPrices =[[UILabel alloc] initWithFrame:CGRectMake(eachViewWidth,25,eachViewWidth,20)];
//    orginalPrices.font=[UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
//    NSString *orginalPricesText = [NSString stringWithFormat:@"为你节省 %f",ori-now];
//    [orginalPrices setText:orginalPricesText];
//    [self addSubview:orginalPrices];
//    orginalPrices = nil;
    
      NSString *countText = [NSString stringWithFormat:@"%@商品总量：%d件",[self returnType:array[0]],data.count];
     [countLabel setText:countText];
    
    NSString *priceText = [NSString stringWithFormat:@"商品总价：RMB %f",now];
    [priceTips setText:priceText];
    
}
-(void)setImageMethod:(NSArray *)array{

    UIImageView *imageView = array[0];
    UIImage *image = array[1];
    [imageView setImage:image];
}
-(NSString *)returnType:(NSNumber *)type{
    
    switch ([type intValue]) {
        case 0:
            return @"家具";
            
        case 1:
            return @"装饰";
            
        case 2:
            return @"建材";
            
        case 3:
            return @"硬装";
            
        default:
            return @"家具";
    }
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
