//
//  SecondViewController.m
//  brandv1.2
//
//  Created by Roc.Tian on 14-7-24.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "SecondViewController.h"
#import "messageView.h"
#import "collocationViewController.h"
#import "Define.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "AFNetworking.h"
#import "globalContext.h"
#import "mutliRowViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController
@synthesize collocation;
@synthesize planDetail;
NSMutableArray *allData;
LoginInfo *loginInfo;
int listpageIndex=0;
NSString *search =@"";
messageView  *messageview;
NSString *searchName;
NSDictionary *collocationDataTempPlan;
NSString *reload = @"0";
mutliRowViewController *typeSearchPlan;
UIPopoverController *popControllerPlan;
NSMutableArray *tempPlanSearchType;
NSMutableArray *editPlanSearchType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    loginInfo.planSearch = @"";
    
    [loginInfo addObserver:self forKeyPath:@"brand_logo_app" options:NSKeyValueObservingOptionNew context:nil];
    
    allData = [[NSMutableArray alloc] init];
    
  // [self.view setBackgroundColor:[UIColorFromRGB(0xff0000) colorWithAlphaComponent:0.5]];
    [self.view setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
    
    [self getPlanType:nil];
    
     self.topBarLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:18.0f];//
     self.topBarLabel.userInteractionEnabled = YES;
     [self.topBarLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(retrievalAction:)]];
    
    [self.topBarViewBack setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
    
    self.searchText.delegate = self;
    
    for(UITabBarItem *item in self.tabBarController.tabBar.items) {
        // use the UIImage category code for the imageWithColor: method
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
//    UIButton *clearButton = [self.searchText valueForKey:@"_clearButton"];
//    [clearButton setImage:[UIImage imageNamed:@"叉.png"] forState:UIControlStateNormal];
    
    [globalContext settingBrandLogo:self.brandLogo nameLabel:self.brandLabelLabel];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
      if ([keyPath isEqualToString:@"brand_logo_app"] && object == loginInfo) {
          [globalContext settingBrandLogo:self.brandLogo nameLabel:self.brandLabelLabel];

      }
    }
-(void)getPlanType:(id)sender{
    
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
        [manager POST:[BASEURL stringByAppendingString:planType] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
         //   NSLog(@"JSON: %@", responseObject);
    
            NSArray *rootArray = responseObject;
    
            loginInfo.planSearchType = [rootArray mutableCopy];
            
            tempPlanSearchType = [rootArray mutableCopy];

    
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
    
    
        }];
    
    
    
}

-(void)initNSNotificationCenter{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addListView:) name:@"addListView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToDetail:) name:@"goToDetail" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToList:) name:@"goToList" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToCollocation:) name:@"goToCollocation" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(back:) name:@"goToBack" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(planUpdateTotalCount:) name:@"planUpdateTotalCount" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDetailView:) name:@"removeDetailView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadView:) name:@"unloadView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchByType:) name:@"searchByType" object:nil];
    
}
-(void)unloadView:(NSNotification *)sender{
    
    [messageview removeFromSuperview];
      messageview = nil;
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addListView" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToDetail" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToList" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToCollocation" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToBack" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"planUpdateTotalCount" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeDetailView" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"unloadView" object:nil];
    
      [[NSNotificationCenter defaultCenter] removeObserver:self name:@"searchByType" object:nil];
    
    [self initNSNotificationCenter];
    [self addListView:@"1"];
    
}

-(void)planUpdateTotalCount:(NSNotification *)totalCount{
    

    
//    [self performSelector:@selector(restoreScrcollView:) withObject:nil afterDelay:0.1];

    
      if([reload isEqualToString:@"2"]){
        
    }
    
    else if([reload isEqualToString:@"3"]){
  
       
        
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
  //   Dispose of any resources that can be recreated.
    //  [self unloadView:nil];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            
            interfaceOrientation == UIInterfaceOrientationLandscapeRight );
}


