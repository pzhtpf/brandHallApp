//
//  beautifyPictureDetailViewController.h
//  brandv1.2
//
//  Created by Apple on 15/3/6.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface beautifyPictureDetailViewController : UIViewController<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>{

    BOOL _bpIsHidden;
    BOOL _bpCanMove;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;

}
-(void)initView:(NSDictionary *)data;
@property (strong, nonatomic) IBOutlet UIImageView *mainImageView;
- (IBAction)backAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)accountAction:(id)sender;
- (IBAction)settingAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *mainUpView;
@property (strong, nonatomic) IBOutlet UILabel *upTopBackLabel;
@property (strong, nonatomic) IBOutlet UILabel *bgName;
@property (strong, nonatomic) IBOutlet UILabel *bgCreateTime;
@property (strong, nonatomic) IBOutlet UILabel *bgStyle;
- (IBAction)bgFavoriteAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *bpDescription;
@property (strong, nonatomic) IBOutlet UITextView *bpCommentTextView;
@property (strong, nonatomic) IBOutlet UILabel *inputCommentTip;
@property (strong, nonatomic) IBOutlet UIView *bpCommentView;
@property (strong, nonatomic) IBOutlet UITableView *bpCommentTableView;
@property (strong, nonatomic) IBOutlet UILabel *bpCommentTotalCount;
@property (strong, nonatomic) IBOutlet UIButton *bpFavotiteButton;
@end
