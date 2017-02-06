//
//  PersonalSettledViewController.m
//  Shops-iPhone
//
//  Created by cml on 16/8/9.
//  Copyright © 2016年 net.atyun. All rights reserved.
//

#import "PersonalSettledViewController.h"

#import "WaitAuditingViewController.h"

#import "LibraryHeadersForCommonController.h"
#import "AppDelegate.h"

@interface PersonalSettledViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/// 服务协议的按钮
@property (nonatomic, strong) UIButton *agreementButton;

/// 数据
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) UIButton *chooseImageButtonOne;

@property (nonatomic, strong) UIButton *chooseImageButtonTwo;

@property (nonatomic, strong) UIImage *IDImageOne;

@property (nonatomic, strong) UIImage *IDImageTwo;

@property (nonatomic, assign) NSUInteger tapButtonIndex;

@property (nonatomic, strong) MBProgressHUD *hud;

// 图片数组
@property (nonatomic, strong) NSMutableArray *imageViewArray;

@end

@implementation PersonalSettledViewController

#pragma mark - Initialization -

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        UILabel *naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        naviTitle.font = [UIFont fontWithName:kFontFamily size:kFontBigSize];
        naviTitle.backgroundColor = kClearColor;
        naviTitle.textColor = [UIColor whiteColor];
        naviTitle.textAlignment = NSTextAlignmentCenter;
        naviTitle.text = @"个人商家入驻";
        
        self.navigationItem.titleView = naviTitle;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 25, 25);
        [button setImage:[UIImage imageNamed:@"back_new"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        backItem.style = UIBarButtonItemStylePlain;
        
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kWhiteColor;
    
    [self createUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBarTintColor:kOrangeColor];
    
    _dataArr = [NSMutableArray arrayWithArray:@[@"", @"", @"", @""]];
    
    _imageViewArray = [NSMutableArray arrayWithArray:@[@"", @""]];

//    self.navigationController.navigationBar.backgroundColor = kOrangeColor;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBarTintColor:kWhiteColor];

//    self.navigationController.navigationBar.backgroundColor = kWhiteColor;
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

- (void)createUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 44) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
//    tableView.scrollEnabled = NO;
    
    [self.view addSubview:tableView];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    saveButton.backgroundColor = kOrangeColor;
    [saveButton setTitle:@"提交审核" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
    [saveButton addTarget:self action:@selector(postData) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:saveButton];
}

- (void)postData
{
    [self.view endEditing:YES];
    
    AppDelegate *appDelegate = kAppDelegate;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力上传中...";
    
    NSArray *alarmArr = @[@"店铺名称不能为空", @"真实姓名不能为空", @"支付宝账号不能为空" , @"身份证号码不能为空"];
    
    for (int i = 0; i < _dataArr.count; i ++) {
        if ([_dataArr[i] isEqualToString:@""]) {
            [_hud addErrorString:alarmArr[i] delay:2.0];
            
            return;
        }
    }
    
    for (int i = 0; i < _imageViewArray.count; i ++) {
        if ([_imageViewArray[i] isEqualToString:@""]) {
            [_hud addErrorString:@"请上传照片" delay:2.0];
            
            return;
        }
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    NSDictionary *params = @{@"shop_name"                   :       _dataArr[0],
                             @"name"                        :       _dataArr[1],
                             @"alipay_no"                   :       _dataArr[2],
                             @"certificates_type"           :       @"1",
                             @"certificates_num"            :       _dataArr[3],
                             @"terminal_session_key"        :       kNullToString(appDelegate.terminalSessionKey),
                             @"user_session_key"            :       kNullToString(appDelegate.user.userSessionKey),
                             @"apply_type"                  :       @"1"};
    
    NSString *saleURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kShopAdminShopsURL params:params];
    
    YunLog(@"saleURL = %@", saleURL);
    
    // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
    // 要解决此问题，
    // 可以在上传时使用当前的系统事件作为文件名
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    
    [manager POST:saleURL parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i  = 0; i < _imageViewArray.count; i ++) {
            NSString *fileName = [NSString stringWithFormat:@"pic%@%d.png", str, i];
            NSData *imageData;
            
            if ([_imageViewArray[i] isKindOfClass:[NSString class]]) {
                imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_imageViewArray[i]]];
            } else {
                imageData = UIImageJPEGRepresentation(_imageViewArray[i], 0.5);
            }
            
            if (i == 0) {
                [formData appendPartWithFileData:imageData name:@"certificates_image_front" fileName:fileName mimeType:@"image/jpg/png/jpeg"];
            } else {
                [formData appendPartWithFileData:imageData name:@"certificates_image_back" fileName:fileName mimeType:@"image/jpg/png/jpeg"];
            }
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void)selectAgree:(UIButton *)sender
{
    if (sender.selected == YES) {
        sender.selected = NO;
    } else {
        sender.selected = YES;
    }
}

- (void)takePhoto:(UIButton *)sender
{
    // 加载actionSheet之前先结束当前页面的编辑状态，以防止pickerView 和 actionSheet  重叠的问题
    [self.view endEditing:YES];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择",nil];
    actionSheet.tag = sender.tag;
    
    _tapButtonIndex = sender.tag;
    
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionSheet Delegate -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (buttonIndex == 0) {
        YunLog(@"拍照");
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
        return;
    }
    if (buttonIndex == 1) {
        YunLog(@"从照片选择");
        
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:picker animated:YES completion:nil];
        return;
    }
}

