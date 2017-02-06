////
////  QRCodeByZBarViewController.m
////  Shops-iPhone
////
////  Created by rujax on 14-1-17.
////  Copyright (c) 2014年 net.atyun. All rights reserved.
////
//
//#import "QRCodeByZBarViewController.h"
//
//// Classes
//#import "OrderManager.h"
//
//// Views
//#import "UIButtonForBarButton.h"
//
//// Controllers
//#import "WebViewController.h"
//#import "LoginViewController.h"
//
//// // Common Headers
//#import "LibraryHeadersForCommonController.h"
//
//@interface QRCodeByZBarViewController () <ZBarReaderViewDelegate, UIAlertViewDelegate>
//
//@property (nonatomic, strong) ZBarReaderView *readerView;
//
//@property (nonatomic, assign) int num;
//@property (nonatomic, assign) BOOL upOrDown;
//@property (nonatomic, strong) NSTimer *timer;
//@property (nonatomic, strong) UIImageView *line;
//
//@property (nonatomic, copy) NSString *qrcodeURL;
//@property (nonatomic, strong) NSDictionary *favoriteObject;
//
//@end
//
//@implementation QRCodeByZBarViewController
//
//#pragma mark - Initialization -
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
//        
//        naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
//        naviTitle.backgroundColor = kClearColor;
//        naviTitle.textColor = kNaviTitleColor;
//        naviTitle.textAlignment = NSTextAlignmentCenter;
//        naviTitle.text = @"扫一扫";
//        
//        self.navigationItem.titleView = naviTitle;
//        
//        _qrcodeURL = @"";
//        _favoriteObject = [[NSDictionary alloc] init];
//    }
//    return self;
//}
//
//#pragma mark - UIView Functions -
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    [_readerView start];
//    
//    if (!_timer) {
//        _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
//    } else {
//        [_timer setFireDate:[NSDate distantPast]];
//    }
//
//    if (_favoriteObject.count > 0) {
//        [self addFavorite];
//    }
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    self.view.backgroundColor = kBackgroundColor;
//	
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(0, 0, 25, 25);
//    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
//    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    backItem.style = UIBarButtonItemStylePlain;
//    
//    self.navigationItem.leftBarButtonItem = backItem;
//    
//    double delayInSeconds = 0.5;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        
//        _readerView = [[ZBarReaderView alloc] init];
//        _readerView.frame = CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScreenHeight - kCustomNaviHeight);
//        _readerView.readerDelegate = self;
//        _readerView.torchMode = 0;
//        _readerView.scanCrop = CGRectMake(40 / kScreenWidth * 0.8, (60 + kCustomNaviHeight) / (kScreenHeight - kCustomNaviHeight) * 0.8, 240 / kScreenWidth * 1.2, 240 / (kScreenHeight - kCustomNaviHeight) * 1.2);
//        
//        [self.view addSubview:_readerView];
//        
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 60, 240, 240)];
//        imageView.image = [UIImage imageNamed:@"qrcode_bg"];
//        imageView.backgroundColor = kClearColor;
//        
//        [_readerView addSubview:imageView];
//        
//        _upOrDown = NO;
//        _num = 0;
//        
//        _line = [[UIImageView alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + 10, imageView.frame.origin.y + 10, imageView.frame.size.width - 20, 2)];
//        _line.image = [UIImage imageNamed:@"qrcode_line"];
//        
//        [_readerView addSubview:_line];
//        
//        [_readerView start];
//    });
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//- (void)dealloc
//{
//    _readerView.readerDelegate = nil;
//}
//
//#pragma mark - Private Functions -
//
//- (void)backToPrev
//{    
//    [self.navigationController popViewControllerAnimated:YES];
//    
//    [_timer invalidate];
//}
//
//- (void)animation
//{
//    if (_upOrDown == NO) {
//        _num ++;
//        _line.frame = CGRectMake(_line.frame.origin.x, 70 + 2 * _num, _line.frame.size.width, 2);
//        if (2 * _num == 220) {
//            _upOrDown = YES;
//        }
//    }
//    else {
//        _num --;
//        _line.frame = CGRectMake(_line.frame.origin.x, 70 + 2 * _num, _line.frame.size.width, 2);
//        if (_num == 0) {
//            _upOrDown = NO;
//        }
//    }
//}
//
//- (void)handResult
//{
//    if ([_qrcodeURL hasPrefix:@"http://"] || [_qrcodeURL hasPrefix:@"https://"])
//    {
//        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"访问网页"
//                                                           message:_qrcodeURL
//                                                          delegate:self
//                                                 cancelButtonTitle:@"取消"
//                                                 otherButtonTitles:@"前往", nil];
//        alerView.tag = 111;
//        [alerView show];
//    } else {
//        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"检测到"
//                                                           message:_qrcodeURL
//                                                          delegate:self
//                                                 cancelButtonTitle:@"确定"
//                                                 otherButtonTitles:nil];
//        [alerView show];
//    }
//}
//
//- (void)resetReaderView
//{
//    [_readerView start];
//    [_timer setFireDate:[NSDate distantPast]];
//    
//    _qrcodeURL = @"";
//    _favoriteObject = nil;
//}
//
//- (void)addFavorite
//{
//    
//    AppDelegate *appDelegate = kAppDelegate;
//    
//    NSDictionary *params = @{@"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
//                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
//                             @"resource_id"             :   kNullToString([_favoriteObject objectForKey:@"resource_id"]),
//                             @"resource_type"           :   kNullToString([_favoriteObject objectForKey:@"resource_type"]),
//                             @"sid"                     :   kNullToString([_favoriteObject objectForKey:@"shop_id"])};
//    
//    NSString *favoriteAddURL = [Tool buildRequestURLHost:kRequestHost
//                                              APIVersion:kAPIVersion1
//                                              requestURL:kFavoriteAddURL
//                                                  params:params];
//    
//    YunLog(@"favoriteAddURL = %@", favoriteAddURL);
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer.timeoutInterval = 30;
//
//    [manager GET:favoriteAddURL
//      parameters:nil
//         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//             YunLog(@"favorite add responseObject = %@", responseObject);
//             
//             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
//             
//             if ([code isEqualToString:kSuccessCode]) {
//                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                                     message:@"添加收藏成功"
//                                                                    delegate:nil
//                                                           cancelButtonTitle:@"确定"
//                                                           otherButtonTitles:nil];
//                 [alertView show];
//             } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
//                 [Tool resetUser];
//                 
//                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                                     message:@"添加收藏失败"
//                                                                    delegate:nil
//                                                           cancelButtonTitle:@"确定"
//                                                           otherButtonTitles:nil];
//                 [alertView show];
//             } else {
//                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                                     message:@"添加收藏失败"
//                                                                    delegate:nil
//                                                           cancelButtonTitle:@"确定"
//                                                           otherButtonTitles:nil];
//                 [alertView show];
//             }
//             
//             [self resetReaderView];
//         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//             YunLog(@"favorite add error = %@", error);
//             
//             if (![operation isCancelled]) {
//                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                                     message:@"添加收藏失败"
//                                                                    delegate:nil
//                                                           cancelButtonTitle:@"确定"
//                                                           otherButtonTitles:nil];
//                 [alertView show];
//             }
//         }];
//}
//
//#pragma mark - ZBarReaderViewDelegate -
//
//- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
//{
//    for (ZBarSymbol *symbol in symbols) {
//        
//        // 处理中文乱码
//        if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding])
//        {
//            _qrcodeURL = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding]
//                                            encoding:NSUTF8StringEncoding];
//        }
//        else
//        {
//            _qrcodeURL = symbol.data;
//        }
//        
//        YunLog(@"_qrcodeURL = %@", _qrcodeURL);
//        
//        break;
//    }
//    
////    switch (_useType) {
////        case QRCodeNormal:
////        {
////            if (![_qrcodeURL isEqualToString:@""]) {
////                [_readerView stop];
////                [_timer setFireDate:[NSDate distantFuture]];
////                
////                if ([_qrcodeURL rangeOfString:@"yundianjia.com"].location != NSNotFound || [_qrcodeURL rangeOfString:@"yundianjia.net"].location != NSNotFound) {
////                    
////                    NSDictionary *params = @{@"string"    :   _qrcodeURL};
////                    
////                    NSString *urlCheck = [Tool buildRequestURLHost:kRequestHost
////                                                        APIVersion:kAPIVersion1
////                                                        requestURL:kFavoriteURLCheckURL
////                                                            params:params];
////                    
////                    YunLog(@"urlCheck = %@", urlCheck);
////                    
////                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
////                    manager.requestSerializer.timeoutInterval = 30;
////
////                    [manager GET:urlCheck
////                      parameters:nil
////                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
////                             YunLog(@"favorite url check responseObject = %@", responseObject);
////                             
////                             _favoriteObject = [[responseObject objectForKey:@"data"] objectForKey:@"favorite_object"];
////                             
////                             if (_favoriteObject.count > 0) {
////                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"检测到云店家相关"
////                                                                                     message:_qrcodeURL
////                                                                                    delegate:self
////                                                                           cancelButtonTitle:@"取消"
////                                                                           otherButtonTitles:@"收藏", @"前往", nil];
////                                 alertView.tag = 112;
////                                 
////                                 [alertView show];
////                             } else {
////                                 [self handResult];
////                             }
////                         }
////                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
////                             YunLog(@"favorite url check error = %@", error);
////                             
////                             [self handResult];
////                         }];
////                } else {
////                    [self handResult];
////                }
////            }
////            
////            break;
////        }
////            
////        case QRCodeExpress:
////        {
////            if (![_qrcodeURL isEqualToString:@""]) {
////                [_readerView stop];
////                [_timer setFireDate:[NSDate distantFuture]];
////                
////                if ([_qrcodeURL hasPrefix:@"http://"] || [_qrcodeURL hasPrefix:@"https://"])
////                {
////                    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"非快递号"
////                                                                       message:_qrcodeURL
////                                                                      delegate:self
////                                                             cancelButtonTitle:@"确定"
////                                                             otherButtonTitles:nil];
////                    [alerView show];
////                } else {
////                    [[OrderManager defaultManager] addInfo:_qrcodeURL forKey:@"expressNumber"];
////                    
////                    [self.navigationController popViewControllerAnimated:YES];
////                }
////            }
////        }
////            
////        case QRCodeFavorite:
////        {
////            break;
////        }
////            
////        default:
////            break;
////    }
//}
//
//#pragma mark - UIAlertViewDelegate -
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 111) {
//        if (buttonIndex == 0) {
//            [self resetReaderView];
//        } else {
//            WebViewController *web = [[WebViewController alloc] init];
//            web.naviTitle = _qrcodeURL;
//            web.url = _qrcodeURL;
//            
//            [self.navigationController pushViewController:web animated:YES];
//        }
//    }
//    
//    else if (alertView.tag == 112) {
//        switch (buttonIndex) {
//            case 0:
//            {
//                [self resetReaderView];
//                
//                break;
//            }
//                
//            case 1:
//            {
//                AppDelegate *appDelegate = kAppDelegate;
//                
//                if (appDelegate.isLogin) {
//                    [self addFavorite];
//                } else {
//                    LoginViewController *loginVC = [[LoginViewController alloc] init];
//                    
//                    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
//                    
//                    [self.navigationController presentViewController:loginNC animated:YES completion:nil];
//                }
//                
//                break;
//            }
//                
//            case 2:
//            {
//                WebViewController *web = [[WebViewController alloc] init];
//                web.naviTitle = _qrcodeURL;
//                web.url = _qrcodeURL;
//                
//                [self.navigationController pushViewController:web animated:YES];
//                
//                _favoriteObject = nil;
//                
//                break;
//            }
//                
//            default:
//                break;
//        }
//    }
//    
//    else {
//        [self resetReaderView];
//    }
//}
//
//- (void)willPresentAlertView:(UIAlertView *)alertView
//{
//    for (id so in alertView.subviews) {
//        if ([so isKindOfClass:[UILabel class]]) {
//            UILabel *label = (UILabel *)so;
//            label.font = kNormalFont;
//        }
//    }
//}
//
//@end
