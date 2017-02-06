//
//  EditProductViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/8/13.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "EditProductViewController.h"

// Common
#import "LibraryHeadersForCommonController.h"

// Controlers
#import "AddProductVariantsViewController.h"

// Views
#import "LMComBoxView.h"
#import "LMContainsLMComboxScrollView.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <SystemConfiguration/SystemConfiguration.h>

#define kSpace 10
#define kDropDownListTag 1000
#define kPhotoTag 10
#define kFerightViewTag 10001
#define kAddProductVariantsTag 10000

// 照片原图路径
#define KOriginalPhotoImagePath   \
[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"OriginalPhotoImages"]

@interface EditProductViewController () <UITextViewDelegate, LMComBoxViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UILabel                      *naviTitle;

@property (nonatomic, strong) UITextView                   *textView;

@property (nonatomic, strong) LMContainsLMComboxScrollView *scrollView;

@property (nonatomic, strong) YunTextField                 *nameTextField;

@property (nonatomic, strong) YunTextField                 *productStockTextField;

@property (nonatomic, strong) YunTextField                 *purLeftTextFile;
@property (nonatomic, strong) YunTextField                 *purRightTextFile;

@property (nonatomic, strong) UIButton                     *variantsButton;

@property (nonatomic, strong) UIButton                     *saveBtn;

@property (nonatomic, assign) NSInteger                    tagCount;

@property (nonatomic, strong) UIButton                     *selectedPhotoBtn;

@property (nonatomic, strong) UIButton                     *postageButton;

@property (nonatomic, strong) UIButton                     *freightBoardButton;

@property (nonatomic, strong) UIButton                     *ferightSelectButton;

@property (nonatomic, strong) LMContainsLMComboxScrollView *variantsScrollView;

/// 产品分类之后整理出来的名称数组
@property (nonatomic, strong) NSMutableArray               *variantsArray;

/// 产品分类数据
@property (nonatomic, strong) NSMutableArray               *productCategoryArray;

/// 运费模板数据
@property (nonatomic, strong) NSMutableArray               *ferightArray;

/// 保存运费模板里面名称的列表数组
@property (nonatomic, strong) NSMutableArray               *ferightNameArray;

/// 保存下拉框选中的对应ID
@property (nonatomic, assign) NSInteger                          selectIndex;

/// 上传商品基本信息后，返回的数据
@property (nonatomic, strong) NSMutableDictionary          *getPostProductData;

/// 保存用户选择的图片数组
@property (nonatomic, strong) NSMutableArray               *productImageArray;

/// 如果是从相册跳转回来的时候 ，不对库存总量进行处理
@property (nonatomic, assign) BOOL enterImageController;

/// 键盘回收控件
@property (nonatomic, strong) IQKeyboardManager            *keyManager;
@property (nonatomic, strong) IQKeyboardReturnKeyHandler   *returnKeyHandler;

/// 最后一次上传图片的标记
@property (nonatomic, assign) NSInteger lastPostImageCount;

/**
 *  请求返回数据
 */
@property (nonatomic, strong) NSMutableData *mResponseData;

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation EditProductViewController

