//
//  MyInfoViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/7/20.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "MyInfoViewController.h"

// Classes
#import "User.h"

// Views
#import "KLCPopup.h"
#import "YunShareView.h"

// Common
#import "LibraryHeadersForCommonController.h"

// controller
#import "AddressListViewController.h"
#import "OrderListViewController.h"

// Libraries
#import "UUDatePicker.h"

#define kCellHeight 44
#define kSpace 10

@interface MyInfoViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UUDatePickerDelegate/*, YunShareViewDelegate*/>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) NSArray *leftTitleArray;
@property (nonatomic, strong) NSArray *rightArray;

/// 头像路径
@property (nonatomic, copy) NSString *imagePath;

/// 头像控件
@property (nonatomic, copy) UIImageView *imageView;

/// 用户
@property (nonatomic, strong) User *user;

/// 生日输入框
@property (nonatomic, strong) UITextField *birthdayTextField;

/// 昵称输入框
@property (nonatomic, strong) UITextField *nickNameTextField;

/// 三方库MBProgressHUD对象
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation MyInfoViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 页面访问量统计（开始）
    //  [TalkingData trackPageBegin:@"page_name"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面访问量统计 （结束）
    //  [TalkingData trackPageEnd:@"page_name"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColor;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
    
    naviTitle.font = [UIFont fontWithName:kFontBold size:kFontBigSize];
    naviTitle.backgroundColor = kClearColor;
    naviTitle.textColor = kNaviTitleColor;
    naviTitle.textAlignment = NSTextAlignmentCenter;
    naviTitle.text = @"用户信息";
    
    self.navigationItem.titleView = naviTitle;
    
    // 获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    
    // 指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile"];
    
    // 创建ImageFile文件夹
    [[NSFileManager defaultManager] createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    // 保存图片的路径
    self.imagePath = [imageDocPath stringByAppendingPathComponent:@"image.png"];
    
    YunLog(@"imagePath = %@",_imagePath);
    
    // 造数据
    _leftTitleArray = @[@"头像", @"昵称", @"云号", @"生日", @"我的地址", @"我的订单"];
    // TODO: 需要替换，这里使用的是本地数据

    YunLog(@"appDelegate.user.nickname = %@", kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"birthday"]));
    _rightArray = @[@"", kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"]), kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"phone"]), kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"birthday"])];
    
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - createUI - 

- (void)createUI
{
//    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    _scrollView.backgroundColor = [UIColor colorWithRGBHex:0xf8f8f8];
//    _scrollView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight + kSpace);
//    
//    [self.view addSubview:_scrollView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
//    _tableView.layer.masksToBounds = YES;
//    _tableView.layer.cornerRadius  = 5;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.backgroundColor = kBackgroundColor;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    
//    [_scrollView addSubview:_tableView];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _leftTitleArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *cellID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        // 根据图片路径载入图片
//        UIImage *image=[UIImage imageWithContentsOfFile:self.imagePath];
//        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_tableView.bounds.size.width - 60, kSpace / 2, 50, 50)];
//
//        if (image == nil) {
            //显示默认
            _imageView.image = [UIImage imageNamed:@"user_icon"];
//        } else {
//            //显示保存过的
//            _imageView.image = image;
//        }

        [cell.contentView addSubview:_imageView];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (indexPath.row == 2) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = _leftTitleArray[indexPath.row];
    cell.textLabel.font = kMidFont;
    
    if (indexPath.row >= 1 && indexPath.row <= 3) {
        cell.detailTextLabel.text = _rightArray[indexPath.row];
        cell.detailTextLabel.font = kMidFont;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 60;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0) {
//        [self changeImage];
//    }
    if (indexPath.row == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改昵称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        _nickNameTextField = [alert textFieldAtIndex:0];
        
        //把当前行的数据显示到文本框中
        _nickNameTextField.text = _rightArray[indexPath.row];
        _nickNameTextField.placeholder = @"请输入2到4个字符";

        alert.tag = indexPath.row;
        
        [alert show];
    }
    if (indexPath.row == 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改生日" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        _birthdayTextField = [alert textFieldAtIndex:0];
        
        //把当前行的数据显示到文本框中
        _birthdayTextField.text = _rightArray[indexPath.row];
        _birthdayTextField.placeholder = @"yyyy-MM-dd";
        
        // UUPickView
        NSDate *now = [NSDate date];
        
        UUDatePicker *datePicker= [[UUDatePicker alloc]initWithframe:CGRectMake(0, 0, kScreenWidth, 216)
                                                            Delegate:self
                                                         PickerStyle:UUDateStyle_YearMonthDay];
        YunLog(@"%f",kScreenWidth);
        
        datePicker.ScrollToDate = now;
        datePicker.maxLimitDate = now;
        
        _birthdayTextField.inputView = datePicker;

        alert.tag = indexPath.row;
        
        [alert show];
    }
    if (indexPath.row == 4) {
        AddressListViewController *address = [[AddressListViewController alloc] init];
        address.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:address animated:YES];
    }
    if (indexPath.row == 5) {
        int orderTypeArray[6] = {All, WaitingForPay, AlreadyPay, WaitingForReceive, AlreadyComplete};
        OrderListViewController *order = [[OrderListViewController alloc] init];
        order.hidesBottomBarWhenPushed = YES;
        order.orderType = orderTypeArray[0];
        
        [self.navigationController pushViewController:order animated:YES];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 如果选中的是取消，那么就返回，不做任何操作
    if (0 == buttonIndex) return;
    
    // 拿到当前弹窗中的文本数据（已经修改后的数据）
    UITextField *text=[alertView textFieldAtIndex:0];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"修改中...";

    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params;
    
    if (alertView.tag == 1)
    {
        params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                   @"nick_name"               :   kNullToString(text.text)};
        
        if (text.text.length > 4 || text.text.length < 2)
        {
            [_hud addErrorString:@"输入的昵称不符合要求" delay:1.0];
            
            return;
        }
    }
    else
    {
        params = @{@"user_session_key"        :   kNullToString(appDelegate.user.userSessionKey),
                   @"birthday"                :   kNullToString(text.text)};
    }
    
    NSString *changeBirthURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:@"/users/update_user_info.json" params:params];
    
    YunLog(@"changeBirthURL = %@", changeBirthURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager PATCH:changeBirthURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"responseObject = %@",responseObject);
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            if (alertView.tag == 1)
            {
                // 刷新指定行
                [[NSUserDefaults standardUserDefaults] setObject:text.text forKey:@"nickname"];
                
                _rightArray = @[@"", kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"]), kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"phone"]), kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"birthday"])];
                
                NSIndexPath *path = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
                
                [_hud addSuccessString:@"修改昵称成功" delay:1.0];
                
                [_tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            }
            else
            {
                // 刷新指定行
                [[NSUserDefaults standardUserDefaults] setObject:text.text forKey:@"birthday"];
                
                _rightArray = @[@"", kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"]), kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"phone"]), kNullToString([[NSUserDefaults standardUserDefaults] objectForKey:@"birthday"])];
                
                NSIndexPath *path = [NSIndexPath indexPathForRow:alertView.tag inSection:0];
                
                [_hud addSuccessString:@"修改生日成功" delay:1.0];
                
                [_tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        else
        {
            [_hud addErrorString:@"网络异常，请稍后再试" delay:1.0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_hud addErrorString:@"网络异常，请稍后再试" delay:1.0];
    }];
}

#pragma mark - Private Functions -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 点击头像弹出UIActionSheet
 */
- (void)changeImage
{
    [self openShare];
}

- (void)openShare
{
    YunShareView *shareView = [[YunShareView alloc] initWithTopBar:@[@{@"icon" : @"share_photo" , @"title" : @"相册"},
                                                                     
                                                                     @{@"icon" : @"share_camera" , @"title" : @"拍照"}]
                                                         bottomBar:@[]
                               ];
    
//    shareView.delegate = self;
    [shareView setTip:@"从下面方法获取图片"];
    KLCPopup *popUp = [KLCPopup popupWithContentView:shareView showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToBottom maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    [popUp showAtCenter:CGPointMake(kScreenWidth * 0.5, kScreenHeight - shareView.frame.size.height * 0.5) inView:self.view];
}

/**
 从相册选择
 */
- (void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    //资源类型为图片库
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    
    [self presentViewController:picker animated:YES completion:nil];
}

/**
 拍照
 */
- (void)takePhoto
{
    //资源类型为照相机
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    
    //判断是否有相机
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        
        //资源类型为照相机
        picker.sourceType = sourceType;
        
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        NSLog(@"该设备无摄像头");
    }
}

#pragma mark - UIActionSheetDelegate -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //从相册选择
            [self LocalPhoto];
            break;
        case 1:
            //拍照
            [self takePhoto];
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate -

/**
 图像选取器的委托方法，选完图片后回调该方法
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    //当图片不为空时显示图片并保存图片
    if (image != nil) {
        
        //图片显示在界面上
        _imageView.image = image;
        
        //以下是保存文件到沙盒路径下
        //把图片转成NSData类型的数据来保存文件
        NSData *data;
        
        //判断图片是不是png格式的文件
        if (UIImagePNGRepresentation(image)) {
            //返回为png图像。
            data = UIImagePNGRepresentation(image);
        } else {
            //返回为JPEG图像。
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        //保存
        [[NSFileManager defaultManager] createFileAtPath:self.imagePath contents:data attributes:nil];
    }
    //关闭相册界面
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - UUDatePicker's delegate -

- (void)uuDatePicker:(UUDatePicker *)datePicker year:(NSString *)year month:(NSString *)month day:(NSString *)day hour:(NSString *)hour minute:(NSString *)minute weekDay:(NSString *)weekDay
{
    _birthdayTextField.text = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
}

#pragma mark - YunShareViewDelegate -

- (void)shareViewDidSelectViewInSection:(NSUInteger)section index:(NSUInteger)index{
    YunLog(@"您点击了第%lu排的第%ld个按钮", (long)section + 1, (long)index + 1);
    
    switch (index) {
        case 0:
            //从相册选择
            [self LocalPhoto];
            break;
        case 1:
            //拍照
            [self takePhoto];
            break;
        default:
            break;
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
