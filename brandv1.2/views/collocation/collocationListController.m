//
//  collocationListController.m
//  brandv1.2
//
//  Created by Apple on 14-8-13.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "collocationListController.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "Define.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Resize.h"
#import "UIImage+Helpers.h"

@interface collocationListController ()

@end

@implementation collocationListController
LoginInfo *loginInfo;
int selected;
UIAlertView *alertView;
UIScrollView *planScrollView;
UIScrollView *collocationScrollView;
UILabel *total;
UILabel *disprice;
NSString *priceText;
UIImageView *arrow;
UIImage *unSelected;
UIImage *selectedImage;
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
    [self.view setBackgroundColor:UIColorFromRGB(0xf1f1f1)];
    
    NSString *hotimagepath = [[NSBundle mainBundle]pathForResource:@"unSelected.png" ofType:@""];
    unSelected = [UIImage imageWithContentsOfFile:hotimagepath];
    unSelected= [unSelected resizedImage:unSelected.size interpolationQuality: kCGInterpolationHigh];
    
    NSString *hotimagepath1 = [[NSBundle mainBundle]pathForResource:@"边框.png" ofType:@""];
    selectedImage = [UIImage imageWithContentsOfFile:hotimagepath1];
    selectedImage = [selectedImage resizedImage:selectedImage.size interpolationQuality: kCGInterpolationHigh];
    
    self.collocationListTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17];
    self.backButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
    
    [self initView:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
-(void)initView:(NSMutableArray *)data{
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    selected = 0;
    priceText = @"总参考价格:";
    
    
    if(loginInfo!=nil && loginInfo.allMessage!=nil){
        
        NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(initPlanList:) object:loginInfo.allMessage];
        [thread1 start];
        
   //     NSMutableArray *firstDefaut = loginInfo.allMessage[loginInfo.allMessage.count-1][2];
        
   //     NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(initCollocationList:) object:firstDefaut];
   //     [thread2 start];
        
     //   NSThread *thread3 = [[NSThread alloc] initWithTarget:self selector:@selector(afterInitView:) object:nil];
     //   [thread3 start];
      //  [self performSelector:@selector(afterInitView:) withObject:nil afterDelay:0.3];
        
//        [self performSelectorInBackground:@selector(afterInitView:) withObject:nil];

    }
    
}

- (IBAction)backAction:(id)sender {
    
    [arrow removeFromSuperview];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
     //   NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(removeSelfView:) object:nil];
     //   [thread start];
        [self removeSelfView:nil];
        
    }];
    
    
    
}

- (IBAction)backIconAction:(id)sender {
    
    [arrow removeFromSuperview];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
      //  NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(removeSelfView:) object:nil];
      //  [thread start];
         [self removeSelfView:nil];
        
    }];
    
}
-(void)removeSelfView:(id)sender{
  //  [NSThread sleepForTimeInterval:2];
    [self.view removeFromSuperview];
    self.view = nil;
    [planScrollView removeFromSuperview];
    planScrollView = nil;
    [collocationScrollView removeFromSuperview];
    collocationScrollView = nil;
    unSelected = nil;
    selectedImage = nil;
    
}
-(void)initPlanList:(NSMutableArray *)data{
    
    if(planScrollView !=nil){
        
        // [planScrollView removeFromSuperview];
        
    }
    
    planScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 54,1004, 280)];
    
    CGSize size = CGSizeMake([data count]*260,0);
    [planScrollView setContentSize:size];
    [planScrollView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:planScrollView];
    
    int x =0;
    
    
    for(int i =data.count-1; i>=0;i--){
        
        NSArray *temp = data[i];
        
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(2,2,256,266)];
        
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(x*(260+10),0, 260, 270)];
        view.tag = i;
