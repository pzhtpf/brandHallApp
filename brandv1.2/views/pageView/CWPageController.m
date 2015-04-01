//
//  CWPageController.m
//  brandv1.2
//
//  Created by Apple on 14-7-29.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "CWPageController.h"
#import "UIImageView+AFNetworking.h"
#import "collocationViewController.h"
#import "Define.h"
#import "LoginInfo.h"
#import "StockData.h"
#import "UIImage+Resize.h"

@interface CWPageController ()

@end

@implementation CWPageController
@synthesize dataObject;
collocationViewController *collocation;
LoginInfo *loginInfo;
UIImageView *imageView;
UIImageView  *imageViewAnimation;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,670,620)];
    
    imageView =[[UIImageView alloc] initWithFrame:self.view.bounds];
    //  imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    
    if(loginInfo.collocationType==4){
        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSArray *names = [[dataObject objectForKey:@"image"] componentsSeparatedByString:@"/"];

        int tag = [[dataObject objectForKey:@"id"] integerValue];
        
        UIImage * result;
        
        if(tag==0||tag==1||tag==2||tag==3||tag==4||tag==5){
        
            NSString *pathImage = [[NSBundle mainBundle]pathForResource:names[names.count-1] ofType:@""];
            
            result = [UIImage imageWithContentsOfFile:pathImage];
        }
        
        else{
            
            NSString * path = [NSString stringWithFormat:@"%@/%@", documentsDirectoryPath, names[names.count-1]];
            result = [UIImage imageWithContentsOfFile:path];
        }
        
        
        if(result)
        {
            
            result = [result resizedImage:result.size interpolationQuality: kCGInterpolationHigh];
            [imageView setImage:result];
            result = nil;
        }
        
        imageView.layer.cornerRadius = 8;
        self.view.layer.cornerRadius = 8;
        scrollView.layer.cornerRadius = 8;
        
        imageView.userInteractionEnabled = YES;
        
        scrollView.frame = CGRectMake(0, 0,520,615);
        
        imageView.frame = CGRectMake(0, 0,520,615);
        
        imageView.tag = [[dataObject objectForKey:@"id"] integerValue];
        
        imageView.contentMode = UIViewContentModeScaleToFill;
        
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
        
        [self.view addSubview:imageView];
        
    }
    else if(loginInfo.collocationType==5){
        
        
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.frame = CGRectMake(0, 0,1024,768);
        
        NSString * path = [dataObject objectForKey:@"image"];
        
        NSString *pathImage = [[NSBundle mainBundle]pathForResource:path ofType:@""];
        
        UIImage * result = [UIImage imageWithContentsOfFile:pathImage];
        
        //  NSLog(@"保存路径:%@",documentsDirectoryPath);
        
        
        //  NSString *path = [[NSBundle mainBundle]pathForResource:[dataObject objectForKey:@"image"] ofType:@""];
        //  UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        if(result)
        {
            
            result = [result resizedImage:result.size interpolationQuality: kCGInterpolationHigh];
            
             [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
            
            [imageView setImage:result];
            result = nil;
        }
        
        imageView.tag = [[dataObject objectForKey:@"id"] integerValue];
        
        [self.view addSubview:imageView];
        
    }
    else{
        
        if(loginInfo.collocationType == 1){
        
         imageView.frame = CGRectMake(0, 0,640,480);
         scrollView.frame = CGRectMake(0, 0,640,480);
        
        }
        
        else{
            if(!loginInfo.productIsZoom){
                
              scrollView.frame =  CGRectMake(0, 0,657,651);
              imageView.frame = CGRectMake(0, 0,657,651);
                
            }
            else{
            
                scrollView.frame =  CGRectMake(0, 0,1024,724);
                imageView.frame = CGRectMake(0, 0,1024,724);
            }
            
        }
        
        imageView.userInteractionEnabled = YES;
        
        
        if(!loginInfo.isOfflineMode){
            
            NSString *path = [imageUrl stringByAppendingString:[dataObject objectForKey:@"image"]];
            NSURL *pathUrl = [NSURL URLWithString:path];
            
            // [imageView setImageWithURL:pathUrl placeholderImage:image size:CGSizeMake(0, 0)];
           
            
            if(loginInfo.collocationType == 1){
                
                path = [path stringByAppendingString:@"_L1000"];
                pathUrl = [NSURL URLWithString:path];
                
                [imageView setCenterImageWithURL:pathUrl size:imageView.frame.size];
                
            }
            
            else{
                
                 [imageView setImageWithURL:pathUrl size:CGSizeMake(0, 0)];
                
            }


        }
        else{
            
            NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString * path = [NSString stringWithFormat:@"%@/%@", documentsDirectoryPath,[dataObject objectForKey:@"image"]];
            
            UIImage * result = [UIImage imageWithContentsOfFile:path];
            
            
            if(result)
            {
                
                result = [result resizedImage:result.size interpolationQuality: kCGInterpolationHigh];
                [imageView setImage:result];
                result = nil;
            }
            
            
        }
        
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scrollView addSubview:imageView];
        [self.view addSubview:scrollView];
        
    }
    
    
    
    
    
    scrollView.contentSize = imageView.frame.size;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 3.0;
    scrollView.delegate = self;
    
    scrollView.tag = [[dataObject objectForKey:@"id"] integerValue];
    
    if(loginInfo.collocationType==4 || loginInfo.collocationType==5){
        
    [self.view addSubview:imageView];
        
    }    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}
