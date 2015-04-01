#import "CWPageModel.h"
#import "CWPageController.h"

@implementation CWPageModel
@synthesize pageContent;

- (void) createContentPages:(NSMutableArray *)array {
    pageContent = [[NSArray alloc] initWithArray:array];
}

- (id) init {
    if (self = [super init]) {
     //   [self createContentPages];
    }
    return self;
}



- (CWPageController *)viewControllerAtIndex:(NSUInteger)index {
    // Return the data view controller for the given index.
    if (([self.pageContent count] == 0) ||
        (index >= [self.pageContent count])) {
        return nil;
    }
    // Create a new view controller and pass suitable data.
    CWPageController *dataViewController =[[CWPageController alloc] init];
    dataViewController.dataObject =
    [self.pageContent objectAtIndex:index];
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(CWPageController *)viewController {
    return [self.pageContent
            indexOfObject:viewController.dataObject];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:
                        (CWPageController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    if(index >-1){
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pageChanged" object:[NSNumber numberWithInt:index]];
    }
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:
                        (CWPageController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.pageContent count]) {
        return nil;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pageChanged" object:[NSNumber numberWithInt:index]];
    return [self viewControllerAtIndex:index];
}

@end