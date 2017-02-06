//
//  LimitPreferentialDetailViewController.m
//  Shops-iPhone
//
//  Created by cml on 15/9/1.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "LimitPreferentialDetailViewController.h"

#import "LibraryHeadersForCommonController.h"

#import "PromotionViewController.h"

@interface LimitPreferentialDetailViewController ()

/// 三方库MBProgressHUD对象
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation LimitPreferentialDetailViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.text = [_activityDic objectForKey:@"name"];
    
    self.navigationItem.titleView = naviTitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getData
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"shop_id"                 :   kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"shopID"]),
                             @"action_type"             :   @"Discount"};
    
    NSString *getActivitiesURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kAdminGetActivities params:params];
    
    YunLog(@"getActivitiesURL = %@", getActivitiesURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:getActivitiesURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"getActivities responseObject = %@", responseObject);
             if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
             {
             }
             else
             {
                 //                  [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
             }
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             //              [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
             YunLog(@"getActivitiesURL - error = %@", error);
         }];
}

- (void)createUI
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 66, kScreenWidth, 180)];
    
    topView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:topView];
    
    UIImageView *topIcon = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 70) / 2, 20, 70, 70)];
    
    topIcon.image = [UIImage imageNamed:@"activity"];
    
    [topView addSubview:topIcon];
    
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topIcon.frame), kScreenWidth, 30)];
    
    topLabel.text = @"活动正在进行中";
    topLabel.font = kNormalFont;
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.textColor = [UIColor darkGrayColor];
    
    [topView addSubview:topLabel];
    
    CGFloat temp;
    
    for (int i = 0; i < _rulesArr.count; i ++) {
        UILabel *midLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topLabel.frame) + 30 *i, kScreenWidth, 30)];
        
        CGFloat minValue = [kNullToString([[[_rulesArr firstObject] objectForKey:@"rule"] objectForKey:@"min_value"]) floatValue];
        CGFloat discountPercent = [kNullToString([[_rulesArr[i] objectForKey:@"promotion_action"] objectForKey:@"discount_percent"]) floatValue] / 10;
        NSString *discountAmount = kNullToString([[_rulesArr[i] objectForKey:@"promotion_action"] objectForKey:@"discount_amount"]);
        
        midLabel.text = [discountAmount isEqualToString:@""] ? [NSString stringWithFormat:@"消费满%0.1f元打%0.1f折", minValue, discountPercent] : [NSString stringWithFormat:@"消费满%0.1f元减%0.1f元", minValue, [discountAmount floatValue]];
        midLabel.font = kLargeFont;
        midLabel.textAlignment = NSTextAlignmentCenter;
        midLabel.textColor = kLightBlackColor;
        
        [topView addSubview:midLabel];
        
        temp = CGRectGetMaxY(midLabel.frame);
    }
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
    NSDate *minLimitDate = [inputFormatter dateFromString:kNullToString([_activityDic objectForKey:@"started_at"])];
    NSDate *maxLimitDate = [inputFormatter dateFromString:kNullToString([_activityDic objectForKey:@"ended_at"])];
    
    NSDate *min = minLimitDate;
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
//    [outputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [outputFormatter setDateFormat:@"yyyyMMdd HH:mm:ss"];
    NSString *minString = [outputFormatter stringFromDate:min];
    NSLog(@"%@",minString);
    
    NSDate *max = maxLimitDate;
    NSString *maxString = [outputFormatter stringFromDate:max];
    NSLog(@"%@",maxString);
    
    UILabel *tittleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, temp + 5, kScreenWidth, 25)];
