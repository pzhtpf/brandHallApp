//
//  productDisplayViewController.m
//  brandv1.2
//
//  Created by Apple on 14-8-6.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "productDisplayViewController.h"
#import "Define.h"
#import "productMessageView.h"
#import "productDetailViewController.h"
#import "AFNetworking.h"
#import "StockData.h"
#import "LoginInfo.h"
#import "globalContext.h"
#import "typeSearchTableViewController.h"

@interface productDisplayViewController ()

@end

@implementation productDisplayViewController
NSMutableArray *productAllData;
UITableView *tableViewTemp;
NSArray *category;
productMessageView *product;
productDetailViewController *productDetail;
UIScrollView *productScrollView;
int productPageIndex=0;
NSString *searchField =@"";
LoginInfo *loginInfo;
NSString *productSearchName;
NSString *productSearchField;
NSString *productSecondSearchName;
NSString *productSearchCode;
NSString *productSecondSearchCode;
NSDictionary *productToCollocationData;
NSString *reLoad = @"0";
typeSearchTableViewController *typeSearch;
UIPopoverController *popController;
NSMutableArray *isExtend;
UITableView *childTableView;
UITableView *secondChildTableView;
NSArray *childArray;
NSArray *secondChildArray;
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
    // Do any additional setup after loading the view.
    loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    loginInfo.productSearch = @"";
    
    [loginInfo addObserver:self forKeyPath:@"brand_logo_app" options:NSKeyValueObservingOptionNew context:nil];
    [globalContext setUserHead:self.accountButton];
    
    self.totalCount.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
    self.productButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
    self.productTips.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
    self.menu.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
    [self.productButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    [self.totalCount setTextColor:UIColorFromRGB(0x666666)];
    
    self.orderByTextLabel.userInteractionEnabled = YES;
    [self.orderByTextLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(orderByAction:)]];
    
    self.productSearchBar.delegate = self;
    
    self.searchText.delegate = self;
    
    self.searchText.returnKeyType = UIReturnKeySearch;
    
    [self getProductType:nil];
    
    loginInfo.isProductDetail = false;
    
    [globalContext settingBrandLogo:self.brandLogo nameLabel:self.brandNameLabel];
    
   }
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"brand_logo_app"] && object == loginInfo) {
        [globalContext settingBrandLogo:self.brandLogo nameLabel:self.brandNameLabel];
        
    }
}
-(void)reLogin:(id)sender{
    
        [globalContext setUserHead:self.accountButton];
}
-(void)initNSNotificationCenter{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addListView:) name:@"productaddListView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToProductDetail:) name:@"goToProductDetail" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTotalCount:) name:@"updateTotalCount" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productToCollocation:) name:@"productToCollocation" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeProductDetailView:) name:@"removeProductDetailView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderByType:) name:@"orderByType" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadView:) name:@"unloadView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLogin:) name:@"reLogin" object:nil];

    
}
-(void)unloadView:(NSNotification *)sender{
    
//    [product removeFromSuperview];
//    product = nil;
//    searchField = @"";
//    productPageIndex = 0;
//    [productScrollView removeFromSuperview];
//    productScrollView = nil;
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"goToProductDetail" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"productaddListView" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateTotalCount" object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"productToCollocation" object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeProductDetailView" object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeProductDetailView" object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"unloadView" object:nil];
//    
//      [[NSNotificationCenter defaultCenter] removeObserver:self name:@"orderByType" object:nil];
    
}
-(void)orderByType:(NSNotification *)notification{
    
    NSArray *orderByArray = @[@"名称",@"价格",@"上架时间"];
    
    int selectIndex = [[notification object] intValue];
    
    
    NSString *name = orderByArray[selectIndex];
    
    CGSize constraint1 = CGSizeMake(2800,21);
    CGSize size1 = [name sizeWithFont:[UIFont fontWithName:@"MicrosoftYaHei" size:12.0f] constrainedToSize:constraint1 lineBreakMode:NSLineBreakByWordWrapping];
    
    [self.dropArrowButton setFrame:CGRectMake(self.orderByTextLabel.frame.origin.x+size1.width+5, self.dropArrowButton.frame.origin.y, self.dropArrowButton.frame.size.width, self.dropArrowButton.frame.size.height)];

    
    [self.orderByTextLabel setText:orderByArray[selectIndex]];
    
    if(product)
        [product orderByType:selectIndex];

}
-(void)productToCollocation:(NSNotification *)sender{
    
    productToCollocationData = [sender object];
    [self performSegueWithIdentifier:@"productToCollocation" sender:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"productToCollocation"]) //"goView2"是SEGUE连线的标识
    {
        collocationViewController *theSegue = segue.destinationViewController;
        theSegue.collocationData = productToCollocationData;
    }
}
-(void)updateTotalCount:(NSNotification *)totalCount{
    
    
    if([reLoad isEqualToString:@"2"]){
        
        
       
            NSString *tips = [NSString stringWithFormat:@" > %@",productSearchName];
            [self.productTips setText:tips];
            [product initProductIndex:nil];
           [self.productTips setTextColor:[UIColor blackColor]];
        
    }
    
    else  if([reLoad isEqualToString:@"3"]){
        
        
     
            NSString *tips = [NSString stringWithFormat:@"\"%@\"的搜索结果",self.productSearchBar.text];
            [self.productTips setText:tips];
            [self.productTips setTextColor:[UIColor redColor]];
             [product initProductIndex:nil];
        
    }

    reLoad = @"0";
    
    NSString *total = [NSString stringWithFormat:@"共%@件商品",[totalCount object]];
    
    [self.totalCount setText:total];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            
            interfaceOrientation == UIInterfaceOrientationLandscapeRight );
}
#pragma mark - Table View

