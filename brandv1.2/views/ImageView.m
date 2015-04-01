//
//  ImageView.m
//  dayInSchool
//
//  Created by Apple on 14-7-12.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "ImageView.h"
#import "AFNetworking.h"
#import "SBJson.h"
#import "UIImageView+AFNetworking.h"
@implementation ImageView
NSMutableArray *dataArray;
NSMutableArray *hotPic;
UITapGestureRecognizer *tapGesture;
int count =0;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        dataArray = [[NSMutableArray alloc] init];
        hotPic = [[NSMutableArray alloc] init];

        
       tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        
            tapGesture.delegate = self;
            tapGesture.numberOfTapsRequired = 1; // The default value is 1.
            tapGesture.numberOfTouchesRequired = 1; // The default value is 1.
            [self addGestureRecognizer:tapGesture];
        
        
        
           
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    UIImage* image=nil;
    NSString* path =@"http://image.gezlife.com/upload//space//2013//11//14//528559458cdfe.jpg";
  //  NSString* path =@"http://image.gezlife.com/upload/space/2013/12/21/52b546a78bebe.jpg";
    
    NSURL* url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];//网络图片url
    NSData* data = [NSData dataWithContentsOfURL:url];//获取网咯图片数据
    if(data!=nil)
    {
        image = [[UIImage alloc] initWithData:data];//根据图片数据流构造image
    }
 //  [image drawInRect:CGRectMake(0, 0, 1024, 500)];
    
    


    if(count>0){
    
        for (int i=0; i<dataArray.count; i++) {
     //   for (int i=dataArray.count-1; i>=0; i--) {

            
            id image= dataArray[i];
            if([image isKindOfClass:[UIImage class]]){
         //   [image drawInRect:CGRectMake(0, 0, 1024, 500)];
                UIImageView *imageView = [[UIImageView alloc] init];
               imageView.frame = CGRectMake(0, 0, 1024, 500);
                imageView.tag = i;
                imageView.image = image;
           //  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
            //  [imageView addGestureRecognizer:tapGesture];
                [self addSubview:imageView];
            }
        }
    }
}

-(void)getData:(NSMutableArray *)pathArray{
    int  index = [(pathArray[0]) intValue];
    NSLog(@"%@",pathArray[0]) ;
    
    UIImage* image=nil;
    NSString* path = pathArray[1];
    NSURL* url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];//网络图片url
    NSData* data = [NSData dataWithContentsOfURL:url];//获取网咯图片数据
    if(data!=nil)
    {
        image = [[UIImage alloc] initWithData:data];//根据图片数据流构造image
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    dataArray[index] = image;
    count ++;
    imageView.frame = CGRectMake(0, 0, 1024, 500);
    imageView.tag = index;
   // [imageView addGestureRecognizer:tapGesture];
   //  [self insertSubview:imageView atIndex:loginInfo.message.count-index];
   // [self insertSubview:imageView atIndex:index];
    NSLog(@"%@",pathArray[1]);
    NSLog(@"%d",index);
  //  if(count == loginInfo.message.count){
  // [self setNeedsDisplay];
 
  
//   }
}
-(void)searchElemList:(NSMutableArray *)params{
NSString *path =[NSString stringWithFormat: @"http://www.gezlife.com/flash/searchElemList?pageSize=36&brandhallId=1&srid=205&layerId=%@&1405498117989",params[0]];
    
    
    NSString *URLTmp = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  //转码成UTF-8  否则可能会出现错误
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: URLTmp]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *requestTmp = [NSString stringWithString:operation.responseString];
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSDictionary *rootDic = [parser objectWithString:requestTmp error:nil];
        
        NSData *resData = [[NSData alloc] initWithData:[requestTmp dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        
        //    NSDictionary *result  = [[rootDic objectForKey:@"data"] objectForKey:@"init"];
        
        
        
        //    NSArray * array = [result objectForKey:@"srid_1"];
        NSMutableArray *data = [[NSMutableArray alloc] init];
        NSArray * array = [[rootDic objectForKey:@"data"] objectForKey:@"elements"];
        [data addObject:array];
        [data addObject:params[1]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getElementsList" object:data];
    
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //   NSLog(@”Failure: %@”,error);
        
    }];
    [operation start];
    


}

