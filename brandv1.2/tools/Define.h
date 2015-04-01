#define DEBUG							1

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define SLog(...) NSLog((@"[Line %d] %@"),  __LINE__, ##__VA_ARGS__);
#define NLog(...) NSLog((@"[Line %d] %d"),  __LINE__, ##__VA_ARGS__);

#else
#define DLog(...)
#endif

//#define BASEURL                         @"http://www.local-gez.cn/home/"
//#define Domain                          @"www.local-gez.cn"
#define Domain                          @"newapp.gezlife.com"
#define BASEURL                         @"http://newapp.gezlife.com/home/"
#define loginApi                        @"cbrand/applogin"
#define planType                        @"cbrand/appSerCon"
#define planMessageListApi              @"cbrand/appRecplan"
#define planDetailApi                   @"cbrand/planDetail"
#define initCollocationApi              @"cbrand/matchDetail"
#define getCollocationElementApi        @"cbrand/matchList"
#define getProductListApi               @"cbrand/productList"
#define getProductDetailApi             @"cbrand/productDetail"
#define getHousesListApi                @"cbrand/propertyList"
#define getHousesTypeApi                @"cbrand/serConProperty"
#define getHousesDetailApi              @"cbrand/propertyDetail"
#define getProductTypeApi               @"cbrand/proSerCon"
#define getHousesHuTypeApi              @"cbrand/houseType"
#define getPlanProductApi               @"cbrand/initProduct"
#define getLanuchApi                    @"cbrand/initImg"
#define permissionsControlApi           @"cbrand/permissionsControl"
#define getDownloadHousesListApi        @"cbrand/getHousesList"
#define getHousesListDetailApi          @"cbrand/getHousesDetail"
#define judgeHousesListApi              @"cbrand/judgeHousesList"
#define getClassicDataApi               @"cbrand/getClassicData"
#define checkVersionApi                 @"cbrand/checkVersion"
#define downRecordApi                   @"cbrand/downRecord"
#define getCasesListApi                 @"cbrand/getCasesList"
#define getCasesDetailApi               @"cbrand/getCasesDetail"
#define getCommentApi                   @"cbrand/getComment"
#define saveCommentApi                  @"cbrand/saveComment"
#define changeFavoriteApi               @"cbrand/changeFavorite"
#define regLoginApi                     @"cbrand/regLogin"
#define checkSendApi                    @"cbrand/checkSend"
#define saveRegApi                      @"cbrand/saveReg"
#define brandhallDetailApi              @"cbrand/brandhallDetail"
#define saveFeedbackApi                 @"cbrand/saveFeedback"
#define imageUrl                        @"http://image.gezlife.com/"
#define staticImageUrl                  @"http://static.gezlife.com/"

#define defaultPermissionsArray         [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:2],[NSNumber numberWithInt:5],nil];
#define permissionsArray                  [[NSMutableArray alloc] initWithObjects:@"app/shop",@"/plan/index",@"product/index",@"app/property",@"self/design",@"app/beautify",@"app/offline", nil];
//#define loginApi                        @"http://mall.local-gez.cn/cbrand/applogin"
//#define planType                        @"http://mall.local-gez.cn/cbrand/appSerCon"
//#define planMessageListApi              @"http://mall.local-gez.cn/cbrand/appRecplan"
//#define planDetailApi                   @"http://mall.local-gez.cn/cbrand/planDetail"
//#define initCollocationApi              @"http://mall.local-gez.cn/cbrand/matchDetail"
//#define getCollocationElementApi        @"http://mall.local-gez.cn/cbrand/matchList"
//#define getProductListApi               @"http://mall.local-gez.cn/cbrand/productList"
//#define getProductDetailApi             @"http://mall.local-gez.cn/cbrand/productDetail"
//#define getHousesListApi                @"http://mall.local-gez.cn/cbrand/propertyList"
//#define getHousesTypeApi                @"http://mall.local-gez.cn/cbrand/serConProperty"
//#define getHousesDetailApi              @"http://mall.local-gez.cn/cbrand/propertyDetail"
//#define getProductTypeApi               @"http://mall.local-gez.cn/cbrand/proSerCon"
//#define getHousesHuTypeApi              @"http://mall.local-gez.cn/cbrand/houseType"
//#define getPlanProductApi              @"http://mall.local-gez.cn/cbrand/initProduct"
//#define getLanuchApi                    @"http://mall.local-gez.cn/cbrand/initImg"

#define PROCESSAPPLYURL                 @"/bpm/applyform?moduleType=apply"
#define QUERYAPPLYURL                   @"/bpm/traceapply"
#define QUERYSIGNURL                    @"/bpm/traceapprove?type=approve"
#define QUERYCCURL                      @"/bpm/tracecopyto"
#define PROCESSSIGNURL                  @"/bpm/approve"
#define INBOXURL                        @"/ic/inBox/list"
#define UIColorFromRGB(rgbValue)        [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define	ISPAD							(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define DEVICE_ORIENTATION				[[UIApplication sharedApplication] 	statusBarOrientation]
#define	ISPORTRAIT						(DEVICE_ORIENTATION == UIInterfaceOrientationPortrait || DEVICE_ORIENTATION == UIInterfaceOrientationPortraitUpsideDown)

#define SCREEN_FRAME					(ISPORTRAIT?IPAD_PORTRAIT_FRAME:IPAD_LANDSCAPE_FRAME)
#define SCREEN_SIZE						(ISPORTRAIT?IPAD_PORTRAIT_SIZE:IPAD_LANDSCAPE_SIZE)
#define SCREEN_WIDTH					(ISPORTRAIT?IPAD_PORTRAIT_WIDTH:IPAD_LANDSCAPE_WIDTH)
#define SCREEN_HEIGHT					(ISPORTRAIT?IPAD_PORTRAIT_HEIGHT:IPAD_LANDSCAPE_HEIGHT)
#define	SCREEN_HEIGHT_NO_STATUS			(SCREEN_HEIGHT)

#define	IPAD_PORTRAIT_FRAME				(CGRect){CGPointZero,   IPAD_PORTRAIT_WIDTH,	IPAD_PORTRAIT_HEIGHT}
#define	IPAD_LANDSCAPE_FRAME			(CGRect){CGPointZero,   IPAD_LANDSCAPE_WIDTH,	IPAD_LANDSCAPE_HEIGHT}

#define	IPAD_SIZE						(ISPORTRAIT?IPAD_PORTRAIT_SIZE:IPAD_LANDSCAPE_SIZE)
#define	IPAD_WIDTH						(ISPORTRAIT?IPAD_PORTRAIT_WIDTH:IPAD_LANDSCAPE_WIDTH)
#define	IPAD_HEIGHT						(ISPORTRAIT?IPAD_PORTRAIT_HEIGHT:IPAD_LANDSCAPE_HEIGHT)

#define	IPAD_PORTRAIT_SIZE				(CGSize){IPAD_PORTRAIT_WIDTH,	IPAD_PORTRAIT_HEIGHT}
#define	IPAD_LANDSCAPE_SIZE				(CGSize){IPAD_LANDSCAPE_WIDTH,	IPAD_LANDSCAPE_HEIGHT}

#define	ISPAD							(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define DEVICE_ORIENTATION				[[UIApplication sharedApplication] 	statusBarOrientation]
#define	ISPORTRAIT						(DEVICE_ORIENTATION == UIInterfaceOrientationPortrait || DEVICE_ORIENTATION == UIInterfaceOrientationPortraitUpsideDown)

#define	IPAD_PORTRAIT_WIDTH				([[UIScreen  mainScreen] applicationFrame].size.width)	//(ISPAD?768:320)
#define	IPAD_PORTRAIT_HEIGHT			([[UIScreen  mainScreen] applicationFrame].size.height)	//(ISPAD?1004:460)

#define	IPAD_LANDSCAPE_WIDTH			([[UIScreen  mainScreen] applicationFrame].size.height)	//(ISPAD?1024:480)
#define	IPAD_LANDSCAPE_HEIGHT			([[UIScreen  mainScreen] applicationFrame].size.width)	//(ISPAD?748:300)

#define	KEYBOARD_HEIGHT					(ISPAD?IPAD_KEYBOARD_HEIGHT:IPHONE_KEYBOARD_HEIGHT)
#define	IPAD_KEYBOARD_HEIGHT			(ISPORTRAIT?264:352)
#define	IPHONE_KEYBOARD_HEIGHT			(ISPORTRAIT?216:162)


#define NPLocalizedString(str)			NSLocalizedString(str, "")

#define DEVICE_IDENTIFIER               [[UIDevice currentDevice]  uniqueIdentifier]
#define BOUNDLE_VERSION					[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#define USER_DEFAULT(str)               [[NSUserDefaults standardUserDefaults] objectForKey:str]
#define USER_DEFAULT_STORE(value, str)  [[NSUserDefaults standardUserDefaults] setObject:value forKey:str];[[NSUserDefaults standardUserDefaults] synchronize];
#define USER_DEFAULT_REMOVE(str)        [[NSUserDefaults standardUserDefaults] removeObjectForKey:str];[[NSUserDefaults standardUserDefaults] synchronize];

#define	OPEN_URL(URL)                   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]]