-(void)getProductType:(id)sender{
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
        [manager POST:[BASEURL stringByAppendingString: getProductTypeApi] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
    
            NSArray *rootArray = responseObject;
    
            if([rootArray isKindOfClass:[NSArray class]]){
    
            loginInfo.productSearchType = [rootArray mutableCopy];
                
            NSDictionary *firstDictionary = @{@"searchField":@"all",@"typeItems":[[NSArray alloc] init],@"typeName":@"全部商品"};
            [loginInfo.productSearchType insertObject:firstDictionary atIndex:0];
                
            isExtend =[[NSMutableArray alloc] init];
                
                for (int i=0;i<loginInfo.productSearchType.count; i++) {
                    
                    [isExtend addObject:[NSNumber numberWithInt:1]];
                    
                }
    
            
                [tableViewTemp setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
                tableViewTemp = [[UITableView alloc] init];
                tableViewTemp.tag = 0;
                tableViewTemp.frame = CGRectMake(0,0,165,654);
                tableViewTemp.delegate = self;
                tableViewTemp.dataSource = self;
                [tableViewTemp setSeparatorColor:UIColorFromRGB(0xd7d7d7)];
                [self.mainTableView addSubview: tableViewTemp];
                
                tableViewTemp.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
                [tableViewTemp reloadData];
            }
    
    
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
    
    
        }];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   // tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView.tag==0)
    return [loginInfo.productSearchType count];
    
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     if(tableView.tag == 0){
    
    NSDictionary *temp = loginInfo.productSearchType [section];
    NSArray *typeItems = [temp objectForKey:@"typeItems"];
    if([typeItems isKindOfClass:[NSArray class]]){
        
        if(!isExtend[section] || [isExtend[section] integerValue]==1){
             return [typeItems count];
        }
        else{
            
            return 0;
        }
       
    }
    else return 0;
}
   else if(tableView.tag == 1)
       return childArray.count;
   else
       return secondChildArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 45)];
    view.tag = section;
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 42)];
    [label setFont:[UIFont boldSystemFontOfSize:15]];
    [label setTextColor:UIColorFromRGB(0x131313)];
    label.textAlignment = NSTextAlignmentCenter;
     label.font=[UIFont fontWithName:@"MicrosoftYaHei" size:15];
    [view addSubview:label];
    
    UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width,1)];
    [topLine setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
    [view addSubview:topLine];
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(17,18,15,8)];
   
    if(tableView.tag ==0){
    
     [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ExpandOrCollapse:)]];
        
    NSDictionary *temp = loginInfo.productSearchType[section];
    NSString *string = [temp objectForKey:@"typeName"];
        /* Section header is in 0th index... */
    [label setText:string];
        
     NSArray *typeItems = [temp objectForKey:@"typeItems"];
      
    if(typeItems.count>0){
        
    if(!isExtend[view.tag] || [isExtend[view.tag] integerValue]==1){
        [back setImage:[UIImage imageNamed:@"upArrow.png"] forState:UIControlStateNormal];
    }
    else{
        [back setImage:[UIImage imageNamed:@"dropArrow.png"] forState:UIControlStateNormal];
    }
        
        [back addTarget:self action:@selector(buttonExpandOrCollapse:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:back];
            
      }
    }
    
    else{
    
        
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backParentView:)]];
        
        if(tableView.tag==1)
        [label setText:productSearchName];
        else
        [label setText:productSecondSearchName];
        
        back.frame = CGRectMake(17, 13, 9, 15);

        [back setImage:[UIImage imageNamed:@"detailBackIcon.png"] forState:UIControlStateNormal];
        
        [back addTarget:self action:@selector(backParentView:) forControlEvents:UIControlEventTouchUpInside];
        
        back.tag = tableView.tag;
        
        [view addSubview:back];
    }
    
    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, tableView.frame.size.width,1)];
    [bottomLine setBackgroundColor:UIColorFromRGB(0xd7d7d7)];
    [view addSubview:topLine];
    [view addSubview:bottomLine];
    [view setBackgroundColor:UIColorFromRGB(0xf4f4f4)]; //your background color...
    return view;
}
-(void)ExpandOrCollapse:(UIGestureRecognizer *)recognizer{

    UIView *view = [recognizer view];
    
    if (view.tag != 0) {
    
    if(!isExtend[view.tag] || [isExtend[view.tag] integerValue]==1){
        isExtend[view.tag] = [NSNumber numberWithInt:0];
    }
    else{
        isExtend[view.tag] = [NSNumber numberWithInt:1];
    }
    
    [tableViewTemp reloadSections:[NSIndexSet indexSetWithIndex:view.tag] withRowAnimation:UITableViewRowAnimationFade];
      
    }
    else{
    
        //加载全部商品
        
        searchField = @"";
        
        loginInfo.productSearch = searchField;
        
        reLoad = @"3";
        
        [product getMessageList:@"1"];
    
    }
    
}

