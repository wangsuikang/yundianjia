//
//  QRCodeByNatureViewController.m
//  Shops-iPhone
//
//  Created by rujax on 14-1-17.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "QRCodeByNatureViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Classes
#import "OrderManager.h"

// Controllers
#import "WebViewController.h"
#import "LoginViewController.h"
#import "PopGestureRecognizerController.h"

// category
#import "UIButtonForBarButton.h"
#import "BlurImage.h"

#import <AVFoundation/AVFoundation.h>
#import <ZXingObjC/ZXingObjC.h>

@interface QRCodeByNatureViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableSet *qrReader;
    BOOL scanningQR;
}
@property (weak, nonatomic) IBOutlet UIImageView *myPIC;
// ----------------------------------------------------------------------------------
@property (nonatomic, assign) int num;
@property (nonatomic, assign) BOOL upOrDown;
@property (nonatomic, strong) NSTimer *timer;

//@property (nonatomic, strong) AVCaptureDevice *device;
//@property (nonatomic, strong) AVCaptureDeviceInput *input;
//@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
//@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) UIImageView *line;
@property (nonatomic, strong) UIView *preview;

@property (nonatomic, copy) NSString *qrcodeURL;
@property (nonatomic, strong) NSDictionary *favoriteObject;
@property (nonatomic, strong) UIButton *enterAlbum;
@property (nonatomic, strong) UIButton *myQRCode;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) MBProgressHUD *hud;


@property (nonatomic, assign) SystemSoundID soundID;

@end

@implementation QRCodeByNatureViewController

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
        naviTitle.text = @"二维码/条码";
        
        self.navigationItem.titleView = naviTitle;
        
        _qrcodeURL = @"";
    }
    return self;
}

