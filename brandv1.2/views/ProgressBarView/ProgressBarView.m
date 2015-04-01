//
//  ProgressBarView.m
//  brandv1.2
//
//  Created by Apple on 14-10-14.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "ProgressBarView.h"

@implementation ProgressBarView
UIActivityIndicatorView *activityIndicator;
UIView *view ;
@synthesize  progressView;
@synthesize tips;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // Do any additional setup after loading the view.
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.width)];
        
        [view setTag:108];
        // [view setBackgroundColor:[UIColor blackColor]];
        //  [view setAlpha:0.7];
        progressView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.height/2-50),self.frame.size.width/2-50, 100,100)];
        [progressView setCenter:view.center];
        NSString *hotimagepath = [[NSBundle mainBundle]pathForResource:@"progressView.png" ofType:@""];
        UIImage *image = [UIImage imageWithContentsOfFile:hotimagepath];

        [progressView setImage:image];
        
        [self addSubview:progressView];
        
        [self addSubview:view];
        
        
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [activityIndicator setCenter:view.center];
        activityIndicator.frame = CGRectMake(activityIndicator.frame.origin.x, activityIndicator.frame.origin.y-10, 32.0f, 32.0f);
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [view addSubview:activityIndicator];
        
        [activityIndicator startAnimating];
        
        tips = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,30)];
        [tips setBackgroundColor:[UIColor clearColor]];
        [tips setCenter:view.center];
        tips.frame = CGRectMake(tips.frame.origin.x, tips.frame.origin.y +15,100, 30);
        [tips setTag:109];
        [tips setTextColor:[UIColor whiteColor]];
        tips.textAlignment = NSTextAlignmentCenter;
        tips.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
        [self addSubview:tips];

    }
    return self;
}
-(void)setTip:(NSString *)tip{
    
   
    tips.text=tip;
    
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
