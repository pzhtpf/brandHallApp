//
//  lanuchImageController.h
//  brandv1.2
//
//  Created by Apple on 14-9-27.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWPageModel.h"
#import <MessageUI/MessageUI.h> 
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ISSShareViewDelegate.h>

@class AppDelegate;


@interface lanuchImageController : UIViewController<UIPageViewControllerDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate,MFMailComposeViewControllerDelegate,UIPopoverControllerDelegate,UIScrollViewDelegate,ISSShareViewDelegate>{

}
@property (nonatomic,retain) UIPageViewController *pageController;
@property (nonatomic,retain) CWPageModel    *pModel;

@end