-(void)searchByType:(NSNotification *)notification{
    
    searchName = @"";
    
    NSArray *args = [notification object];
    
    NSArray *data = args[0];
    
    NSArray *dataName = args[1];

    NSIndexPath *indexPath = data[2];
    
    NSDictionary *temp = editPlanSearchType[indexPath.section];
    
    NSString *searchField = [temp objectForKey:@"searchField"];
    NSArray *typeItems = [temp objectForKey:@"typeItems"];
    NSString *typeItem = [typeItems[indexPath.row] objectForKey:@"code"];
    
    
    int count = 0;
    
    for (int i=0;i<dataName.count;i++) {
        
        NSIndexPath *path = dataName[i];
        
        if(path.section !=-1){
        
            NSDictionary *temp = editPlanSearchType[path.section];
            NSArray *typeItems = [temp objectForKey:@"typeItems"];
            
           NSString  *tempSearchName =  [typeItems[path.row] objectForKey:@"name"];
            
            if(count!=0)
            searchName = [NSString stringWithFormat:@"%@,%@",searchName,tempSearchName];
           else
            searchName = [NSString stringWithFormat:@"%@%@",searchName,tempSearchName];

            count++;
        }
    }
  
    
    NSString *titleName = [NSString stringWithFormat:@"装修设计方案 %@",searchName];
    
    CGSize constraint1 = CGSizeMake(2800,21);
    CGSize size1 = [titleName sizeWithFont:[UIFont fontWithName:@"MicrosoftYaHei-Bold" size:18.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
    
    int x = 512-size1.width/2;
    
    if(x+size1.width<645)
    {
        self.topBarLabel.frame = CGRectMake(x, 11, size1.width, 21);
        self.topBarLabel.textAlignment = NSTextAlignmentCenter;
    }
    else{
    
        self.topBarLabel.frame = CGRectMake(645-size1.width, 11, size1.width, 21);
        self.topBarLabel.textAlignment = NSTextAlignmentRight;
    }
    
    self.retrievalButton.frame = CGRectMake(self.topBarLabel.frame.origin.x+self.topBarLabel.frame.size.width+5,self.retrievalButton.frame.origin.y, self.retrievalButton.frame.size.width, self.retrievalButton.frame.size.height);
    
    [self.topBarLabel setText:titleName];
    
    NSMutableAttributedString *text =
    [[NSMutableAttributedString alloc]
     initWithAttributedString: self.topBarLabel.attributedText];
    
    //NSForegroundColorAttributeName
    
    [text addAttribute:NSFontAttributeName
                 value:[UIFont fontWithName:@"MicrosoftYaHei-Bold" size:18.0f]
                 range:NSMakeRange(0,6)];
    [self.topBarLabel setAttributedText: text];
    
    search = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",searchField,typeItem];
    
    loginInfo.planSearch = search;
    
    reload = @"2";
    
    if(messageview){
        
        [messageview getMessageList:@"1"];
    }

    
}
-(void)addListView:(id)sender{

    messageview = [[messageView alloc] initWithFrame:CGRectMake(0,44,1024,651)];
    messageview.tag = 200;

    [self.view addSubview: messageview];
    
}

-(void)goToDetail:(NSNotification*) notification{
    
    loginInfo.isOfflineMode = false;
    
    if(planDetail ==nil){
        
        planDetail = [[DetailViewController alloc] init];
        planDetail.view.frame = CGRectMake(0,0, self.view.frame.size.width,self.view.frame.size.height);
       
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        
        
        if (!window)
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        
        
        NSArray *subViews = [window subviews];
        
        [[subViews objectAtIndex:subViews.count-1] addSubview:planDetail.view];
    }
    
    
    NSMutableArray * array = [notification object];
    NSNumber *number =array[0];
    int id = [number intValue];
    
    [planDetail initView:id];
    
    
}


-(void)goToList:(NSNotification*) notification{

    CGRect endFrame= planDetail.view.frame;
    endFrame.origin.y= -self.view.frame.size.height;
    planDetail.view.frame=endFrame;    
    
}
-(void)removeDetailView:(NSNotification*) notification{

       [planDetail.view removeFromSuperview];
        planDetail = nil;
}

-(void)goToCollocation:(NSNotification*) notification{
    
    collocationDataTempPlan = [notification object];
    [self performSegueWithIdentifier:@"goToCollocation" sender:self];
    
    [planDetail.view removeFromSuperview];
    planDetail = nil;

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"goToCollocation"]) //"goView2"是SEGUE连线的标识
    {
        collocationViewController *theSegue = segue.destinationViewController;
        theSegue.collocationData = collocationDataTempPlan;
    }
}
-(void)back:(NSNotification*) notification{
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         CGRect endFrame= collocation.view.frame;
                         endFrame.origin.x=-self.view.frame.size.width;
                         collocation.view.frame= endFrame;
                     }
                     completion:^(BOOL finished) {
                         [self removeCollocationView:nil];
                     }
     ];
    
    
}
-(void)removeCollocationView:(id)sender{
    
    [collocation.view removeFromSuperview];
    collocation = nil;
}
- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    
    UIView *view = [self.view viewWithTag:200];
    if(view == nil){
        
        [self initNSNotificationCenter];
        [self addListView:@"1"];
    }
    loginInfo.collocationType =1;
    
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    
//      UIView *view = [self.view viewWithTag:200];
//      if(view != nil){
//           [view removeFromSuperview];
//            view = nil;
//      }
}

