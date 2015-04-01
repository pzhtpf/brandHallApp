#import <Foundation/Foundation.h>

@class CWPageController;

@interface CWPageModel : NSObject <UIPageViewControllerDataSource>

@property (strong, nonatomic) NSArray *pageContent;
- (void) createContentPages:(NSMutableArray *)array ;
- (CWPageController *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfViewController:(CWPageController *)viewController;
@end