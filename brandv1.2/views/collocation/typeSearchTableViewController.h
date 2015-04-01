//
//  typeSearchTableViewController.h
//  brandv1.2
//
//  Created by Apple on 14-8-9.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface typeSearchTableViewController : UITableViewController
-(void)initView:(int)type;
-(void)initViewWithData:(int)type data:(NSMutableArray *)data;
@end
