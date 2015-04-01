//
//  mutliRowViewController.m
//  brandv1.2
//
//  Created by Apple on 15/2/4.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import "mutliRowViewController.h"
#import "Define.h"

@interface mutliRowViewController ()

@end

@implementation mutliRowViewController

NSMutableArray *firstData;
NSMutableArray *secondData;
NSMutableArray *thridData;

NSIndexPath *firstIndexPath;
NSIndexPath *secondIndexPath;
NSIndexPath *thridIndexPath;

int type = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.firstTableViw.delegate = self;
    self.firstTableViw.dataSource = self;
    self.firstTableViw.tag = 1;
    self.firstTableViw.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.firstTableViw.separatorColor = UIColorFromRGB(0xd0d0d0);

    
    self.secondTableView.delegate = self;
    self.secondTableView.dataSource = self;
    self.secondTableView.tag = 2;
    self.secondTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.secondTableView.separatorColor = UIColorFromRGB(0xd0d0d0);

    
    self.thridTableView.delegate = self;
    self.thridTableView.dataSource = self;
    self.thridTableView.tag = 3;
    self.thridTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.thridTableView.separatorColor = UIColorFromRGB(0xd0d0d0);

}
-(void)initView:(NSMutableArray *)data type:(int)typeArgs{

    type = typeArgs;
    
    firstData = [[NSMutableArray alloc] init];
    secondData = [[NSMutableArray alloc] init];
    thridData = [[NSMutableArray alloc] init];
    
    firstIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    secondIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    thridIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
    
    if (data.count<3) {
        self.view.frame = CGRectMake(0, 0,190*data.count, self.view.frame.size.height);
    }
    
    for (int i =0;i<data.count;i++) {
        
        if(i%3==0)
            [firstData addObject:data[i]];
        if(i%3==1)
            [secondData addObject:data[i]];
        if(i%3==2)
            [thridData addObject:data[i]];
    }
    
    [self.firstTableViw reloadData];
    [self.secondTableView reloadData];
    [self.thridTableView reloadData];
    
    NSLog(@"x:%f,y:%f,width:%f,height:%f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
    
     NSLog(@"x:%f,y:%f,width:%f,height:%f",self.firstTableViw.frame.origin.x,self.firstTableViw.frame.origin.y,self.firstTableViw.frame.size.width,self.firstTableViw.frame.size.height);
    
     NSLog(@"x:%f,y:%f,width:%f,height:%f",self.secondTableView.frame.origin.x,self.secondTableView.frame.origin.y,self.secondTableView.frame.size.width,self.firstTableViw.frame.size.height);
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
    else if(tableView.tag ==2)
        return secondData.count;
    else
        return thridData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSDictionary *temp;
    
    if(tableView.tag ==1)
        temp = firstData[section];
    else if(tableView.tag ==2)
         temp = secondData[section];
    else
          temp = thridData[section];
    

    NSArray *typeItems = [temp objectForKey:@"typeItems"];
    
    if([typeItems isKindOfClass:[NSArray class]]){
        
        return [typeItems count];
    }
    else return 0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        return 32;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    

        return 40;
    
}
-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDictionary *temp;
    
    if(tableView.tag ==1)
        temp = firstData[section];
    else if(tableView.tag ==2)
        temp = secondData[section];
    else
        temp = thridData[section];
    
    return [temp objectForKey:@"typeName"];
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
    
    if(tableView.tag ==1)
        temp = firstData[section];
    else if(tableView.tag ==2)
        temp = secondData[section];
    else
        temp = thridData[section];
    
        NSString *string = [temp objectForKey:@"typeName"];
        
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
        
    NSDictionary *temp;
    
    if(tableView.tag ==1)
        temp = firstData[indexPath.section];
    else if(tableView.tag ==2)
        temp = secondData[indexPath.section];
    else
        temp = thridData[indexPath.section];
    
        NSArray *typeItems = [temp objectForKey:@"typeItems"];
        NSDictionary *typeItem = typeItems[indexPath.row];
        
        [cell.textLabel setText:[typeItem objectForKey:@"name"]];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
        
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
    [self addRightArrow:cell frame:CGRectMake(90,14, 11, 8)];
    
    NSArray *data = [[NSArray alloc] initWithObjects:firstIndexPath,secondIndexPath,thridIndexPath, nil];
    
    if(tableView.tag ==1){
    
       firstIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section*3];
        
       data = [[NSArray alloc] initWithObjects:thridIndexPath,secondIndexPath,firstIndexPath, nil];

    }
    else if(tableView.tag ==2){
        
        secondIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section*3+1];
        
        data = [[NSArray alloc] initWithObjects:firstIndexPath,thridIndexPath,secondIndexPath, nil];

    }
    else if(tableView.tag ==3){
        
        thridIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section*3+2];
        
        data = [[NSArray alloc] initWithObjects:firstIndexPath,secondIndexPath,thridIndexPath, nil];

    }
    
     NSArray *dataName = [[NSArray alloc] initWithObjects:firstIndexPath,secondIndexPath,thridIndexPath, nil];
    
     NSArray *args = [[NSArray alloc] initWithObjects:data,dataName, nil];
    
    if (type ==1)
    [[NSNotificationCenter defaultCenter] postNotificationName:@"searchByType" object:args];
    
}
-(void)addRightArrow:(UITableViewCell *)cell frame:(CGRect)frame{
    
    UIView *bgColorView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.firstTableViw.frame.size.width, 32)];
    bgColorView.backgroundColor = UIColorFromRGB(0xf4f4f4);
    
    UILabel *topLine = [[UILabel alloc] initWithFrame:CGRectMake(15,0, self.firstTableViw.frame.size.width,1)];
    [topLine setBackgroundColor:UIColorFromRGB(0xd0d0d0)];
    
    [bgColorView addSubview:topLine];
    
    NSString *pathImage = [[NSBundle mainBundle]pathForResource:@"rightArrow.png" ofType:@""];
    
    UIImage  *result = [UIImage imageWithContentsOfFile:pathImage];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:result];
    [bgColorView addSubview:imageView];
    
    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(15,32, self.firstTableViw.frame.size.width,1)];
    [bottomLine setBackgroundColor:UIColorFromRGB(0xd0d0d0)];
    
    [bgColorView addSubview:bottomLine];
    
    [cell setSelectedBackgroundView:bgColorView];
}

@end