-(void)buttonExpandOrCollapse:(UIButton *)sender{
    
    UIView *view = [sender superview];
    
    if(!isExtend[view.tag] || [isExtend[view.tag] integerValue]==1){
        isExtend[view.tag] = [NSNumber numberWithInt:0];
    }
    else{
        isExtend[view.tag] = [NSNumber numberWithInt:1];
    }
    
    [tableViewTemp reloadSections:[NSIndexSet indexSetWithIndex:view.tag] withRowAnimation:UITableViewRowAnimationFade];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDictionary *temp = loginInfo.planSearchType[section];
    
    return [temp objectForKey:@"typeName"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    [cell.textLabel setTextColor:UIColorFromRGB(0x2b2b2b)];
    cell.textLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
    
    if(tableView.tag == 0){
    
    NSDictionary *temp = loginInfo.productSearchType [indexPath.section];
    NSArray *typeItems = [temp objectForKey:@"typeItems"];
    NSDictionary *typeItem = typeItems[indexPath.row];
    [cell.textLabel setText:[typeItem objectForKey:@"name"]];
    
    NSArray *childArray = [typeItem objectForKey:@"parentcode"];
    
    if(childArray.count>0)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else if(tableView.tag == 1){
    
        NSDictionary *temp1 = childArray[indexPath.row];
        NSArray *childArray = [temp1 objectForKey:@"parentcode"];
        
        if(childArray.count>0)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [cell.textLabel setText:[temp1 objectForKey:@"name"]];
    }
    else if(tableView.tag == 2){
        
        NSDictionary *temp1 = secondChildArray[indexPath.row];
        NSArray *childArray = [temp1 objectForKey:@"parentcode"];
        
        if(childArray.count>0)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [cell.textLabel setText:[temp1 objectForKey:@"name"]];
    }
    
    [cell setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView.tag==0){
    
    NSDictionary *temp = loginInfo.productSearchType[indexPath.section];
    
    productSearchField = [temp objectForKey:@"searchField"];
    NSArray *typeItems = [temp objectForKey:@"typeItems"];
    
    
    
    productSearchCode = [typeItems[indexPath.row] objectForKey:@"code"];
    productSearchName = [typeItems[indexPath.row] objectForKey:@"name"];
    
    searchField = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",productSearchField,productSearchCode];
    
    loginInfo.productSearch = searchField;
    
    reLoad = @"2";
    
    NSArray *childArrayTemp = [typeItems[indexPath.row] objectForKey:@"parentcode"];
    
    if(childArrayTemp.count>0){   // Add  child view
        
        childArray = childArrayTemp;
        
        [self addChildTableView];
    }
    
    }
    else if(tableView.tag==1){
    
        NSArray *childArrayTemp = [childArray[indexPath.row] objectForKey:@"parentcode"];
        productSecondSearchName = [childArray[indexPath.row] objectForKey:@"name"];
        
        
        productSecondSearchCode = [childArray[indexPath.row] objectForKey:@"code"];
        
        searchField = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",productSearchField,productSecondSearchCode];
        
        loginInfo.productSearch = searchField;
        
        reLoad = @"2";

        
        if(childArrayTemp.count>0){   // Add  child view
            
            secondChildArray = childArrayTemp;
        
            [self addSecondChildTableView];
        }

    }
    else{
    
        NSDictionary *temp1 = secondChildArray[indexPath.row];
        NSString *code = [temp1 objectForKey:@"code"];
        searchField = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",productSearchField,code];
        loginInfo.productSearch = searchField;
        reLoad = @"2";
    }
    
    [product getMessageList:@"1"];
}
-(void)addChildTableView{
   
    if(!childTableView){
    
        childTableView = [[UITableView alloc] initWithFrame:CGRectMake(165,0,165,654)];
        
        childTableView.dataSource= self;
        
        childTableView.delegate = self;
        
        childTableView.tag = 1;
        
        childTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [self.mainTableView addSubview:childTableView];
    }

    [childTableView reloadData];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         childTableView.frame = CGRectMake(0,0,165,654);
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];

}
-(void)addSecondChildTableView{
    
    if(!secondChildTableView){
        
        secondChildTableView = [[UITableView alloc] initWithFrame:CGRectMake(165,0,165,654)];
        
        secondChildTableView.dataSource= self;
        
        secondChildTableView.delegate = self;
        
        secondChildTableView.tag = 2;
        
        secondChildTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [self.mainTableView addSubview:secondChildTableView];
    }
    
    [secondChildTableView reloadData];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         secondChildTableView.frame = CGRectMake(0,0,165,654);
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
    
}
-(void)backParentView:(id)sender{
    
    int tag = 0;
    
    if([sender isKindOfClass:[UIButton class]]){
       UIButton *back = (UIButton *)sender;
        tag = back.tag;
    }
    else{
    
        UIView *view = [(UIGestureRecognizer *)sender view];
        NSArray *subViews = [view subviews];
        for (UIView *temp in subViews) {
            
            if([temp isKindOfClass:[UIButton class]]){
                UIButton *back = (UIButton *)temp;
                tag = back.tag;
                break;
            }
        }
    }

    if(tag==1)
    searchField = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",productSearchField,productSearchCode];
    else
    searchField = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",productSearchField,productSecondSearchCode];
    
    loginInfo.productSearch = searchField;
    
    reLoad = @"2";
    
    [product getMessageList:@"1"];
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         if(tag==1)
                         childTableView.frame = CGRectMake(165,0,165,654);
                         else
                         secondChildTableView.frame = CGRectMake(165,0,165,654);

                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];


}
-(void)addListView:(id)sender{
    
    
    productScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(166,86,859,654)];
    
    product= [[productMessageView alloc] initWithFrame:CGRectMake(0,0,859,654)];
    product.tag = 110;
 //   productScrollView.contentSize = CGSizeMake(1004, 0);
    [productScrollView addSubview:product];
    [self.view addSubview: productScrollView];
    
    [self.menu setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
}

