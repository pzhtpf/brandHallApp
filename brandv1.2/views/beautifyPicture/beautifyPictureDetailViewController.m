//
//  beautifyPictureDetailViewController.m
//  brandv1.2
//
//  Created by Apple on 15/3/6.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "beautifyPictureDetailViewController.h"
#import "Define.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "globalContext.h"
#import "loginViewController.h"
#import "LoginInfo.h"
#import "StockData.h"

@interface beautifyPictureDetailViewController ()

@end

@implementation beautifyPictureDetailViewController
float bpLastSwipeLocationY = 67;
int bpCommentPageIndex = 0;
NSMutableArray *bpAllCommentArray;
loginViewController *loginController;
id bpId;
LoginInfo *loginInfo;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initView:(NSDictionary *)data{

    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    
    bpAllCommentArray = [[NSMutableArray alloc] init];
    
    UIPanGestureRecognizer *swipeDown = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(barViewWasSwiped:)];
    [self.mainUpView addGestureRecognizer:swipeDown];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(KeyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(KeyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.bpCommentTextView.delegate = self;
    
    self.bpCommentTableView.dataSource = self;
    self.bpCommentTableView.delegate = self;
    [self.bpCommentTableView setBackgroundColor:[UIColor clearColor]];
    
    
    self.bpCommentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    [self.bgName setText:[data objectForKey:@"title"]];
    NSString *path = [NSString stringWithFormat:@"%@%@",imageUrl,[data objectForKey:@"image"]];
    [self.mainImageView setImageWithURL:[NSURL URLWithString:path] size:CGSizeMake(0, 0)];
    self.mainImageView.tag = [[data objectForKey:@"id"] intValue];
    
    
    if (_refreshHeaderView == nil) {
        
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f-self.bpCommentTableView.bounds.size.height,self.bpCommentTableView.frame.size.width,self.bpCommentTableView.bounds.size.height)];
        view.delegate = self;
        [self.bpCommentTableView addSubview:view];
        _refreshHeaderView = view;
        view = nil;
    }
    
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    
    
    bpId = [data objectForKey:@"id"];
    
    [self getbpDetailMessage:bpId];
    [self getbpCommentMessage:bpId reload:@"1"];
    
    
}
-(void)getbpDetailMessage:(id)bpId{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":bpId};
    
    [manager POST:[BASEURL stringByAppendingString: getCasesDetailApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //    NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *data = responseObject;
        
        NSString *timeStamp = [data objectForKey:@"create_time"];
        
        NSDate *dateTime = [NSDate  dateWithTimeIntervalSince1970:[timeStamp longLongValue]];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        
        [self.bgCreateTime setText:[formatter stringFromDate:dateTime]];
        
        [self.bgStyle setText:[data objectForKey:@"style"]];
        
        [self.bpDescription setText:[data objectForKey:@"description"]];
        
        int favorite = [[data objectForKey:@"favorite"] intValue];
        
        self.bpFavotiteButton.tag = favorite;
        
        if(favorite==1){
        
        NSString *favoritePathString = [[NSBundle mainBundle]pathForResource:@"favorite.png" ofType:@""];
        UIImage *favorite = [UIImage imageWithContentsOfFile:favoritePathString];
        [self.bpFavotiteButton setImage:favorite forState:UIControlStateNormal];
        favorite = nil;
        }
        
        else if(favorite==2){
        
            NSString *noFavoritePathString = [[NSBundle mainBundle]pathForResource:@"noFavorite.png" ofType:@""];
            UIImage *noFavorite = [UIImage imageWithContentsOfFile:noFavoritePathString];
            [self.bpFavotiteButton setImage:noFavorite forState:UIControlStateNormal];
            noFavorite = nil;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        
    }];


}

-(void)getbpCommentMessage:(id)bpId reload:(NSString *)reload{
    
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":bpId,@"pageIndex":[NSNumber numberWithInt:bpCommentPageIndex],@"pageCount":[NSNumber numberWithInt:4]};
    
    [manager POST:[BASEURL stringByAppendingString: getCommentApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
     //   NSLog(@"JSON: %@", responseObject);
        
        
        NSString *totalCount = [NSString stringWithFormat:@"共有%@条评论",[responseObject objectForKey:@"totalCount"]];
        
        [self.bpCommentTotalCount setText:totalCount];
        
        NSArray *data = [responseObject objectForKey:@"data"];
        
        if(data && data.count>0){
            
        [bpAllCommentArray addObjectsFromArray:data];
        [self.bpCommentTableView reloadData];
            bpCommentPageIndex++;
            
        }
        
        if([reload isEqualToString:@"1"]){
            
            [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
        }
        else{
            
            [self doneLoadMoreData];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        if([reload isEqualToString:@"1"]){
            
            [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
        }
        else{
            
            [self doneLoadMoreData];
        }

        
    }];
    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
       // [textView resignFirstResponder];
        
        if(self.bpCommentTextView.returnKeyType == UIReturnKeySend){
            
        if([globalContext isLogin]){
        
            [self.bpCommentTextView resignFirstResponder];
            [self postbpCommentMessage];
        }
        
        else{
            
            UIAlertView  *alertView=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 111;
            [alertView show];
        }
            
    }
        else{
        
          //  [self performSelectorInBackground:@selector(initInputView:) withObject:nil];
            self.bpCommentTextView.returnKeyType = UIReturnKeySend;
            [self.bpCommentTextView reloadInputViews];
            
             [self performSelector:@selector(initInputView:) withObject:nil afterDelay:0.1];
            
             return  YES;
            
        }
        
        return  NO;
    }
    else{
    
        if (self.bpCommentTextView.text.length ==1 && (!text.length)) {
            
            self.bpCommentTextView.returnKeyType = UIReturnKeySend;
            [self.bpCommentTextView reloadInputViews];
        }
        else{
        
            self.bpCommentTextView.returnKeyType = UIReturnKeyDone;
            [self.bpCommentTextView reloadInputViews];
      
        }
        
       return YES;
    }
}
-(void)initInputView1:(id)sender{
    


    self.bpCommentTextView.returnKeyType = UIReturnKeyDone;
    [self.bpCommentTextView reloadInputViews];
}
-(void)initInputView:(id)sender{
    
    self.bpCommentTextView.text = [self.bpCommentTextView.text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    self.bpCommentTextView.text = [self.bpCommentTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];


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
-(void)postbpCommentMessage{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":bpId,@"content":self.bpCommentTextView.text};
    
    [manager POST:[BASEURL stringByAppendingString: saveCommentApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
     //   NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *temp = responseObject;
        
        NSString *flag = [temp objectForKey:@"flag"];
        
        if([flag isEqualToString:@"true"]){
        
            [globalContext addStatusBarNotification:@"评论成功，审核后才能显示哦"];
            [self.bpCommentTextView setText:@""];
            [self.inputCommentTip setHidden:false];
            self.bpCommentTextView.returnKeyType = UIReturnKeySend;
        }
        else{
        
              [globalContext addStatusBarNotification:@"评论失败"];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
          [globalContext addStatusBarNotification:@"网络异常"];
    }];

    
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [self.inputCommentTip setHidden:true];
    [self.bpCommentTableView setHidden:true];
   
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    [self.bpCommentTableView setHidden:false];
    
    if(textView.text.length==0)
          [self.inputCommentTip setHidden:false];
}
- (void)KeyboardDidShow:(UITextField *)textField
{
    /* keyboard is visible, move views */
    
    loginInfo.keyBoardIsShow = true;
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         CGRect  endFrame =  self.bpCommentView.frame;
                         endFrame.origin.y =0;
                         self.bpCommentView.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}

- (void)KeyboardDidHide:(UITextField *)textField
{
    /* resign first responder, hide keyboard, move views */
    
    loginInfo.keyBoardIsShow = false;
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         CGRect  endFrame =  self.bpCommentView.frame;
                         endFrame.origin.y =463;
                         self.bpCommentView.frame = endFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
 
        return [bpAllCommentArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSArray *sub = [bpAllCommentArray[section] objectForKey:@"sub"];
    
    if(sub && ![sub isKindOfClass:[NSNull class]])
        return sub.count;
    
    else
   return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 90;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    
    return 80;
    
}
-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
    return @"";
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,0)];
    /* Create custom view to display section header... */
    
    [view setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
    
    NSDictionary *tempDictionary = bpAllCommentArray[section];
    
    view.frame = CGRectMake(0, 0, tableView.frame.size.width, 80);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    
    imageView.layer.cornerRadius = 5;
    [imageView setBackgroundColor:UIColorFromRGB(0x8e8e8e)];
    
    NSString *portrait = [tempDictionary objectForKey:@"portrait"];
    
    if(portrait.length>0){
    
        NSString *path = [NSString stringWithFormat:@"%@%@",imageUrl,portrait];
        
        NSURL *pathUrl = [NSURL URLWithString:path];
        [imageView setImageWithURL:pathUrl size:imageView.frame.size];

    }
  
    
    [view addSubview:imageView];
    
    NSString *nickNameString = [tempDictionary objectForKey:@"nickname"];
    
    NSString *timeStamp = [tempDictionary objectForKey:@"create_time"];
    
    NSDate *dateTime = [NSDate  dateWithTimeIntervalSince1970:[timeStamp longLongValue]];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSString *createTimeString = [formatter stringFromDate:dateTime];
    
    CGSize constraint1 = CGSizeMake(2800,20);
    CGSize size1 = [nickNameString sizeWithFont:[UIFont fontWithName:@"MicrosoftYaHei-Bold" size:10.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize size2 = [createTimeString sizeWithFont:[UIFont fontWithName:@"MicrosoftYaHei" size:10.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
    
    int width = (int)ceilf(size1.width);
    
    if(50+width+size2.width> tableView.frame.size.width)
        width = tableView.frame.size.width-50-size2.width;
    
    UILabel *nickName = [[UILabel alloc] initWithFrame:CGRectMake(40, 0,width,20)];
    [nickName setFont:[UIFont fontWithName:@"MicrosoftYaHei-Bold" size:10.0f]];
    [nickName setBackgroundColor:[UIColor clearColor]];
    [nickName setTextColor:UIColorFromRGB(0x2b2b2b)];
    [nickName setText:nickNameString];
    
    [view addSubview:nickName];
    
    UILabel *createTime = [[UILabel alloc] initWithFrame:CGRectMake(50+width,0,size2.width, 20)];
    [createTime setFont:[UIFont fontWithName:@"MicrosoftYaHei" size:10.0f]];
    [createTime setBackgroundColor:[UIColor clearColor]];
    [createTime setTextColor:UIColorFromRGB(0x2b2b2b)];
    
    
    
    [createTime setText:createTimeString];
    
     [view addSubview:createTime];
    
    UITextView *content = [[UITextView alloc] initWithFrame:CGRectMake(40,25, tableView.frame.size.width-40,55)];
    [content setFont:[UIFont fontWithName:@"MicrosoftYaHei" size:10.0f]];
    [content setBackgroundColor:[UIColor clearColor]];
    [content setTextColor:UIColorFromRGB(0x2b2b2b)];
    [content setText:[tempDictionary objectForKey:@"content"]];
    
    [view addSubview:content];
    
    
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setTextColor:UIColorFromRGB(0x2B2B2B)];

    [cell setBackgroundColor:[UIColor clearColor]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20,10, tableView.frame.size.width-20,0)];
    /* Create custom view to display section header... */
    
    NSDictionary *temp1Dictionary = bpAllCommentArray[indexPath.section];
    NSArray *sub = [temp1Dictionary objectForKey:@"sub"];
    NSDictionary *tempDictionary = sub[indexPath.row];
    
    view.frame = CGRectMake(20,10, tableView.frame.size.width-20, 80);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    
    imageView.layer.cornerRadius = 5;
    [imageView setBackgroundColor:UIColorFromRGB(0x8e8e8e)];

    
    NSString *portrait = [tempDictionary objectForKey:@"portrait"];
    
    if(portrait.length>0){
        
        NSString *path = [NSString stringWithFormat:@"%@%@",imageUrl,portrait];
        
        NSURL *pathUrl = [NSURL URLWithString:path];
        [imageView setImageWithURL:pathUrl size:imageView.frame.size];
        
    }
    
    [view addSubview:imageView];
    
   NSString *nickNameString = [tempDictionary objectForKey:@"nickname"];
    
    NSString *timeStamp = [tempDictionary objectForKey:@"create_time"];
    
    NSDate *dateTime = [NSDate  dateWithTimeIntervalSince1970:[timeStamp longLongValue]];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSString *createTimeString = [formatter stringFromDate:dateTime];
    
    CGSize constraint1 = CGSizeMake(2800,20);
    CGSize size1 = [nickNameString sizeWithFont:[UIFont fontWithName:@"MicrosoftYaHei-Bold" size:10.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize size2 = [createTimeString sizeWithFont:[UIFont fontWithName:@"MicrosoftYaHei" size:10.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
    
    float width = (int)ceilf(size1.width);
    
    if(50+width+size2.width> tableView.frame.size.width-20)
        width = tableView.frame.size.width-20-50-size2.width;
    
    UILabel *nickName = [[UILabel alloc] initWithFrame:CGRectMake(40, 0,width, 20)];
    [nickName setFont:[UIFont fontWithName:@"MicrosoftYaHei-Bold" size:10.0f]];
    [nickName setBackgroundColor:[UIColor clearColor]];
    [nickName setTextColor:UIColorFromRGB(0x2b2b2b)];
    [nickName setText:nickNameString];
    
    [view addSubview:nickName];
    
    UILabel *createTime = [[UILabel alloc] initWithFrame:CGRectMake(50+width,0,size2.width, 20)];
    [createTime setFont:[UIFont fontWithName:@"MicrosoftYaHei" size:10.0f]];
    [createTime setBackgroundColor:[UIColor clearColor]];
    [createTime setTextColor:UIColorFromRGB(0x2b2b2b)];
    

    
    [createTime setText:createTimeString];
    
    [view addSubview:createTime];
    
    UITextView *content = [[UITextView alloc] initWithFrame:CGRectMake(40,25, tableView.frame.size.width-60,55)];
    [content setFont:[UIFont fontWithName:@"MicrosoftYaHei" size:10.0f]];
    [content setBackgroundColor:[UIColor clearColor]];
    [content setTextColor:UIColorFromRGB(0x2b2b2b)];
    [content setText:[tempDictionary objectForKey:@"content"]];
    
    [view addSubview:content];

    [cell.contentView addSubview:view];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
 //   UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    

    
}


- (void)barViewWasSwiped:(UIPanGestureRecognizer*)recognizer
{
    CGPoint swipeLocation = [recognizer locationInView:self.mainUpView];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _bpCanMove = YES;
      
        return;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged && _bpCanMove) {
        float maxYPosition = 100;
        
        if(swipeLocation.y<67){
            NSLog(@"%f",swipeLocation.y);
            
            if (700+swipeLocation.y > maxYPosition && swipeLocation.y<bpLastSwipeLocationY) {
                
                bpLastSwipeLocationY = swipeLocation.y;
                CGRect frame = CGRectMake(0,700+swipeLocation.y, self.mainUpView.frame.size.width, self.mainUpView.frame.size.height);
                [self.mainUpView setFrame:frame];
            }
        }
        
        else{
            
            if (100+swipeLocation.y < 700 && swipeLocation.y>bpLastSwipeLocationY) {
                //   NSLog(@"%f",swipeLocation.y);
                bpLastSwipeLocationY = swipeLocation.y;
                CGRect frame = CGRectMake(0,100+swipeLocation.y, self.mainUpView.frame.size.width, self.mainUpView.frame.size.height);
                [self.mainUpView setFrame:frame];
            }
            
        }
        
        return;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded && _bpCanMove) {
        float pivotYPosition = 600;
        bpLastSwipeLocationY = 0;
        
        if(swipeLocation.y>0){
            
            pivotYPosition = 300;
        }
        
        _bpCanMove = NO;
        [self completeAnimation:(self.mainUpView.frame.origin.y < pivotYPosition)];
        return;
    }
}

#pragma mark - Private methods

- (void)completeAnimation:(BOOL)show
{
    _bpIsHidden = !show;
    //   CGRect parentFrame = self.parentView.frame;
    CGRect goToFrame;
    if (show) {
        goToFrame = CGRectMake(0, 190, self.mainUpView.frame.size.width, self.mainUpView.frame.size.height);
    }
    else {
        goToFrame = CGRectMake(0, 700, self.mainUpView.frame.size.width, self.mainUpView.frame.size.height);
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainUpView setFrame:goToFrame];
    } completion:^(BOOL finished){
        if (finished) {
            if (show) {
         
                self.upTopBackLabel.alpha=0.95;
            }
            else if (!show) {
            
                self.upTopBackLabel.alpha=1.0;
            }
        }
    }];
}
- (IBAction)backAction:(id)sender {
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         self.view.frame = CGRectMake(0,768,1024, 768);
                     }
                     completion:^(BOOL finished) {
                         
                         bpLastSwipeLocationY = 67;
                         bpCommentPageIndex = 0;
                         [bpAllCommentArray removeAllObjects];
                         [self.bpCommentTableView reloadData];

                         
                        [self.view removeFromSuperview];
                         self.view = nil;
                     }
     ];

}

- (IBAction)shareAction:(id)sender {
    
 //   NSArray  *data  =[[NSArray alloc] initWithObjects:sender,nil];
    
    if(self.mainImageView.image){
    
    NSArray  *data  =[[NSArray alloc] initWithObjects:sender,self.mainImageView.image,self.bgName.text,nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addShareView" object:data];
        
    }
    else{
    
        [globalContext showAlertView:@"请稍候，正在加载美图..."];
    }
    
}

- (IBAction)accountAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goUserCentre" object:nil];
}

- (IBAction)settingAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addSettingView" object:sender];
}
- (IBAction)bgFavoriteAction:(id)sender {
    
    //类型：1商品2方案3案例图
    
       if ([globalContext isLogin]) {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"id":bpId,@"type":[NSNumber numberWithInt:3],@"status":[NSNumber numberWithInt:self.bpFavotiteButton.tag]};
    
    [manager POST:[BASEURL stringByAppendingString: changeFavoriteApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //   NSLog(@"JSON: %@", responseObject);
        
        
        NSDictionary *temp = responseObject;
        
        NSString *flag = [temp objectForKey:@"flag"];
        
        if([flag isEqualToString:@"true"]){
            
            if(self.bpFavotiteButton.tag==2){
                
                self.bpFavotiteButton.tag=1;
                NSString *favoritePathString = [[NSBundle mainBundle]pathForResource:@"favorite.png" ofType:@""];
                UIImage *favorite = [UIImage imageWithContentsOfFile:favoritePathString];
                [self.bpFavotiteButton setImage:favorite forState:UIControlStateNormal];
                favorite = nil;
            }
            
            else if(self.bpFavotiteButton.tag==1){
                
                self.bpFavotiteButton.tag=2;
                NSString *noFavoritePathString = [[NSBundle mainBundle]pathForResource:@"noFavorite.png" ofType:@""];
                UIImage *noFavorite = [UIImage imageWithContentsOfFile:noFavoritePathString];
                [self.bpFavotiteButton setImage:noFavorite forState:UIControlStateNormal];
                noFavorite = nil;
            }

        }
        else{
            
            if(self.bpFavotiteButton.tag==2){
                
              [globalContext addStatusBarNotification:@"收藏失败"];
                
            }
            else{
            
                 [globalContext addStatusBarNotification:@"取消收藏失败"];
            }
        }

        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
        
        
        if(self.bpFavotiteButton.tag==2){
            
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
- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    bpCommentPageIndex = 0;
    [bpAllCommentArray removeAllObjects];
    [self getbpCommentMessage:bpId reload:@"1"];

    
    _reloading = YES;
    
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.bpCommentTableView];
    
}

- (void)doneLoadMoreData{
    
    //  model should call this when its done loading
    [_refreshHeaderView egoRefreshScrollViewDataSourceLoadMoreDidFinished:self.bpCommentTableView];
    
}
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}
- (void)egoRefreshTableHeaderDidTriggerLoadMore:(EGORefreshTableHeaderView*)view{
    
    [self getbpCommentMessage:bpId reload:@"2"];

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    // NSArray *views = [table subviews];
    
    [self reloadTableViewDataSource];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    _refreshHeaderView = nil;
}
@end