-(void)collocation:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    int tag = button.tag;
    
    NSDictionary *id = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",tag],@"id", nil];
    
    if(loginInfo.isOfflineMode){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToDownloadCollocation" object:id];
    
    }
    else{
    
    if(loginInfo.collocationType ==1){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToCollocation" object:id];
    }
    else if(loginInfo.collocationType ==2){
        //  [[NSNotificationCenter defaultCenter] postNotificationName:@"goToHousesCollocation" object:dataObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goHousesCollocation" object:id];
        
    }
}
}
-(void)goToLogin:(id)sender{
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLogin" object:nil];
    
}
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    return imageView;
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
    
    CGPoint currentPoint = [gestureRecognizer locationInView:view];
    
    int trueX = currentPoint.x*2;
    int trueY = currentPoint.y*2;
    
    NSArray *dataArray = [dataObject objectForKey:@"data"];
    
    for(NSDictionary *data in dataArray){
    
    if(trueX>[[data objectForKey:@"X"] intValue] && trueX<([[data objectForKey:@"X"] intValue]+[[data objectForKey:@"width"] intValue] )
       &&
       (trueY>[[data objectForKey:@"Y"] intValue] && (trueY<[[data objectForKey:@"Y"] intValue]+[[data objectForKey:@"height"] intValue]))
       )
    {
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startLoadView" object:[data objectForKey:@"url"]];

        break;
    
    }
    }
    
}

-(void)initAnimation{

    int tag = [[dataObject objectForKey:@"id"] integerValue];
    
    if(tag==0){
    
        imageViewAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0,-768,1024, 768)];
        
        NSString *pathImage = [[NSBundle mainBundle]pathForResource:@"lanuchText.png" ofType:@""];
        
        UIImage * result = [UIImage imageWithContentsOfFile:pathImage];
        
    if(result)
        {
            
            result = [result resizedImage:result.size interpolationQuality: kCGInterpolationHigh];
            
          
            
            [imageViewAnimation setImage:result];
            result = nil;
        }
        
        imageViewAnimation.tag = tag;
        
        [self.view addSubview:imageViewAnimation];
        
        [UIView setAnimationsEnabled:true];
        [UIView animateWithDuration:0.7
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             // Shrink!
                          //   imageView.transform = CGAffineTransformMakeScale(0.15, 0.15);
                             imageViewAnimation.frame = CGRectMake(0,0, imageView.frame.size.width,imageView.frame.size.height);
                             //   sourceViewController.view.center = self.targetPoint;
                         }
                         completion:^(BOOL finished){
                             
                             
                         }];

    }
    else if(tag==1){
        
       imageViewAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,1024, 768)];
        imageViewAnimation.alpha = 0;
        
        NSString *pathImage = [[NSBundle mainBundle]pathForResource:@"subjectText.png" ofType:@""];
        
        UIImage * result = [UIImage imageWithContentsOfFile:pathImage];
        
        if(result)
        {
            
            result = [result resizedImage:result.size interpolationQuality: kCGInterpolationHigh];
            
            
            
            [imageViewAnimation setImage:result];
            result = nil;
        }
        
        imageViewAnimation.tag = tag;
        
        [self.view addSubview:imageViewAnimation];
        
        [UIView setAnimationsEnabled:true];
        [UIView animateWithDuration:0.7
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             // Shrink!
                             //   imageView.transform = CGAffineTransformMakeScale(0.15, 0.15);
                           //  imageViewAnimation.frame = CGRectMake(0,0, imageView.frame.size.width,imageView.frame.size.height);
                             imageViewAnimation.alpha  = 1;
                             //   sourceViewController.view.center = self.targetPoint;
                         }
                         completion:^(BOOL finished){
                             
                             
                         }];
        
    }

}
- (void)viewDidAppear:(BOOL)animated{
   
    [super viewDidAppear:YES];
  //  [self initAnimation];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    [imageViewAnimation removeFromSuperview];
    imageViewAnimation = nil;
}
-(void)handleRightSwipe:(id)sender{}
@end
