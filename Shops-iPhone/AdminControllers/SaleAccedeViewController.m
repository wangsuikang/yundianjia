//
//  SaleAccedeViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/8/17.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "SaleAccedeViewController.h"

// Comones
#import "LibraryHeadersForCommonController.h"
#import "AppDelegate.h"
#import "IndexTabViewController.h"
#import "PopGestureRecognizerController.h"
#import "WaitAuditingViewController.h"

#import "MBProgressHUD.h"
#import "MBProgressHUD+Extend.h"

#define kSpace 10
#define kIconWidthHeight 30
#define kTag 100

@interface SaleAccedeViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *imageNameArray;

@property (nonatomic, assign) NSInteger height;

@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) UIView *nextView;

@property (nonatomic, strong) MBProgressHUD *hud;


@end

@implementation SaleAccedeViewController

#pragma mark - UIView Functions -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PopGestureRecognizerController *popNC = (PopGestureRecognizerController *)self.navigationController;
    [popNC setPopGestureEnabled:YES];
    
    // 设置透明导航栏
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        NSArray *list = self.navigationController.navigationBar.subviews;
        
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)obj;
                imageView.alpha = 0.0;
            }
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
        
        imageView.image = [UIImage imageNamed:@"navigation_bar_background"];
        
        [self.navigationController.navigationBar addSubview:imageView];
        
        [self.navigationController.navigationBar sendSubviewToBack:imageView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    [TalkingData trackPageEnd:@"离开注册页面"];
    
    [super viewWillDisappear:animated];
    
    NSArray *list=self.navigationController.navigationBar.subviews;
    
    for (id obj in list) {
        
        if ([obj isKindOfClass:[UIImageView class]]) {
            
            UIImageView *imageView=(UIImageView *)obj;
            [UIView animateWithDuration:0.01 animations:^{
                imageView.alpha = 1.0;
            }];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = YES;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sale_view"]];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:_button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    if (kScreenWidth > 320) {
        imageView.image = [UIImage imageNamed:@"sale_flash_iphone6"];
    } else {
        imageView.image = [UIImage imageNamed:@"sale_flash_iphone4"];
    }
    
    [self.view addSubview:imageView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageView removeFromSuperview];
        
        _button.frame = CGRectMake(0, 0, 25, 25);
        [_button setImage:[UIImage imageNamed:@"admin_arrow_left"] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self createUI];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CreateUI -

- (void)createUI
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _scrollView.contentSize = CGSizeMake(kScreenWidth, 1.5 * kScreenHeight);
    _scrollView.backgroundColor = kClearColor;
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:_scrollView];
    
    // 添加单击手势
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    singleTapGestureRecognizer.delegate = self;
    
    [_scrollView addGestureRecognizer:singleTapGestureRecognizer];
    
    // 云店家卖家版
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4 * kSpace, kScreenWidth, 40)];
    titleLabel.backgroundColor = kClearColor;
    titleLabel.text = @"云店家卖家版";
    titleLabel.textColor = kWhiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = kLargeBoldFont;
    
    [_scrollView addSubview:titleLabel];
    
    // 商家入驻
    UILabel *regSaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), kScreenWidth, 40)];
    regSaleLabel.backgroundColor = kClearColor;
    regSaleLabel.text = @"商家入驻";
    regSaleLabel.textColor = kWhiteColor;
    regSaleLabel.textAlignment = NSTextAlignmentCenter;
    regSaleLabel.font = kLargeBoldFont;
    
    [_scrollView addSubview:regSaleLabel];
    
    _imageNameArray = @[@"sale_name", @"sale_email", @"corporation_name", @"sale_telphoto", @"sale_shop_name"];
//    NSArray *titleNameArray = @[@"姓 名", @"邮 箱", @"企业名称", @"联系电话", @"店铺名称"];
    NSArray *placeholderNameArray = @[@"请输入真实姓名", @"请输入联系电子邮箱", @"请输入企业名称", @"请输入联系电话", @"请输入10字以内的店铺名称"];
//    NSArray *textTitleArray = @[@"云云", @"380491563@qq.com", @"云店家", @"15021170067", @"云店家测试"];
    
    CGFloat iconX = 3 * kSpace;
    _height = CGRectGetMaxY(regSaleLabel.frame) + 4 * kSpace;
    CGFloat iconWidth = kIconWidthHeight;
    CGFloat iconHeight = kIconWidthHeight;
    for (int i = 0; i < _imageNameArray.count; i++) {
        CGFloat iconY = _height + (iconWidth + 2 * kSpace) * i;
        // 图标
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, iconWidth, iconHeight)];
        iconImageView.image = [UIImage imageNamed:_imageNameArray[i]];
        
        [_scrollView addSubview:iconImageView];
        
        // 计算文字宽度
