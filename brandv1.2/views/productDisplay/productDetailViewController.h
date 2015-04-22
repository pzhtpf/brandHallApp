//
//  productDetailViewController.h
//  brandv1.2
//
//  Created by Apple on 14-8-8.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "collocationViewController.h"
#import "CWPageModel.h"

@interface productDetailViewController : UIViewController<UIScrollViewDelegate,UIPageViewControllerDelegate,UIPageViewControllerDataSource>
-(void)initView:(NSArray *)data;
- (IBAction)back:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *viewScroll;

@property (strong, nonatomic) UILabel *brandName;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *disprice;
@property (strong, nonatomic) IBOutlet UILabel *size;
@property (strong, nonatomic) IBOutlet UILabel *count;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *fitRoom;
@property (strong, nonatomic) IBOutlet UILabel *height;
@property (strong, nonatomic) IBOutlet UILabel *style;
@property (strong, nonatomic) IBOutlet UILabel *material;
@property (strong, nonatomic) IBOutlet UILabel *productAddress;
@property (strong, nonatomic) IBOutlet UILabel *function;
@property (strong, nonatomic) IBOutlet UILabel *careText;
@property (strong, nonatomic) IBOutlet UITextView *adress;
@property (strong, nonatomic) IBOutlet UILabel *phone;
@property (strong, nonatomic) IBOutlet UILabel *functionText;
@property (strong, nonatomic) IBOutlet UILabel *addressText;
@property (strong, nonatomic) IBOutlet UILabel *phoneText;
@property (strong, nonatomic) IBOutlet UILabel *careLabel;
@property (strong, nonatomic) IBOutlet UILabel *materialText;
@property (strong, nonatomic) IBOutlet UILabel *styleText;
@property (strong, nonatomic) IBOutlet UILabel *sizeText;
@property (strong, nonatomic) IBOutlet UILabel *remianText;
@property (strong, nonatomic) IBOutlet UILabel *fitRoomText;
@property (strong, nonatomic) IBOutlet UILabel *priceText;
@property (strong, nonatomic) IBOutlet UILabel *weightText;
@property (strong, nonatomic) IBOutlet UILabel *productAddressText;
@property (strong, nonatomic)  collocationViewController *collocation;
@property (nonatomic,retain) UIPageViewController *pageController;
@property (nonatomic,retain) CWPageModel    *pModel;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)settingAction:(id)sender;
- (IBAction)accountAction:(id)sender;
- (IBAction)shoppingAction:(id)sender;
- (IBAction)shareAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *imagePreviewBack;
- (IBAction)favoriteAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *productFavoriteButton;
@property (strong, nonatomic) UIButton *love;
@property (strong, nonatomic) IBOutlet UIButton *accountButton;
@end