#pragma mark - Initialization -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _naviTitle = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, 0, 200, 44)];
        
        _naviTitle.font = kBigFont;
        _naviTitle.backgroundColor = kClearColor;
        _naviTitle.textColor = kOrangeColor;
        _naviTitle.textAlignment = NSTextAlignmentCenter;
        _naviTitle.text = @"编辑商品信息";
        
        self.navigationItem.titleView = _naviTitle;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *stockString = [[NSUserDefaults standardUserDefaults] objectForKey:@"stockString"];
    
    _productStockTextField.text = stockString;
    
    _lastPostImageCount = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (!_enterImageController) {  // 如果是要进入图片选择 就不进行处理库存
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"stockString"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"isFirst"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /// 键盘处理操作
    self.returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    self.returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyDone;
    self.returnKeyHandler.toolbarManageBehaviour = IQAutoToolbarBySubviews;
    
    _keyManager = [IQKeyboardManager sharedManager];
    
    _keyManager.enable = YES;
    
    _keyManager.keyboardDistanceFromTextField = 20;
    
    _keyManager.enableAutoToolbar = NO;
    
    _keyManager.toolbarManageBehaviour = IQAutoToolbarBySubviews;
    
    _keyManager.shouldToolbarUsesTextFieldTintColor = YES;
    
    _keyManager.shouldShowTextFieldPlaceholder = NO;
    
    _keyManager.canAdjustTextView = YES;
    
    _variantsArray        = [NSMutableArray array];

    _productCategoryArray = [NSMutableArray arrayWithCapacity:0];

    _ferightArray         = [NSMutableArray arrayWithCapacity:0];

    _ferightNameArray     = [NSMutableArray arrayWithCapacity:0];

    _getPostProductData   = [NSMutableDictionary dictionaryWithCapacity:0];

    _productImageArray    = [NSMutableArray arrayWithCapacity:0];
    
    _selectIndex = 0;
    
    _enterImageController = NO;
    
    self.view.backgroundColor = kGrayColor;
    // 添加左边退出图标
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self createUI];
    
    [self getVariantsArray];
    
    [self getFerightData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CreateUI -

- (void)createUI
{
    _scrollView = [[LMContainsLMComboxScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _scrollView.backgroundColor = kGrayColor;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(kScreenWidth, 2.0 * kScreenHeight);
    
    [self.view addSubview:_scrollView];
    
    
    UIView *photoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 130)];
    photoView.backgroundColor = kWhiteColor;
    photoView.tag = 1;
    
    [_scrollView addSubview:photoView];
    
    // 循环创建五个按钮
    CGFloat photoY = kSpace;
    CGFloat photoWidth= (kScreenWidth - 8 * kSpace) / 5;
    CGFloat photoHeight = photoWidth;
    
    for (int i = 0 ; i < 5; i++) {
        CGFloat photoX = kSpace * 2 + (photoWidth + kSpace) * i;
        UIButton *selectPhoto = [[UIButton alloc] initWithFrame:CGRectMake(photoX, photoY, photoWidth, photoHeight)];
        // 图片选择的 tag值  // 这里的tag值是 （10-----14）
        selectPhoto.tag = i + kPhotoTag;
        selectPhoto.backgroundColor = kClearColor;
        if (i == 0) {
            [selectPhoto setImage:[UIImage imageNamed:@"edit_BtnImage_selected"] forState:UIControlStateNormal];
        } else {
            [selectPhoto setImage:[UIImage imageNamed:@"edit_BtnImage"] forState:UIControlStateNormal];
        }
        selectPhoto.layer.cornerRadius = 5;
        selectPhoto.layer.masksToBounds = YES;
        
        [selectPhoto addTarget:self action:@selector(selectPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [photoView addSubview:selectPhoto];
        
        if (i == 0) {
            // 添加图片选择说明
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, 2 * kSpace + photoHeight, 80, 20)];
            label.text = @"商品图片";
            label.textColor = kBlackColor;
            label.font = kSizeFont;
            
            [photoView addSubview:label];
            
            // 添加图片选择详细说明
            NSString *descString = @"最多可以上传5张图片，最后一张作为封面图片图片规格800px*800px的jpg或png,小于1Mb";
            
            UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame) + kSpace, kSpace + photoHeight, kScreenWidth - CGRectGetMaxX(label.frame) - 4 * kSpace, 60)];
            descLabel.text = descString;
            descLabel.textColor = [UIColor lightGrayColor];
            descLabel.numberOfLines = 0;
            descLabel.font = [UIFont systemFontOfSize:kFontSmallSize];
            
            [photoView addSubview:descLabel];
        }
    }
    
    // 创建描述样式
    UIView *descView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(photoView.frame) + kSpace, kScreenWidth, 120)];
    descView.backgroundColor = kWhiteColor;
    descView.tag = 2;
    
    [_scrollView addSubview:descView];
    
    // 添加描述字样
    UILabel *descTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, kSpace, 50, 20)];
    descTitleLabel.text = @"描述";
    descTitleLabel.font = [UIFont systemFontOfSize:kFontSize];
    descTitleLabel.textColor = kBlackColor;
    
    [descView addSubview:descTitleLabel];
    
    // 添加textview
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(descTitleLabel.frame), 5, kScreenWidth - CGRectGetMaxX(descTitleLabel.frame) - 5, descView.bounds.size.height - 10)];
    _textView.backgroundColor=[UIColor whiteColor]; //背景色
    _textView.scrollEnabled = YES;    //当文字超过视图的边框时是否允许滑动，默认为“YES”
    _textView.editable = YES;        //是否允许编辑内容，默认为“YES”
    _textView.delegate = self;       //设置代理方法的实现类
    _textView.layer.borderColor = kBlackColor.CGColor;
    _textView.layer.borderWidth = 1.0;
    _textView.font=[UIFont fontWithName:kLetterFamily size:kFontMidSize]; //设置字体名字和字体大小;
    _textView.returnKeyType = UIReturnKeyDefault;//return键的类型
    _textView.keyboardType = UIKeyboardTypeDefault;//键盘类型
    _textView.textAlignment = NSTextAlignmentLeft; //文本显示的位置默认为居左
    _textView.dataDetectorTypes = UIDataDetectorTypeAll; //显示数据类型的连接模式（如电话号码、网址、地址等）
    _textView.textColor = [UIColor blackColor];
    _textView.text = @"请输入描述内容";//设置显示的文本内容
    [descView addSubview:_textView];
    
    // 添加名称 和用途
    UIView *nameAndUseView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(descView.frame) + kSpace, kScreenWidth, 100)];
    nameAndUseView.backgroundColor = kWhiteColor;
    nameAndUseView.tag = 3;
    
    [_scrollView addSubview:nameAndUseView];
    
    // 名称
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, 2 * kSpace, 50, 20)];
    nameLabel.text = @"名称";
    nameLabel.font = [UIFont systemFontOfSize:kFontSize];
    nameLabel.textColor = kBlackColor;
    
    [nameAndUseView addSubview:nameLabel];
    
    // 添加textfile
    _nameTextField = [[YunTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nameLabel.frame), 2 * kSpace - 5, kScreenWidth - CGRectGetMaxX(nameLabel.frame) - 40, 30)];
    _nameTextField.layer.borderColor = kBlackColor.CGColor;
    _nameTextField.layer.borderWidth = 1.0;
    _nameTextField.placeholder = @" 不超过50个字(必填)";
    _nameTextField.font = kMidFont;
    
    [nameAndUseView addSubview:_nameTextField];
    
    // 商品规格
    UILabel *variantLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, nameAndUseView.bounds.size.height - 40, 80, 20)];
    variantLabel.text = @"商品规格";
    variantLabel.font = [UIFont systemFontOfSize:kFontSize];
    variantLabel.textColor = kBlackColor;
    
    [nameAndUseView addSubview:variantLabel];
    
    CGFloat variantsButtonY = CGRectGetMaxY(_nameTextField.frame) + kSpace;
    _variantsButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(variantLabel.frame), variantsButtonY, kScreenWidth - CGRectGetMaxX(variantLabel.frame) - 40, 30)];
    [_variantsButton setTitle:@" ＋添加规格条目" forState:UIControlStateNormal];
    _variantsButton.titleLabel.font = kNormalFont;
    _variantsButton.backgroundColor = kClearColor;
    [_variantsButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    _variantsButton.enabled = NO;
    
    _variantsButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _variantsButton.layer.borderWidth = 1.0;
    _variantsButton.layer.masksToBounds = YES;
    _variantsButton.layer.cornerRadius = 5;
    [_variantsButton addTarget:self action:@selector(addVariants:) forControlEvents:UIControlEventTouchUpInside];
    
    [nameAndUseView addSubview:_variantsButton];
    
    // 商品库存
    UILabel *productStockLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, CGRectGetMaxY(nameAndUseView.frame) + kSpace, 80, 20)];
    productStockLabel.text = @"库存总量";
    productStockLabel.font = kSizeFont;
    
    [_scrollView addSubview:productStockLabel];
    
    _productStockTextField = [[YunTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(productStockLabel.frame), CGRectGetMaxY(nameAndUseView.frame) + kSpace / 2, kScreenWidth - CGRectGetMaxX(productStockLabel.frame) - 40, 30)];
    
    _productStockTextField.text = @"0";
    _productStockTextField.enabled = NO;
    _productStockTextField.layer.borderColor = kBlackColor.CGColor;
    _productStockTextField.layer.borderWidth = 1.0;
    _productStockTextField.font = kMidFont;
    
    [_scrollView addSubview:_productStockTextField];
    
    // 添加运费设置
    UILabel *freightLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, CGRectGetMaxY(productStockLabel.frame) + 2 * kSpace, 80, 20)];
    freightLabel.text = @"运费设置";
    freightLabel.font = kSizeFont;
    
    [_scrollView addSubview:freightLabel];
    
    // 添加运费设置
    _postageButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(freightLabel.frame), freightLabel.frame.origin.y, 80, 20)];
    [_postageButton setImage:[UIImage imageNamed:@"freight_unselected"] forState:UIControlStateNormal];
    [_postageButton setImage:[UIImage imageNamed:@"freight_selected"] forState:UIControlStateSelected];
    
    [_postageButton setTitle:@"包邮" forState:UIControlStateNormal];
    _postageButton.selected = YES;
    // 设置默认选中的按钮
    _ferightSelectButton = _postageButton;
    
    _postageButton.titleLabel.font = kMidFont;
    [_postageButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    [_postageButton addTarget:self action:@selector(ferightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _postageButton.tag = 1111;
    
    [_scrollView addSubview:_postageButton];
    
    // 添加运费设置
    _freightBoardButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_postageButton.frame), freightLabel.frame.origin.y, 160, 20)];
    [_freightBoardButton setImage:[UIImage imageNamed:@"freight_unselected"] forState:UIControlStateNormal];
    [_freightBoardButton setImage:[UIImage imageNamed:@"freight_selected"] forState:UIControlStateSelected];
    
    [_freightBoardButton setTitle:@"运费模板" forState:UIControlStateNormal];
    _freightBoardButton.selected = NO;
    _freightBoardButton.enabled = NO;
    _freightBoardButton.titleLabel.font = kMidFont;
    [_freightBoardButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    [_freightBoardButton addTarget:self action:@selector(ferightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _freightBoardButton.tag = 2222;
    _freightBoardButton.enabled = NO;   // 这里设置不可被选择，并且不可见
    _freightBoardButton.alpha = 0.0;
    
    [_scrollView addSubview:_freightBoardButton];
    
    UIView *purchaseView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(freightLabel.frame) + kSpace, kScreenWidth, 150)];
    purchaseView.backgroundColor = kWhiteColor;
    
    [_scrollView addSubview:purchaseView];
    
    // 每人限购
    UILabel *purchaseLabel = [[UILabel alloc] initWithFrame:CGRectMake(2 * kSpace, 2 * kSpace, 80, 20)];
    purchaseLabel.text = @"每人限购";
    purchaseLabel.font = [UIFont systemFontOfSize:kFontSize];
    purchaseLabel.textColor = kBlackColor;
    
    [purchaseView addSubview:purchaseLabel];
    
    // 添加两个文本框
    _purLeftTextFile = [[YunTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(purchaseLabel.frame), 1.5 * kSpace, 50, 30)];
    _purLeftTextFile.text = @"0";
    _purLeftTextFile.textAlignment = NSTextAlignmentCenter;
    _purLeftTextFile.layer.masksToBounds = YES;
    _purLeftTextFile.layer.borderColor = kBlackColor.CGColor;
    _purLeftTextFile.layer.borderWidth = 1.0;
    _purLeftTextFile.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    [purchaseView addSubview:_purLeftTextFile];
    
    // 添加 ————
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_purLeftTextFile.frame) + kSpace, _purLeftTextFile.frame.origin.y + 1.5 * kSpace, 10, 2)];
    lineLabel.backgroundColor = kBlackColor;
    
    [purchaseView addSubview:lineLabel];
    
    // 添加两个文本框
    _purRightTextFile = [[YunTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lineLabel.frame) + kSpace, 1.5 * kSpace, 50, 30)];
    _purRightTextFile.text = @"0";
    _purRightTextFile.textAlignment = NSTextAlignmentCenter;
    _purRightTextFile.layer.masksToBounds = YES;
    _purRightTextFile.layer.borderColor = kBlackColor.CGColor;
    _purRightTextFile.layer.borderWidth = 1.0;
    _purRightTextFile.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    [purchaseView addSubview:_purRightTextFile];
    
    // 0 代表不限购O
    NSString *noPurchaseString = @"0代表不限购";
    CGFloat noPurchaseHeight = [Tool calculateContentLabelHeight:noPurchaseString withFont:kNormalFont withWidth:kScreenWidth - CGRectGetMaxX(_purRightTextFile.frame) - kSpace];
    
    UILabel *noPurchaseLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_purRightTextFile.frame) + kSpace, 2 * kSpace, kScreenWidth - CGRectGetMaxX(_purRightTextFile.frame) - kSpace, noPurchaseHeight)];
    noPurchaseLabel.text = @"0代表不限购";
    noPurchaseLabel.font = kNormalFont;
    noPurchaseLabel.textColor = [UIColor grayColor];
    noPurchaseLabel.numberOfLines = 0;
    
    [purchaseView addSubview:noPurchaseLabel];
    
    // 保存并发布
    _saveBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 150) / 2, CGRectGetMaxY(_purRightTextFile.frame) + 3.5 * kSpace, 150, 50)];
    _saveBtn.backgroundColor = kOrangeColor;
    _saveBtn.layer.masksToBounds = YES;
    _saveBtn.layer.cornerRadius = 5;
    [_saveBtn setTitle:@"保存并发布" forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(seveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [purchaseView addSubview:_saveBtn];
    
    //    CGFloat scrollHeight = CGRectGetMaxY(purchaseView.frame);
    //    if (scrollHeight > kScreenHeight) {
    _scrollView.contentSize = CGSizeMake(kScreenWidth, CGRectGetMaxY(purchaseView.frame) + 100);
    //    } else {
    //        _scrollView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight + 50);
    //    }
}

#pragma mark - CreateFerightUI -

- (void)createFerightUI:(UIButton *)sender
{
    // 创建运费设置模板UI
    _variantsScrollView = [[LMContainsLMComboxScrollView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 360)];
    _variantsScrollView.backgroundColor = kWhiteColor;
    
    [self.view addSubview:_variantsScrollView];
    
    // 添加右上角 取消按钮
    EnterButton *cancel = [EnterButton buttonWithType:UIButtonTypeCustom];
    cancel.frame = CGRectMake(kScreenWidth - 40, 0, 40, 40);
    cancel.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [cancel setImage:[UIImage imageNamed:@"product_cancel"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_variantsScrollView addSubview:cancel];
    
    UILabel *ferightBoardLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kSpace, kScreenWidth, 30)];
    ferightBoardLabel.text = @"运费模板设置";
    ferightBoardLabel.font = kSizeFont;
    ferightBoardLabel.textAlignment = NSTextAlignmentCenter;
    ferightBoardLabel.textColor = kBlackColor;
    
    [_variantsScrollView addSubview:ferightBoardLabel];
    
    LMComBoxView *ferightBoardComBox = [[LMComBoxView alloc] initWithFrame:CGRectMake((kScreenWidth - 200) / 2, CGRectGetMaxY(ferightBoardLabel.frame) + 2 * kSpace, 200, 40)];
    ferightBoardComBox.arrowImgName = @"downArrow.png";
    ferightBoardComBox.titlesList = _ferightNameArray;
    ferightBoardComBox.delegate = self;
    ferightBoardComBox.supView = _variantsScrollView;
    ferightBoardComBox.defaultIndex = (int)_selectIndex;
    [ferightBoardComBox defaultSettings];
    ferightBoardComBox.tag = kDropDownListTag;
    
    [_variantsScrollView addSubview:ferightBoardComBox];
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = _variantsScrollView.frame;
        
        frame.origin.y = kScreenHeight - 360;
        
        _variantsScrollView.frame = frame;
    }];
}