//        
        if(i==data.count-1){
            
           // selectedImage = [selectedImage resizedImage:view.frame.size interpolationQuality: kCGInterpolationHigh];
            view.image = selectedImage;
            
        }
        else{
            
          //  unSelected = [unSelected resizedImage:view.frame.size interpolationQuality: kCGInterpolationHigh];
             view.image = unSelected;
        }
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 256, 200)];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0,220, 256, 20)];
        [name setBackgroundColor:[UIColor clearColor]];
        UILabel *size = [[UILabel alloc] initWithFrame:CGRectMake(0,245, 256, 15)];
        [size setBackgroundColor:[UIColor clearColor]];
        name.textAlignment = NSTextAlignmentCenter;
        size.textAlignment = NSTextAlignmentCenter;
        [name setText:@"主卧室"];
        name.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
        [size setText:@"尺寸：1024*758"];
        size.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14];
        UIImage *imageViewImage =  temp[1];
        imageViewImage = [imageViewImage resizedCenterImage:image.frame.size interpolationQuality: kCGInterpolationLow];
        image.image = imageViewImage;
     //   imageViewImage = nil;
//        
        [subView addSubview:image];
       // image = nil;
        [subView addSubview:name];
        name = nil;
        [subView addSubview:size];
        size = nil;
//
        [subView setBackgroundColor:[UIColor whiteColor]];
        
        [view addSubview:subView];
        
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(planTap:)]];
//
        
        [planScrollView addSubview:view];
        x++;
    }
    
    
    [self afterInitView:nil];
    
}
- (void)planTap:(UIGestureRecognizer *)gestureRecognizer{
    
    priceText = @"总参考价格:";
    
    UIView *view = [gestureRecognizer view];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(changeBackImage:) object:view];
    [thread start];
    
    //   NSLog(@"%@",loginInfo.allMessage);
    
    [self initCollocationList:loginInfo.allMessage[view.tag][2]];
    
    CGPoint p = planScrollView.contentOffset;
    
    float x = (loginInfo.allMessage.count-1-view.tag)*270;
    
    float moveX = x-p.x;
    
    [UIView setAnimationsEnabled:true];
    
    CGRect endFrame= arrow.frame;
    endFrame.origin.x= -900 + moveX;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    arrow.frame=endFrame;
    [UIView commitAnimations];
    
}
-(void)changeBackImage:(id)sender{
    
    UIView *typeButtonView  = [self.view viewWithTag:110];
    for(UIButton *button in typeButtonView.subviews){
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    for(UIView *view in planScrollView.subviews){
    //    unSelected = [unSelected resizedImage:view.frame.size interpolationQuality: kCGInterpolationHigh];
     //   view.backgroundColor = [UIColor colorWithPatternImage:unSelected];
        if([view isKindOfClass:[UIImageView class]]){
        
            UIImageView *tempImageView = (UIImageView *)view;
            [tempImageView setImage:unSelected];
        }
        
    }
    
    UIImageView *view =(UIImageView *) sender;
    
    selected = loginInfo.allMessage.count-1-view.tag;
  //  selectedImage = [selectedImage resizedImage:view.frame.size interpolationQuality: kCGInterpolationHigh];
  //  view.backgroundColor = [UIColor colorWithPatternImage:selectedImage];
    [view setImage:selectedImage];
    
}
-(void)initCollocationList:(NSMutableArray *)data{
    
    UIView *remove = [self.view viewWithTag:120];
    
    if(remove !=nil){
        
        [remove removeFromSuperview];
        
    }
    
    collocationScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10,384,1004,368)];
    collocationScrollView.tag = 120;
    
    int x= 0;
    int y =0;
    
    
    NSArray *goods = data;
    
    float nowTotal = 0;
    float originalTotal = 0;
    
    for(int i =0;i<goods.count;i++){
        
        if(i%4==0 && i!=0){
            x = 0;
            y++;
        }
        
        NSDictionary *temp = goods[i];
        
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(5+x*250,10+y*250, 240, 240)];
        
     //   CGSize imgSize = view.frame.size;
        
      //  unSelected = [unSelected resizedImage:imgSize interpolationQuality:kCGInterpolationHigh];
        
        view.image = unSelected;
        
        NSString *nameStr = [temp objectForKey:@"name"];
        
        if([nameStr isEqualToString:@"未知信息"])
            nameStr = @"此商品暂无信息";
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5,5, 230, 190)];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(5,200, 210, 20)];
        [name setBackgroundColor:[UIColor clearColor]];
        name.font=[UIFont fontWithName:@"MicrosoftYaHei" size:14];
        [name setText:nameStr];
        
        NSString *priceStr = [temp objectForKey:@"disprice"];
        
        if(![priceStr isEqualToString:@"未知信息"]){
        
        UILabel *disPrice = [[UILabel alloc] initWithFrame:CGRectMake(5,220, 110, 20)];
        [disprice setBackgroundColor:[UIColor clearColor]];
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(120,220, 120, 20)];
        price.font=[UIFont fontWithName:@"MicrosoftYaHei" size:14];
        [price setBackgroundColor:[UIColor clearColor]];
        //   name.textAlignment = NSTextAlignmentCenter;
        [disPrice setText:[NSString stringWithFormat:@"¥%@",[temp objectForKey:@"disprice"]]];
        [disPrice setTextColor:[UIColor redColor]];
        [disPrice setBackgroundColor:[UIColor clearColor]];
        disPrice.font=  [UIFont fontWithName:@"MicrosoftYaHei" size:14];
        [price setText:[NSString stringWithFormat:@"¥%@",[temp objectForKey:@"price"]]];
        
        nowTotal += [[temp objectForKey:@"disprice"] floatValue];
        originalTotal += [[temp objectForKey:@"price"] floatValue];
            
            [view addSubview:disPrice];
            disPrice = nil;
            [view addSubview:price];
            price = nil;
        }
        
        else{
            name.font=[UIFont fontWithName:@"MicrosoftYaHei" size:13];
            name.frame = CGRectMake(10,215, 210,20);
        }
        
