//
//  downloading.h
//  brandv1.2
//
//  Created by Apple on 14-11-19.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface downloading : UIViewController<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate,UIScrollViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *back;
- (IBAction)backAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *backIconAction;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *clear;
- (IBAction)clearAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *delete;
- (IBAction)deleteAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *complete;
- (IBAction)completeAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *downloadingTable;
@property (strong, nonatomic) IBOutlet UILabel *totalCaptiy;
@property (strong, nonatomic) IBOutlet UILabel *otherApp;
@property (strong, nonatomic) IBOutlet UILabel *thisApp;
@property (strong, nonatomic) IBOutlet UILabel *remainApp;
@property (strong, nonatomic) IBOutlet UILabel *totalText;
@property (strong, nonatomic) NSMutableArray *downloadingAllData;
@property (strong, nonatomic) IBOutlet UIView *planSelectView;
@property (strong, nonatomic) IBOutlet UIImageView *planSelectImageView;
@property (strong, nonatomic) IBOutlet UILabel *planSelectHousesName;
@property (strong, nonatomic) IBOutlet UILabel *planSelectAddress;
@property (strong, nonatomic) IBOutlet UILabel *planSelectSize;
@property (strong, nonatomic) IBOutlet UILabel *planSelectCounts;
- (IBAction)planSelectCloseAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) IBOutlet UIScrollView *mapScrollView;
- (IBAction)mapBackAction:(id)sender;
- (IBAction)mapPreviewAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *planSelectMainView;
@property (strong, nonatomic) IBOutlet UILabel *planSelectGoodCount;
- (IBAction)settingAction:(id)sender;
- (IBAction)accountAction:(id)sender;
- (IBAction)searchAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *searchBorder;
@property (strong, nonatomic) IBOutlet UITextField *searchText;
@property (strong, nonatomic) IBOutlet UILabel *downloadTipLabel;
@property (strong, nonatomic) IBOutlet UIView *deleteBackView;
@property (strong, nonatomic) IBOutlet UILabel *deleteTitleLabel;
- (IBAction)topCancelAction:(id)sender;
- (IBAction)backIconAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *accountButton;
@end