#pragma mark - UIView Functions -

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
    
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    
        dispatch_after(time, dispatch_get_main_queue(), ^(void){
    [self setupCamera];
        });
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (_hud) {
        [_hud hide:YES];
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    _enterAlbum = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [_enterAlbum setTitle:@"相册" forState:UIControlStateNormal];
    [_enterAlbum setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [_enterAlbum setBackgroundColor:kClearColor];
    _enterAlbum.titleLabel.font = [UIFont systemFontOfSize:kFontNormalSize];
    _enterAlbum.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
    _enterAlbum.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [_enterAlbum addTarget:self action:@selector(enterAlbumBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *enterAlbumItem = [[UIBarButtonItem alloc] initWithCustomView:_enterAlbum];
    enterAlbumItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.rightBarButtonItem = enterAlbumItem;
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"努力加载中...";
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_hud hide:YES afterDelay:1.0];
        
        CGFloat width = 200 * kScreenWidth / 320;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - width) / 2, kCustomNaviHeight + (kScreenWidth - width) / 2, width, width)];
        imageView.image = [UIImage imageNamed:@"qrcode_bg"];
        
        [self.view addSubview:imageView];
        
        // 添加上面透明部分
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kCustomNaviHeight + (kScreenWidth - width) / 2)];
        topView.backgroundColor = [UIColor blackColor];
        topView.alpha = 0.2;
        
        [self.view addSubview:topView];
        
        // 添加左侧透明view
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), (kScreenWidth - width) / 2, width)];
        leftView.backgroundColor = [UIColor blackColor];
        leftView.alpha = 0.2;
        
        [self.view addSubview:leftView];
        
        // 添加底部侧透明view
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), kScreenWidth , kScreenHeight - CGRectGetMaxY(imageView.frame) - 75)];
        bottomView.backgroundColor = [UIColor blackColor];
        bottomView.alpha = 0.2;
        
        [self.view addSubview:bottomView];
        
        // 添加右侧透明view
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame), CGRectGetMaxY(topView.frame), (kScreenWidth - width) / 2, width)];
        rightView.backgroundColor = [UIColor blackColor];
        rightView.alpha = 0.2;
        
        [self.view addSubview:rightView];
        
        _upOrDown = NO;
        _num = 0;
        
        _line = [[UIImageView alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + 10, imageView.frame.origin.y + 10, imageView.frame.size.width - 20, 2)];
        _line.image = [UIImage imageNamed:@"qrcode_line"];
        
        [self.view addSubview:_line];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.origin.y + imageView.frame.size.height + 20, kScreenWidth, 20)];
        label.text = @"自动识别框内的二维码";
        label.textColor = [UIColor orangeColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = kNormalFont;
        
        [self.view addSubview:label];
        
        //        _myQRCode = [[UIButton alloc] initWithFrame:CGRectMake(0, label.frame.origin.y + label.frame.size.height + 10, kScreenWidth, 20)];
        //        [_myQRCode addTarget:self action:@selector(enterMyQRCode:) forControlEvents:UIControlEventTouchUpInside];
        //        [_myQRCode setTitle:@"我的二维码" forState:UIControlStateNormal];
        //        [_myQRCode setTintColor:[UIColor greenColor]];
        //        _myQRCode.titleLabel.textAlignment = NSTextAlignmentCenter;
        //
        //        [self.view addSubview:_myQRCode];
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 75, kScreenWidth, 75)];
        _bottomView.backgroundColor = kClearColor;
        
        [self.view addSubview:_bottomView];
        
        // 添加透明底部view
        UIImageView *backGroundImageView = [[UIImageView alloc] initWithFrame:_bottomView.bounds];
        UIImage *image = [BlurImage blurryImage:[UIImage imageNamed:@"cover_bg"] withBlurLevel:0.5];
        backGroundImageView.image = image;
        backGroundImageView.alpha = 0.4;
        
        [_bottomView addSubview:backGroundImageView];
        
        NSArray *arrayPhoto = @[@"iconfont_erweima", @"iconfont_duihuanma"];
        NSArray *titleName = @[@"二维码", @"条形码"];
        
        // TODO:
        // 添加两个按钮
        for (int i = 0; i < arrayPhoto.count; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 100) / 2 + (30 + 40) * i, 10, 30, 30)];
            [btn setImage:[UIImage imageNamed:arrayPhoto[i]] forState:UIControlStateNormal];
            btn.tag = i;
            [btn addTarget:self action:@selector(planarOrBar:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:btn];
            
            UILabel *label = [[UILabel alloc] init];
            if (i == 0) {
                label.frame = CGRectMake((kScreenWidth - 100) / 2 + (30 + 40) * i - 10, 45, 50, 20);
            }
            if (i == 1) {
                label.frame = CGRectMake((kScreenWidth - 100) / 2 + (30 + 40) * i - 10, 45, 50, 20);
            }
            label.text = titleName[i];
            label.textColor = kNaviTitleColor;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:kFontNormalSize];
            
            [_bottomView addSubview:label];
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  - bottomBtnClick -

- (void)planarOrBar:(UIButton *)btn
{
    YunLog(@"yes");
}

//#pragma mark - enterMyQRCode -
//
//- (void)enterMyQRCode:(UIButton *)btn
//{
//    YunLog(@"yes");
//}

#pragma mark - enterAlbumBtnClick -

- (void)enterAlbumBtnClick:(UIButton *)btn
{
    //    self.detector = [CIDetector detectorOfType:CIDetectorAccuracy context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    
    // 弹出相册选中界面0
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    
    // 设置代理
    ctrl.delegate = self;
    
    ctrl.allowsEditing = YES;
    
    //设置类型
    ctrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // 显示
    [self.navigationController presentViewController:ctrl animated:YES completion:nil];
}

#pragma mark - Select Photo -
// 选中图片的时候出发的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // TODO:
    // 解析二维码图片信息
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self getURLWithImage:image];
    }];
}

