//
//  PromotionViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/8/31.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "PromotionViewController.h"

// Controllers
#import "SettingFreeViewController.h"
#import "LimitPreferentialViewController.h"
#import "SettingFreeDetailViewController.h"
#import "LimitPreferentialDetailViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

@interface PromotionViewController ()

/// 三方库MBProgressHUD对象
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation PromotionViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = kNaviTitleColor;
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"促销管理";
        
        self.navigationItem.titleView = naviTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createActivitySucceed:) name:@"createActivitySucceedDiscount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createActivitySucceed:) name:@"createActivitySucceedFreight" object:nil];

    self.view.backgroundColor = kGrayColor;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self createUI];
    
//    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Functions -

- (void)createActivitySucceed:(NSNotification *)note
{
    YunLog(@"note =%@", note.name);
    if ([note.name isEqualToString:@"createActivitySucceedDiscount"]) {
        [self checkActivity:(UIButton *)[self.view viewWithTag:101]];
    }
    else
    {
        [self checkActivity:(UIButton *)[self.view viewWithTag:100]];
    }
}

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createUI
{
    NSArray *colorArr = @[COLOR(17, 205, 110, 0.95), COLOR(244, 100, 111, 0.95)];
    NSArray *tittleArr = @[@"包邮", @"限时特惠"];
    
    for (int i = 0; i < colorArr.count; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, (100 + 10) * i + 64, kScreenWidth, 100)];
        
        button.backgroundColor = colorArr[i];
        [button setTitle:tittleArr[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:kFontFamily size:35];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.tag = 100 +i;
        [button addTarget:self action:@selector(checkActivity:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
    }
}

- (void)createActivity:(NSInteger)index
{
    switch (index) {
        case 100:
        {
            SettingFreeViewController *settingFree = [[SettingFreeViewController alloc] init];
            
            [self.navigationController pushViewController:settingFree animated:YES];
        }
            break;
            
        case 101:
        {
            LimitPreferentialViewController *limitPreferential = [[LimitPreferentialViewController alloc] init];
            
            [self.navigationController pushViewController:limitPreferential animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)checkActivity:(UIButton *)sender
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"获取优惠活动中";
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"shop_id"                 :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]),
                             @"action_type"             :   sender.tag == 100 ? @"Freight" : @"Discount"};
    
    NSString *getActivitiesURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kAdminGetActivities params:params];
    
    YunLog(@"getActivitiesURL = %@", getActivitiesURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:getActivitiesURL
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              YunLog(@"getActivities responseObject = %@", responseObject);
              if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
              {
                  NSDictionary *activity = [[responseObject objectForKey:@"data"] objectForKey:@"activity"];
                  if ([activity isKindOfClass:[NSDictionary class]]) {
                      _hud.hidden = YES;
                      if (sender.tag == 100)
                      {
                          SettingFreeDetailViewController *settingFreeDetail = [[SettingFreeDetailViewController alloc] init];
                          
                          settingFreeDetail.activityDic = activity;
                          settingFreeDetail.rulesArr = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"rules"]);
                          
                          [self.navigationController pushViewController:settingFreeDetail animated:YES];
                      }
                      else
                      {
                          LimitPreferentialDetailViewController *limitPreferentialDetail = [[LimitPreferentialDetailViewController alloc] init];
                          
                          limitPreferentialDetail.activityDic = activity;
                          
                          limitPreferentialDetail.rulesArr = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"rules"]);

                          [self.navigationController pushViewController:limitPreferentialDetail animated:YES];
                      }
                     
                  }
                  else
                  {
                      _hud.hidden = YES;
                     [self createActivity:sender.tag];
                  }
              }
              else
              {
                  [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
              }
          }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
              YunLog(@"getActivitiesURL - error = %@", error);
          }];
}

@end
