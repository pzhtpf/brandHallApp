#import <UIKit/UIKit.h>

@interface productDisplayViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UILabel *totalCount;
@property (strong, nonatomic) IBOutlet UIButton *menu;
@property (strong, nonatomic) IBOutlet UISearchBar *productSearchBar;
@property (strong, nonatomic) IBOutlet UILabel *productTips;
- (IBAction)productButtonAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *productButton;
- (IBAction)settingAction:(id)sender;
- (IBAction)accountAction:(id)sender;
- (IBAction)shoppingAction:(id)sender;
- (IBAction)searchAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *searchBorderImage;
@property (strong, nonatomic) IBOutlet UITextField *searchText;
- (IBAction)orderByAction:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *orderByTextLabel;
@property (strong, nonatomic) IBOutlet UIButton *dropArrowButton;
@property (strong, nonatomic) IBOutlet UIView *mainTableView;
@property (strong, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *brandLogo;
@end