-(void)getURLWithImage:(UIImage *)img{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *loadImage= img;
        CGImageRef imageToDecode = loadImage.CGImage;
        
        ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
        ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
        
        NSError *error = nil;
        
        ZXDecodeHints *hints = [ZXDecodeHints hints];
        
        ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
        ZXResult *result = [reader decode:bitmap
                                    hints:hints
                                    error:&error];
        if (result) {
            // The coded result as a string. The raw data can be accessed with
            // result.rawBytes and result.length.
            [self playSound];
            
            _qrcodeURL = result.text;
            
            switch (_useType) {
                case QRCodeNormal:
                {
                    if (![_qrcodeURL isEqualToString:@""]) {
                        if ([_qrcodeURL rangeOfString:@"yundianjia.com"].location != NSNotFound || [_qrcodeURL rangeOfString:@"yundianjia.net"].location != NSNotFound) {
                            NSDictionary *params = @{@"string"    :   _qrcodeURL};
                            
                            NSString *urlCheck = [Tool buildRequestURLHost:kRequestHost
                                                                APIVersion:kAPIVersion1
                                                                requestURL:kFavoriteURLCheckURL
                                                                    params:params];
                            
                            YunLog(@"urlCheck = %@", urlCheck);
                            
                            if (!_hud) {
                                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                                _hud.labelText = @"正在加载...";
                            }
                            
                            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                            manager.requestSerializer.timeoutInterval = 30;
                            
                            [manager GET:urlCheck
                              parameters:nil
                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     YunLog(@"favorite url check responseObject = %@", responseObject);
                                     
                                     [_hud hide:YES];
                                     
                                     _favoriteObject = [[responseObject objectForKey:@"data"] objectForKey:@"favorite_object"];
                                     
                                     if (_favoriteObject.count > 0) {
                                         dispatch_sync(dispatch_get_main_queue(), ^{
                                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"检测到云店家相关"
                                                                                                 message:_qrcodeURL
                                                                                                delegate:self
                                                                                       cancelButtonTitle:@"取消"
                                                                                       otherButtonTitles:@"收藏", @"前往", nil];
                                             alertView.tag = 112;
                                             
                                             [alertView show];
                                             
                                         });
                                         
                                     } else {
                                         [self handResult];
                                     }
                                 }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     YunLog(@"favorite url check error = %@", error);
                                     
                                     //                                 [MBProgressHUD hideHUDForView:self.navigationController.view.window animated:YES];
                                     [_hud hide:YES];
                                     
                                     [self handResult];
                                 }];
                        } else {
                            [self handResult];
                        }
                    }
                    
                    break;
                }
                    
                case QRCodeExpress:
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        if (![_qrcodeURL isEqualToString:@""]) {
                            if ([_qrcodeURL hasPrefix:@"http://"] || [_qrcodeURL hasPrefix:@"https://"])
                            {
                                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"非快递号"
                                                                                   message:_qrcodeURL
                                                                                  delegate:self
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                                [alerView show];
                            } else {
                                [[OrderManager defaultManager] addInfo:_qrcodeURL forKey:@"expressNumber"];
                                
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                        }
                    });
                    
                }
                    
                case QRCodeFavorite:
                {
                    break;
                }
                    
                default:
                    break;
            }
        }
    });
}

// 点击取消的时候调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    YunLog(@"六六六");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Functions -

- (void) playSound
{
    if (!_soundID) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"qrcode" ofType:@"caf"];
        
        YunLog(@"path = %@", path);
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &_soundID);
    }
    
    AudioServicesPlaySystemSound(_soundID);
}

- (void)addFavorite
{
    
    if (!_hud) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = @"添加收藏...";
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"terminal_session_key"    :   kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                             @"resource_id"             :   kNullToString([_favoriteObject objectForKey:@"resource_id"]),
                             @"resource_type"           :   kNullToString([_favoriteObject objectForKey:@"resource_type"]),
                             @"sid"                     :   kNullToString([_favoriteObject objectForKey:@"shop_id"])};
    
    YunLog(@"fav_Params = %@", params);
    
    NSString *favoriteAddURL = [Tool buildRequestURLHost:kRequestHost
                                              APIVersion:kAPIVersion1
                                              requestURL:kFavoriteAddURL
                                                  params:params];
    
    YunLog(@"favoriteAddURL = %@", favoriteAddURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:favoriteAddURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             YunLog(@"favorite add responseObject = %@", responseObject);
             
             [_hud hide:YES];
             
             NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
             
             if ([code isEqualToString:kSuccessCode]) {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                     message:@"添加收藏成功"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
             } else if ([code isEqualToString:kUserSessionKeyInvalidCode]) {
                 [Tool resetUser];
                 
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                     message:@"添加收藏失败"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
             } else {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                     message:@"添加收藏失败"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
             }
             
             [self setupCamera];
             
             _qrcodeURL = @"";
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             YunLog(@"favorite add error = %@", error);
             
             [_hud hide:YES];
             
             if (![operation isCancelled]) {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                     message:@"添加收藏失败"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"确定"
                                                           otherButtonTitles:nil];
                 [alertView show];
             }
         }];
}

