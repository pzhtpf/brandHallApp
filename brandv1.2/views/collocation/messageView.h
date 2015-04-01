//
//  messageView.h
//  brandv1.2
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface messageView : UIView<UIGestureRecognizerDelegate,UIScrollViewDelegate>{
	
	
}
-(void)configView:(NSMutableArray *)data;
-(void)getMessageList:(id)sender;
@end
