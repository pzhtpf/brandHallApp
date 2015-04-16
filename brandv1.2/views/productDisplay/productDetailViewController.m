//
//  productDetailViewController.m
//  brandv1.2
//
//  Created by Apple on 14-8-8.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "productDetailViewController.h"
#import "Define.h"
#import "collocationViewController.h"
#import "pageControl.h"
#import "AFNetworking.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Resize.h"
#import "globalContext.h"
#import "loginViewController.h"

@interface productDetailViewController ()

@end

@implementation productDetailViewController
@synthesize collocation;
@synthesize pageController = _pageController;
@synthesize pModel = _pModel;
UIScrollView *tempScrollView;
UIImageView *imageView ;
NSArray *goodsData ;
int selectedGood = 0;
pageControl *pagecontrol;
LoginInfo *loginInfo;
NSDictionary *productToCollocationData;
int productImageSelectIndex = 0;
NSArray *globalproductImg;
NSString *productId;
loginViewController *loginController;
float planY = 0;
UIView *planView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    goodsData = loginInfo.productData;
    
    planView = [[UIView alloc] initWithFrame:CGRectMake(0,0,343,0)];
    
    self.backButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
    self.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17.0f];
    
    loginInfo.isProductDetail = true;
    loginInfo.productIsZoom  = false;
    
    self.love = [[UIButton alloc] initWithFrame:CGRectMake(939,12,22,20)];
    self.love.tag = 41;
    
    [self.love addTarget:self action:@selector(favoriteAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.love setHidden:true];
    
    [self.imagePreviewBack addSubview:self.love];
    
   }
- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addView:(NSString *)productIdArgs{
    
    productId = productIdArgs;
    
    UIView *tempView = [self.view viewWithTag:67];
    if(tempView != nil){
    [tempView removeFromSuperview];
        tempView = nil;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"product_id":productId};
    
    [manager POST:[BASEURL stringByAppendingString: getProductDetailApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
     //       NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *data = responseObject;
        
        int favorite = [[data objectForKey:@"favorite"] intValue];
        
        [self setFavoriteImage:self.productFavoriteButton status:favorite];
        
            [self settingView:responseObject];
       
            
            [loginInfo.progressBarView removeFromSuperview];
            
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [loginInfo.progressBarView removeFromSuperview];
    }];
    
}
-(void)settingView:(NSDictionary *)selected{

   if(selected != nil){
       
       if(selectedGood ==0){
       
           UIView *leftButton = [self.view viewWithTag:200];
           leftButton.alpha = 0.4;
       }
       else if(selectedGood == loginInfo.productData.count-1){
       
           UIView *rightButton = [self.view viewWithTag:300];
           rightButton.alpha = 0.4;
       }
       else{
       
           UIView *leftButton = [self.view viewWithTag:200];
           leftButton.alpha = 1.0;
           
           UIView *rightButton = [self.view viewWithTag:300];
           rightButton.alpha = 1.0;
       }
       
        tempScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(664,54,343, 641)];
       
       
      if([[selected objectForKey:@"product_img"] isKindOfClass:[NSArray class]])
       {
        NSArray *productImg = [selected objectForKey:@"product_img"];
       NSMutableArray *pageData = [[NSMutableArray alloc] initWithObjects:nil];
        
        for(int i= 0;i<productImg.count;i++){
            NSDictionary *temp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i] ,@"id",productImg[i],@"image",nil];
           [pageData addObject:temp];
       }
        
        
        _pModel = [[CWPageModel alloc] init];
        [_pModel createContentPages:pageData];
        
       
        CWPageController *initialViewController =[_pModel viewControllerAtIndex:0];
        NSArray *viewControllers =[NSArray arrayWithObject:initialViewController];
        [_pageController setDataSource:_pModel];
       
       [_pageController setViewControllers:viewControllers
                                 direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:NO
                                 completion:^(BOOL f){}];
        [self addDot:productImg];
       }
    
       self.productName = [[UILabel alloc] initWithFrame:CGRectMake(0,10,343,30)];
       [self.productName setText:[selected objectForKey:@"product_name"]];
       self.productName.font = [UIFont fontWithName:@"MicrosoftYaHei" size:22.0f];
       [self.productName setTextColor:UIColorFromRGB(0x2B2B2B)];
       [tempScrollView addSubview:self.productName];
       
       self.brandName = [[UILabel alloc] initWithFrame:CGRectMake(0,45,343,30)];
       self.brandName.font = [UIFont fontWithName:@"MicrosoftYaHei" size:22.0f];
       [self.brandName setTextColor:UIColorFromRGB(0x2B2B2B)];
        NSString *brandNameText = [NSString stringWithFormat:@"%@      %@",[selected objectForKey:@"brand_name"],[selected objectForKey:@"sn_num"]];
        [self.brandName setText:brandNameText];
        [tempScrollView addSubview:self.brandName];
       
      float now = [[selected objectForKey:@"promote_price"] floatValue];
       
      int joinButtonY = 0;
       
       
       if(now!=0){
       self.price = [[UILabel alloc] initWithFrame:CGRectMake(0,85,343,20)];
       self.price.font = [UIFont fontWithName:@"MicrosoftYaHei" size:18.0f];
       [self.price setTextColor:UIColorFromRGB(0x2b2b2b)];
        NSString *price = [NSString stringWithFormat:@"RMB %@",[selected objectForKey:@"promote_price"]];
       self.price.font = [UIFont fontWithName:@"MicrosoftYaHei" size:16.0f];
       [self.price setText:price];
        
           NSString *priceString = [selected objectForKey:@"promote_price"];
           
           NSMutableAttributedString *text =
           [[NSMutableAttributedString alloc]
            initWithAttributedString: self.price.attributedText];
           
           [text addAttribute:NSForegroundColorAttributeName
                        value:UIColorFromRGB(0xff0000)
                        range:NSMakeRange(4, priceString.length)];
           [self.price setAttributedText: text];
           
           [tempScrollView addSubview:self.price];

           
           joinButtonY = joinButtonY +20;
           
           
           float original = [[selected objectForKey:@"shop_price"] floatValue];
           
           
           if(original != 0){
               
               self.disprice = [[UILabel alloc] initWithFrame:CGRectMake(0,110,343,20)];
               self.disprice.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
               [self.disprice setTextColor:UIColorFromRGB(0xa6aaae)];
               NSString *disprice = [NSString stringWithFormat:@"市场价: RMB %f",original];
               [self.disprice setText:disprice];
               [tempScrollView addSubview:self.disprice];
               joinButtonY = joinButtonY +30;
           }

       }
       
       
       UIButton *joinshopping = [[UIButton alloc] initWithFrame:CGRectMake(0,140+joinButtonY,343,45)];

       [joinshopping addTarget:self action:@selector(joinShooppingCart:) forControlEvents:UIControlEventTouchUpInside];
       
        NSString *path = [[NSBundle mainBundle]pathForResource:@"joinShopping.png" ofType:@""];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
       
       [joinshopping setImage:image forState:UIControlStateNormal];
       
       [tempScrollView addSubview:joinshopping];
       
       NSString *descriptionString = [selected objectForKey:@"description"];
       
      UIView *detailItemView = [[UIView alloc] initWithFrame:CGRectMake(0,280, 343,270)];
       
       if(![descriptionString isEqualToString:@"暂无"]){
       
       dispatch_async(dispatch_get_main_queue(), ^{
           UITextView *descriptionText = [[UITextView alloc] initWithFrame:CGRectMake(0,joinshopping.frame.origin.y+50,343,60)];
           [descriptionText setText:[selected objectForKey:@"description"]];
           // [self.description setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
           [descriptionText setTextColor:UIColorFromRGB(0x999999)];
           descriptionText.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
           
           [descriptionText sizeToFit]; //added
           [descriptionText layoutIfNeeded]; //added
           
           [tempScrollView addSubview:descriptionText];
          
           detailItemView.frame = CGRectMake(0,descriptionText.frame.origin.y+descriptionText.frame.size.height+10, 343,detailItemView.frame.size.height);

      //     NSLog(@"%f",detailItemView.frame.origin.y+300);
           
           planView.frame = CGRectMake(0,detailItemView.frame.origin.y+270,343,planView.frame.size.height);
           CGSize newSize = CGSizeMake(0,planView.frame.origin.y+planView.frame.size.height);
           [tempScrollView setContentSize:newSize];
           
       });
       }
       else{

           detailItemView.frame = CGRectMake(0,joinshopping.frame.origin.y+55, 343,detailItemView.frame.size.height);
           planView.frame = CGRectMake(0,detailItemView.frame.origin.y+270,343,planView.frame.size.height);
           CGSize newSize = CGSizeMake(0,planView.frame.origin.y+planView.frame.size.height);
           [tempScrollView setContentSize:newSize];

       }
       
      
       
       self.size = [[UILabel alloc] initWithFrame:CGRectMake(0,0,343,15)];
        self.size.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
        [self.size setTextColor:UIColorFromRGB(0x2b2b2b)];
        NSString *size = [NSString stringWithFormat:@"【宝贝尺寸】    %@",[selected objectForKey:@"size"]];
       [self.size setText:size];
       [detailItemView addSubview:self.size];
       
       self.remianText = [[UILabel alloc] initWithFrame:CGRectMake(0,20,343,15)];
        self.remianText.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
        [self.remianText setTextColor:UIColorFromRGB(0x2b2b2b)];
       NSString *remianString = [NSString stringWithFormat:@"【宝贝库存】    %@",[selected objectForKey:@"remain"]];
        [self.remianText setText:remianString];
        [detailItemView addSubview:self.remianText];
       
       
       
        self.fitRoom = [[UILabel alloc] initWithFrame:CGRectMake(0,40,343,15)];
       self.fitRoom.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
       [self.fitRoom setTextColor:UIColorFromRGB(0x2b2b2b)];
        [self.fitRoom setText:[NSString stringWithFormat:@"【适用空间】    %@",[selected objectForKey:@"weight"]]];
        [detailItemView addSubview:self.fitRoom];
       
        self.height = [[UILabel alloc] initWithFrame:CGRectMake(0,60,343,15)];
        self.height.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
       [self.height setTextColor:UIColorFromRGB(0x2b2b2b)];
        [self.height setText:[NSString stringWithFormat:@"【产品重量】    %@",[selected objectForKey:@"weight"]]];
        [detailItemView addSubview:self.height];
       
       
       self.style = [[UILabel alloc] initWithFrame:CGRectMake(0,80,343,15)];
        self.style.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
        [self.style setTextColor:UIColorFromRGB(0x2b2b2b)];
        [self.style setText:[NSString stringWithFormat:@"【所属风格】    %@",[selected objectForKey:@"weight"]]];
       [detailItemView addSubview:self.style];
       
        self.material = [[UILabel alloc] initWithFrame:CGRectMake(0,100,343,15)];
        self.material.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
        [self.material setTextColor:UIColorFromRGB(0x2b2b2b)];
        [self.material setText:[NSString stringWithFormat:@"【主要材料】    %@",[selected objectForKey:@"material"]]];
        [detailItemView addSubview:self.material];
       
       self.productAddress = [[UILabel alloc] initWithFrame:CGRectMake(0,120,343,15)];
        self.productAddress.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
       [self.productAddress setTextColor:UIColorFromRGB(0x2b2b2b)];
       [self.productAddress setText:[NSString stringWithFormat:@"【商品产地】    %@",[selected objectForKey:@"made_country"]]];
       [detailItemView addSubview:self.productAddress];
       
       
       self.function = [[UILabel alloc] initWithFrame:CGRectMake(0,140,343,15)];
        self.function.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
        [self.function setTextColor:UIColorFromRGB(0x2b2b2b)];
        [self.function setText:[NSString stringWithFormat:@"【主要功能】    %@",[selected objectForKey:@"function"]]];
       [detailItemView addSubview:self.function];
       
       
        self.careText = [[UILabel alloc] initWithFrame:CGRectMake(0,160,343,15)];
        self.careText.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
       [self.careText setTextColor:UIColorFromRGB(0x2b2b2b)];
       [self.careText setText:[NSString stringWithFormat:@"【保养说明】    %@",[selected objectForKey:@"instructions"]]];
       [detailItemView addSubview:self.careText];
     
       
       
       
       self.addressText = [[UILabel alloc] initWithFrame:CGRectMake(0,190,80,15)];
       [self.addressText setText:@"【店铺地址】"];
       [self.addressText setTextColor:UIColorFromRGB(0x2b2b2b)];
       self.addressText.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
       [detailItemView addSubview:self.addressText];
       self.adress = [[UITextView alloc] initWithFrame:CGRectMake(83,182,260,50)];
       [self.adress setText:[selected objectForKey:@"address"]];
       self.adress.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
       [self.adress setTextColor:UIColorFromRGB(0x2b2b2b)];
       [self.adress setEditable:false];
       [self.adress sizeToFit]; //added
       [self.adress layoutIfNeeded]; //added
       [detailItemView addSubview:self.adress];
       
       self.phone = [[UILabel alloc] initWithFrame:CGRectMake(0,190+self.adress.frame.size.height+5,343,20)];
       self.phone.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
       [self.phone setTextColor:UIColorFromRGB(0x2b2b2b)];
       [self.phone setText:[NSString stringWithFormat:@"【联系电话】    %@",[selected objectForKey:@"phone"]]];
       [detailItemView addSubview:self.phone];
       
      [detailItemView setFrame:CGRectMake(detailItemView.frame.origin.x, detailItemView.frame.origin.y,detailItemView.frame.size.width,self.phone.frame.origin.y+20)];
      [tempScrollView addSubview:detailItemView];
       
    

       