-(void)goToProductDetail:(NSNotification*) notification{
    
    // if(productDetail ==nil){
    
    productDetail = [[productDetailViewController alloc] init];
    productDetail.view.frame = CGRectMake(0,-self.view.frame.size.height, self.view.frame.size.width,self.view.frame.size.height-73);
//    [self.view addSubview:productDetail.view];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    
    
    NSArray *subViews = [window subviews];
    
    [[subViews objectAtIndex:subViews.count-1] addSubview:productDetail.view];
    
    //  }
    
    
    
    CGRect endFrame= productDetail.view.frame;
    endFrame.origin.y=0;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    productDetail.view.frame=endFrame;
    [UIView commitAnimations];
    
    NSMutableArray * array = [notification object];
    
    [productDetail initView:array];
    
}

-(void)back:(NSNotification*) notification{
    
    
    CGRect endFrame= productDetail.view.frame;
    endFrame.origin.y= -self.view.frame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    productDetail.view.frame=endFrame;
    [UIView commitAnimations];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(removeProductDetailView:) object:nil];
    [thread start];
}

-(void)removeProductDetailView:(id)sender{

    [productDetail.view removeFromSuperview];
    productDetail = nil;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    
    searchField = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",@"keyword",searchBar.text];
    
    loginInfo.productSearch = searchField;
    
    reLoad = @"3";
    
    [product getMessageList:@"1"];

    
    [searchBar resignFirstResponder];
}
//cancel button clicked...
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar                    // called when cancel button pressed
{
    NSLog( @"%s,%d" , __FUNCTION__ , __LINE__ );
    
    searchField = @"";
    
    loginInfo.productSearch = searchField;
    
    [product getMessageList:@"1"];
    
    [searchBar resignFirstResponder];
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    NSLog(@"%d",searchText.length);
    if(searchText.length == 0)
    {
        searchField = @"";
        
        loginInfo.productSearch = searchField;
        [self.productTips setText:@""];
         [product getMessageList:@"1"];
    }
    
}
- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    
    loginInfo.isOfflineMode = false;
    
      if(product == nil)
      {
          [self addListView:nil];
          [self initNSNotificationCenter];
        //  [self getMessage:@"0"];
      }
    
    if(loginInfo.isProductDetail){
        
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        
        if (!window)
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        
        
        NSArray *subViews = [window subviews];
        
        [[subViews objectAtIndex:subViews.count-1] addSubview:productDetail.view];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    if(loginInfo.isProductDetail){
    [self.view addSubview:productDetail.view];
    }
}

