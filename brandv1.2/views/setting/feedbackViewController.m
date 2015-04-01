//
//  feedbackViewController.m
//  brandv1.2
//
//  Created by Apple on 15/3/17.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "feedbackViewController.h"
#import "Define.h"
#import "AFNetworking.h"
#import "globalContext.h"
#import "LoginInfo.h"
#import "StockData.h"

@interface feedbackViewController ()

@end

@implementation feedbackViewController
LoginInfo *loginInfo;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    
    self.nameView.layer.cornerRadius = 5;
    self.nameView.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.nameView.layer.borderWidth = 1 ;
    
    self.addressView.layer.cornerRadius = 5;
    self.addressView.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.addressView.layer.borderWidth = 1 ;
    
    self.contactView.layer.cornerRadius = 5;
    self.contactView.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.contactView.layer.borderWidth = 1 ;
    
    self.descriptionView.layer.cornerRadius = 5;
    self.descriptionView.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
    self.descriptionView.layer.borderWidth = 1 ;
    
    self.submitButton.layer.cornerRadius = 5;
    
    self.nameTextField.delegate = self;
    self.addressTextField.delegate = self;
    self.contactTextField.delegate = self;
    self.descriptionTextView.delegate = self;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
 //   [center addObserver:self selector:@selector(KeyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(KeyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(id)sender {
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         self.view.frame = CGRectMake(-350, 0, 350,768);
                         
                     }
                     completion:^(BOOL finished) {
                         
                         [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
                         [self.view removeFromSuperview];
                         self.view = nil;
                     }
     ];

}

- (IBAction)closeAction:(id)sender {
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeSetting" object:nil];
    [self.view removeFromSuperview];
     self.view = nil;

}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{

    float y = 0;
    
    y = self.descriptionView.frame.origin.y;
    
    [self.scrollView setContentSize:CGSizeMake(0, self.scrollView.frame.size.height+y)];
    
    [self.scrollView setContentOffset:CGPointMake(0,y) animated:YES];

    
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    //返回一个BOOL值，指定是否循序文本字段开始编辑
    
    [self textFieldMoveTop:textField];
    
    return YES;
}
-(void)textFieldMoveTop:(UITextField *)textField{
    
    float y = 0;
    
    if (textField ==self.nameTextField) {
        
    }
    else if (textField ==self.contactTextField) {
        
        y = self.contactView.frame.origin.y;
    }
    else if (textField ==self.addressTextField) {
        
        y = self.addressView.frame.origin.y;
    }
    
    [self.scrollView setContentSize:CGSizeMake(0, self.scrollView.frame.size.height+y)];
    
    [self.scrollView setContentOffset:CGPointMake(0,y) animated:YES];
    
}
-(void)KeyboardDidHide:(id)sender{

    [self.scrollView setContentSize:CGSizeMake(0, self.scrollView.frame.size.height)];
    
    [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
}
- (IBAction)submitAction:(id)sender {
    
    if(self.descriptionTextView.text.length>0){
        self.descriptionView.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
        [self.mustInputTip setHidden:true];
        
        [loginInfo.progressBarView setTip:@"正在发送您的反馈信息..."];
        [self.view addSubview:loginInfo.progressBarView];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"name":self.nameTextField.text,@"address":self.addressTextField.text,@"contact":self.contactTextField.text,@"message":self.descriptionTextView.text};
        
        [manager POST:[BASEURL stringByAppendingString:saveFeedbackApi] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //  NSLog(@"JSON: %@", responseObject);
            
            [loginInfo.progressBarView removeFromSuperview];
            
            NSDictionary *rootDic = responseObject;
            NSString *flag  =[rootDic objectForKey:@"flag"];
            
            if([flag isEqualToString:@"true"]){
                
                
                self.nameTextField.text = @"";
                self.contactTextField.text = @"";
                self.addressTextField.text = @"";
                self.descriptionTextView.text = @"";
                
               [globalContext showAlertView:@"您的反馈信息发送成功"];
            }
            else{
                
                [globalContext showAlertView:@"您的反馈信息发送失败"];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [loginInfo.progressBarView removeFromSuperview];
            [globalContext showAlertView:@"网络异常"];
            
        }];

    }
    else{
    
        self.descriptionView.layer.borderColor = [UIColor redColor].CGColor;
        [self.mustInputTip setHidden:false];
    }
}
@end
