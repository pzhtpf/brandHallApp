//
//  beautifyPicture.h
//  brandv1.2
//
//  Created by Apple on 15/3/6.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface beautifyPicture : UIView<UIGestureRecognizerDelegate,UIScrollViewDelegate>
-(void)configView:(NSMutableArray *)data;
-(void)getMessageList:(id)sender searchText:(NSString *)searchArg;
@end