//    tittleLable.backgroundColor = [UIColor redColor];
    tittleLable.text = @"有效时期:";
    tittleLable.font = kNormalFont;
    tittleLable.textColor = kLightBlackColor;
    tittleLable.textAlignment = NSTextAlignmentCenter;
    
    [topView addSubview:tittleLable];
    
    NSString *promotionTime = [NSString stringWithFormat:@"%@ 至 %@",[minString substringWithRange:NSMakeRange(0, 17)],[maxString substringWithRange:NSMakeRange(0, 17)]];
    
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(tittleLable.frame), kScreenWidth, 20)];
//    bottomLabel.backgroundColor = [UIColor redColor];
    bottomLabel.text = promotionTime;
    bottomLabel.font = kMidFont;
    bottomLabel.textColor = kLightBlackColor;
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.numberOfLines = 0;
    
    topView.frame = CGRectMake(0, 66, kScreenWidth, CGRectGetMaxY(bottomLabel.frame) + 10);
    
    [topView addSubview:bottomLabel];
    
    NSMutableAttributedString *timeStr = [[NSMutableAttributedString alloc] initWithString:bottomLabel.text];
    NSRange orangeRangeOne = NSMakeRange(0,17);
    NSRange orangeRangeTwo = NSMakeRange(20,17);
    [timeStr addAttribute:NSForegroundColorAttributeName value:kOrangeColor range:orangeRangeOne];
    [timeStr addAttribute:NSForegroundColorAttributeName value:kOrangeColor range:orangeRangeTwo];
    
    [bottomLabel setAttributedText:timeStr] ;
    
    NSString *alarm = @"包邮只对自营商品生效，分销商品只能由供应商设置。";
    CGSize size = [alarm sizeWithFont:kMidFont size:CGSizeMake(kScreenWidth - 20, 9999)];
    
    UILabel *alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(topView.frame) + 10, size.width, size.height)];
    
    alarmLabel.text = alarm;
    alarmLabel.font = kMidFont;
    alarmLabel.textColor = [UIColor darkGrayColor];
    alarmLabel.numberOfLines = 0;
    
    [self.view addSubview:alarmLabel];
    
    for (int i = 0 ; i < 1; i ++) {
        UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        createButton.frame = CGRectMake(10, CGRectGetMaxY(alarmLabel.frame) + 10 + (10 + 40) * i, kScreenWidth - 20, 40);
        createButton.titleLabel.font = kFont;
        createButton.layer.masksToBounds = YES;
        createButton.layer.cornerRadius = 3;
        
        switch (i) {
            case 0:
            {
                createButton.backgroundColor = kOrangeColor;
                [createButton setTitle:@"删除" forState:UIControlStateNormal];
                [createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [createButton addTarget:self action:@selector(deleteActivity) forControlEvents:UIControlEventTouchUpInside];
            }
                break;
    
//            case 1:
//            {
//                createButton.backgroundColor = [UIColor whiteColor];
//                [createButton setTitle:@"分享" forState:UIControlStateNormal];
//                [createButton setTitleColor:kBlueColor forState:UIControlStateNormal];
//            }
//                break;
                
            default:
                break;
        }
        
        [self.view addSubview:createButton];
    }
}

- (void)deleteActivity
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"删除活动中...";
    
    NSDictionary *params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *deleteActivitiesURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:[NSString stringWithFormat:@"/promotion_activities/%@/delete_activity.json",[_activityDic objectForKey:@"code"]] params:params];
    
    YunLog(@"deleteActivitiesURL = %@", deleteActivitiesURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager DELETE:deleteActivitiesURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"deleteActivities responseObject = %@", responseObject);
             if ([kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"code"]) isEqualToString:kSuccessCode])
             {
                 [_hud addSuccessString:@"成功删除活动~" delay:2.0];
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteActivitySucceedDiscount" object:nil];
                 
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self backToPrev];
                 });
             }
             else
             {
                [_hud addErrorString:kNullToString([[responseObject objectForKey:@"status"] objectForKey:@"message"]) delay:2.0];
             }
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [_hud addErrorString:@"网络异常,请稍后再试" delay:2.0];
             YunLog(@"deleteActivitiesURL - error = %@", error);
         }];
}

@end