#pragma mark - GetVariantsData -

- (void)getVariantsArray
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"         :     kNullToString(appDelegate.user.userSessionKey),
                             @"product_category_id"      :     kNullToString(_productFirstId)};
    
    NSString *categoryURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kGetProductCategoryURL params:params];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    YunLog(@"categoryURL = %@", categoryURL);
    
    [manager GET:categoryURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"cate res = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            _variantsButton.enabled = YES;
            
            _productCategoryArray = [[responseObject objectForKey:@"data"] objectForKey:@"product_spec_type"];
            
            // 获取分类名称
            for (NSDictionary *dict in _productCategoryArray) {
                [_variantsArray addObject:[dict safeObjectForKey:@"name"]];
            }
            
            if (_variantsArray.count > 0) {
                _productStockTextField.enabled = NO;
            } else {
                _productStockTextField.enabled = YES;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
        
    }];
}

- (void)getFerightData
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *parmas = @{@"user_session_key"         :      kNullToString(appDelegate.user.userSessionKey),
                             @"shop_code"                :      kNullToString(_shopCode),
                             @"page"                     :      kNullToString(@"1"),
                             @"per"                      :      kNullToString(@"30")};
    
    NSString *getFerightURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kGetFerightURL params:parmas];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    YunLog(@"getFerightURL = %@", getFerightURL);
    
    [manager GET:getFerightURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"respo = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            _ferightArray = [[responseObject objectForKey:@"data"] objectForKey:@"template_list"];
            
            if (_ferightArray.count > 0) {
                for (int i = 0; i < _ferightArray.count; i++) {
                    NSDictionary *tempDict = _ferightArray[i];
                    
                    [_ferightNameArray addObject:tempDict[@"name"]];
                }
                
                _freightBoardButton.enabled = YES;
                _freightBoardButton.alpha = 1.0;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
    }];
}

