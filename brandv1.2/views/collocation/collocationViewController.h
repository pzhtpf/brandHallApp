//
//  collocationViewController.h
//  brandv1.2
//
//  Created by Apple on 14-7-30.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface collocationViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate,UIPopoverControllerDelegate,UIAlertViewDelegate,UIAccelerometerDelegate>
-(void)initView:(NSDictionary *)data;
@property(nonatomic,weak)NSDictionary *collocationData;
@property (retain, nonatomic) NSString *elementId;
@property (retain, nonatomic) NSString *planId;
@property (retain, nonatomic) NSString *angle;
@property (retain, nonatomic) NSString *selectedDaPeiImagePath;
@property (retain, nonatomic) NSMutableArray *elemensArray;
@property (strong, nonatomic) NSNumber *elemenSelected;
@property (strong, nonatomic) NSArray *ElementsList;
@property (strong, nonatomic) NSMutableArray *hotPic;
@property (strong, nonatomic) NSMutableArray *elements;
@property (strong, nonatomic) NSArray *elementsGoods;
@property (strong, nonatomic)  NSMutableArray *goods;
@property (strong, nonatomic)  UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic)  UIScrollView *myscrollview;
@end