//       CGSize newSize = CGSizeMake(0,detailItemView.frame.origin.y+270);
//       [tempScrollView setContentSize:newSize];
      tempScrollView.tag= 67;
      [self.view addSubview:tempScrollView];
        
        
        NSArray *planIds =[selected objectForKey:@"plan"];
        [self initPlanView:planIds];
       
        
    }

    
}
-(void)initView:(NSArray *)data{

    productImageSelectIndex = 0;
    
    NSMutableArray *pageData = [[NSMutableArray alloc] initWithObjects:nil];
    NSArray *productImg = [[NSMutableArray alloc] initWithObjects:nil];
    
    if(data.count>1){
    
    globalproductImg= data[1];
    
    for(int i= 0;i<globalproductImg.count;i++){
        NSDictionary *temp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i] ,@"id",globalproductImg[i],@"image",nil];
        [pageData addObject:temp];
    }
}
    
    //productData
    
    for(int i =0;i<loginInfo.productData.count;i++){
    
        NSDictionary *temp = loginInfo.productData[i];
        
        if([[temp objectForKey:@"product_id"] isEqualToString:[NSString stringWithFormat:@"%@",data[0]]]){
        
            selectedGood = i;
            break;
        }
    
    }
    
  [self initThread:data[0]];
    
 [self initPageView:pageData];
 [self nextGoodsView];
 [self addDot:productImg];
    
}
-(void)initThread:(NSString *)productId{

    [loginInfo.progressBarView setTip:@"正在加载......"];
    [self.view addSubview:loginInfo.progressBarView];
    
 //   NSThread *threadColl = [[NSThread alloc] initWithTarget:self selector:@selector(addView:) object:productId];
 //   [threadColl start];
    
    productImageSelectIndex = 0;
    
    [self addView:productId];
}
-(void)initPlanView:(NSArray *)planIds{

    planView = [[UIView alloc] initWithFrame:CGRectMake(0,0,343,0)];
    
    if([planIds isKindOfClass:[NSArray class]] && [planIds[0] isKindOfClass:[NSDictionary class]]){
    
    int x = 0;
    int y = 0;
    
        
        
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,343,5)];
    NSString *imagepath = [[NSBundle mainBundle]pathForResource:@"line.png" ofType:@""];
    UIImage *image = [UIImage imageWithContentsOfFile:imagepath];
    lineView.image = image;
    [planView addSubview:lineView];
    
    UILabel *tips =[[UILabel alloc] initWithFrame:CGRectMake(0,5, 230,20)];
    tips.font=[UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];
    [tips setText:@"此商品的搭配方案"];
    [tips setTextColor:UIColorFromRGB(0x2b2b2b)];
    [planView addSubview:tips];

    
    
    int eachViewHeight = 120;
    int  eachViewWidth  = (planView.frame.size.width-10)/2;
    
 //   CGSize imgSize = CGSizeMake(eachViewWidth, eachViewHeight);
    NSString *hotimagepath = [[NSBundle mainBundle]pathForResource:@"unSelected.png" ofType:@""];
    UIImage *img = [UIImage imageWithContentsOfFile:hotimagepath];
  //  img = [img resizedImage:imgSize interpolationQuality: kCGInterpolationHigh];

    for(int i=0;i<planIds.count;i++){
        
        NSDictionary *temp = planIds[i];
        
        if(i!=0 &&i%2==0){
            y++;
            x=0;
        }
        

            
            UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(x*(eachViewWidth+10),30+y*eachViewHeight, eachViewWidth, eachViewHeight)];
            view.image = img;
                
            if([temp objectForKey:@"image"]){
              
                
            NSString *hotimagepath = [imageUrl stringByAppendingString:[temp objectForKey:@"image"]];
                NSURL *url = [NSURL URLWithString:hotimagepath];
                
            
          //  UIImage *image =[UIImage imageNamed:[temp1 objectForKey:@"image"]];
            UIImageView * imageView =[[UIImageView alloc] init];
            imageView.frame = CGRectMake(2, 2, eachViewWidth-4, eachViewHeight-4);
            [imageView setCenterImageWithURL:url  size:CGSizeMake(eachViewWidth, eachViewHeight)];
                
            
            view.userInteractionEnabled = YES;
            view.tag =[[temp objectForKey:@"plan_id"] intValue];
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onProductDetailTap:)]];
            [view addSubview:imageView];
        }
        
        [planView addSubview: view];
        
        x++;
    }
    planView.frame = CGRectMake(0,tempScrollView.contentSize.height+10,343,30+y*eachViewHeight+eachViewHeight);
    [tempScrollView addSubview:planView];
    CGSize newSize = CGSizeMake(0,tempScrollView.contentSize.height+planView.frame.size.height+10);
    [tempScrollView setContentSize:newSize];
               img = nil;
    }

}
-(void)addDot:(NSArray *)productImg{
    
    int count = productImg.count;
    
    if([self.imagePreviewBack viewWithTag:11]){
    
        [[self.imagePreviewBack viewWithTag:11] removeFromSuperview];
    }
    
    if(count>1){
    
        UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(60, self.imagePreviewBack.frame.size.height-71, 530, 50)];
        
        imageScrollView.tag = 11;
       
        for (int i =0;i<productImg.count;i++) {
            NSString *path = [NSString stringWithFormat:@"%@%@",imageUrl,productImg[i]];
            NSArray *names = [path componentsSeparatedByString:@"."];
            path = [NSString stringWithFormat:@"%@_thumb.%@",path,names[names.count-1]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*60, 0,50, 50)];
            imageView.userInteractionEnabled = true;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSelectProductTap:)]];
            imageView.tag = i;
            
            if(i==0){
            
                imageView.layer.borderColor = [UIColor blackColor].CGColor;
                imageView.layer.borderWidth = 1 ;
            }
            
            NSURL *url = [NSURL URLWithString:path];
            [imageView setCenterImageWithURL:url size:imageView.frame.size];
            
            [imageScrollView addSubview:imageView];
        }
        imageScrollView.contentSize = CGSizeMake(count*60,0);
        
        if(count*60<530){
        
            imageScrollView.frame = CGRectMake(self.imagePreviewBack.frame.size.width/2-(count*60)/2, self.imagePreviewBack.frame.size.height-71, count*60, 50);
        }
        
        [self.imagePreviewBack addSubview:imageScrollView];
    }
    
    
    if(pagecontrol ==nil){
    pagecontrol = [[pageControl alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-144,651, 20)];
    [pagecontrol setPageCount:count];
    
    }
    else{
    
        [pagecontrol setPageCount:count];

    }
    
    [pagecontrol setHidden:true];
       [self.imagePreviewBack addSubview:pagecontrol];
  }