- (IBAction)retrievalAction:(id)sender {

    if(!popControllerPlan && !typeSearchPlan){
        
        typeSearchPlan = [[mutliRowViewController alloc] init];
        
        typeSearchPlan.view.backgroundColor = UIColorFromRGB(0xf4f4f4);
        
        popControllerPlan = [[UIPopoverController alloc] initWithContentViewController:typeSearchPlan];
        popControllerPlan.delegate=self;
        
        if(tempPlanSearchType){
            
            editPlanSearchType = [tempPlanSearchType mutableCopy];
            
            typeSearchPlan.view.frame = CGRectMake(0, 0,390,288);
            [popControllerPlan setPopoverContentSize:CGSizeMake(390,288) animated:YES];
            
            
            for (int i =0; i<editPlanSearchType.count; i++) {
                
                NSArray *typeItems = [editPlanSearchType[i] objectForKey:@"typeItems"];
                
                NSDictionary *item = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"全部%@",[editPlanSearchType[i] objectForKey:@"typeName"]],@"name",@"",@"code", nil];
                
                NSMutableArray *all = [[NSMutableArray alloc] initWithObjects:item, nil];
                
                [all addObjectsFromArray:typeItems];
                
                NSMutableDictionary *tempItem = [editPlanSearchType[i] mutableCopy];
                
                [tempItem setObject:all forKey:@"typeItems"];
                
                editPlanSearchType[i] = tempItem;
                
            }
            
            [typeSearchPlan initView:editPlanSearchType type:1];
        }
    }
    
    if(editPlanSearchType){
        
        [popControllerPlan presentPopoverFromRect:self.topBarLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
    else{
        
        [globalContext showAlertView:@"没有筛选条件可选"];
    }

}

- (IBAction)searchAction:(id)sender {
    
    float alpha = self.searchBorder.alpha;
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         if(alpha ==0){
                         self.searchBorder.alpha = 1;
                         self.searchText.hidden = false;
                        [self.searchText becomeFirstResponder];
                         }
                         else{
                         
                             self.searchBorder.alpha = 0;
                             self.searchText.hidden = true;
                              self.searchText.text = @"";
                             search = @"";
                             loginInfo.planSearch = search;
                             [self.searchText resignFirstResponder];

                         }
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];

}

- (IBAction)shareAction:(id)sender {
    
    NSArray  *data  =[[NSArray alloc] initWithObjects:sender,nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addShareView" object:data];

}

- (IBAction)accountAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLogin" object:nil];
}

- (IBAction)settingAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addSettingView" object:sender];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(self.searchText.text.length>0){
    
    search = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",@"keyword",self.searchText.text];
    
    loginInfo.planSearch = search;
    
    reload = @"3";
    
    if(messageview){
        
        [messageview getMessageList:@"1"];
    }

    }
    
   return  [self.searchText resignFirstResponder];
}
-(BOOL)textFieldShouldClear:(UITextField *)textField{

 self.searchText.text = @"";
    
 search = @"";
    
 loginInfo.planSearch = search;

 if(messageview){
    
    [messageview getMessageList:@"1"];
  }
  return [self.searchText resignFirstResponder];
}
@end
