#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark pageController
@interface CWPageController : UIViewController<UIScrollViewDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) id dataObject;

@end