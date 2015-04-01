//
//  ProgressBarView.h
//  brandv1.2
//
//  Created by Apple on 14-10-14.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressBarView : UIView
-(void)setTip:(NSString *)tip;
@property (retain, nonatomic) UIImageView *progressView;
@property (retain, nonatomic) UILabel *tips;
@end