#pragma mark - LMComBoxViewDelegate -

- (void)selectAtIndex:(NSInteger)index inCombox:(LMComBoxView *)_combox
{
    YunLog(@"----%ld", index);
    
    _selectIndex = index;
}

#pragma mark - UIButton Click -

- (void)selectPhotoClick:(UIButton *)sender
{
    _selectedPhotoBtn = nil;
    _tagCount = sender.tag - 10;
    YunLog(@"_tagCount = %ld", (long)_tagCount);
    _selectedPhotoBtn = sender;
    
    // 弹出相册选中界面0
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    
    // 设置代理
    ctrl.delegate = self;
    
    ctrl.allowsEditing = YES;
    
    //设置类型
    ctrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    _enterImageController = YES;
    
    // 显示
    [self presentViewController:ctrl animated:YES completion:nil];
}

// 添加商品规格
- (void)addVariants:(UIButton *)sender
{
    YunLog(@"添加商品");
    if (_variantsArray.count > 0) {
        AddProductVariantsViewController *vc = [[AddProductVariantsViewController alloc] init];
        vc.productCategoryArray = _productCategoryArray;
        vc.variantsArray = _variantsArray;
        _enterImageController = NO;
        
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"没有可选规格" delay:1.5];
    }
}

// 运费模板点击按钮实现
- (void)ferightButtonClick:(UIButton *)sender
{
    YunLog(@"运费模板点击按钮实现---%ld", sender.tag);
    if (_selectedPhotoBtn.tag != sender.tag) {
        _ferightSelectButton.selected = NO;
        
        sender.selected = YES;
        
        _ferightSelectButton = sender;
    }
    
    if (sender.tag == 2222) {
        if (_ferightNameArray.count > 0) {
            [self createFerightUI:sender];
        }
    }
}

