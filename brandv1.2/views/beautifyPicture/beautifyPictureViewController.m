//
//  beautifyPictureViewController.m
//  brandv1.2
//
//  Created by Apple on 15/3/4.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "beautifyPictureViewController.h"
#import "beautifyPicture.h"
#import "globalContext.h"
#import "StockData.h"
#import "LoginInfo.h"

@interface beautifyPictureViewController ()

@end
beautifyPicture *_beautifyPicture;
LoginInfo *loginInfo;
@implementation beautifyPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    loginInfo = [[StockData getSingleton] valueForKey:@"loginInfo"];
    [loginInfo addObserver:self forKeyPath:@"brand_logo_app" options:NSKeyValueObservingOptionNew context:nil];
    [globalContext settingBrandLogo:self.brandLogo nameLabel:self.brandNameLabel];
    [loginInfo addObserver:self forKeyPath:@"portrait" options:NSKeyValueObservingOptionNew context:nil];
     [globalContext setUserHead:self.accountButton];
    
    _beautifyPicture = [[beautifyPicture alloc] initWithFrame:CGRectMake(0,44,1024,651)];
    _beautifyPicture.tag = 202;
    
    [self.view addSubview: _beautifyPicture];

    self.searchTextField.delegate = self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"brand_logo_app"] && object == loginInfo) {
        [globalContext settingBrandLogo:self.brandLogo nameLabel:self.brandNameLabel];
        
    }
    if ([keyPath isEqualToString:@"portrait"] && object == loginInfo) {
        [globalContext setUserHead:self.accountButton];
    }
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

- (IBAction)searchAction:(id)sender {
    
    float alpha = self.searchBorder.alpha;
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         if(alpha ==0){
                             self.searchBorder.alpha = 1;
                             self.searchTextField.hidden = false;
                             [self.searchTextField becomeFirstResponder];
                         }
                         else{
                             
                             self.searchBorder.alpha = 0;
                             self.searchTextField.hidden = true;
                             self.searchTextField.text = @"";
                             [self.searchTextField resignFirstResponder];
                             
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];

}

- (IBAction)accountAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goUserCentre" object:nil];
}

- (IBAction)settingAction:(id)sender {
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"addSettingView" object:sender];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(self.searchTextField.text.length>0){
        
       NSString *search = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",@"keyword",self.searchTextField.text];
        

      [_beautifyPicture getMessageList:@"1" searchText:search];
      
        
    }
    
    return  [self.searchTextField resignFirstResponder];
}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    
    self.searchTextField.text = @"";
    
    [_beautifyPicture getMessageList:@"1" searchText:@""];

    
    return [self.searchTextField resignFirstResponder];
}

@end
