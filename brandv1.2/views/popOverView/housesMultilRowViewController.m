//
//  housesMultilRowViewController.m
//  brandv1.2
//
//  Created by Apple on 15/3/19.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "housesMultilRowViewController.h"
#import "Define.h"

@interface housesMultilRowViewController ()

@end

@implementation housesMultilRowViewController

NSMutableArray *firstData;
NSMutableArray *secondData;

NSIndexPath *firstIndexPath;
NSIndexPath *secondIndexPath;

int _type = 0;

NSDictionary *areaDictionary;

UITableView *thridTableView;

UIView *cityHeaderView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.firstTableView.delegate = self;
    self.firstTableView.dataSource = self;
    self.firstTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.firstTableView.separatorColor = UIColorFromRGB(0xd0d0d0);
    
    
    self.secondTableView.delegate = self;
    self.secondTableView.dataSource = self;
    self.secondTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.secondTableView.separatorColor = UIColorFromRGB(0xd0d0d0);
}

-(void)initView:(NSMutableArray *)data type:(int)_typeArgs{
    
    _type = _typeArgs;
    
    firstData = [[NSMutableArray alloc] init];
    secondData = [[NSMutableArray alloc] init];
    
    firstIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    secondIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    

    
    for (int i =0;i<data.count;i++) {
        
        if(i%2==0){
            
          //  NSLog(@"%@",data[i]);
            
            NSArray *typeItems = [data[i] objectForKey:@"typeItems"];
            
            [firstData addObjectsFromArray:typeItems];
        }
        if(i%2==1)
            [secondData addObject:data[i]];

    }
    
    [self.firstTableView reloadData];
    [self.secondTableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(tableView.tag ==1)
        return firstData.count;
    else if(tableView.tag ==1)
        return secondData.count;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSDictionary *temp;
    NSArray *_typeItems;
    
    if(tableView.tag ==1){
        temp = firstData[section];
          _typeItems = [temp objectForKey:@"parentcode"];
    }
    else if(tableView.tag ==2){
        temp = secondData[section];
        _typeItems = [temp objectForKey:@"typeItems"];
    }
    else{
    
        _typeItems = [areaDictionary objectForKey:@"parentcode"];

    }
  
    
    if([_typeItems isKindOfClass:[NSArray class]]){
        
        return [_typeItems count];
    }
    else return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 32;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    
    return 40;
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,0)];
    /* Create custom view to display section header... */
    
    
    view.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, tableView.frame.size.width, 40)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    [label setBackgroundColor:[UIColor clearColor]];
    
    NSDictionary *temp;
    NSString *string;
    
    if(tableView.tag ==1){
        temp = firstData[section];
        string = [temp objectForKey:@"name"];
        
        if (section ==0) {
           
            cityHeaderView = view;
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadAllCity:)]];
        }
    }
    else  if(tableView.tag ==2){
        temp = secondData[section];
        string = [temp objectForKey:@"typeName"];
    }
    else{
        
      label.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
      label.textAlignment = NSTextAlignmentCenter;
        
     [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backParentView:)]];
        
        UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(14, 13, 9, 15)];
        
        [back setImage:[UIImage imageNamed:@"detailBackIcon.png"] forState:UIControlStateNormal];
        
        [back addTarget:self action:@selector(backParentView:) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:back];
        
      string = [areaDictionary objectForKey:@"name"];
    }
    
    
    
    /* Section header is in 0th index... */
    [label setText:string];
    [label setTextColor:UIColorFromRGB(0x222222)];
    label.font=[UIFont fontWithName:@"MicrosoftYaHei-Bold" size:12.0f];
    [view addSubview:label];
    [view setBackgroundColor:UIColorFromRGB(0xf4f4f4)]; //your background color...
    
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setTextColor:UIColorFromRGB(0x2B2B2B)];
    
    cell.textLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0f];
    [cell setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
    
    if(tableView.tag ==1 || tableView.tag==2){
    
    NSDictionary *temp;
    NSArray *_typeItems;
        
    if(tableView.tag ==1){
        temp = firstData[indexPath.section];
        _typeItems = [temp objectForKey:@"parentcode"];
    }
    else if(tableView.tag ==2){
        temp = secondData[indexPath.section];
       _typeItems = [temp objectForKey:@"typeItems"];

    }
    
    NSDictionary *_typeItem = _typeItems[indexPath.row];
    
    if(tableView.tag ==1){
        NSArray *areaTypeItems = [_typeItem objectForKey:@"parentcode"];
        if(areaTypeItems.count>0)
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell.textLabel setText:[_typeItem objectForKey:@"name"]];
        
    }
    
    else{
    
        NSArray *areaArray = [areaDictionary objectForKey:@"parentcode"];
        NSDictionary *temp3 = areaArray[indexPath.row];
        [cell.textLabel setText:[temp3 objectForKey:@"name"]];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(tableView.tag ==1){
        
        firstIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section*3];
        
        NSDictionary  *temp = firstData[indexPath.section];
        NSArray *_typeItems = [temp objectForKey:@"parentcode"];
        
        areaDictionary  = _typeItems[indexPath.row];
        
        [self addAreaTableView];
        
        [cityHeaderView setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeCitySelect" object:areaDictionary];
    }
    else if(tableView.tag ==2){
        
        secondIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section*3+1];
        
        [self addRightArrow:cell frame:CGRectMake(90,14, 11, 8)];

        NSDictionary *data = secondData[indexPath.section];
        NSArray *typeItems = [data objectForKey:@"typeItems"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSizeSelect" object:typeItems[indexPath.row]];
    }
    else{
    
        [self addRightArrow:cell frame:CGRectMake(90,14, 11, 8)];

        NSArray *area = [areaDictionary objectForKey:@"parentcode"];
        
       [[NSNotificationCenter defaultCenter] postNotificationName:@"changeAreaSelect" object:area[indexPath.row]];
    }
    
}
-(void)loadAllCity:(UIGestureRecognizer *)recognizer{
    
    [[recognizer view] setBackgroundColor:UIColorFromRGB(0xd9d9d9)];
   [[NSNotificationCenter defaultCenter] postNotificationName:@"changeProvinceSelect" object:[NSNumber numberWithInt:-1]];
    
    [self.firstTableView reloadData];
}
-(void)addRightArrow:(UITableViewCell *)cell frame:(CGRect)frame{
    
    UIView *bgColorView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.firstTableView.frame.size.width, 32)];
    bgColorView.backgroundColor = UIColorFromRGB(0xf4f4f4);
    
    UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(15,0, self.firstTableView.frame.size.width,1)];
    [topLine setBackgroundColor:UIColorFromRGB(0xd0d0d0)];
    
    [bgColorView addSubview:topLine];
    
    NSString *pathImage = [[NSBundle mainBundle]pathForResource:@"rightArrow.png" ofType:@""];
    
    UIImage  *result = [UIImage imageWithContentsOfFile:pathImage];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:result];
    [bgColorView addSubview:imageView];
    
    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(15,32, self.firstTableView.frame.size.width,1)];
    [bottomLine setBackgroundColor:UIColorFromRGB(0xd0d0d0)];
    
    [bgColorView addSubview:bottomLine];
    
    [cell setSelectedBackgroundView:bgColorView];
}
-(void)addAreaTableView{

    if(!thridTableView){
    
    thridTableView = [[UITableView alloc] initWithFrame:CGRectMake(-self.firstTableView.frame.size.width, 0, self.firstTableView.frame.size.width, self.firstTableView.frame.size.height)];
    
    thridTableView.delegate = self;
    thridTableView.dataSource = self;
    thridTableView.tag = 3;
    thridTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [thridTableView setBackgroundColor:UIColorFromRGB(0xf4f4f4)];
    }
    
    [thridTableView reloadData];
    
    [self.firstTableView addSubview:thridTableView];
    
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         thridTableView.frame = CGRectMake(0,0,self.firstTableView.frame.size.width, self.firstTableView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                         
                     }
     ];

}
-(void)backParentView:(id)sender{

    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionFlipFromLeft
                     animations:^{
                         
                         thridTableView.frame = CGRectMake(-self.firstTableView.frame.size.width,0,self.firstTableView.frame.size.width, self.firstTableView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                         [thridTableView removeFromSuperview];
                         thridTableView = nil;
                     }
     ];

}
@end