#pragma mark - CancelButtonClick -

- (void)cancelButtonClick:(EnterButton *)sender
{
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = _variantsScrollView.frame;
        
        frame.origin.y = kScreenHeight;
        
        _variantsScrollView.frame = frame;
    } completion:^(BOOL finished) {
        [_freightBoardButton setTitle:_ferightNameArray[_selectIndex] forState:UIControlStateNormal];
    }];
}

#pragma mark - Select Photo -

// 选中图片的时候出发的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 解析二维码图片信息
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    UIImage *newImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake((kScreenWidth - 8 * kSpace) / 5, (kScreenWidth - 8 * kSpace) / 5)];
    
    // 设置按钮为选择的图片
    [_selectedPhotoBtn setImage:newImage forState:UIControlStateNormal];
    
//    /// 转换图片 成为二进制文件
//    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.5);
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    // Now we get the full path to the file
//    NSString *filePathToFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"imageName_%ld", _tagCount]];
//    
//    NSString *tempFilePathToFile = [filePathToFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    filePathToFile = tempFilePathToFile;
//    
//    NSData *imageFileData = [NSData dataWithContentsOfFile:filePathToFile];
    
    [_productImageArray addObject:image];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 点击取消的时候调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)  picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//压缩图片
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

- (void)seveBtnClick:(UIButton *)sender
{
    YunLog(@"保存按钮被点击");
    /// 判断
    if (_textView.text.length <= 0 ) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"产品描述不能为空" delay:1.5];
        
        return;
    }
    
    if (_nameTextField.text.length <= 0 || _nameTextField.text.length > 50) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"产品名称不能为空" delay:1.5];
        
        return;
    }
    
    if (_variantsArray.count > 0) {
        if ([_productStockTextField.text intValue] < [_purLeftTextFile.text intValue]) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"库存总量小于最小限购量" delay:1.5];
            
            return;
        }
    }
    
    AppDelegate *appDelegate = kAppDelegate;
    
    /// 规格数组
    NSArray *variantsArray = [NSArray array];
    variantsArray = [kUserDefaults objectForKey:@"saveVariantsArray"];
    YunLog(@"variantsArray = %@", variantsArray);
    
    if (variantsArray.count <= 0) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [_hud addErrorString:@"规格参数不正确" delay:1.5];
        
        return;
    }
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"上传商品信息...";
    
    /// 产品信息字典
    NSDictionary *variantsDict = [NSDictionary dictionary];
    
    // 判断运费设置里面选择的是那种模板
    NSInteger ferightSelectTag = _ferightSelectButton.tag;
    NSString *ferightBordID;
    if (ferightSelectTag == 1111) {  // 选中的是包邮
        ferightBordID = @"0";
        
        variantsDict = @{@"name"                            :      kNullToString(_nameTextField.text),
                         @"total_inventory_quantity"        :      kNullToString(_productStockTextField.text),
                         @"shop_id"                         :      kNullToString(_shopID),
                         @"minimum_quantity"                :      kNullToString(_purLeftTextFile.text),
                         @"limited_quantity"                :      kNullToString(_purRightTextFile.text),
                         @"short_desc"                      :      kNullToString(_textView.text),
                         @"act_id"                          :      kNullToString(ferightBordID)};
    }
    
    if (ferightSelectTag == 2222) {  // 选中的是运费模板
        NSString *selectName = _ferightNameArray[_selectIndex];
        
        for (NSDictionary *dict in _ferightArray) {
            if ([dict[@"name"] isEqualToString:selectName]) {
                ferightBordID = dict[@"id"];
                
                variantsDict = @{@"name"                            :      kNullToString(_nameTextField.text),
                                 @"total_inventory_quantity"        :      kNullToString(_productStockTextField.text),
                                 @"shop_id"                         :      kNullToString(_shopID),
                                 @"minimum_quantity"                :      kNullToString(_purLeftTextFile.text),
                                 @"limited_quantity"                :      kNullToString(_purRightTextFile.text),
                                 @"short_desc"                      :      kNullToString(_textView.text),
                                 @"freight_template_id"             :      kNullToString(ferightBordID)};
            }
        }
    }
    
    NSDictionary *params = @{@"specification"           :      kNullToArray(variantsArray),
                             @"info"                    :      kNullToDictionary(variantsDict),
                             @"option"                  :      kNullToDictionary(_optionCateDict),
                             @"user_session_key"        :      kNullToString(appDelegate.user.userSessionKey)};
    
    NSString *postProductURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kPostProductURL params:nil];
    
    YunLog(@"postProductURL = %@", postProductURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:postProductURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        YunLog(@"post res = %@", responseObject);
        
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        
        if ([code isEqualToString:kSuccessCode]) {
            _getPostProductData = [[responseObject objectForKey:@"data"] objectForKey:@"product"];
            
            YunLog(@"getPostProductData = %@", _getPostProductData);
            
            NSString *productId = [_getPostProductData safeObjectForKey:@"id"];
            
            if (_productImageArray.count > 0) {
                [_hud hide:YES];
                // 上传商品图片  这里需要判断用户是否选择了图片
                [self postProductImages:_productImageArray productID:productId];
            } else {
                [_hud addSuccessString:@"上传成功" delay:1.5];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    // 设置跳转条件
                    [kUserDefaults setObject:@"yes" forKey:@"jumpSave"];
                    [kUserDefaults synchronize];
                    
                    // 当再次进来的时候需要将原先设置的数据清空，以免重复使用
                    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
                    [kUserDefaults setObject:tempArray forKey:@"saveVariantsArray"];
                    [kUserDefaults synchronize];
                    
                    NSArray *viewControllers = self.navigationController.viewControllers;
                    UIViewController *adminProductController = (UIViewController *)[viewControllers objectAtIndex:2];
                    
                    [self.navigationController popToViewController:adminProductController animated:YES];
                });
            }
        } else {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:@"上传商品失败" delay:1.5];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
        [_hud addErrorString:@"上传商品失败" delay:1.5];
    }];
}