//        CGFloat width = [titleNameArray[i] boundingRectWithSize:CGSizeMake(MAXFLOAT, iconHeight) options:        NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:kSizeBoldFont} context:nil].size.width;
//        
//        // 标题
//        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame) + kSpace, iconY, width, iconHeight)];
//        nameLabel.text = titleNameArray[i];
//        nameLabel.textColor = kWhiteColor;
//        nameLabel.font = kSizeBoldFont;
//        
//        [_scrollView addSubview:nameLabel];
        
        // textfield
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame) + kSpace, iconY, kScreenWidth - CGRectGetMaxX(iconImageView.frame) - kSpace, iconHeight)];
         textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderNameArray[i] attributes:@{NSFontAttributeName:kNormalFont, NSForegroundColorAttributeName: ColorFromRGB(0xcccbcb)}];
//        self.placeholder drawInRect:rect withAttributes:@{NSFontAttributeName:kNormalFont, NSForegroundColorAttributeName: [UIColor whiteColor]}];
//        textField.placeholder = placeholderNameArray[i];
//        textField.text = textTitleArray[i];
        textField.font = kNormalFont;
        textField.textColor = COLOR(229, 229, 229, 1);
        textField.tag = i + kTag;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        if (i == _imageNameArray.count - 2) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
        } else {
            textField.keyboardType = UIKeyboardTypeDefault;
        }
        
        [_scrollView addSubview:textField];
        
        // 分割线
        UIView *spitLine = [[UIView alloc] initWithFrame:CGRectMake(iconX, CGRectGetMaxY(iconImageView.frame) + 0.5 * kSpace, kScreenWidth - 5 * kSpace, 1)];
        spitLine.backgroundColor = COLOR(229, 229, 229, 0.5);
        
        [_scrollView addSubview:spitLine];
        
        if (i == _imageNameArray.count - 1) {
            _height = CGRectGetMaxY(spitLine.frame);
        }
    }
    CGFloat nextImageViewY = _height + 6 * kSpace;
    
    // 添加加入按钮
//    UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 140) / 2, nextImageViewY, 100, 57)];
//    nextImageView.image = [UIImage imageNamed:@"sale_next"];
//    
//    [_scrollView addSubview:nextImageView];
    
    _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 140) / 2, nextImageViewY, 120, 60)];
//    _nextBtn.backgroundColor = kClearColor;
//    [_nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [_scrollView addSubview:_nextBtn];
    _nextBtn.layer.masksToBounds = YES;
    _nextBtn.layer.cornerRadius = 30;
    _nextBtn.layer.borderColor = kWhiteColor.CGColor;
    _nextBtn.layer.borderWidth = 2.0;
    
    [_nextBtn setTitle:@"提 交" forState:UIControlStateNormal];
    _nextBtn.titleLabel.font = kLargeBoldFont;
    _nextBtn.titleLabel.textColor = [UIColor redColor];
    [_nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView addSubview:_nextBtn];
    
//    // 添加一个返回按钮
//    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2 * kSpace, 1.5 * kSpace, 40, 40)];
//    backImageView.image = [UIImage imageNamed:@"sale_back"];
//    
//    [_scrollView addSubview:backImageView];
//    
//    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(2 * kSpace, 2 * kSpace, 18, 32)];
//    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [_scrollView addSubview:backBtn];
}

- (void)singleTap:(UIGestureRecognizer *)ges
{
    [_scrollView endEditing:YES];
}

#pragma mark - NextBtnClick -