-(void)onSelectProductTap:(UIGestureRecognizer *)recognizer{
    
    UIView *view = [recognizer view];
    
    if(view.tag != productImageSelectIndex){
        
        productImageSelectIndex = view.tag;
        
        CWPageController *initialViewController =
        [_pModel viewControllerAtIndex:productImageSelectIndex];
        NSArray *viewControllers =
        [NSArray arrayWithObject:initialViewController];
        [_pageController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:NO
                                 completion:^(BOOL f){}];
        
        
        
        [self changeBack];
        
    }
}
- (void)onProductDetailTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
  //  NSLog(@"%ld",(long)view.tag);
    
    
    NSDictionary *data =[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:view.tag],@"id",[NSNumber numberWithInt:view.tag],@"id", nil];
    
            
            [self goToCollocation:data];
            
         }
-(void)nextGoodsView{
    
    NSString *leftpath = [[NSBundle mainBundle]pathForResource:@"左箭头1副本.png" ofType:@""];
    UIImage *leftImg = [UIImage imageWithContentsOfFile:leftpath];
    UIButton *leftImageView = [[UIButton alloc] initWithFrame:CGRectMake(20, 650, 40, 40)];
    [leftImageView setImage:leftImg forState:UIControlStateNormal];
    leftImg = nil;
    leftImageView.tag = 200;
//    [leftImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nextTap:)]];
//    leftImageView.userInteractionEnabled = YES;
    [leftImageView addTarget:self action:@selector(nextTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:leftImageView];
    
    NSString *rightpath = [[NSBundle mainBundle]pathForResource:@"右箭头1副本.png" ofType:@""];
    UIImage *rightImage = [UIImage imageWithContentsOfFile:rightpath];
    UIButton *rightImageView = [[UIButton alloc] initWithFrame:CGRectMake(590, 650, 40, 40)];
    rightImageView.tag = 300 ;
//    [rightImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nextTap:)]];
//    rightImageView.userInteractionEnabled = YES;
    [rightImageView addTarget:self action:@selector(nextTap:) forControlEvents:UIControlEventTouchUpInside];
    [rightImageView setImage:rightImage forState:UIControlStateNormal];
    rightImage = nil;
    [self.view addSubview:rightImageView];
    
}
- (void)nextTap:(UIButton *)view{
    
    [planView removeFromSuperview];
    planView.frame = CGRectMake(0,0,343,0);
    
    if(loginInfo.productData.count>0){
    if(view.tag == 200){
        if(selectedGood>0){
            selectedGood --;
            NSDictionary *temp = loginInfo.productData[selectedGood];
            int productId = [[temp objectForKey:@"product_id"] intValue];
            [self initThread:[NSString stringWithFormat:@"%d",productId]];
        }
        else{
        
            [globalContext showAlertView:@"已是第一个商品"];
        }
    }
    else{
        if(selectedGood<loginInfo.productData.count-1){
            selectedGood++;
            NSDictionary *temp = loginInfo.productData[selectedGood];
            int productId = [[temp objectForKey:@"product_id"] intValue];
            [self initThread:[NSString stringWithFormat:@"%d",productId]];
        
        }
        else{
            [globalContext showAlertView:@"已是最后一个商品"];

        }
    }
    }
}
- (void)onTap:(UIGestureRecognizer *)gestureRecognizer{
    
    UIView *view = [gestureRecognizer view]; // 这个view是手势所属的view，也就是增加手势的那个view
    
    CGSize imgSize = view.frame.size;
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"边框.png" ofType:@""];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    img = [img resizedImage:imgSize interpolationQuality: kCGInterpolationHigh];
    
    view.backgroundColor = [UIColor colorWithPatternImage:img];
    img = nil;
    
    int productId = view.tag;
    [self initThread:[NSString stringWithFormat:@"%d",productId]];

}

