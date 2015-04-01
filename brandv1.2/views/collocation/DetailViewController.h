//
//  DetailViewController.h
//  brandv1.2
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWPageModel.h"

@interface DetailViewController : UIViewController<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>
- (IBAction)back:(id)sender;
-(void)initView:(int)id;
@property (strong, nonatomic) IBOutlet UILabel *fName;
@property (strong, nonatomic) IBOutlet UILabel *style;
@property (strong, nonatomic) IBOutlet UILabel *size;
@property (strong, nonatomic) IBOutlet UILabel *authorName;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,retain) UIPageViewController *pageController;
@property (nonatomic,retain) CWPageModel    *pModel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mySegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *statusBar;
@property (strong, nonatomic) IBOutlet UIButton *back;
@property (strong, nonatomic) IBOutlet UIView *goodsView;
@property (strong, nonatomic) NSDictionary *goods;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
- (IBAction)backIcon:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *detailTitle;
@property (strong, nonatomic) IBOutlet UIButton *collocationButton;
- (IBAction)collocationButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *detailButton;
- (IBAction)detailButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *mainPlanName;
@property (strong, nonatomic) IBOutlet UIView *mainViewBack;
@property (strong, nonatomic) IBOutlet UIScrollView *mainViewScroll;
@property (strong, nonatomic) IBOutlet UIScrollView *huxingScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *huxingImageView;
@property (strong, nonatomic) IBOutlet UILabel *huxingLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *detailScrollView;
- (IBAction)detailBackAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *mainInfoView;
@property (strong, nonatomic) IBOutlet UIView *mainGoodsView;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalGoodsCount;
@property (strong, nonatomic) IBOutlet UIButton *firstButton;
- (IBAction)firstAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *secondButton;
- (IBAction)secondAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *thridButton;
- (IBAction)thridAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *fourButton;
- (IBAction)fourAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *favoriteButton;
- (IBAction)favoriteAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)moreAction:(id)sender;
@end