#pragma mark - UIImagePickerController Delegate -

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    YunLog(@"照片选择完毕");
    [picker dismissViewControllerAnimated:YES completion:^{
        if (_tapButtonIndex == 1) {
            _IDImageOne = [info objectForKey:@"UIImagePickerControllerEditedImage"];
            
            [_chooseImageButtonOne setImage:_IDImageOne forState:UIControlStateNormal];
            
            [_imageViewArray replaceObjectAtIndex:0 withObject:_IDImageOne];
        } else {
            _IDImageTwo = [info objectForKey:@"UIImagePickerControllerEditedImage"];
            
            [_chooseImageButtonTwo setImage:_IDImageTwo forState:UIControlStateNormal];
            
            [_imageViewArray replaceObjectAtIndex:1 withObject:_IDImageOne];
        }
    }];
}

#pragma mark - UITextFieldDelegate -

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_dataArr replaceObjectAtIndex:textField.tag withObject:textField.text];
    
    YunLog(@"_dataArr = %@", _dataArr);
}

#pragma mark - UITableViewDelegate and UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {
        return 220 * (kScreenWidth / 600) + 60;
    }
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    NSArray *titleArray = @[@"店铺名称", @"真实姓名", @"支付宝账号", @"身份证号码", @"上传照片", @"入驻同意"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    } else {
        // 解决重用cell的重影问题
        if (cell.contentView.subviews.count > 0)
            [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 80, 50)];
    titleLabel.text = titleArray[indexPath.row];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.alpha = 0.8;
    titleLabel.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
    
    [cell.contentView addSubview:titleLabel];
    
    if (indexPath.row == 4) {
        _chooseImageButtonOne = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 30, 20, 200 * (kScreenWidth / 600), 110 * (kScreenWidth / 600))];
        //        chooseImageButton.backgroundColor = kRedColor;
        [_chooseImageButtonOne setImage:[UIImage imageNamed:@"personalID_1"] forState:UIControlStateNormal];
        _chooseImageButtonOne.tag = 1;
        [_chooseImageButtonOne addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:_chooseImageButtonOne];
        
        _chooseImageButtonTwo = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 30, CGRectGetMaxY(_chooseImageButtonOne.frame) + 20, 200 * (kScreenWidth / 600), 110 * (kScreenWidth / 600))];
        //        chooseImageButton.backgroundColor = kRedColor;
        [_chooseImageButtonTwo setImage:[UIImage imageNamed:@"personalID_2"] forState:UIControlStateNormal];
        _chooseImageButtonTwo.tag = 2;
        [_chooseImageButtonTwo addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:_chooseImageButtonTwo];
    } else if (indexPath.row == 5) {
        titleLabel.hidden = YES;
        
        UIButton *ruleButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 10 - 85, 10, 85, 14)];
        //        ruleButton.backgroundColor = kOrangeColor;
        [ruleButton setTitleColor:ColorFromRGB(0x0068b7) forState:UIControlStateNormal];
        [ruleButton setTitle:@"《服务协议》" forState:UIControlStateNormal];
        ruleButton.titleLabel.font = kMidFont;
        [ruleButton addTarget:self action:@selector(goToRuleDetail) forControlEvents:UIControlEventTouchUpInside];
        //        ruleButton.backgroundColor = kRedColor;
        
        [cell.contentView addSubview:ruleButton];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, ruleButton.frame.size.height - 0.5, ruleButton.frame.size.width, 0.5)];
        line.backgroundColor = ColorFromRGB(0x0068b7);
        
        [ruleButton addSubview:line];
        
        _agreementButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(ruleButton.frame) - 85, 10, 85, 14)];
        //        _agreementButton.backgroundColor = kRedColor;
        [_agreementButton setImage:[UIImage imageNamed:@"agreement_unselect"] forState:UIControlStateNormal];
        [_agreementButton setImage:[UIImage imageNamed:@"agreement_select"] forState:UIControlStateSelected];
        [_agreementButton setTitle:titleArray[indexPath.row] forState:UIControlStateNormal];
        _agreementButton.titleLabel.font = kMidFont;
        //        _agreementButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        _agreementButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        _agreementButton.titleLabel.textAlignment = NSTextAlignmentRight;
        //    _seeTeam.titleLabel.backgroundColor = kBlueColor;
        [_agreementButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_agreementButton addTarget:self action:@selector(selectAgree:) forControlEvents:UIControlEventTouchUpInside];
        _agreementButton.selected = YES;
        
        [cell.contentView addSubview:_agreementButton];
    } else {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 30, 15, kScreenWidth - 50 - CGRectGetMaxX(titleLabel.frame), 20)];
        textField.textColor = [UIColor blackColor];
        textField.alpha = 0.6;
        textField.font = [UIFont fontWithName:kFontFamily size:kFontNormalSize];
        textField.tag = indexPath.row;
        textField.delegate = self;
        textField.text = _dataArr[indexPath.row];

        [cell.contentView addSubview:textField];
        
        if (indexPath.row == 1) {
            textField.placeholder = @"请如实填写";
        }
        
        if (indexPath.row == 2) {
            textField.placeholder = @"请填写真实账号";
        }
    }
    
    return  cell;
}
@end