-(void)getHotPicData:(NSMutableArray *)pathArray{
    int  index = [(pathArray[0]) intValue];
    NSLog(@"%@",pathArray[0]) ;
    
    UIImage* image=nil;
    NSString* path = pathArray[1];
    NSURL* url = [NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];//网络图片url
    NSData* data = [NSData dataWithContentsOfURL:url];//获取网咯图片数据
    if(data!=nil)
    {
        image = [[UIImage alloc] initWithData:data];//根据图片数据流构造image
    }
    hotPic[index] = image;
}

- (BOOL)pointInside:(NSMutableArray *)array {
    //Using code from http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    
    UIImage *image = array[0];
    CGPoint point = CGPointMake(0, 0);
    float x= [array[1] floatValue];
    float y= [array[2] floatValue];

    point.x = ((image.size.width*x)/1024);
    point.y = ((image.size.height*y)/500);
    
    unsigned char pixel[1] = {0};
    CGContextRef context = CGBitmapContextCreate(pixel,1, 1, 8, 1, NULL,kCGImageAlphaOnly);
    UIGraphicsPushContext(context);
    [image drawAtPoint:CGPointMake(-point.x,-point.y)];
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGFloat alpha = pixel[0]/255.0f;
    BOOL transparent = alpha < 0.01f;
    
    return !transparent;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateEnded:{ // UIGestureRecognizerStateRecognized = UIGestureRecognizerStateEnded // 正常情况下只响应这个消息
           NSLog(@"======UIGestureRecognizerStateEnded || UIGestureRecognizerStateRecognized");
            break;
        }
        case UIGestureRecognizerStateFailed:{ //
            NSLog(@"======UIGestureRecognizerStateFailed");
            break;
        }
        case UIGestureRecognizerStatePossible:{ //
            NSLog(@"======UIGestureRecognizerStatePossible");
            break;
        }
        default:{
            NSLog(@"======Unknow gestureRecognizer");
            break;
        }
    }
}

// 询问一个手势接收者是否应该开始解释执行一个触摸接收事件
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint currentPoint = [gestureRecognizer locationInView:self];
    NSString *x =[NSString stringWithFormat:@"%f",currentPoint.x];
    NSLog(@"%@",x);
    NSMutableArray *temp =nil;
    for(int x= hotPic.count-1;x>=0;x--){
        if([hotPic[x] isKindOfClass:[UIImage class]]){
        
        temp = [[NSMutableArray alloc] init];
        [temp addObject:hotPic[x]];
        [temp addObject:[NSNumber numberWithFloat:currentPoint.x]];
        [temp addObject:[NSNumber numberWithFloat:currentPoint.y]];
        bool flag = [self pointInside:temp];
        if(flag){
            NSLog(@"%d",x);
       //     NSLog(@"%@",[[loginInfo.message[x] objectForKey:@"image"] objectForKey:@"dapei_pic"]);
        
            NSMutableArray *params =[[NSMutableArray alloc] init];
    //        [params addObject:[loginInfo.message[x] objectForKey:@"layer_id"]];
            [params addObject:[NSNumber numberWithInt: x+1]];
            [self searchElemList:params];
          //   NSLog(@"%@",[[[loginInfo.message[x] objectForKey:@"items"] objectForKey:@"A1"] objectForKey:@"dapei_pic"]);
            break;
        }
        }
    }
    //    if (CGRectContainsPoint(CGRectMake(0, 0, 100, 100), currentPoint) ) {
    //        return YES;
    //    }
    //
    //    return NO;
    
    return YES;
}

// 询问delegate，两个手势是否同时接收消息，返回YES同事接收。返回NO，不同是接收（如果另外一个手势返回YES，则并不能保证不同时接收消息）the default implementation returns NO。
// 这个函数一般在一个手势接收者要阻止另外一个手势接收自己的消息的时候调用
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

// 询问delegate是否允许手势接收者接收一个touch对象
// 返回YES，则允许对这个touch对象审核，NO，则不允许。
// 这个方法在touchesBegan:withEvent:之前调用，为一个新的touch对象进行调用
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}



@end
