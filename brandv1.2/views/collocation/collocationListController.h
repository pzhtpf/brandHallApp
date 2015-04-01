//
//  collocationListController.h
//  brandv1.2
//
//  Created by Apple on 14-8-13.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface collocationListController : UIViewController
-(void)initView:(NSMutableArray *)data;
- (IBAction)backAction:(id)sender;
- (IBAction)backIconAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *collocationListTitle;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@end