- (void)nextBtnClick:(UIButton *)sender
{
    [_scrollView endEditing:YES];
    
    for (int i = 0; i < _imageNameArray.count; i++) {
        UITextField *nameTextField = (UITextField *)[_scrollView viewWithTag:(i + kTag)]; // 名字输入框
        switch (i) {
            case 0:
            {
                if (nameTextField.text == nil || [nameTextField.text isEqualToString:@""]) {
                    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [_hud addErrorString:@"姓名为空" delay:1.5];
                    
                    return;
                }
                break;
            }
            case 1:
            {
                BOOL email = [self validateEmail:nameTextField.text];
                
                if (nameTextField.text == nil || [nameTextField.text isEqualToString:@""] || email == NO) {
                    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [_hud addErrorString:@"邮箱不正确" delay:1.5];
                    
                    return;
                }
                
                break;
            }
            case 2:
            {
                if (nameTextField.text == nil || [nameTextField.text isEqualToString:@""]) {
                    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [_hud addErrorString:@"企业名称为空" delay:1.5];
                    
                    return;
                }
                
                break;
            }
            case 3:
            {
                //   BOOL email = [self isValidateEmail:nameTextField.text];
                BOOL photo = [self validateMobile:nameTextField.text];
                
                if (nameTextField.text == nil || [nameTextField.text isEqualToString:@""] || photo == NO) {
                    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [_hud addErrorString:@"电话号码不正确" delay:1.5];
                    
                    return;
                }
                break;
            }
            case 4:
            {
                break;
            }
            default:
                break;
        }
    }
    
    [self PostData];
}

#pragma mark - Post Data - 

- (void)PostData
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力上传中...";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;

    UITextField *nameText = (UITextField *)[_scrollView viewWithTag:kTag + 0];
    UITextField *emailText = (UITextField *)[_scrollView viewWithTag:kTag + 1];
    UITextField *company_nameText = (UITextField *)[_scrollView viewWithTag:kTag + 2];
    UITextField *phoneText = (UITextField *)[_scrollView viewWithTag:kTag + 3];
    UITextField *shopNameText = (UITextField *)[_scrollView viewWithTag:kTag + 4];
    
    NSDictionary *params = @{@"shop_name"                   :       kNullToString(shopNameText.text),
                             @"name"                        :       kNullToString(nameText.text),
                             @"phone"                       :       kNullToString(phoneText.text),
                             @"email"                       :       kNullToString(emailText.text),
                             @"company_name"                :       kNullToString(company_nameText.text),
                             @"terminal_session_key"        :       kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"            :       kNullToString(appDelegate.user.userSessionKey),};
    
    NSString *saleURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kShopAdminShopsURL params:params];
    
    YunLog(@"saleURL = %@", saleURL);

    [manager POST:saleURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"responseSale = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            
            [_hud addSuccessString:@"上传成功" delay:2.0];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                WaitAuditingViewController *waitVC = [[WaitAuditingViewController alloc] init];
                waitVC.status = @"1";
                
                [self.navigationController pushViewController:waitVC animated:YES];
            });
        } else {
            [_hud addErrorString:@"上传失败" delay:2.0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
        
        [_hud addErrorString:@"上传失败" delay:2.0];
    }];
}

#pragma mark - Validate Function -

//手机号码验证
- (BOOL)validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

// 邮箱验证
- (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//通过区分字符串  邮箱验证
- (BOOL)validateEmail:(NSString*)email
{
    if((0 != [email rangeOfString:@"@"].length) &&
       (0 != [email rangeOfString:@"."].length))
    {
        NSCharacterSet* tmpInvalidCharSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSMutableCharacterSet* tmpInvalidMutableCharSet = [tmpInvalidCharSet mutableCopy];
        [tmpInvalidMutableCharSet removeCharactersInString:@"_-"];
        
        
        NSRange range1 = [email rangeOfString:@"@"
                                      options:NSCaseInsensitiveSearch];
        
        //取得用户名部分
        NSString* userNameString = [email substringToIndex:range1.location];
        NSArray* userNameArray   = [userNameString componentsSeparatedByString:@"."];
        
        for(NSString* string in userNameArray)
        {
            NSRange rangeOfInavlidChars = [string rangeOfCharacterFromSet: tmpInvalidMutableCharSet];
            if(rangeOfInavlidChars.length != 0 || [string isEqualToString:@""])
                return NO;
        }
        
        //取得域名部分
        NSString *domainString = [email substringFromIndex:range1.location+1];
        NSArray *domainArray   = [domainString componentsSeparatedByString:@"."];
        
        for(NSString *string in domainArray)
        {
            NSRange rangeOfInavlidChars=[string rangeOfCharacterFromSet:tmpInvalidMutableCharSet];
            if(rangeOfInavlidChars.length !=0 || [string isEqualToString:@""])
                return NO;
        }
        
        return YES;
    }
    else {
        return NO;
    }
}

- (void)backBtnClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_scrollView endEditing:YES];
    
    CGPoint point = scrollView.contentOffset;
    
    if ( point.y > kNavTabBarHeight - 4) {
        _button.hidden = YES;
    }
    
    if (point.y < kNavTabBarHeight - 4) {
        _button.hidden = NO;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
