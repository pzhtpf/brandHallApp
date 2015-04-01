//
//  pageControl.m
//  brandv1.2
//
//  Created by Apple on 14-9-13.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "pageControl.h"

@implementation pageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setPageCount:(int)pageCount{
    
    
    UIView *temp = [self viewWithTag:400];
    if(temp){
        [temp removeFromSuperview];
    }
    
    if(pageCount>1){
        UIView *view = [[UIView alloc] init];
        view.tag = 400;
        
        for(int i =0;i<pageCount;i++){
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*15,5, 10, 10)];
            imageView.tag = i;
            NSString *hotimagepath = [[NSBundle mainBundle]pathForResource:@"点2.png" ofType:@""];
            if(i == 0){
                hotimagepath = [[NSBundle mainBundle]pathForResource:@"点1.png" ofType:@""];
            }
            UIImage *image = [UIImage imageWithContentsOfFile:hotimagepath];
            imageView.image =image;
            [view addSubview:imageView];
        }
        int width = pageCount*15;
      //  [view setCenter:self.center];
        view.frame= CGRectMake(self.frame.size.width/2-width/2,0, width, 20);
        
        [self addSubview:view];
    }

   
}
-(void)setSelected:(int)pageSelected{

    UIView *temp = [self viewWithTag:400];
    NSArray *allSubViews = [temp subviews];
    for(UIImageView *temp in allSubViews){
        
        NSString *hotimagepath = [[NSBundle mainBundle]pathForResource:@"点2.png" ofType:@""];
        if(temp.tag == pageSelected){
            hotimagepath = [[NSBundle mainBundle]pathForResource:@"点1.png" ofType:@""];
        }
        UIImage *image = [UIImage imageWithContentsOfFile:hotimagepath];
        temp.image =image;
        
        
    }
}

@end