- (IBAction)productButtonAction:(id)sender {
    searchField = @"";
    
    loginInfo.productSearch = searchField;
    
    [self.productTips setText:@""];
    
    [product getMessageList:@"1"];
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

- (IBAction)searchAction:(id)sender {
    
    float alpha = self.searchBorderImage.alpha;
    
    [UIView setAnimationsEnabled:true];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         if(alpha ==0){
                             self.searchBorderImage.alpha = 1;
                             self.searchText.hidden = false;
                             [self.searchText becomeFirstResponder];
                         }
                         else{
                             
                             self.searchBorderImage.alpha = 0;
                             self.searchText.hidden = true;
                             self.searchText.text = @"";
                             searchField = @"";
                             loginInfo.productSearch = searchField;
                             [self.searchText resignFirstResponder];
                             
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if(textField.text.length>0){

    searchField = [NSString stringWithFormat:@"{\"%@\":\"%@\"}",@"keyword",textField.text];
    
    loginInfo.productSearch = searchField;
    
    reLoad = @"3";
    
    [product getMessageList:@"1"];
    }
    
    return  [self.searchText resignFirstResponder];
}
- (IBAction)orderByAction:(id)sender {
    
    if(!typeSearch || !popController){
        
        typeSearch = [[typeSearchTableViewController alloc] init];
        
        popController = [[UIPopoverController alloc] initWithContentViewController:typeSearch];
        
        typeSearch.view.frame = CGRectMake(0, 0, 110, 100);
        popController.popoverContentSize = CGSizeMake(110,100);
        
        [typeSearch initView:15];
    }
    
    [popController presentPopoverFromRect:self.orderByTextLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    
    self.searchText.text = @"";
    
    searchField = @"";
    
    loginInfo.productSearch = searchField;
    
    reLoad = @"3";
    
    [product getMessageList:@"1"];
    
    return [self.searchText resignFirstResponder];
}
@end