- (void)backToPrev
{
    if (_hud) {
        [_hud hide:YES];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [_timer invalidate];
    _timer = nil;
    //[_timer setFireDate:[NSDate distantFuture]];
}

- (void)animation
{
    CGFloat width = 200 * kScreenWidth / 320;
    
    if (_upOrDown == NO) {
        _num++;
        _line.frame = CGRectMake(_line.frame.origin.x, (kScreenWidth - width) / 2 + kCustomNaviHeight + 10 + 2 * _num, _line.frame.size.width, 2);
        if (2 * _num == (int)(200 * kScreenWidth / 320 - 20)) {
            _upOrDown = YES;
        }
    }
    else {
        _num--;
        _line.frame = CGRectMake(_line.frame.origin.x, (kScreenWidth - width) / 2 + kCustomNaviHeight + 10 + 2 * _num, _line.frame.size.width, 2);
        if (_num == 0) {
            _upOrDown = NO;
        }
    }
}

- (void)handResult
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_qrcodeURL hasPrefix:@"http://"] || [_qrcodeURL hasPrefix:@"https://"])
        {
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"访问网页"
                                                               message:_qrcodeURL
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                     otherButtonTitles:@"前往", nil];
            alerView.tag = 111;
            [alerView show];
        } else {
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"检测到"
                                                               message:_qrcodeURL
                                                              delegate:self
                                                     cancelButtonTitle:@"确定"
                                                     otherButtonTitles:nil];
            [alerView show];
        }
        
    });
    
}