-(void)initPageView:(NSMutableArray *)detailData {
    
    if(_pageController){
        
        [_pageController.view removeFromSuperview];
        
    }
    
    // NSMutableArray *image = [[NSMutableArray alloc] initWithObjects:[data objectForKey:@"photoUrl"],[data objectForKey:@"id"], goods,nil];
    
    //  NSMutableArray *detailData = [[NSMutableArray alloc] initWithObjects:image, nil];
    _pModel = [[CWPageModel alloc] init];
    [_pModel createContentPages:detailData];
    

    NSDictionary *options =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                forKey: UIPageViewControllerOptionSpineLocationKey];
    
    _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                      navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                    options:options];
    _pageController.delegate = self;
    
    CWPageController *initialViewController =
    [_pModel viewControllerAtIndex:0];
    NSArray *viewControllers =
    [NSArray arrayWithObject:initialViewController];
    [_pageController setDataSource:_pModel];
    
    [_pageController setViewControllers:viewControllers
                              direction:UIPageViewControllerNavigationDirectionReverse
                               animated:NO
                             completion:^(BOOL f){}];
    [self addChildViewController:_pageController];
    _pageController.view.frame = CGRectMake(0,0,651, 651);
    [self.imagePreviewBack addSubview:_pageController.view];
    [_pageController didMoveToParentViewController:self];
    
    
    
    UIButton *zoomOut = [[UIButton alloc] initWithFrame:CGRectMake(602,17,35,35)];
    zoomOut.tag = 20;
    NSString *path = [[NSBundle mainBundle]pathForResource:@"zoomOut.png" ofType:@""];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    [zoomOut setImage:image forState:UIControlStateNormal];
    
    [zoomOut addTarget:self action:@selector(zoomOut:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imagePreviewBack addSubview:zoomOut];
    
};
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
    if(completed)
    {
      
        UIView *temp1  = [previousViewControllers[0] view];
        
        NSArray *allViews1 =[temp1 subviews];
        for(UIView *x in allViews1){
            if([x isKindOfClass:[UIScrollView class]]){
                
                UIScrollView *tempX = (UIScrollView *)x;
                tempX.contentSize = CGSizeMake(0, 0);
                
                x.frame =  CGRectMake(0,0,651,651);
                NSArray *subViews  = [x subviews];
                UIImageView *temp = subViews[0];
                temp.frame =  CGRectMake(0,0,651,651);
          
                
                break;
                
            }
            
        }

        
        UIView *temp  = [[pageViewController.viewControllers objectAtIndex:0] view];
        
        NSArray *allViews =[temp subviews];
        for(UIView *x in allViews){
            if([x isKindOfClass:[UIScrollView class]]){
                
                productImageSelectIndex = x.tag;
                [self pageChanged:x.tag];
                
                break;
                
            }
            
        }
        
    }
}
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{

    [self changePageFrame:pendingViewControllers];
  
    
}
-(void)changePageFrame:(NSArray *)controllers{

    UIView *temp  = [controllers[0] view];
    
    NSArray *allViews =[temp subviews];
    for(UIView *x in allViews){
        if([x isKindOfClass:[UIScrollView class]]){
            
            UIScrollView *tempX = (UIScrollView *)x;
            tempX.contentSize = CGSizeMake(0, 0);
            
            if(!pagecontrol.isHidden){
                x.frame =  CGRectMake(0,0, 1024,724);
                NSArray *subViews  = [x subviews];
                UIImageView *temp = subViews[0];
                temp.frame =  CGRectMake(0,0, 1024,724);
            }
            else{
                
                x.frame =  CGRectMake(0,0,651,651);
                NSArray *subViews  = [x subviews];
                UIImageView *temp = subViews[0];
                temp.frame =  CGRectMake(0,0,651,651);
                
            }
            
            break;
            
        }
        
    }

}
-(void)pageChanged:(int)tag{
    

    if(pagecontrol){
    
        [pagecontrol setSelected:tag];
    }
    
    [self changeBack];
}
-(void)changeBack{

    UIView *view = [self.imagePreviewBack viewWithTag:11];
    NSArray *imageViewArray = [view subviews];
    
    for (int i =0; i<imageViewArray.count; i++) {
        
        UIView *imageView = imageViewArray[i];
        
        if(i!=productImageSelectIndex){
            
            imageView.layer.borderWidth = 0;
        }
        else{
            
            imageView.layer.borderWidth = 1;
            imageView.layer.borderColor = [UIColor blackColor].CGColor;
        }
    }


}
-(void)goToCollocation:(NSDictionary *)data{

    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"productToCollocation" object:data];
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"productToCollocation"]) //"goView2"是SEGUE连线的标识
    {
        collocationViewController *theSegue = segue.destinationViewController;
        theSegue.collocationData = productToCollocationData;
    }
}

