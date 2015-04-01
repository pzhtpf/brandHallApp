#import <UIKit/UIKit.h>
#import "collocationViewController.h"
#import "DetailViewController.h"

@interface SecondViewController : UIViewController<UITextFieldDelegate,UIPopoverControllerDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) collocationViewController *collocation;
@property (strong, nonatomic) DetailViewController *planDetail;
@property (strong, nonatomic) IBOutlet UIView *topBarViewBack;
@property (strong, nonatomic) IBOutlet UILabel *topBarLabel;
- (IBAction)retrievalAction:(id)sender;
- (IBAction)searchAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)accountAction:(id)sender;
- (IBAction)settingAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *searchBorder;
@property (strong, nonatomic) IBOutlet UITextField *searchText;
@property (strong, nonatomic) IBOutlet UIButton *retrievalButton;
@property (strong, nonatomic) IBOutlet UIImageView *brandLogo;
@property (strong, nonatomic) IBOutlet UILabel *brandLabelLabel;
@end