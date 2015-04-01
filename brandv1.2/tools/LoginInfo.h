//
//  LoginInfo.h
//  GaiaPad
//
//  Created by Mac on 12/8/28.
//  Copyright (c) 2012年 BanQ Guru Leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "housesDetailController.h"
#import "ProgressBarView.h"
#import <MapKit/MapKit.h>

@interface LoginInfo : NSObject

-(void) superDealloc;

@property (retain, nonatomic) NSString *userId;
@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) NSString *userAccount;
@property (retain, nonatomic) NSString *apiToken;
@property (retain, nonatomic) NSString *cookieName;
@property (retain, nonatomic) NSString *cookieValue;
@property (retain, nonatomic) NSString *password;
@property (assign, nonatomic) BOOL isAutoLogin;//是否自動登入
@property (retain, nonatomic) NSString *serverUrl;
@property (retain, nonatomic) NSString *domain;
@property (retain, nonatomic) NSString *portrait;
@property (retain, nonatomic) NSString *brandName;
@property (retain, nonatomic) NSString *brand_logo_app;
@property (retain, nonatomic) NSString *userType;
@property (assign, nonatomic) NSInteger lang;
@property (assign, nonatomic) BOOL isPush;
@property (retain, nonatomic) NSString *url;
@property (assign, nonatomic) BOOL isLogin;//是否已經登入
@property (strong, nonatomic) NSMutableArray *productViewData;
@property (strong, nonatomic) NSMutableArray *planViewData;
@property (strong, nonatomic) NSMutableArray *bpAllData;
@property (strong, nonatomic) NSMutableArray *housesViewData;
@property (strong, nonatomic) NSMutableArray *downloadingViewData;
@property (strong, nonatomic) NSMutableArray *housesListDetailViewData;
@property (strong, nonatomic) NSMutableArray *downloadListViewData;
@property (strong, nonatomic) housesDetailController *housesdetailcontroller;
@property (assign, nonatomic) NSString *deviceToken;
@property (retain, nonatomic) NSMutableArray *allMessage;
@property (retain, nonatomic) NSArray *message;
@property (retain, nonatomic) NSMutableArray *planSearchType;
@property (retain, nonatomic) NSArray *classicPlanSearchType;
@property (retain, nonatomic) NSArray *productAllData;
@property (assign, nonatomic) NSInteger selected;
@property (assign, nonatomic) BOOL isWiFi;
@property (assign, nonatomic) NSInteger collocationType;
@property (retain, nonatomic) NSMutableArray *productSearchType;
@property (retain, nonatomic) NSArray *housesSearchType;
@property (assign, nonatomic) NSString *planSearch;
@property (assign, nonatomic) NSString *productSearch;
@property (assign, nonatomic) NSString *houseSearch;
@property (assign, nonatomic) NSString *loadingName;
@property (retain, nonatomic) NSMutableArray *lanuchImages;
@property (retain, nonatomic) NSMutableArray *productData;
@property (assign, nonatomic) BOOL isMirror;
@property (retain, nonatomic) NSMutableArray *hideArray;
@property (retain, nonatomic) ProgressBarView *progressBarView;
@property (retain, nonatomic) NSMutableArray *permissionsMutableArray;
@property (retain, nonatomic) NSMutableArray *defaultPermissionsMutableArray;
@property (retain, nonatomic) NSString *housesListSearch;
@property (retain, nonatomic) NSString *housesClassicSearch;
@property (retain, nonatomic) NSMutableDictionary *dataFromPlanTable;
@property (assign, nonatomic) BOOL isDownloadComplete;
@property (assign, nonatomic) BOOL isRedownload;
@property (assign, nonatomic) BOOL isTouching;
@property (retain, nonatomic) NSMutableDictionary *progressArray;
@property (retain, nonatomic) NSMutableDictionary *downloadList;
@property (retain, nonatomic) NSMutableDictionary *downloadedImage;
@property (assign, nonatomic) BOOL isOfflineMode;
@property (assign, nonatomic) int housesType;
@property (assign, nonatomic) int downloadType;     // 户型列表，3；经典样板间，1；
@property (assign, nonatomic) int enableDownload;     // 0，没有下载权限；1，有下载权限；
@property (strong, nonatomic) UISegmentedControl *mySegmented;
@property (strong, nonatomic) UIView *topBarView;
@property (strong, nonatomic) NSMutableDictionary *notificationQueue;
@property (assign, nonatomic) BOOL isProductDetail;
@property (assign, nonatomic) BOOL productIsZoom;
@property (assign, nonatomic) BOOL keyBoardIsShow;
@property (retain, nonatomic) NSMutableDictionary *allDownloadedImage;
@property (retain, nonatomic) MKMapView *housesMapView;
@end
