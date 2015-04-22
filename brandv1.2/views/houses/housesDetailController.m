//
//  housesDetailController.m
//  brandv1.2
//
//  Created by Apple on 14-8-16.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "housesDetailController.h"
//#import "UIImage+Resize.h"
#import "Define.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "housesDetailMessage.h"
#import "DetailViewController.h"
#import "globalContext.h"
#import "typeSearchTableViewController.h"

@interface housesDetailController ()

@end

@implementation housesDetailController
@synthesize collocation;
LoginInfo *loginInfo;
NSArray *housestypeArray;
housesDetailMessage *housesdetailMessage;
NSString *housesName;
NSString *housesId;
DetailViewController *detail;
UIPopoverController *popController;
typeSearchTableViewController *typeSearch;
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
    
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    loginInfo.houseSearch = @"";
    
    housestypeArray = [[NSArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLogin:) name:@"reLogin" object:nil];
    [globalContext setUserHead:self.accountButton];

   
    self.housesName.font =  [UIFont fontWithName:@"MicrosoftYaHei" size:17.0f];
    self.houseCount.font =  [UIFont fontWithName:@"MicrosoftYaHei" size:14.0f];
    self.descriptionTextView.font =  [UIFont fontWithName:@"MicrosoftYaHei" size:13.0f];
    self.backButton.titleLabel.font =  [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
    self.titleLabel.font =  [UIFont fontWithName:@"MicrosoftYaHei" size:16.0f];
    self.housesTypeLabel.font =  [UIFont fontWithName:@"MicrosoftYaHei" size:17.0f];
    
    self.titleLabel.userInteractionEnabled = YES;
    [self.titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectPlanAction:)]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToHousesDetail:) name:@"goToHousesTestDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDetail:) name:@"removeDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadView:) name:@"unloadView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePlan:) name:@"changePlan" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLogin:) name:@"reLogin" object:nil];
    
}
-(void)unloadView:(NSNotification *)sender{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToHousesTestDetail" object:nil];
  
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeDetail" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"unloadView" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changePlan" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reLogin" object:nil];
}
-(void)reLogin:(id)sender{
    
        [globalContext setUserHead:self.accountButton];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView:(NSMutableArray *)array{

    [self getHousesType:array[0]];
    
    housesId = array[0];
    
    housesdetailMessage = [[housesDetailMessage alloc] initWithFrame:CGRectMake(391,1, self.view.frame.size.width-391, self.view.frame.size.height-114)];
    
    [self.mainScrollView addSubview:housesdetailMessage];

    [self initHousesView:array[1]];
    
 //   [housesdetailMessage setHousesId:[NSString stringWithFormat:@"%@",array[0]] housesName:housesName];
}
-(void)initHousesView:(NSDictionary *)data{

    data = [data mutableCopy];
    
    NSLog(@"%@",data);
    
    NSString *path = [imageUrl stringByAppendingString:[data objectForKey:@"image"]];
    NSURL *url = [NSURL URLWithString:path];
    [self.housesImageView setCenterImageWithURL:url size:self.housesImageView.frame.size];
    
     NSString *houseCount = [NSString stringWithFormat:@"%@个户型" ,[data objectForKey:@"count"]];
    
    [self.houseCount setText:houseCount];
    
    housesName = [data objectForKey:@"name"];
    
    CGSize constraint1 = CGSizeMake(2800,21);
    CGSize size1 = [housesName sizeWithFont:[UIFont fontWithName:@"MicrosoftYaHei" size:16.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.titleLabel setFrame:CGRectMake(512-size1.width/2,10, size1.width,21)];
    
    [self.selectPlanButton setFrame:CGRectMake(self.titleLabel.frame.origin.x+self.titleLabel.frame.size.width+8, self.selectPlanButton.frame.origin.y,self.selectPlanButton.frame.size.width,self.selectPlanButton.frame.size.height)];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel setText:housesName];
    
    [self.housesName setText:[data objectForKey:@"name"]];
    [self.descriptionTextView setText:[data objectForKey:@"description"]];

}
-(void)getHousesType:(NSNumber *)housesId{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":housesId};
    
    [manager POST:[BASEURL stringByAppendingString: getHousesHuTypeApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //    NSLog(@"JSON: %@", responseObject);
        
        NSArray *rootArray = responseObject;
        
        housestypeArray = [rootArray mutableCopy];
        
        [housesdetailMessage setHousesType:housestypeArray housesId:[NSString stringWithFormat:@"%@",housesId] housesName:housesName mainScrollView:self.mainScrollView];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
       
    }];
}

-(void)changePlan:(NSNotification *)notification{
    
    int  index = [[notification object] intValue];
    
    [self.mainScrollView setContentOffset:CGPointMake(index*390, 0) animated:YES];

}
-(void)goToHousesDetail:(NSNotification *)notification{

    int id = [[notification object] intValue];
    
    detail = nil;
    
    if(detail ==nil){
        
        detail = [[DetailViewController alloc] init];
        detail.view.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height);
        
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        
        
        if (!window)
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        
        
        NSArray *subViews = [window subviews];
        
        [[subViews objectAtIndex:subViews.count-1] addSubview:detail.view];
    }
    
    [detail initView:id];
    
}
-(void)removeDetail:(NSNotification *)notification{
    [detail.view removeFromSuperview];
    detail = nil;

}
- (IBAction)backAction:(id)sender {

      
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         CGRect endFrame= self.view.frame;
                         endFrame.origin.y= self.view.frame.size.height;
                         detail.view.frame=endFrame;
                          self.view.frame=endFrame;
                     }
                     completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         self.view = nil;
                         [housesdetailMessage removeFromSuperview];
                         housesdetailMessage= nil;
                         popController = nil;
                         typeSearch = nil;
                         
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reLogin" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeHousesDetail" object:nil];
                         
                     }
     ];
 }
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
}
- (IBAction)accountAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goUserCentre" object:nil];
}

- (IBAction)settingAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addSettingView" object:sender];
}

- (IBAction)infoAction:(id)sender {
}

- (IBAction)selectPlanAction:(id)sender {
    
    if(!popController && !typeSearch){
    
    typeSearch = [[typeSearchTableViewController alloc] init];
    
    typeSearch.view.frame = CGRectMake(0, 0,275,32*housestypeArray.count);
    
    popController = [[UIPopoverController alloc] initWithContentViewController:typeSearch];
    popController.popoverContentSize = CGSizeMake(275,32*housestypeArray.count);
    popController.delegate=self;
    
        if(housestypeArray){
            
            NSMutableArray *data = [[NSMutableArray alloc] init];
            
            for(NSDictionary *temp in housestypeArray){
                
                [data addObject:[temp objectForKey:@"typeName"]];
            }
            
            [typeSearch initViewWithData:10 data:data];
            
        }
    }
    
    if(housestypeArray){
   
       [popController presentPopoverFromRect:self.titleLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    else{
    
        [globalContext showAlertView:@"没有户型可选"];
    }
}
@end
