//
//  typeSearchTableViewController.m
//  brandv1.2
//
//  Created by Apple on 14-8-9.
//  Copyright (c) 2014年 Apple. All rights reserved.
//

#import "typeSearchTableViewController.h"
#import "Define.h"
#import "StockData.h"
#import "LoginInfo.h"

@interface typeSearchTableViewController ()

@end

@implementation typeSearchTableViewController
NSMutableArray *data;
LoginInfo *loginInfo;
int typeIndex;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    data = [[NSMutableArray alloc] init];
   loginInfo =[[StockData getSingleton] valueForKey:@"loginInfo"];
    
    self.tableView.tag = 1;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
-(void)initView:(int)type{
    
    typeIndex = type;
    
    switch (type) {
        case 1:
           data = [[NSMutableArray alloc] initWithObjects:@"富邦",@"莱洛克",nil];
            break;
        case 2:
            data = [[NSMutableArray alloc] initWithObjects:@"右墙",@"床",@"后床头柜",@"床前凳",@"植物",nil];
            break;
        case 3:
            data = [[NSMutableArray alloc] initWithObjects:@"中国风",@"田园",@"欧式",@"地中海",nil];
            break;
        case 4:
            data = [[NSMutableArray alloc] initWithObjects:@"切换账号",nil];
            break;
        case 5:
            data = loginInfo.hideArray;
            break;
        case 6:
            data = [[NSMutableArray alloc] initWithObjects:@"全部面积",@"0-30",@"30-60",@"60-90",@"90-120",@"更多",nil];
            break;
        case 7:
            data = [[NSMutableArray alloc] initWithObjects:@"全部空间", nil];
            
            if(data && !loginInfo.classicPlanSearchType){
            for (NSDictionary *temp in loginInfo.planSearchType) {
                NSString *searchField = [temp objectForKey:@"searchField"];
                if([searchField isEqualToString:@"room"]){
                
                    loginInfo.classicPlanSearchType = [temp objectForKey:@"typeItems"];
                    break;
                }
            }
            }
            
            for (NSDictionary *temp in loginInfo.classicPlanSearchType) {
            
                NSString *name = [temp objectForKey:@"name"];
                [data addObject:name];
            }
            
            break;
        case 8:
            data = [[NSMutableArray alloc] initWithObjects:@"全部尺寸",@"0-10",@"10-20",@"20-30",@"30-40",@"更多",nil];
            break;
        case 9:
            [self addShareView];
             break;
        case 11:
             break;
        case 13:
             data = [[NSMutableArray alloc] initWithObjects:@"名称",@"面积",@"房间数量",nil];
            break;
        case 14:
            data = [[NSMutableArray alloc] initWithObjects:@"名称",@"面积",@"产品数量",@"上架时间",nil];
            break;
        case 15:
            data = [[NSMutableArray alloc] initWithObjects:@"名称",@"价格",@"上架时间",nil];
            break;
        case 16:
            data = [[NSMutableArray alloc] initWithObjects:@"标清",@"高清",nil];
            break;

        default:
            break;
    }
    [self.tableView reloadData];
}
-(void)initViewWithData:(int)type data:(NSMutableArray *)dataTemp{

       typeIndex = type;
    
       data = dataTemp;
    
    if(typeIndex ==10){
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.separatorColor = UIColorFromRGB(0XD7D7D7);
    }
    
    [self.tableView reloadData];

}
-(void)planSearchView{


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(typeIndex ==11 || typeIndex == 12)
          return [data count];
    else
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(typeIndex == 11 || typeIndex == 12){
     
        NSDictionary *temp = data[section];
        NSArray *typeItems = [temp objectForKey:@"typeItems"];
        
        if([typeItems isKindOfClass:[NSArray class]]){
            
            return [typeItems count];
        }
        else return 0;

    
    }
    else
    return [data count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(typeIndex ==10|| typeIndex ==6 || typeIndex ==7|| typeIndex ==8 || typeIndex ==13|| typeIndex ==14|| typeIndex ==15|| typeIndex ==16|| typeIndex ==17|| typeIndex ==18)
        return 32;
    
    else
        return 40;

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(typeIndex == 11 || typeIndex == 12)
    return 40;
    
    else
        return 0;
}
-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDictionary *temp = data[section];
    
    return [temp objectForKey:@"typeName"];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,0)];
    /* Create custom view to display section header... */
    
    if(typeIndex == 11|| typeIndex == 12){
    
    view.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
        
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 40)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    [label setBackgroundColor:[UIColor clearColor]];
    
    //  NSString *string =[typeArray objectAtIndex:section];
    NSDictionary *temp = data [section];
    NSString *string = [temp objectForKey:@"typeName"];
    
    /* Section header is in 0th index... */
    [label setText:string];
    label.font=[UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
    [view addSubview:label];
    [view setBackgroundColor:UIColorFromRGB(0xf1f1f1)]; //your background color...
        
    }
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [cell.textLabel setTextColor:UIColorFromRGB(0x2B2B2B)];
    
    if(typeIndex ==10 || typeIndex ==6 || typeIndex ==7|| typeIndex ==8|| typeIndex ==13|| typeIndex ==14|| typeIndex ==15|| typeIndex ==16|| typeIndex ==17|| typeIndex ==18)
       cell.textLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0f];
    
    if(typeIndex == 11 || typeIndex == 12){
    
        [cell.textLabel setTextColor:UIColorFromRGB(0x666666)];
        
        NSDictionary *temp = data [indexPath.section];
        NSArray *typeItems = [temp objectForKey:@"typeItems"];
        NSDictionary *typeItem = typeItems[indexPath.row];
        
        cell.textLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
        
        [cell.textLabel setText:[typeItem objectForKey:@"name"]];
        
    }
    else if (typeIndex==17){
    
        NSDictionary *temp17 = data[indexPath.row];
        if(indexPath.row==0)
        [cell.textLabel setText:@"全部省份"];
        else
        [cell.textLabel setText:[temp17 objectForKey:@"name"]];

    }
    else if (typeIndex==18){
        
        NSDictionary *temp17 = data[indexPath.row];
        if(indexPath.row==0)
            [cell.textLabel setText:@"全部城市"];
        else
            [cell.textLabel setText:[temp17 objectForKey:@"name"]];
        
    }
    else
    {
        cell.textLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0f];
       [cell.textLabel setText:data[indexPath.row]];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(typeIndex == 4){
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"goToLogin" object:nil];
    }
   else if(typeIndex == 5){
        [self changeHideStatus:(int)indexPath.row];
    }
   else if(typeIndex == 6 || typeIndex == 7){
       
       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
       
       [self addRightArrow:cell frame:CGRectMake(90,12, 11, 8)];
       
      [[NSNotificationCenter defaultCenter] postNotificationName:@"sizeSearch" object:data[indexPath.row]];
   }
   else if(typeIndex == 8){
       
       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
       [self addRightArrow:cell frame:CGRectMake(90,12, 11, 8)];
       
    [[NSNotificationCenter defaultCenter] postNotificationName:@"classicSizeSearch" object:data[indexPath.row]];
    }
    
   else if(typeIndex == 10){
       
       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
       
       [self addRightArrow:cell frame:CGRectMake(250,12, 11, 8)];
       
     [[NSNotificationCenter defaultCenter] postNotificationName:@"changePlan" object:[NSNumber numberWithInt:indexPath.row]];
   }
    
   else if(typeIndex == 11){
   
       [[NSNotificationCenter defaultCenter] postNotificationName:@"searchByType" object:indexPath];
   
   }
    
   else if(typeIndex == 12){
       
       [[NSNotificationCenter defaultCenter] postNotificationName:@"searchHouses" object:indexPath];
       
   }
   else if(typeIndex == 13 || typeIndex == 14){
       
       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
       
       [self addRightArrow:cell frame:CGRectMake(90,12, 11, 8)];
       
       [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadedOrderByType" object:[NSNumber numberWithInt:indexPath.row]];
   }
   else if(typeIndex == 15){
       
       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
       
       [self addRightArrow:cell frame:CGRectMake(90,12, 11, 8)];
       
      [[NSNotificationCenter defaultCenter] postNotificationName:@"orderByType" object:[NSNumber numberWithInt:indexPath.row]];
   }
   else if(typeIndex == 16){
       
       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
       
       [self addRightArrow:cell frame:CGRectMake(50,14, 11, 8)];
       
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setNormalOrHigh" object:[NSNumber numberWithInt:indexPath.row]];
   }
   else if(typeIndex == 17){
       
       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
       
       [self addRightArrow:cell frame:CGRectMake(90,14, 11, 8)];
       
       [[NSNotificationCenter defaultCenter] postNotificationName:@"changeProvinceSelect" object:[NSNumber numberWithInt:indexPath.row]];
   }
   else if(typeIndex == 18){
       
       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
       
       [self addRightArrow:cell frame:CGRectMake(90,14, 11, 8)];
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeCitySelect" object:data[indexPath.row]];
   }
   
}
-(void)addRightArrow:(UITableViewCell *)cell frame:(CGRect)frame{
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = UIColorFromRGB(0xefedec);
    
    // rightArrow.png
    
    NSString *pathImage = [[NSBundle mainBundle]pathForResource:@"rightArrow.png" ofType:@""];
    
    UIImage  *result = [UIImage imageWithContentsOfFile:pathImage];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:result];
    [bgColorView addSubview:imageView];
    
    [cell setSelectedBackgroundView:bgColorView];
}
-(void)changeHideStatus:(int)index{
    
    bool isHide = false;
    
    switch (index) {
        case 0:
            if([data[0] isEqualToString:@"隐藏硬装"]){
                isHide = true;
                data[0] = @"显示硬装";
                if([data[2] isEqualToString:@"显示配饰"] && [data[1] isEqualToString:@"显示家居"]){
                
                    data[3] = @"显示全部";
                }
            }
            else{
                isHide = false;
                data[0] = @"隐藏硬装";
                data[3] = @"隐藏全部";

            }
            break;
        case 1:
            if([data[1] isEqualToString:@"隐藏家居"]){
                 isHide = true;
                data[1] = @"显示家居";
                if([data[2] isEqualToString:@"显示配饰"] && [data[0] isEqualToString:@"显示硬装"]){
                    
                    data[3] = @"显示全部";
                }
            }
            else{
                 isHide = false;
                data[1] = @"隐藏家居";
                data[3] = @"隐藏全部";

            }
            break;
        case 2:
            if([data[2] isEqualToString:@"隐藏配饰"]){
                 isHide = true;
                data[2] = @"显示配饰";
                if([data[1] isEqualToString:@"显示家居"] && [data[0] isEqualToString:@"显示硬装"]){
                    
                    data[3] = @"显示全部";
                }
            }
            else{
                 isHide = false;
                data[2] = @"隐藏配饰";
                data[3] = @"隐藏全部";

            }
            break;
        case 3:
            if([data[3] isEqualToString:@"隐藏全部"]){
                 isHide = true;
                data[0] = @"显示硬装";
                data[1] = @"显示家居";
                data[2] = @"显示配饰";
                data[3] = @"显示全部";
            }
            else{
                 isHide = false;
                data[0] = @"隐藏硬装";
                data[1] = @"隐藏家居";
                data[2] = @"隐藏配饰";
                data[3] = @"隐藏全部";
            }
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
    
  NSArray  *dataobject = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:index],[NSNumber numberWithBool:isHide], nil];
  loginInfo.hideArray =  data;

 [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHideStatus" object:dataobject];
}
-(void)addShareView{

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 335,104)];
    [self.view addSubview:view];
    
    UIButton *weiChat = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 64, 64)];
    [weiChat setImage:[UIImage imageNamed:@"weichatIcon.png"] forState:UIControlStateNormal];
    [view addSubview:weiChat];
    
    UILabel *weiboLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,74, 64, 20)];
    [weiboLabel setText:@"微信"];
    weiboLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:9.0f];
    [weiboLabel setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:weiboLabel];
    
    
    UIButton *sinaWeibo = [[UIButton alloc] initWithFrame:CGRectMake(89, 10, 64, 64)];
    [sinaWeibo setImage:[UIImage imageNamed:@"sinaWeiboIcon.png"] forState:UIControlStateNormal];
    [view addSubview:sinaWeibo];
    
    UILabel *sinaWeiboLabel = [[UILabel alloc] initWithFrame:CGRectMake(89,74, 64, 20)];
    [sinaWeiboLabel setText:@"新浪微博"];
    sinaWeiboLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:9.0f];
    [sinaWeiboLabel setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:sinaWeiboLabel];
    
    UIButton *QQWeibo = [[UIButton alloc] initWithFrame:CGRectMake(168, 10, 64, 64)];
    [QQWeibo setImage:[UIImage imageNamed:@"QQWeiboIcon.png"] forState:UIControlStateNormal];
    [view addSubview:QQWeibo];
    
    UILabel *QQWeiboLabel = [[UILabel alloc] initWithFrame:CGRectMake(168,74, 64, 20)];
    [QQWeiboLabel setText:@"腾讯微博"];
     QQWeiboLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:9.0f];
    [QQWeiboLabel setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:QQWeiboLabel];
    
    UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(247, 10, 64, 64)];
    [more setImage:[UIImage imageNamed:@"moreIcon.png"] forState:UIControlStateNormal];
    
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(247,74, 64, 20)];
    [moreLabel setText:@"更多"];
     moreLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:9.0f];
    [moreLabel setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:moreLabel];
    [view addSubview:more];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
