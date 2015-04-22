//
//  housesViewController.h
//  brandv1.2
//
//  Created by Apple on 14-8-16.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "housesDetailController.h"

@interface housesViewController : UIViewController<UIGestureRecognizerDelegate,UISearchBarDelegate,UITextFieldDelegate,UIPopoverControllerDelegate,CLLocationManagerDelegate,MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *totalCount;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *housesButtonAction;
@property (strong, nonatomic)  housesDetailController *housesDetail ;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *menuButton1;
@property (strong, nonatomic) IBOutlet UIView *topBarBackView;
@property (strong, nonatomic) IBOutlet UILabel *topBarTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)searchButtonAction:(id)sender;
- (IBAction)searchIconAction:(id)sender;
- (IBAction)accountAction:(id)sender;
- (IBAction)settingAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *searchText;
- (IBAction)showConidition:(id)sender;
//@property (strong, nonatomic) IBOutlet MKMapView *housesMapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIView *mainSearchView;
@property (strong, nonatomic) IBOutlet UIView *searchCenterMainView;
@property (strong, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *privinceSelectButton;
- (IBAction)privinceSelectAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *citySelectButton;
- (IBAction)citySelectAction:(id)sender;
- (IBAction)searchTrueAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *searchTrueButton;
@property (strong, nonatomic) IBOutlet UIView *searchMainBack;
- (IBAction)closeSearchViewAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *searchFieldBackView;
@property (strong, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *brandLogo;
@property (strong, nonatomic) IBOutlet UIButton *accountButton;
@end