//        if([temp count] == 6){
//            NSString *hotimagepath = [imageUrl stringByAppendingString:[temp objectForKey:@"image"]];
//            //  UIImage *image = [UIImage imageWithContentsOfFile:hotimagepath];
//            NSURL *url = [NSURL URLWithString:hotimagepath];
//            
//          //  [imageView setImageWithURL:url placeholderImage:image size:CGSizeMake(0, 0)];
//            [imageView setImageWithURL:url size:CGSizeMake(230, 190)];
//
//        }
//        else{
        
            if(!loginInfo.isOfflineMode){
         //   NSString *hotimagepath = [imageUrl stringByAppendingString:[temp objectForKey:@"dapei"]];
            NSString *hotimagepath = [imageUrl stringByAppendingString:[temp objectForKey:@"image"]];
            NSURL *url = [NSURL URLWithString:hotimagepath];
            
         //   [imageView setImageWithURL:url placeholderImage:image size:CGSizeMake(0, 0)];
            [imageView setImageWithURL:url size:CGSizeMake(230, 190)];
            }
            else{
                
                [UIImage loadFromURL:[temp objectForKey:@"image"] callback: ^(UIImage *image){
                    
                   image = [image resizedImage:selectedImage.size interpolationQuality: kCGInterpolationHigh];
                    [imageView setImage:image];
                    
                }];
                
         //   }

        }
        
        [view addSubview:imageView];
        imageView = nil;
        [view addSubview:name];
        name = nil;
        
        
        [collocationScrollView addSubview:view];
        
        x++;
    }
    
    [total setText:[NSString stringWithFormat:@"%@%f",priceText,nowTotal]];
    [disprice setText:[NSString stringWithFormat:@"为你节省:%f",originalTotal-nowTotal]];
    
    
    CGSize size = CGSizeMake(0,(y+1)*280);
    [collocationScrollView setContentSize:size];
    [collocationScrollView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:collocationScrollView];
}
-(void)afterInitView:(id)sender{
    [NSThread sleepForTimeInterval:1];
    
    arrow = [[UIImageView alloc] initWithFrame:CGRectMake(-900,768*0.5-65 , 2048, 55)];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"箭头.png" ofType:@""];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    arrow.image = image;
    image = nil;
    [self.view addSubview: arrow];
    
    total = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.height-420,self.view.frame.size.width*0.5-50 , 200, 40)];
    [total setBackgroundColor:[UIColor clearColor]];
    [total setTextColor:[UIColor redColor]];
    total.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14];
    disprice = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.height-210,self.view.frame.size.width*0.5-50 , 200, 40)];
    disprice.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
    [disprice setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:total];
    [self.view addSubview:disprice];
    
    
    NSMutableArray *firstDefaut = loginInfo.allMessage[loginInfo.allMessage.count-1][2];
    
    [self initCollocationList:firstDefaut];
    
    [self initTypeView];
    
}
-(void)initTypeView{
    
    UIView *typeButtonView = [[UIView alloc] initWithFrame:CGRectMake(10,768*0.5-50 , 200, 40)];
    typeButtonView.tag = 110;
    
    UIButton *type1 = [[UIButton alloc] initWithFrame:CGRectMake(0,0 , 50, 40)];
    UIButton *type2 = [[UIButton alloc] initWithFrame:CGRectMake(50,0, 50, 40)];
    UIButton *type3 = [[UIButton alloc] initWithFrame:CGRectMake(100,0, 50, 40)];
    UIButton *type4 = [[UIButton alloc] initWithFrame:CGRectMake(150,0, 50, 40)];
    [type1 setTitle:@"家具" forState:UIControlStateNormal];
    [type2 setTitle:@"配饰" forState:UIControlStateNormal];
    [type3 setTitle:@"建材" forState:UIControlStateNormal];
    [type4 setTitle:@"硬装" forState:UIControlStateNormal];
    
    type1.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
     type2.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
     type3.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
     type4.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
    
    [type1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [type2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [type3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [type4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
    
    type1.tag = 0;
    type2.tag = 1;
    type3.tag = 2;
    type4.tag = 3;
    
    [type1 addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchUpInside];
    [type2 addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchUpInside];
    [type3 addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchUpInside];
    [type4 addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [typeButtonView addSubview:type1];
    [typeButtonView addSubview:type2];
    [typeButtonView addSubview:type3];
    [typeButtonView addSubview:type4];
    
    [self.view addSubview: typeButtonView];
    
}
-(void)typeClick:(id)sender{
    
    UIButton *selectedButton = sender;
    
    NSArray *selectedPlan = loginInfo.allMessage[selected];
    NSArray *selectedPlanOfGoods = selectedPlan[2];
    
    NSMutableArray *typeGoods = [[NSMutableArray alloc] init];
    
    for(NSDictionary *temp in selectedPlanOfGoods){
        
        if([[temp objectForKey:@"type"] intValue] == selectedButton.tag){
            
            [typeGoods addObject:temp];
            
            priceText = [self returnType:[NSNumber numberWithInt:selectedButton.tag]];
            
        }
    }
    
    if(typeGoods.count>0){
        
        UIView *typeButtonView  = [self.view viewWithTag:110];
        for(UIButton *button in typeButtonView.subviews){
            [button setBackgroundColor:[UIColor clearColor]];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        
        [selectedButton setBackgroundColor:UIColorFromRGB(0x0091ff)];
        [selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self initCollocationList:typeGoods];
        
    }
    else{
        
        [self showAlertView:@"此方案没有搭配此类商品"];
    }
    
    
}

-(void)showAlertView:(NSString *)message{     //显示提示框
    
    alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:message delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
    [alertView setMessage:message];
    alertView.tag = 110;
    [alertView show];
}
-(NSString *)returnType:(NSNumber *)type{
    
    switch ([type intValue]) {
        case 0:
            return @"家具总参考价格:";
            
        case 1:
            return @"装饰总参考价格:";
            
        case 2:
            return @"建材总参考价格:";
            
        case 3:
            return @"硬装总参考价格:";
            
        default:
            return @"家具总参考价格:";
    }
    
}
@end
