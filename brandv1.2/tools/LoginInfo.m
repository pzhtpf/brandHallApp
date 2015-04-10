//
//  LoginInfo.m
//  GaiaPad
//
//  Created by Mac on 12/8/28.
//  Copyright (c) 2012年 BanQ Guru Leo. All rights reserved.
//

#import "LoginInfo.h"

@implementation LoginInfo
@synthesize userName,apiToken,cookieName,cookieValue;
@synthesize password,isAutoLogin,serverUrl,domain,lang,isLogin,isPush,productViewData,url,planViewData,housesViewData,deviceToken,allMessage,selected,isWiFi,message,planSearchType,productAllData,collocationType,productSearchType,housesSearchType,houseSearch,planSearch,productSearch,lanuchImages,productData,housesdetailcontroller,isMirror,hideArray,progressBarView,permissionsMutableArray,defaultPermissionsMutableArray,housesListSearch,housesListDetailViewData,dataFromPlanTable,downloadingViewData,isDownloadComplete,isRedownload,progressArray,downloadList,isOfflineMode,housesType,downloadType,enableDownload,downloadListViewData,classicPlanSearchType,housesClassicSearch,isTouching,mySegmented,topBarView,notificationQueue,isProductDetail,productIsZoom,bpAllData,keyBoardIsShow,portrait,userType,userId,userAccount,brandName,brand_logo_app,allDownloadedImage,downloadedImage,housesMapView,arrFileDownloadData,tempArrFileDownloadData;

-(void) superDealloc{
    userName=nil;
    apiToken=nil;
    cookieName=nil;
    cookieValue=nil;
    url=nil;
    password =nil;
    serverUrl = nil;
    domain = nil;
    planViewData= nil;
    productAllData = nil;
    productSearchType = nil;
    housesSearchType = nil;
    houseSearch = nil;
    planSearch = nil;
    productSearch = nil;
    lanuchImages = nil;
    hideArray = nil;
    progressBarView = nil;
    housesdetailcontroller = nil;
    productData = nil;
    housesViewData = nil;
    planViewData = nil;
    productViewData = nil;
    permissionsMutableArray = nil;
    defaultPermissionsMutableArray = nil;
    housesListDetailViewData = nil;
    dataFromPlanTable = nil;
    downloadingViewData = nil;
    downloadList = nil;
    downloadListViewData = nil;
    classicPlanSearchType = nil;
    housesClassicSearch = nil;
    mySegmented = nil;
    topBarView = nil;
    notificationQueue = nil;
    bpAllData = nil;
    keyBoardIsShow = false;
    portrait = nil;
    userType = nil;
    userId = nil;
    userAccount = nil;
    brandName =nil;
    brand_logo_app =nil;
    downloadedImage = nil;
    allDownloadedImage = nil;
    housesMapView = nil;
    arrFileDownloadData = nil;
    tempArrFileDownloadData = nil;
}

@end
