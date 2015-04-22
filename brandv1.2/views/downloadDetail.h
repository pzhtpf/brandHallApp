//
//  downloadDetail.h
//  brandv1.2
//
//  Created by Apple on 14-11-13.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@protocol RNSwipeBarDelegate

@optional

- (void)swipeBarDidAppear:(id)sender;
- (void)swipeBarDidDisappear:(id)sender;
- (void)swipebarWasSwiped:(id)sender;

@end

@interface downloadDetail : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UIScrollViewDelegate,EGORefreshTableHeaderDelegate>{
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isHidden;
    BOOL _canMove;
    float _height;
    float _padding;
    float _animationDuration;
    BOOL _reloading;
}
@property (weak, nonatomic) NSObject <RNSwipeBarDelegate> *delegate;
@property (strong, nonatomic) NSMutableArray *housesListDetailAllData;
@property (strong, nonatomic) IBOutlet UIImageView *housesIcon;
@property (strong, nonatomic) IBOutlet UILabel *housesName;
@property (strong, nonatomic) IBOutlet UILabel *housesAddress;
@property (strong, nonatomic) IBOutlet UILabel *nameTypeSize;
@property (strong, nonatomic) IBOutlet UIButton *button18;
@property (strong, nonatomic) IBOutlet UIButton *previewMapButton;
- (IBAction)previewMapAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *accountButton;

- (IBAction)button18Action:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *count;
@property (strong, nonatomic) IBOutlet UILabel *label18;
@property (strong, nonatomic) IBOutlet UIButton *button916;
- (IBAction)button916Action:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *label916;
@property (strong, nonatomic) IBOutlet UITableView *housesListDetailTable;
- (IBAction)selectAllButton:(id)sender;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmented;
@property (strong, nonatomic) IBOutlet UIImageView *bar_gray;
- (IBAction)startDownload:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *bar_yellow;
@property (strong, nonatomic) IBOutlet UIImageView *bar_blue;
@property (strong, nonatomic) IBOutlet UILabel *capticy;

@property (strong, nonatomic) IBOutlet UILabel *housesListLabel;
@property (strong, nonatomic) IBOutlet UIButton *startDownload;
@property (strong, nonatomic) IBOutlet UIButton *selectAll;
-(void)initCGRect:(CGRect)frame data:(NSDictionary *)data downloadStatus:(NSString *)downloadStatus image:(UIImage *)image;
- (IBAction)closeAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *detailAllView;
@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) IBOutlet UIImageView *mapImageView;
@property (strong, nonatomic) IBOutlet UIButton *mapViewBackButton;
- (IBAction)mapViewBackAction:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *planName;
@property (strong, nonatomic) IBOutlet UILabel *planSize;
@property (strong, nonatomic) IBOutlet UILabel *goodsCount;
@property (strong, nonatomic) IBOutlet UIButton *planStartDownLoad;
- (IBAction)planStartDownLoadAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *planCapticy;
@property (strong, nonatomic) IBOutlet UIView *planDetailView;
@property (strong, nonatomic) IBOutlet UIImageView *planDetailImageView;
@property (strong, nonatomic) IBOutlet UILabel *goodsPreviewLabel;
@property (strong, nonatomic) IBOutlet UISegmentedControl *planDetailSegmented;
@property (strong, nonatomic) IBOutlet UILabel *latestUpdateTime;
@property (strong, nonatomic) IBOutlet UIScrollView *mapZoom;
@property (strong, nonatomic) IBOutlet UIView *otherView;
@property (strong, nonatomic) IBOutlet UILabel *detailTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *planDetailTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *huxingTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *planDetailTime;
- (IBAction)planDetailBackAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *productPreviewView;
@property (strong, nonatomic) IBOutlet UIView *planProductDetail;
@property (strong, nonatomic) IBOutlet UILabel *barBackLabel;
- (IBAction)biaoAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *normalOrHigh;
- (IBAction)settingAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)accountAction:(id)sender;
@end
