//
//  selfDesignViewController.m
//  brandv1.2
//
//  Created by Apple on 14-8-23.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "selfDesignViewController.h"
#import "UIImage+Resize.h"

@interface selfDesignViewController ()

@end

@implementation selfDesignViewController

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
   
}
-(void)addView{

    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 715)];
    view.tag = 100;
    NSString *path = [[NSBundle mainBundle]pathForResource:@"05自主设计.png" ofType:@""];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
           if(image)
        {
            // this "resizedimage" image is what you want to pass to setImage
            UIImage * resizedImage = [image resizedImage:image.size interpolationQuality: kCGInterpolationHigh];
            [view setImage:resizedImage];
        }

    [self.view addSubview:view];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    
    UIView *view = [self.view viewWithTag:100];
    [view removeFromSuperview];
    view = nil;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self addView];
}
@end