- (IBAction)back:(id)sender {
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"goToBack" object:nil];
    loginInfo.isProductDetail = false;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         CGRect endFrame= self.view.frame;
                         endFrame.origin.y= self.view.frame.size.height;
                        self.view.frame=endFrame;
                     }
                     completion:^(BOOL finished) {
                         [self removeProductDetailView:nil];
                     }];

    
 //   NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(removeProductDetailView:) object:nil];
 //   [thread start];

}

-(void)removeProductDetailView:(id)sender{
 //   [NSThread sleepForTimeInterval:1];
    [self.view removeFromSuperview];
     self.view = nil;
    [tempScrollView removeFromSuperview];
    tempScrollView = nil;
      
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeProductDetailView" object:nil];
}
- (IBAction)settingAction:(id)sender {
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"addSettingView" object:sender];
}

- (IBAction)accountAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goUserCentre" object:nil];
}

- (IBAction)shoppingAction:(id)sender {
    
    [globalContext showAlertView:@"暂不支持此功能"];
}

- (IBAction)shareAction:(id)sender {
    
    [self shareMethod:sender];
    
}
-(void)zoomOutShare:(UIButton *)button{

    [self shareMethod:button];
}
-(void)shareMethod:(UIButton *)sender{
    
    UIView *temp  = [[_pageController.viewControllers objectAtIndex:0] view];
    
    UIImage *image;
    
    NSArray *allViews =[temp subviews];
    for(UIView *x in allViews){
        if([x isKindOfClass:[UIScrollView class]]){
            
            NSArray *subViews  = [x subviews];
            UIImageView *temp = subViews[0];
            image = temp.image;
            
            break;
            
        }
        
    }
    
    
    
    NSArray  *data  =[[NSArray alloc] initWithObjects:sender,image,self.productName.text,nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addShareView" object:data];

}
-(void)zoomOut:(id)sender{
   
    loginInfo.productIsZoom  = true;
    
    UIView *zoomOut = [self.imagePreviewBack viewWithTag:20];
    [zoomOut setHidden:true];
    
    [pagecontrol setHidden:false];
    [[self.imagePreviewBack viewWithTag:11] setHidden:true];
    
    NSArray *allViews = [self.view subviews];
    [self.view insertSubview:self.imagePreviewBack atIndex:allViews.count];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         
                         UIView *temp  = [[_pageController.viewControllers objectAtIndex:0] view];
                         
                         NSArray *allViews =[temp subviews];
                         for(UIView *x in allViews){
                             if([x isKindOfClass:[UIScrollView class]]){
                           
                                    UIScrollView *tempX = (UIScrollView *)x;
                                    tempX.contentSize = CGSizeMake(0, 0);
                                    tempX.frame =  CGRectMake(0,0, 1024,724);
                                     NSArray *subViews  = [tempX subviews];
                                     UIImageView *temp = subViews[0];
                                     temp.frame =  CGRectMake(0,0, 1024,724);
                
                                 break;
                                 
                             }
                             
                         }
                         
                         
                         _pageController.view.frame  = CGRectMake(0,44, 1024,724);
                         
                        self.imagePreviewBack.backgroundColor = [UIColor whiteColor];
                        self.imagePreviewBack.frame = CGRectMake(0, 0, 1024, 768);
                        self.view.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height+67);

                         
                         pagecontrol.frame = CGRectMake(184,726,651, 20);
                     }
                     completion:^(BOOL finished) {
                         
                         
                         if(![self.imagePreviewBack viewWithTag:10]){
                             
                             UIButton *zoomIn = [[UIButton alloc] initWithFrame:CGRectMake(983,10,24,24)];
                             zoomIn.tag = 10;
                             NSString *path = [[NSBundle mainBundle]pathForResource:@"zoomIn.png" ofType:@""];
                             UIImage *image = [UIImage imageWithContentsOfFile:path];
                             
                             [zoomIn setImage:image forState:UIControlStateNormal];
                             
                             [zoomIn addTarget:self action:@selector(zoomIn:) forControlEvents:UIControlEventTouchUpInside];
                             
                             [self.imagePreviewBack addSubview:zoomIn];
                         }
                         else{
                             UIView *zoomIn = [self.imagePreviewBack viewWithTag:10];
                             [zoomIn setHidden:false];
                         }
                         
                         if(![self.imagePreviewBack viewWithTag:100]){
                             
                             UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17,9,110,25)];
                             logoImageView.tag = 100;
                             NSString *path = [[NSBundle mainBundle]pathForResource:@"logo.png" ofType:@""];
                             UIImage *image = [UIImage imageWithContentsOfFile:path];
                             
                             [logoImageView setImage:image];
                             
                             [self.imagePreviewBack addSubview:logoImageView];
                         }
                         else{
                             UIView *logoImageView = [self.imagePreviewBack viewWithTag:100];
                             [logoImageView setHidden:false];
                         }
                         
                         if(![self.imagePreviewBack viewWithTag:201]){
                             
                             UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,703,1024,65)];
                             footerView.tag = 201;
                             
                             NSString *path = [[NSBundle mainBundle]pathForResource:@"share.png" ofType:@""];
                             UIImage *image = [UIImage imageWithContentsOfFile:path];
                             
                             UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(17,20,24,24)];
                             share.tag = 301;
                             
                             [share setImage:image forState:UIControlStateNormal];
                             
                             [share addTarget:self action:@selector(zoomOutShare:) forControlEvents:UIControlEventTouchUpInside];
                             
                             [footerView addSubview:share];
                             
                             [footerView setBackgroundColor:[UIColor whiteColor]];
                             
                             
                             [self.imagePreviewBack insertSubview:footerView belowSubview:pagecontrol];
                         }
                         else{
                             UIView *footerView = [self.imagePreviewBack viewWithTag:201];
                             [footerView setHidden:false];
                         }
                       
                     
                        [self setFavoriteImage:self.love status:self.productFavoriteButton.tag];
                        [self.love setHidden:false];
                     
                         
                     }];

}
-(void)zoomIn:(id)sender{
    
    loginInfo.productIsZoom  = false;
    
    [pagecontrol setHidden:true];
    [[self.imagePreviewBack viewWithTag:11] setHidden:false];
    
    UIView *zoomOut = [self.imagePreviewBack viewWithTag:20];
    [zoomOut setHidden:false];
    
    UIView *zoomIn = [self.imagePreviewBack viewWithTag:10];
    [zoomIn setHidden:true];
    
    UIView *logoImageView = [self.imagePreviewBack viewWithTag:100];
    [logoImageView setHidden:true];
    
    UIView *footerView = [self.imagePreviewBack viewWithTag:201];
    [footerView setHidden:true];

    [self.love setHidden:true];

    
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         
                         UIView *temp  = [[_pageController.viewControllers objectAtIndex:0] view];
                         
                         NSArray *allViews =[temp subviews];
                         for(UIView *x in allViews){
                             if([x isKindOfClass:[UIScrollView class]]){
                                 
                                 UIScrollView *tempX = (UIScrollView *)x;
                                 tempX.contentSize = CGSizeMake(0, 0);
                                     tempX.frame =  CGRectMake(0,0,651,651);
                                     NSArray *subViews  = [tempX subviews];
                                     UIImageView *temp = subViews[0];
                                     temp.frame =  CGRectMake(0,0,651,651);
                                 
                                 break;
                                 
                             }
                             
                         }

                         
                       self.view.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height-67);
                         _pageController.view.frame  = CGRectMake(0,0,1024,1024);
                        self.imagePreviewBack.backgroundColor = UIColorFromRGB(0xf4f4f4);
                        self.imagePreviewBack.frame = CGRectMake(0,44,651,651);
                        pagecontrol.frame = CGRectMake(0,624,651, 20);
                      
                     }
                     completion:^(BOOL finished) {
                         
                         
                          [self.view insertSubview:self.imagePreviewBack atIndex:0];
                          [self.imagePreviewBack addSubview:pagecontrol];
                     }];

}
-(void)setFavoriteImage:(UIButton *)favoriteButton status:(int)status{

    if(status==1){
        
        NSString *favoritePathString = [[NSBundle mainBundle]pathForResource:@"redHeart.png" ofType:@""];
        UIImage *favorite = [UIImage imageWithContentsOfFile:favoritePathString];
        [favoriteButton setImage:favorite forState:UIControlStateNormal];
        [self.productFavoriteButton setImage:favorite forState:UIControlStateNormal];
        favorite = nil;
    }
    
    else if(status==2){
        
        NSString *noFavoritePathString = [[NSBundle mainBundle]pathForResource:@"heartBlack.png" ofType:@""];
        UIImage *noFavorite = [UIImage imageWithContentsOfFile:noFavoritePathString];
        [favoriteButton setImage:noFavorite forState:UIControlStateNormal];
        [self.productFavoriteButton setImage:noFavorite forState:UIControlStateNormal];

        noFavorite = nil;
    }

    favoriteButton.tag = status;
    self.productFavoriteButton.tag = status;
}
- (IBAction)favoriteAction:(id)sender {
    
    //类型：1商品2方案3案例图
    
    if ([globalContext isLogin]) {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":productId,@"type":[NSNumber numberWithInt:1],@"status":[NSNumber numberWithInt:(int)self.productFavoriteButton.tag]};
    
    [manager POST:[BASEURL stringByAppendingString: changeFavoriteApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
      
      //  NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *temp = responseObject;
        
        NSString *flagString = [temp objectForKey:@"flag"];
        
        if([flagString isEqualToString:@"true"]){
            
            if(self.productFavoriteButton.tag==2)
                
                [self setFavoriteImage:sender status:1];

            
            else if(self.productFavoriteButton.tag==1)
                
              [self setFavoriteImage:sender status:2];
            
        }
        else{
            
            if(self.productFavoriteButton.tag==2){
                
                [globalContext addStatusBarNotification:@"收藏失败"];
                
            }
            else{
                
                [globalContext addStatusBarNotification:@"取消收藏失败"];
            }
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        if(self.productFavoriteButton.tag==2){
            
            [globalContext addStatusBarNotification:@"网络异常，收藏失败"];
            
        }
        else{
            
            [globalContext addStatusBarNotification:@"网络异常，取消收藏失败"];
        }

        
    }];
        
   }
    else{
    
        UIAlertView  *alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 111;
        [alertView show];
    }
}
-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0){
        
    }
    else{
        // [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLogin" object:nil];
        UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
        loginController = [st instantiateViewControllerWithIdentifier:@"login"];
        [self.view addSubview:loginController.view];
        
        st = nil;
    }
    
    
    
}

-(void)joinShooppingCart:(id)sender {

 [globalContext showAlertView:@"暂不支持此功能"];
}
@end