/**
 *  上传商品的图片
 */
- (void)postProductImages:(NSMutableArray *)imageArray productID:(NSString *)productId
{
    AppDelegate *appDelegate = kAppDelegate;
    
    _lastPostImageCount = 0;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"上传商品图片...";
    
    for (int i = 0; i < imageArray.count; i++) {
        UIImage *imagePost = imageArray[i];
        NSString *indexString = [NSString stringWithFormat:@"%d", i];
        
        NSDictionary *dictionaryParams = @{@"user_session_key"    :     kNullToString(appDelegate.user.userSessionKey),
                                           @"image_file"          :     imagePost,
                                           @"seq"                 :     kNullToString(indexString),
                                           @"productable_id"      :     kNullToString(productId)};
        
        
        NSString *postProductImageURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:kPostProductImageURL params:nil];
        
        YunLog(@"postImageURL = %@", postProductImageURL);
        
        //分界线的标识符
        NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
        //根据url初始化request
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postProductImageURL]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:10];
        //分界线 --AaB03x
        NSString *MPboundary    = [[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
        //结束符 AaB03x--
        NSString *endMPboundary = [[NSString alloc]initWithFormat:@"%@--",MPboundary];
        //要上传的图片
        UIImage *image          = [dictionaryParams objectForKey:@"image_file"];
        //得到图片的data
        NSData *data            = UIImageJPEGRepresentation(image, 0.5);
        //http body的字符串
        NSMutableString *body   = [[NSMutableString alloc]init];
        //参数的集合的所有key的集合
        NSArray *keys           = [dictionaryParams allKeys];
        
        //遍历keys
        for(int i=0;i<[keys count];i++)
        {
            //得到当前key
            NSString *key=[keys objectAtIndex:i];
            //如果key不是pic，说明value是字符类型，比如name：Boris
            if(![key isEqualToString:@"image_file"])
            {
                //添加分界线，换行
                [body appendFormat:@"%@\r\n",MPboundary];
                //添加字段名称，换2行
                [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
                //添加字段的值
                [body appendFormat:@"%@\r\n",[dictionaryParams objectForKey:key]];
            }
        }
        
        ////添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //声明pic字段，文件名为boris.png
        [body appendFormat:@"Content-Disposition: form-data; name=\"image_file\"; filename=\"YunImage.png\"\r\n"];
        //声明上传文件的格式
        [body appendFormat:@"Content-Type:application/octet-stream\r\n\r\n"];  // 不限制图片格式
//        [body appendFormat:@"Content-Type:image/png\r\n\r\n"];
        
        //声明结束符：--AaB03x--
        NSString *end = [[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
        //声明myRequestData，用来放入http body
        NSMutableData *myRequestData = [NSMutableData data];
        //将body字符串转化为UTF8格式的二进制
        [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        //将image的data加入
        [myRequestData appendData:data];
        //加入结束符--AaB03x--
        [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
        
        //设置HTTPHeader中Content-Type的值
        NSString *content = [[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
        //设置HTTPHeader
        [request setValue:content forHTTPHeaderField:@"Content-Type"];
        //设置Content-Length
        [request setValue:[NSString stringWithFormat:@"%ld", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
        //设置http body
        [request setHTTPBody:myRequestData];
        //http method
        [request setHTTPMethod:@"POST"];
        
        //建立连接，设置代理
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        //设置接受response的data
        if (conn) {
            _mResponseData = [[NSMutableData alloc] init];
        }
    }
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_mResponseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_mResponseData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *dic =  [NSJSONSerialization JSONObjectWithData:_mResponseData options:kNilOptions error:nil];
    NSString *code = [[dic objectForKey:@"status"] objectForKey:@"code"];
    
    _lastPostImageCount++;
    
    if (_lastPostImageCount == _productImageArray.count) {
        if ([code isEqualToString:kSuccessCode]) {
//            _hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addSuccessString:@"商品发布成功" delay:1.5];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 设置跳转条件
                [kUserDefaults setObject:@"yes" forKey:@"jumpSave"];
                [kUserDefaults synchronize];
                
                // 当再次进来的时候需要将原先设置的数据清空，以免重复使用
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
                [kUserDefaults setObject:tempArray forKey:@"saveVariantsArray"];
                [kUserDefaults synchronize];
                
                NSArray *viewControllers = self.navigationController.viewControllers;
                UIViewController *adminProductController = (UIViewController *)[viewControllers objectAtIndex:2];
                
                [self.navigationController popToViewController:adminProductController animated:YES];
            });
        } else {
            NSString *message = [[dic objectForKey:@"status"] objectForKey:@"message"];
            
//            _hud  = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:message delay:1.5];
        }
    }
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [_hud addErrorString:@"图片上传失败" delay:1.5];
}

#pragma mark - BackPrev -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ScrollViewDelegate -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [scrollView endEditing:YES];
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate -

//将要开始编辑
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSString *isFirstString = [[NSUserDefaults standardUserDefaults] objectForKey:@"isFirst"];
    
    if ([isFirstString isEqualToString:@"no"]) {
        
    } else {
        textView.text = @"";
        
        [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"isFirst"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}

//将要结束编辑
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

//开始编辑
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

//结束编辑
- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}

//内容将要发生改变编辑
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    YunLog(@"%@", text);
    
    return YES;
}

//焦点发生改变
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    
}


- (void)textViewDidChange:(UITextView *)textView
{
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