- (void)setupCamera
{
    // Session
    if (!_session) {
        // Device
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // Input
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        // Output
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        
        if ([_session canAddInput:input])
        {
            [_session addInput:input];
        }
        
        if ([_session canAddOutput:output])
        {
            [_session addOutput:output];
        }
        
        // 条码类型
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        // Preview
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        previewLayer.frame = CGRectMake(0, kCustomNaviHeight, kScreenWidth, kScreenHeight - kCustomNaviHeight);
        
        [self.view.layer insertSublayer:previewLayer atIndex:0];
    }
        
    // Start
    [_session startRunning];
    
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    } else {
        [_timer setFireDate:[NSDate distantPast]];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate -

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    YunLog(@"metadataObjects = %@", metadataObjects);
    
    if ([metadataObjects count] > 0)
    {
        [_session stopRunning];
        
//        [self.view.layer.sublayers[0] removeFromSuperlayer];
        
        [_timer invalidate];
        _timer = nil;
        
        [self playSound];
        
        AVMetadataMachineReadableCodeObject *metadataObject = (AVMetadataMachineReadableCodeObject *)[metadataObjects objectAtIndex:0];
        
        YunLog(@"metadataObject = %@", metadataObject);
        
        // 处理中文乱码
        if ([metadataObject.stringValue canBeConvertedToEncoding:NSShiftJISStringEncoding])
        {
            _qrcodeURL = [NSString stringWithCString:[metadataObject.stringValue cStringUsingEncoding:NSShiftJISStringEncoding]
                                            encoding:NSUTF8StringEncoding];
        }
        else
        {
            _qrcodeURL = metadataObject.stringValue;
        }
        
        YunLog(@"qrcode url = %@", _qrcodeURL);
        
        switch (_useType) {
            case QRCodeNormal:
            {
                if (![_qrcodeURL isEqualToString:@""]) {
                    if ([_qrcodeURL rangeOfString:@"yundianjia.com"].location != NSNotFound || [_qrcodeURL rangeOfString:@"yundianjia.net"].location != NSNotFound) {
                        NSDictionary *params = @{@"string"    :   _qrcodeURL};
                        
                        NSString *urlCheck = [Tool buildRequestURLHost:kRequestHost
                                                            APIVersion:kAPIVersion1
                                                            requestURL:kFavoriteURLCheckURL
                                                                params:params];
                        
                        YunLog(@"urlCheck = %@", urlCheck);
                        
                        if (!_hud) {
                            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                        }
                        
                        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                        manager.requestSerializer.timeoutInterval = 30;
                        
                        [manager GET:urlCheck
                          parameters:nil
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 YunLog(@"favorite url check responseObject = %@", responseObject);
                                 
                                 [MBProgressHUD hideHUDForView:self.navigationController.view.window animated:YES];
                                 
                                 _favoriteObject = [[responseObject objectForKey:@"data"] objectForKey:@"favorite_object"];
                                 
                                 if (_favoriteObject.count > 0) {
                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"检测到云店家相关"
                                                                                         message:_qrcodeURL
                                                                                        delegate:self
                                                                               cancelButtonTitle:@"取消"
                                                                               otherButtonTitles:@"收藏", @"前往", nil];
                                     alertView.tag = 112;
                                     
                                     [alertView show];
                                     
                                 } else {
                                     [self handResult];
                                 }
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 YunLog(@"favorite url check error = %@", error);
                                 
                                 //                                 [MBProgressHUD hideHUDForView:self.navigationController.view.window animated:YES];
                                 [_hud hide:YES];
                                 
                                 [self handResult];
                             }];
                    } else {
                        [self handResult];
                    }
                }
                
                break;
            }
                
            case QRCodeExpress:
            {
                if (![_qrcodeURL isEqualToString:@""]) {
                    if ([_qrcodeURL hasPrefix:@"http://"] || [_qrcodeURL hasPrefix:@"https://"])
                    {
                        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"非快递号"
                                                                           message:_qrcodeURL
                                                                          delegate:self
                                                                 cancelButtonTitle:@"确定"
                                                                 otherButtonTitles:nil];
                        [alerView show];
                    } else {
                        [[OrderManager defaultManager] addInfo:_qrcodeURL forKey:@"expressNumber"];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
                
            case QRCodeFavorite:
            {
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - UIAlertViewDelegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //    if (buttonIndex == 0) {
    //        [self setupCamera];
    //
    //        _qrcodeURL = @"";
    //    } else {
    //        if ([_qrcodeURL isEqualToString:@"http://www.atyun.net/downloads/yundianjia"]) {
    //            [self.navigationController popViewControllerAnimated:YES];
    //
    //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/yun-dian-jia/id783464466?mt=8&uo=4"]];
    //        } else {
    //            WebViewController *web = [[WebViewController alloc] init];
    //            web.naviTitle = @"";
    //            web.url = _qrcodeURL;
    //            web.hidesBottomBarWhenPushed = YES;
    //
    //            [self.navigationController pushViewController:web animated:YES];
    //        }
    //    }
    
    if (alertView.tag == 111) {
        if (buttonIndex == 0) {
            [self setupCamera];
            
            _qrcodeURL = @"";
        } else {
            WebViewController *web = [[WebViewController alloc] init];
            web.naviTitle = _qrcodeURL;
            web.url = _qrcodeURL;
            
            [self.navigationController pushViewController:web animated:YES];
        }
    }
    
    else if (alertView.tag == 112) {
        switch (buttonIndex) {
            case 0:
            {
                [self setupCamera];
                
                _qrcodeURL = @"";
                
                break;
            }
                
            case 1:
            {
                AppDelegate *appDelegate = kAppDelegate;
                
                if (appDelegate.isLogin) {
                    
                    [self addFavorite];
                    
                } else {
                    LoginViewController *loginVC = [[LoginViewController alloc] init];
                    loginVC.isReturnView = YES;
                    loginVC.isBuyEnter = YES;
                    
                    PopGestureRecognizerController *popNC = [[PopGestureRecognizerController alloc] initWithRootViewController:loginVC];
                    
                    [self.navigationController presentViewController:popNC animated:YES completion:nil];
                    
                    //                    UINavigationController *loginNC = [[UINavigationController alloc] initWithRootViewController:loginVC];
                    //
                    //                    [self.navigationController presentViewController:loginNC animated:YES completion:nil];
                }
                
                break;
            }
                
            case 2:
            {
                WebViewController *web = [[WebViewController alloc] init];
                web.naviTitle = _qrcodeURL;
                web.url = _qrcodeURL;
                
                [self.navigationController pushViewController:web animated:YES];
                
                _favoriteObject = nil;
                
                break;
            }
                
            default:
                break;
        }
    }
    
    else {
        [self setupCamera];
        
        _qrcodeURL = @"";
    }
}

@end