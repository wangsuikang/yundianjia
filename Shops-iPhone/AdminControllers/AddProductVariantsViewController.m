//
//  AddProductVariantsViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/9/23.
//  Copyright © 2015年 net.atyun. All rights reserved.
//

#import "AddProductVariantsViewController.h"

// Comm
#import "LibraryHeadersForCommonController.h"

#define kSpace 10

#define kLMComBoxTag 1
#define kAddButtonTag 10
#define kDeleteButtonTag 100
#define kYunTextFieldTag 1000

/// 创建的表格的里面控件的Tag值
#define kTableTag 10000

@interface AddProductVariantsViewController () <UITextFieldDelegate>
{
    LMContainsLMComboxScrollView *bgScrollView; /// 背景滚动视图
    
    EnterButton *addVariantButton; /// 添加规格按钮
    
    int addVariantsMarker; /// 添加的规格次数  默认是1
    
    //    NSInteger variantsCount;   /// 同一种类型添加的个数  默认是0
    
    NSInteger selectedAddButtonTag; /// 默认选中的点击添加规格类的按钮Tag
    
    NSInteger  topHeight;   // 表头里面的高度
}

@property (nonatomic, strong) UILabel *naviTitle;

@property (nonatomic, strong) MBProgressHUD *hud;

/// 初始化数据源
@property (nonatomic, strong) NSMutableArray *dataSource;

/// 分解后数据源 (这里面存得数据是所有规格商品进行组合后的数据)
@property (nonatomic, strong) NSMutableArray *reduceDataSource;

/// 保存商品规格的具体数据信息数组
@property (nonatomic, strong) NSMutableArray *saveProductVariantsArray;

/// 保存时候 存储的规格数组
@property (nonatomic, strong) NSMutableArray *saveVariantsArray;

/// 存放所有的规格信息对应的名称
@property (nonatomic, strong) NSMutableArray *variantsNameArray;

/// 存放每个规格选择的是那种具体规格
@property (nonatomic, copy) NSString *firstVariantName;

/// 存放每个规格选择的是那种具体规格
@property (nonatomic, copy) NSString *twoVariantName;

/// 存放每个规格选择的是那种具体规格
@property (nonatomic, copy) NSString *threeVariantName;

/// 存放选中的规格参数
@property (nonatomic, assign) int firstDefaultIndex;

/// 存放选中的规格参数
@property (nonatomic, assign) int twoDefaultIndex;

/// 存放选中的规格参数
@property (nonatomic, assign) int threeDefaultIndex;

/// 判断填写的规格是都符合（必须是数字）
@property (nonatomic, assign) BOOL countIsTure;


/// 键盘回收控件
@property (nonatomic, strong) IQKeyboardManager            *keyManager;
@property (nonatomic, strong) IQKeyboardReturnKeyHandler   *returnKeyHandler;

@end

@implementation AddProductVariantsViewController

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
        _naviTitle.text = @"添加规格条目";
        
        self.navigationItem.titleView = _naviTitle;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 当再次进来的时候需要将原先设置的数据清空，以免重复使用
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    [kUserDefaults setObject:tempArray forKey:@"saveVariantsArray"];
    [kUserDefaults synchronize];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kWhiteColor;
    
    /// 键盘处理操作
    self.returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    self.returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyDone;
    self.returnKeyHandler.toolbarManageBehaviour = IQAutoToolbarBySubviews;
    
    _keyManager = [IQKeyboardManager sharedManager];
    
    _keyManager.enable = YES;
    
    _keyManager.keyboardDistanceFromTextField = 40;
    
    _keyManager.enableAutoToolbar = NO;
    
    _keyManager.toolbarManageBehaviour = IQAutoToolbarBySubviews;
    
    _keyManager.shouldToolbarUsesTextFieldTintColor = YES;
    
    _keyManager.shouldShowTextFieldPlaceholder = NO;
    
    //    _keyManager.placeholderFont = [UIFont boldSystemFontOfSize:20];
    
    _keyManager.canAdjustTextView = YES;
    
    // 默认选中的标识
    addVariantsMarker = 1;
    
    _countIsTure = NO;
    
    //    variantsCount = 0;
    // 设置默认defaultIndex
    _firstDefaultIndex = 0;
    _twoDefaultIndex = 0;
    _threeDefaultIndex = 0;
    
    // 初始化
    _reduceDataSource = [NSMutableArray array];
    _saveProductVariantsArray = [NSMutableArray arrayWithCapacity:0];
    _saveVariantsArray = [NSMutableArray arrayWithCapacity:0];
    
    _dataSource = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        
        [_dataSource addObject:array];
    }
    
    YunLog(@"dataSource - %@", _dataSource);
    
    NSArray *tempArray = [NSArray array];
    tempArray = @[_variantsArray[0], @"销售价格", @"成本价格", @"市场价格", @"库存", @"重量(克)"];
    
    NSMutableArray *variantsNameTempArray = [NSMutableArray arrayWithArray:tempArray];
    
    _variantsNameArray = [NSMutableArray arrayWithCapacity:0];
    _variantsNameArray = variantsNameTempArray;
    
    // 设置默认的最开始出现的时候具体规格
    _firstVariantName = [_variantsArray firstObject];
    _twoVariantName = [_variantsArray firstObject];
    _threeVariantName = [_variantsArray firstObject];
    
    // 添加左边退出图标
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    bgScrollView = [[LMContainsLMComboxScrollView alloc]initWithFrame:kScreenBounds];
    bgScrollView.backgroundColor = kWhiteColor;
    bgScrollView.showsVerticalScrollIndicator = NO;
    bgScrollView.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview:bgScrollView];
    
    [self setUpBgScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CreateUI -

- (void)setUpBgScrollView
{
    // 添加商品规格
    UILabel *addProductVariantLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSpace, 1.5 * kSpace, 80, 20)];
    addProductVariantLabel.text = @"商品规格";
    addProductVariantLabel.font = [UIFont systemFontOfSize:kFontSize];
    addProductVariantLabel.textColor = kBlackColor;
    
    [bgScrollView addSubview:addProductVariantLabel];
    
    // 添加第一个规格图
    LMComBoxView *comBox = [[LMComBoxView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(addProductVariantLabel.frame), kSpace, kScreenWidth - 100 - 90, 30)];
    comBox.backgroundColor = [UIColor whiteColor];
    comBox.arrowImgName = @"downArrow.png";
    comBox.titlesList = _variantsArray;
    comBox.delegate = self;
    comBox.supView = bgScrollView;
    // TODO  这里是测试 等会需要删除
    comBox.defaultIndex = 0;
    [comBox defaultSettings];
    comBox.tag = kLMComBoxTag * 1;
    [bgScrollView addSubview:comBox];
    
    // 添加两个按钮  删除  添加
    EnterButton *addFirstBreedVariant = [[EnterButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(comBox.frame) + kSpace / 2, addProductVariantLabel.frame.origin.y - kSpace / 2, 45, 30)];
    addFirstBreedVariant.titleLabel.font = kMidFont;
    [addFirstBreedVariant setTitle:@"＋添加" forState:UIControlStateNormal];
    UIColor *addBreedVariantColor = COLOR(75, 155, 224, 1);
    [addFirstBreedVariant setTitleColor:addBreedVariantColor forState:UIControlStateNormal];
    addFirstBreedVariant.tag = 1 * kAddButtonTag;  /// 第一次进来的时候默认他的tag为1000
    addFirstBreedVariant.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [addFirstBreedVariant addTarget:self action:@selector(addProductBreedVariants:) forControlEvents:UIControlEventTouchUpInside];
    /// 设置默认要点击的添加按钮
    selectedAddButtonTag = addFirstBreedVariant.tag;
    
    [bgScrollView addSubview:addFirstBreedVariant];
    
    // 添加删除按钮
    EnterButton *deleteFirstBreedVariant = [[EnterButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addFirstBreedVariant.frame) + kSpace / 2 , addProductVariantLabel.frame.origin.y - kSpace / 2, 40, 30)];
    deleteFirstBreedVariant.titleLabel.font = kMidFont;
    [deleteFirstBreedVariant setTitle:@"删除" forState:UIControlStateNormal];
    UIColor *deleteColor = COLOR(246, 70, 70, 1);
    [deleteFirstBreedVariant setTitleColor:deleteColor forState:UIControlStateNormal];
    deleteFirstBreedVariant.tag = 1 * kDeleteButtonTag; // 减号默认tag是 10000
    
    deleteFirstBreedVariant.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [deleteFirstBreedVariant addTarget:self action:@selector(deleteProductBreedVariants:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgScrollView addSubview:deleteFirstBreedVariant];
    
    // 添加一个输入框
    YunTextField *variantsFirstTextField = [[YunTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addProductVariantLabel.frame), CGRectGetMaxY(addProductVariantLabel.frame) + 2 * kSpace, comBox.frame.size.width, 30)];
    variantsFirstTextField.placeholder = [NSString stringWithFormat:@"请输入%@", [_variantsArray firstObject]];
    variantsFirstTextField.tag = 1 * kYunTextFieldTag;
    variantsFirstTextField.delegate = self;
    [variantsFirstTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [bgScrollView addSubview:variantsFirstTextField];
    
    // 添加规格条目按钮
    addVariantButton= [[EnterButton alloc] initWithFrame:CGRectMake(variantsFirstTextField.frame.origin.x, CGRectGetMaxY(variantsFirstTextField.frame) + 2.0 * kSpace, 160, 30)];
    [addVariantButton setTitle:@" ＋添加规格条目" forState:UIControlStateNormal];
    addVariantButton.titleLabel.font = kMidFont;
    addVariantButton.backgroundColor = kClearColor;
    [addVariantButton setTitleColor:kBlackColor forState:UIControlStateNormal];
    
    addVariantButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    addVariantButton.layer.borderWidth = 1.0;
    addVariantButton.layer.masksToBounds = YES;
    addVariantButton.layer.cornerRadius = 5;
    [addVariantButton addTarget:self action:@selector(addProductVariants:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgScrollView addSubview:addVariantButton];
}

#pragma mark - UIButton Click -

/**
 *  添加下一个规格 品类
 *
 *  @param sender
 */
- (void)addProductVariants:(EnterButton *)sender
{
    YunLog(@"addvariantsMarker1111  = %d", addVariantsMarker);
    
    if (addVariantsMarker > 3){
        addVariantsMarker--;
        return;
    }
    
    YunLog(@"sender.frame = %@", NSStringFromCGRect(sender.frame));
    
    CGRect frame = sender.frame;
    
    addVariantsMarker++;
    
    if (addVariantsMarker == 3) {
        addVariantButton.alpha = 0.0;
    }
    YunLog(@"addvariantsMarker22222  = %d", addVariantsMarker);
    
    //    NSInteger countTag = (sender.tag / kAddButtonTag) > 3 ? (sender.tag / kAddButtonTag + 1) : sender.tag / kAddButtonTag;
    
    [_variantsNameArray insertObject:_variantsArray[0] atIndex:(addVariantsMarker - 1)];
    
    [self addVariantsUI:frame index:addVariantsMarker isOther:NO];
    
    [self getAllVariants];
    
}

/**
 *  添加商品规格 属性
 *
 *  @param sender 被点击的按钮
 */
- (void)addProductBreedVariants:(EnterButton *)sender
{
    // 根据sender的tag值 获取输入框的frame
    NSInteger senderTag = (sender.tag / kAddButtonTag);
    
    YunTextField *yunTextField = (YunTextField *)[bgScrollView viewWithTag:senderTag * kYunTextFieldTag];
    
    NSString *textString = yunTextField.text;
    
    // 判断添加的不能为空
    if (!textString.length > 0) {
        _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        NSString *comBoxString = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%ld", senderTag * kLMComBoxTag]];
        if (!comBoxString.length > 0) {
            comBoxString = _variantsArray[0];
        }
        
        [_hud addErrorString:[NSString stringWithFormat:@"%@不能为空", comBoxString] delay:1.5];
        return;
    }
    
    // 根据判断 计算出属于个类型
    NSMutableArray *tempArray = [NSMutableArray array];
    tempArray = _dataSource[senderTag - 1];
    // 判断规格是否已经存在
    YunLog(@"添加---%@", textString);
    for (int i =0; i < tempArray.count; i++) {
        if ([textString isEqualToString:tempArray[i]]) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            [_hud addErrorString:[NSString stringWithFormat:@"%@ 已经存在", tempArray[i]] delay:1.5];
            yunTextField.text = @"";
            return;
        }
    }
    
    // 添加规格种类
    [tempArray addObject:textString];
    
    // 替换数据源
    [_dataSource replaceObjectAtIndex:(senderTag - 1) withObject:tempArray];
    
    // 创建对应规格下的规格label
    //    [self createGetVariantsLabel:yunTextField.frame text:textString index:variantsCount];
    
    // 清空输入框内容
    yunTextField.text = @"";
    
    YunLog(@"name---%@", _variantsNameArray);
    YunLog(@"dataSource--add--%@", _dataSource);
    
    /// 获取所有的规格种类数据源
    [self getAllVariants];
}

/**
 *  删除商品规格 属性
 *
 *  @param sender 被点击按钮
 */
- (void)deleteProductBreedVariants:(EnterButton *)sender
{
    
    YunLog(@"addvariantsMarker4444  = %d", addVariantsMarker);
    NSInteger countTag = sender.tag / kDeleteButtonTag;
    
    // 判断点击的按钮是第几个删除按钮
    switch (countTag) {
        case 1:
        {
            /// 删除所有的UI控件
            for (NSInteger i = countTag; i <= addVariantsMarker; i++) {
                LMComBoxView *comBox = (LMComBoxView *)[bgScrollView viewWithTag:i * kLMComBoxTag];
                EnterButton *addVariantsButton = (EnterButton *)[bgScrollView viewWithTag:i * kAddButtonTag];
                EnterButton *deleteVariantsButton = (EnterButton *)[bgScrollView viewWithTag:i * kDeleteButtonTag];
                YunTextField *yunTextField = (YunTextField *)[bgScrollView viewWithTag:i * kYunTextFieldTag];
                
                // 依次删除对应删除按钮之后的所有按钮
                [comBox removeFromSuperview];
                [addVariantsButton removeFromSuperview];
                [yunTextField removeFromSuperview];
                [deleteVariantsButton removeFromSuperview];
            }
            
            // 设置第一个默认的选中的规格参数名称是 0
            _firstDefaultIndex = 0;
            
            // 从新创建后面需要的UI控件
            CGRect tempFrame = CGRectMake(90, 2 * kSpace, 180, 30);
            
            for (NSInteger i = 1; i <= addVariantsMarker - 1; i++) {
                [self addVariantsUI:tempFrame index:i isOther:YES];
                tempFrame.origin.y += 100;
            }
            
            if (addVariantsMarker == 1) {  // 需要删除后面的表格图
                _twoDefaultIndex = 0;
                _threeDefaultIndex = 0;
                
                // 获取添加规格按钮的frame
                CGRect frame = addVariantButton.frame;
                
                // 首先移除添加按钮之下的所有控件
                for (id obj in bgScrollView.subviews) {
                    if ([obj isKindOfClass:[EnterButton class]]) {
                        EnterButton *button = (EnterButton *)obj;
                        if (button.frame.origin.y > frame.origin.y) {
                            [button removeFromSuperview];
                        }
                    }
                    
                    if ([obj isKindOfClass:[UILabel class]]) {
                        YunLabel *variantNameLabel = (YunLabel *)obj;
                        if (variantNameLabel.frame.origin.y > frame.origin.y) {
                            [variantNameLabel removeFromSuperview];
                        }
                    }
                    
                    if ([obj isKindOfClass:[YunTextField class]]) {
                        YunTextField *yunTextField = (YunTextField *)obj;
                        if (yunTextField.frame.origin.y > frame.origin.y) {
                            [yunTextField removeFromSuperview];
                        }
                    }
                }
            }
            
            addVariantButton.frame = tempFrame;
            addVariantButton.alpha = 1.0;
            addVariantsMarker--;
            
            // 移除对应的所有规格
            [_dataSource removeObjectAtIndex:0];
            
            // 这里数据也需要删除，用空进行替换
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
            
            [_dataSource addObject:tempArray];
            
            [_variantsNameArray removeObjectAtIndex:0];
            
            YunLog(@"_dataScoure111 = %@", _dataSource);
            
            /// 获取所有的规格种类数据源
            [self getAllVariants];
            
            break;
        }
        case 2:
        {
            if (addVariantsMarker == 3) {
                // 依次删除对应删除按钮之后的所有按钮
                for (int i = 2; i <= 3; i++)
                {
                    LMComBoxView *comBox = (LMComBoxView *)[bgScrollView viewWithTag:i * kLMComBoxTag];
                    EnterButton *addVariantsButton = (EnterButton *)[bgScrollView viewWithTag:i * kAddButtonTag];
                    EnterButton *deleteVariantsButton = (EnterButton *)[bgScrollView viewWithTag:i * kDeleteButtonTag];
                    YunTextField *yunTextField = (YunTextField *)[bgScrollView viewWithTag:i * kYunTextFieldTag];
                    
                    // 依次删除对应删除按钮之后的所有按钮
                    [comBox removeFromSuperview];
                    [addVariantsButton removeFromSuperview];
                    [yunTextField removeFromSuperview];
                    [deleteVariantsButton removeFromSuperview];
                }
                
                // 设置第二个默认的选中的规格参数名称是 0
                _twoDefaultIndex = 0;
                
                /// 添加规格条目按钮可见
                addVariantButton.alpha = 1.0;
                
                addVariantsMarker--;
                
                
                // 获取第一个规格
                YunTextField *yunTextField = (YunTextField *)[bgScrollView viewWithTag:1 * kYunTextFieldTag];
                
                CGRect tempFrame = yunTextField.frame;
                
                tempFrame.origin.y += 5 * kSpace;
                
                [self addVariantsUI:tempFrame index:2 isOther:YES];
                
                /// 添加规格条目按钮向上移动
                [UIView animateWithDuration:0.4 animations:^{
                    
                    
                    CGRect frame = addVariantButton.frame;
                    
                    frame.origin.y -= 200;
                    
                    addVariantButton.frame = frame;
                    
                } completion:^(BOOL finished) {
                    // 删除第二个数据源
                    [_dataSource removeObjectAtIndex:1];
                    
                    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
                    
                    [_dataSource addObject:tempArray];
                    
                    [_variantsNameArray removeObjectAtIndex:1];
                    
                    YunLog(@"_dataScoure22222 = %@", _dataSource);
                    
                    // 这里需要从新设置第三个选中的默认为0
                    _threeDefaultIndex = 0;
                    
                    /// 获取所有的规格种类数据源
                    [self getAllVariants];
                }];
            } else if (addVariantsMarker == 2) {
                LMComBoxView *comBox = (LMComBoxView *)[bgScrollView viewWithTag:2 * kLMComBoxTag];
                EnterButton *addVariantsButton = (EnterButton *)[bgScrollView viewWithTag:2 * kAddButtonTag];
                EnterButton *deleteVariantsButton = (EnterButton *)[bgScrollView viewWithTag:2 * kDeleteButtonTag];
                YunTextField *yunTextField = (YunTextField *)[bgScrollView viewWithTag:2 * kYunTextFieldTag];
                
                // 依次删除对应的控件 (针对本次点击的删除按钮)
                [comBox removeFromSuperview];
                [addVariantsButton removeFromSuperview];
                [yunTextField removeFromSuperview];
                [deleteVariantsButton removeFromSuperview];
                
                addVariantsMarker--;
                /// 删除之后，添加规格条目按钮式可以再次被点击的
                addVariantButton.alpha = 1.0;
                
                // 设置第三个默认的选中的规格参数名称是 0
                _twoDefaultIndex = 0;
                
                // 添加条目按钮向上移动
                [UIView animateWithDuration:0.4 animations:^{
                    CGRect frame = addVariantButton.frame;
                    
                    frame.origin.y -= 100;
                    
                    addVariantButton.frame = frame;
                } completion:^(BOOL finished) {
                    // 移除对应的所有规格
                    [_dataSource removeObjectAtIndex:1];
                    
                    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
                    
                    [_dataSource addObject:tempArray];
                    
                    YunLog(@"dataSource--33333 -- %@", _dataSource);
                    
                    [_variantsNameArray removeObjectAtIndex:1];
                    
                    /// 获取所有的规格种类数据源
                    [self getAllVariants];
                }];
            }
            
            break;
        }
        case 3:
        {
            LMComBoxView *comBox = (LMComBoxView *)[bgScrollView viewWithTag:3 * kLMComBoxTag];
            EnterButton *addVariantsButton = (EnterButton *)[bgScrollView viewWithTag:3 * kAddButtonTag];
            EnterButton *deleteVariantsButton = (EnterButton *)[bgScrollView viewWithTag:3 * kDeleteButtonTag];
            YunTextField *yunTextField = (YunTextField *)[bgScrollView viewWithTag:3 * kYunTextFieldTag];
            
            // 依次删除对应的控件 (针对本次点击的删除按钮)
            [comBox removeFromSuperview];
            [addVariantsButton removeFromSuperview];
            [yunTextField removeFromSuperview];
            [deleteVariantsButton removeFromSuperview];
            
            addVariantsMarker--;
            /// 删除之后，添加规格条目按钮式可以再次被点击的
            addVariantButton.alpha = 1.0;
            
            // 设置第三个默认的选中的规格参数名称是 0
            _threeDefaultIndex = 0;
            
            // 添加条目按钮向上移动
            [UIView animateWithDuration:0.4 animations:^{
                CGRect frame = addVariantButton.frame;
                
                frame.origin.y -= 100;
                
                addVariantButton.frame = frame;
            } completion:^(BOOL finished) {
                // 移除对应的所有规格
                [_dataSource removeObjectAtIndex:2];
                
                NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
                
                [_dataSource addObject:tempArray];
                
                [_variantsNameArray removeObjectAtIndex:2];
                
                YunLog(@"dataSource--33333 -- %@", _dataSource);
                
                /// 获取所有的规格种类数据源
                [self getAllVariants];
            }];
            
            break;
        }
            
        default:
            break;
    }
    YunLog(@"addvariantsMarker5555  = %d", addVariantsMarker);
}

/**
 *  保存规格类型
 *
 *  @param sender
 */
- (void)saveButtonClick:(EnterButton *)sender
{
    YunLog(@"保存规格按钮被点击");
    
    [self.view endEditing:YES];
    
    YunLog(@"---资222源----%@", _saveProductVariantsArray);
    
    YunLog(@"-reduceDataSource---%@", _reduceDataSource);
    YunLog(@"-VariantsArray -- %@", _variantsNameArray);
    
    switch (_variantsNameArray.count) {
        case 6:
        {
            for (int i = 0; i < _saveProductVariantsArray.count; i++) {  // 行的总数量
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:0];
                
                NSMutableArray *variantsTempArray = [NSMutableArray arrayWithCapacity:0];
                variantsTempArray = _saveProductVariantsArray[i];
                
                if (variantsTempArray.count != 6) {
                    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    
                    [_hud addErrorString:@"所有规格不得为空" delay:1.5];
                    
                    return;
                } else {
                    [tempDict setObject:_firstVariantName forKey:@"key1"];
                    [tempDict setObject:variantsTempArray[0] forKey:@"value1"];
                    [tempDict setObject:variantsTempArray[1] forKey:@"price"];
                    [tempDict setObject:variantsTempArray[2] forKey:@"cost_price"];
                    [tempDict setObject:variantsTempArray[3] forKey:@"market_price"];
                    [tempDict setObject:variantsTempArray[4] forKey:@"inventory"];
                    [tempDict setObject:variantsTempArray[5] forKey:@"weight"];
                    
                    [_saveVariantsArray addObject:tempDict];
                }
            }
            
            break;
        }
        case 7:
        {
            for (int i = 0; i < _saveProductVariantsArray.count; i++) {  // 行的总数量
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:0];
                
                NSMutableArray *variantsTempArray = [NSMutableArray arrayWithCapacity:0];
                variantsTempArray = _saveProductVariantsArray[i];
                
                if (variantsTempArray.count != 7) {
                    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    
                    [_hud addErrorString:@"所有规格不得为空" delay:1.5];
                    
                    return;
                } else {
                    [tempDict setObject:_firstVariantName forKey:@"key1"];
                    [tempDict setObject:variantsTempArray[0] forKey:@"value1"];
                    
                    [tempDict setObject:_twoVariantName forKey:@"key2"];
                    [tempDict setObject:variantsTempArray[1] forKey:@"value2"];
                    
                    [tempDict setObject:variantsTempArray[2] forKey:@"price"];
                    [tempDict setObject:variantsTempArray[3] forKey:@"cost_price"];
                    [tempDict setObject:variantsTempArray[4] forKey:@"market_price"];
                    [tempDict setObject:variantsTempArray[5] forKey:@"inventory"];
                    [tempDict setObject:variantsTempArray[6] forKey:@"weight"];
                    
                    [_saveVariantsArray addObject:tempDict];
                }
            }
            break;
        }
        case 8:
        {
            for (int i = 0; i < _saveProductVariantsArray.count; i++) {  // 行的总数量
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:0];
                
                NSMutableArray *variantsTempArray = [NSMutableArray arrayWithCapacity:0];
                variantsTempArray = _saveProductVariantsArray[i];
                
                if (variantsTempArray.count != 8) {
                    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                    
                    [_hud addErrorString:@"所有规格不得为空" delay:1.5];
                    
                    return;
                } else {
                    [tempDict setObject:_firstVariantName forKey:@"key1"];
                    [tempDict setObject:variantsTempArray[0] forKey:@"value1"];
                    
                    [tempDict setObject:_twoVariantName forKey:@"key2"];
                    [tempDict setObject:variantsTempArray[1] forKey:@"value2"];
                    
                    [tempDict setObject:_threeVariantName forKey:@"key3"];
                    [tempDict setObject:variantsTempArray[2] forKey:@"value3"];
                    
                    [tempDict setObject:variantsTempArray[3] forKey:@"price"];         // 销售价
                    [tempDict setObject:variantsTempArray[4] forKey:@"cost_price"];    // 成本价
                    [tempDict setObject:variantsTempArray[5] forKey:@"market_price"];  // 市场价格
                    [tempDict setObject:variantsTempArray[6] forKey:@"inventory"];     // 库存
                    [tempDict setObject:variantsTempArray[7] forKey:@"weight"];        // 重量
                    
                    [_saveVariantsArray addObject:tempDict];
                }
            }
            break;
        }
            
        default:
            break;
    }
    
    // 将规格数组保存到沙河中
    [kUserDefaults setObject:_saveVariantsArray forKey:@"saveVariantsArray"];
    [kUserDefaults synchronize];
    
    NSInteger stockCount = 0;
    for (int i = 0; i < _saveVariantsArray.count; i++) {
        NSDictionary *tempDict = _saveVariantsArray[i];
        stockCount += [tempDict[@"inventory"] integerValue];
    }
    
    [kUserDefaults setObject:[NSString stringWithFormat:@"%ld", stockCount] forKey:@"stockString"];
    [kUserDefaults synchronize];
    
    if (_saveVariantsArray.count > 0) {
        [self backToPrev];
    }
}

#pragma mark - Create More UI -

/**
 *  点击添加规格条目按钮，添加UI控件，并且设计好各种Tag值
 *
 *  @param frame 被点击按钮的frame值
 *  @param index 当时的标记
 */
- (void)addVariantsUI:(CGRect)frame index:(NSInteger)index isOther:(BOOL)isOther
{
    // 获取选中的规格数
    int defaultIndex = 0;
    NSInteger countTag = index;
    
    // 如果是之后删除 在重新创建的话，需要做判断
    if (isOther) {
        countTag += 1;
    }
    
    switch (countTag) {
        case 1:
        {
            defaultIndex = _firstDefaultIndex;
            break;
        }
        case 2:
        {
            defaultIndex = _twoDefaultIndex;
            break;
        }
        case 3:
        {
            defaultIndex = _threeDefaultIndex;
            break;
        }
            
        default:
            break;
    }
    
    // 添加下拉选择空间(第一个默认选中的时品牌)
    LMComBoxView *variantsFirstComBox = [[LMComBoxView alloc] initWithFrame:CGRectMake(90, frame.origin.y, kScreenWidth - 100 - 90, 30)];
    variantsFirstComBox.arrowImgName = @"downArrow.png";
    variantsFirstComBox.titlesList = _variantsArray;
    variantsFirstComBox.delegate = self;
    variantsFirstComBox.defaultIndex = defaultIndex;
    variantsFirstComBox.supView = bgScrollView;
    [variantsFirstComBox defaultSettings];
    variantsFirstComBox.tag = index * kLMComBoxTag;
    
    [bgScrollView addSubview:variantsFirstComBox];
    
    // 添加两个按钮  删除  添加
    EnterButton *addFirstBreedVariant = [[EnterButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(variantsFirstComBox.frame) + kSpace / 2, variantsFirstComBox.frame.origin.y, 45, 30)];
    addFirstBreedVariant.titleLabel.font = kMidFont;
    [addFirstBreedVariant setTitle:@"＋添加" forState:UIControlStateNormal];
    UIColor *addBreedVariantColor = COLOR(75, 155, 224, 1);
    [addFirstBreedVariant setTitleColor:addBreedVariantColor forState:UIControlStateNormal];
    addFirstBreedVariant.tag = index * kAddButtonTag;  /// 第一次进来的时候默认他的tag为1
    addFirstBreedVariant.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [addFirstBreedVariant addTarget:self action:@selector(addProductBreedVariants:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgScrollView addSubview:addFirstBreedVariant];
    
    // 添加删除按钮
    EnterButton *deleteFirstBreedVariant = [[EnterButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addFirstBreedVariant.frame) + kSpace / 2 , variantsFirstComBox.frame.origin.y, 40, 30)];
    deleteFirstBreedVariant.titleLabel.font = kMidFont;
    [deleteFirstBreedVariant setTitle:@"删除" forState:UIControlStateNormal];
    UIColor *deleteColor = COLOR(246, 70, 70, 1);
    [deleteFirstBreedVariant setTitleColor:deleteColor forState:UIControlStateNormal];
    deleteFirstBreedVariant.tag = index * kDeleteButtonTag; // 减号默认tag是 10
    
    deleteFirstBreedVariant.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [deleteFirstBreedVariant addTarget:self action:@selector(deleteProductBreedVariants:) forControlEvents:UIControlEventTouchUpInside];
    
    [bgScrollView addSubview:deleteFirstBreedVariant];
    
    // 添加一个输入框
    YunTextField *variantsFirstTextField = [[YunTextField alloc] initWithFrame:CGRectMake(variantsFirstComBox.frame.origin.x, CGRectGetMaxY(addFirstBreedVariant.frame) + 2 * kSpace, variantsFirstComBox.frame.size.width, 30)];
    variantsFirstTextField.placeholder = [NSString stringWithFormat:@"请输入%@", [_variantsArray firstObject]];
    variantsFirstTextField.tag = index * kYunTextFieldTag;
    variantsFirstTextField.delegate = self;
    [variantsFirstTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [bgScrollView addSubview:variantsFirstTextField];
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = addVariantButton.frame;
        
        frame.origin.y += 100;
        
        addVariantButton.frame = frame;
        
        if (_dataSource.count < 3) {
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1];
            
            [_dataSource addObject:tempArray];
        }
    } completion:^(BOOL finished) {
        //        CGFloat buttonHieght = CGRectGetMaxY(addVariantButton.frame);
        //
        //        if (buttonHieght < kScreenHeight) {
        //            bgScrollView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight + 50);
        //        } else {
        //            bgScrollView.contentSize = CGSizeMake(kScreenWidth, buttonHieght + 50);
        //        }
        
        YunLog(@"addvariantsMarker3333  = %d", addVariantsMarker);
    }];
}

/**
 *  统计规格种类 的总量
 *
 *  @return
 */
- (void)getAllVariants
{
    // 获取选中的具体规格名称
    NSMutableArray *firstVariantsArray = [NSMutableArray array];
    NSMutableArray *twoVariantsArray = [NSMutableArray array];
    NSMutableArray *threeVariantsArray = [NSMutableArray array];
    
    for (int i = 0; i < _dataSource.count; i++) {
        NSArray *tempArray = [NSArray arrayWithObject:_dataSource[i]];
        
        if (tempArray.count >= 1) {
            switch (i) {
                case 0:
                {
                    firstVariantsArray = _dataSource[0];
                    YunLog(@"firstVariantsArray = %@", firstVariantsArray);
                    
                    break;
                }
                case 1:
                {
                    twoVariantsArray = _dataSource[1];
                    
                    break;
                }
                case 2:
                {
                    threeVariantsArray = _dataSource[2];
                    
                    break;
                }
                    
                default:
                    break;
            }
        }
    }
    
    YunLog(@"variantsNameArray--测试--- = %@", _variantsNameArray);
    YunLog(@"_dataScoure = %@", _dataSource);
    
    // 进入循环之前需要先删除之前的数据源，要不然会有重叠部分
    [_reduceDataSource removeAllObjects];
    
    // 这里获取到了  具体规格里面的数据
    if (firstVariantsArray.count > 0 && twoVariantsArray.count > 0 && threeVariantsArray.count > 0) {   // 1 2 3
        for (int a = 0; a < firstVariantsArray.count; a++) {
            for (int b = 0; b < twoVariantsArray.count; b++) {
                for (int c = 0; c < threeVariantsArray.count; c++) {
                    NSMutableArray *tempVariantsArray = [NSMutableArray arrayWithCapacity:0];
                    [tempVariantsArray addObject:firstVariantsArray[a]];
                    [tempVariantsArray addObject:twoVariantsArray[b]];
                    [tempVariantsArray addObject:threeVariantsArray[c]];
                    
                    [_reduceDataSource addObject:tempVariantsArray];
                }
            }
        }
    } else if (firstVariantsArray.count > 0 && twoVariantsArray.count > 0 && threeVariantsArray.count <= 0) {  // 1 2
        for (int a = 0; a < firstVariantsArray.count; a++) {
            for (int b = 0; b < twoVariantsArray.count; b++) {
                NSMutableArray *tempVariantsArray = [NSMutableArray arrayWithCapacity:0];
                [tempVariantsArray addObject:firstVariantsArray[a]];
                [tempVariantsArray addObject:twoVariantsArray[b]];
                
                [_reduceDataSource addObject:tempVariantsArray];
            }
        }
    } else if (firstVariantsArray.count > 0 && twoVariantsArray.count <= 0 && threeVariantsArray.count > 0) {  // 1 3
        for (int a = 0; a < firstVariantsArray.count; a++) {
            for (int b = 0; b < threeVariantsArray.count; b++) {
                NSMutableArray *tempVariantsArray = [NSMutableArray arrayWithCapacity:0];
                [tempVariantsArray addObject:firstVariantsArray[a]];
                [tempVariantsArray addObject:threeVariantsArray[b]];
                
                [_reduceDataSource addObject:tempVariantsArray];
            }
        }
    } else if (firstVariantsArray.count <= 0 && twoVariantsArray.count > 0 && threeVariantsArray.count > 0) {  // 2 3
        for (int a = 0; a < twoVariantsArray.count; a++) {
            for (int b = 0; b < threeVariantsArray.count; b++) {
                NSMutableArray *tempVariantsArray = [NSMutableArray arrayWithCapacity:0];
                [tempVariantsArray addObject:twoVariantsArray[a]];
                [tempVariantsArray addObject:threeVariantsArray[b]];
                
                [_reduceDataSource addObject:tempVariantsArray];
            }
        }
    } else if (firstVariantsArray.count > 0 && twoVariantsArray.count <= 0 && threeVariantsArray.count <= 0) {  // 1
        for (int a = 0; a < firstVariantsArray.count; a++) {
            NSMutableArray *tempVariantsArray = [NSMutableArray arrayWithCapacity:0];
            [tempVariantsArray addObject:firstVariantsArray[a]];
            
            [_reduceDataSource addObject:tempVariantsArray];
        }
    } else if (firstVariantsArray.count <= 0 && twoVariantsArray.count > 0 && threeVariantsArray.count <= 0) {  // 2
        for (int a = 0; a < twoVariantsArray.count; a++) {
            NSMutableArray *tempVariantsArray = [NSMutableArray arrayWithCapacity:0];
            [tempVariantsArray addObject:twoVariantsArray[a]];
            
            [_reduceDataSource addObject:tempVariantsArray];
        }
    }
    else if (firstVariantsArray.count <= 0 && twoVariantsArray.count <= 0 && threeVariantsArray.count > 0) {  // 3
        for (int a = 0; a < threeVariantsArray.count; a++) {
            NSMutableArray *tempVariantsArray = [NSMutableArray arrayWithCapacity:0];
            [tempVariantsArray addObject:threeVariantsArray[a]];
            
            [_reduceDataSource addObject:tempVariantsArray];
        }
    }
    
    // 建立表格
    YunLog(@"reduceDataSource = %@", _reduceDataSource);
    
    // TODO 等待开放
    if (_reduceDataSource.count > 0) {
        [self createVariantsFrameTable:_reduceDataSource];
    }
}

/**
 *  根据数据源 构建规格信息表
 */
- (void)createVariantsFrameTable:(NSMutableArray *)reduceDataSource
{
    // 获取添加规格按钮的frame
    CGRect frame = addVariantButton.frame;
    
    // 首先移除添加按钮之下的所有控件
    for (id obj in bgScrollView.subviews) {
        if ([obj isKindOfClass:[EnterButton class]]) {
            EnterButton *button = (EnterButton *)obj;
            if (button.frame.origin.y > frame.origin.y) {
                [button removeFromSuperview];
            }
        }
        
        if ([obj isKindOfClass:[UILabel class]]) {
            YunLabel *variantNameLabel = (YunLabel *)obj;
            if (variantNameLabel.frame.origin.y > frame.origin.y) {
                [variantNameLabel removeFromSuperview];
            }
        }
        
        if ([obj isKindOfClass:[YunTextField class]]) {
            YunTextField *yunTextField = (YunTextField *)obj;
            if (yunTextField.frame.origin.y > frame.origin.y) {
                [yunTextField removeFromSuperview];
            }
        }
    }
    
    /**
     *  如果这里的数据是为空得 则这里不做处理
     */
    if (reduceDataSource.count > 0) {
        YunLabel *remindLabel = [[YunLabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(frame) + 8 * kSpace, kScreenWidth, 20)];
        remindLabel.text = @"请按照从左到右的顺序添加商品规格";
        remindLabel.textColor = [UIColor redColor];
        remindLabel.font = kMidFont;
        remindLabel.textAlignment = NSTextAlignmentCenter;
        remindLabel.tag = 2222;
        
        [bgScrollView addSubview:remindLabel];
        
        // 1.构建表头
        topHeight = [self culaArrayItemStringHeight:_variantsNameArray];
        
        CGFloat labelWidth = (kScreenWidth - kSpace) / _variantsNameArray.count;
        CGFloat tempFrameY;
        
        for (int i = 0; i < _variantsNameArray.count; i++) {
            // label
            YunLabel *nameLabel = [[YunLabel alloc] initWithFrame:CGRectMake(kSpace / 2 + (labelWidth * i), CGRectGetMaxY(frame) + 12 * kSpace, labelWidth, topHeight)];
            nameLabel.text = _variantsNameArray[i];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.numberOfLines = 0;
            nameLabel.font = kMidFont;
            nameLabel.textColor = kBlackColor;
            nameLabel.backgroundColor = kClearColor;
            
            nameLabel.layer.borderWidth = kLineHeight;
            nameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            if (i == _variantsNameArray.count - 1) {
                tempFrameY = CGRectGetMaxY(nameLabel.frame);
            }
            
            [bgScrollView addSubview:nameLabel];
        }
        
        // 2.构建信息表 (这里的信息框的高度先使用默认的获取的高度  topHeight)
        CGFloat bgScrollViewHeight = 0;
        for (int i = 0; i < _reduceDataSource.count; i++) {           // 行的总数量
            for (int  j = 0; j < _variantsNameArray.count; j++) {     // 列的总数量
                NSMutableArray *variantsNameArray = _reduceDataSource[i];
                
                // 创建label
                if (j < addVariantsMarker) {
                    YunLabel *variantsNameLabel = [[YunLabel alloc] initWithFrame:CGRectMake(kSpace / 2 + (labelWidth * j), tempFrameY + topHeight * i, labelWidth, topHeight)];
                    variantsNameLabel.text = j < variantsNameArray.count ? variantsNameArray[j] : kNullToString(@"");
                    variantsNameLabel.textColor = kBlackColor;
                    variantsNameLabel.backgroundColor = kClearColor;
                    variantsNameLabel.font = kMidFont;
                    variantsNameLabel.pointXY = CGPointMake(i, j);
                    variantsNameLabel.textAlignment = NSTextAlignmentCenter;
                    variantsNameLabel.tag = (i + 1) * kTableTag + (j + 1);
                    
                    variantsNameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
                    variantsNameLabel.layer.borderWidth = kLineHeight;
                    
                    [bgScrollView addSubview:variantsNameLabel];
                } else {
                    YunTextField *variantYunTextField = [[YunTextField alloc] initWithFrame:CGRectMake(kSpace / 2 + (labelWidth * j), tempFrameY  + topHeight * i, labelWidth, topHeight)];
                    variantYunTextField.backgroundColor = kClearColor;
                    variantYunTextField.textColor = kBlackColor;
                    variantYunTextField.font = kMidFont;
                    variantYunTextField.pointXY = CGPointMake(i, j);
                    variantYunTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    variantYunTextField.textAlignment = NSTextAlignmentCenter;
                    variantYunTextField.delegate = self;
                    [variantYunTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                    variantYunTextField.tag = (i + 1) * kTableTag + (j + 1);
                    //                    variantYunTextField.keyboardType = UIKeyboardTypeNumberPad;
                    //                    variantYunTextField.tag = [[NSString stringWithFormat:@"%d%d", i,j] integerValue];
                    YunLog(@"variantYunTextField.tag = %ld", variantYunTextField.tag);
                    
                    
                    variantYunTextField.layer.borderWidth = kLineHeight;
                    variantYunTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
                    
                    [bgScrollView addSubview:variantYunTextField];
                    
                    if (i == _reduceDataSource.count - 1 && j == _variantsNameArray.count - 1) {
                        bgScrollViewHeight = CGRectGetMaxY(variantYunTextField.frame);
                        
                        if (bgScrollViewHeight > kScreenHeight) {
                            bgScrollView.contentSize = CGSizeMake(kScreenWidth, bgScrollViewHeight + 200);
                        } else {
                            bgScrollView.contentSize = CGSizeMake(kScreenWidth, kScreenHeight + 200);
                        }
                    }
                }
            }
        }
        
        // 3.创建保存按钮
        EnterButton *saveButton = [[EnterButton alloc] initWithFrame:CGRectMake((kScreenWidth - 160) / 2, bgScrollViewHeight + 40, 160, 35)];
        saveButton.backgroundColor = kOrangeColor;
        [saveButton setTitle:@"保存规格" forState:UIControlStateNormal];
        saveButton.titleLabel.font = kSizeBoldFont;
        [saveButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
        
        [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        saveButton.layer.cornerRadius = 6;
        saveButton.layer.masksToBounds = YES;
        
        [bgScrollView addSubview:saveButton];
    }
}

/**
 *  创建规格的存放label
 *
 *  @param array
 */
- (void)createGetVariantsLabel:(CGRect)frame text:(NSString *)text index:(NSInteger)index
{
    // 获取上次宽度
    CGFloat formerWidth = [[[NSUserDefaults standardUserDefaults] objectForKey:@"formerWidth"] floatValue];
    
    // 计算这次文字的宽度
    CGFloat width;
    width = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 30) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:kSizeFont} context:nil].size.width;
    
    if (width < 20) {
        width = 20;
    }
    // 这里设置每个variants的间隙为20
    CGFloat variantsLabelWidth = width;
    CGFloat variantsLabelHeight = 30;
    CGFloat variantsLabelY = 0;
    CGFloat variantsLabelX = 0;
    int col = 0;
    int row = 0;
    
    if ((formerWidth + 2 * kSpace + width) > (kScreenWidth - 4 * kSpace)) {
        col = ((int)(formerWidth + 2 * kSpace + width) % (int)(kScreenWidth - 4 * kSpace));
        row = ((formerWidth + 2 * kSpace + width) / (kScreenWidth - 4 * kSpace));
        variantsLabelX = (formerWidth + 2 * kSpace + width) - (kScreenWidth - 4 * kSpace) * col;
        variantsLabelY = row * (CGRectGetMaxY(frame) + kSpace);
    } else {
        variantsLabelX = formerWidth + 2 * kSpace + width;
        variantsLabelY = CGRectGetMaxY(frame) + kSpace;
    }
    
    UILabel *variantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(variantsLabelX, variantsLabelY, variantsLabelWidth, variantsLabelHeight)];
    variantsLabel.backgroundColor = kWhiteColor;
    variantsLabel.textAlignment = NSTextAlignmentCenter;
    variantsLabel.layer.borderColor = kBlackColor.CGColor;
    variantsLabel.layer.borderWidth = 1.0;
    
    variantsLabel.layer.cornerRadius = 5;
    variantsLabel.layer.masksToBounds = YES;
    
    variantsLabel.text = text;
    variantsLabel.textColor = kBlackColor;
    variantsLabel.font = kMidFont;
    
    [bgScrollView addSubview:variantsLabel];
    
    // 将计算出来的宽度相加，然后存起来(这里是包括间隙在内的所有总宽度)
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f", width + formerWidth + 2 * kSpace] forKey:@"formerWidth"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  返回传进来的数组里面字符串最长的高度
 *
 *  @param array 传进来的数组
 *
 *  @return 返回高度
 */
- (CGFloat)culaArrayItemStringHeight:(NSMutableArray *)array
{
    CGFloat height = 0;
    CGFloat width = kScreenWidth / array.count;
    
    for (int i = 0; i < array.count - 1; i++) {
        CGFloat tempHeight = 0;
        tempHeight = [Tool calculateContentLabelHeight:array[i] withFont:kSizeFont withWidth:width];
        if (tempHeight > height) {
            height = tempHeight;
        }
    }
    if (height < 30) {
        height = 30;
    }
    return height;
}

#pragma mark - LMComBoxViewDelegate -

-(void)selectAtIndex:(NSInteger)index inCombox:(LMComBoxView *)_combox
{
    [bgScrollView endEditing:YES];
    
    /// 存储选择的品种
    NSInteger countTag = _combox.tag / kLMComBoxTag;
    YunLog(@"comBoxTag = %ld", _combox.tag);
    
    switch (countTag) {
        case 1:
        {
            if (![_firstVariantName isEqualToString:_variantsArray[index]]) {
                NSMutableArray *tempArray = _dataSource[countTag - 1];
                [tempArray removeAllObjects];
                
                [_dataSource replaceObjectAtIndex:(countTag - 1) withObject:tempArray];
                [_variantsNameArray replaceObjectAtIndex:0 withObject:_variantsArray[index]];
                YunLog(@"counttag11--- = %ld", countTag);
            }
            
            _firstDefaultIndex = (int)index;
            
            break;
        }
        case 2:
        {
            
            if (![_twoVariantName isEqualToString:_variantsArray[index]]) {
                NSMutableArray *tempArray = _dataSource[countTag - 1];
                [tempArray removeAllObjects];
                
                [_dataSource replaceObjectAtIndex:(countTag - 1) withObject:tempArray];
                [_variantsNameArray replaceObjectAtIndex:1 withObject:_variantsArray[index]];
                YunLog(@"counttag22--- = %ld", countTag);
            }
            
            _twoDefaultIndex = (int)index;
            break;
        }
        case 3:
        {
            if (![_threeVariantName isEqualToString:_variantsArray[index]]) {
                NSMutableArray *tempArray = _dataSource[countTag - 1];
                [tempArray removeAllObjects];
                
                [_dataSource replaceObjectAtIndex:(countTag - 1) withObject:tempArray];
                //                _threeVariantName = _variantsArray[index];
                [_variantsNameArray replaceObjectAtIndex:2 withObject:_variantsArray[index]];
                YunLog(@"counttag33--- = %ld", countTag);
            }
            
            _threeDefaultIndex = (int)index;
            
            break;
        }
            
        default:
            break;
    }
    
    YunTextField *yunTextField = (YunTextField *)[bgScrollView viewWithTag:countTag * kYunTextFieldTag];
    yunTextField.placeholder = [NSString stringWithFormat:@"请输入%@", _variantsArray[index]];
    
    // 获取所有规格合并数组
    [self getAllVariants];
}

#pragma mark - UITextFieldClick -

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 15) {
        textField.text = [textField.text substringToIndex:15];
    }
    
    if (textField.text.length >= 2) {
        NSInteger rangeLocation = [textField.text rangeOfString:@"-"].location;
        
        if (rangeLocation != NSNotFound) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            [_hud addErrorString:@"规格参数填写不正确" delay:1.5];
            
            textField.text = @"";
        }
    }
    
    YunLog(@"------%@", textField.text);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    BOOL tempEdit = NO;
    if (textField.tag >= kTableTag) {
        YunTextField *yunTextField = (YunTextField *)textField;
        
        if (yunTextField.pointXY.y >= addVariantsMarker + 1) {
            YunTextField *formTextField = (YunTextField *)[bgScrollView viewWithTag:textField.tag - 1];
            
            if (formTextField.text.length > 0) {
                tempEdit = YES;
            } else {
                tempEdit = NO;
            }
        } else {
            tempEdit = YES;
        }
    } else {
        tempEdit = YES;
    }
    
    YunTextField *yunTextField = (YunTextField *)textField;
    
    if (textField.tag >= kTableTag) {
        if (yunTextField.pointXY.y > 2) {
            if (_countIsTure == NO) {
                tempEdit = NO;
            }
        }
    }
    
    return tempEdit;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.tag >= kTableTag) {
        float count = [textField.text floatValue];
        
        BOOL countBool = ! count > 0.00;
        
        if (countBool) {
            _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            
            [_hud addErrorString:[NSString stringWithFormat:@"%@ 不符合规格", textField.text] delay:1.0];
            
            textField.text = @"";
            
            YunTextField *formYunTextField = (YunTextField *)[bgScrollView viewWithTag:textField.tag - kTableTag];
            [formYunTextField becomeFirstResponder];
            
            _countIsTure = NO;
        } else {
            _countIsTure = YES;
        }
    }
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    YunLog(@"----444---%@ --- Tag---%ld", textField.text, textField.tag);
    if (textField.tag >= kTableTag && _countIsTure) {
        NSInteger rowCountTag = textField.tag / kTableTag;
        
        YunTextField *yunTextField = (YunTextField *)textField;
        
        _saveProductVariantsArray = _reduceDataSource;
        
        NSMutableArray *tempVariantsArray = [NSMutableArray arrayWithCapacity:5];
        tempVariantsArray = _saveProductVariantsArray[rowCountTag - 1];
        
        NSInteger arrayCount = tempVariantsArray.count;
        
        // 如果数组不够五位的长度，那么在后面没有填写的规格信息默认是0
        switch (arrayCount) {
            case 1:
            {
                for (NSInteger i = arrayCount; i < 6; i++) {
                    [tempVariantsArray addObject:@"0"];
                }
                break;
            }
            case 2:
            {
                for (NSInteger i = arrayCount; i < 7; i++) {
                    [tempVariantsArray addObject:@"0"];
                }
                break;
            }
            case 3:
            {
                for (NSInteger i = arrayCount; i < 8; i++) {
                    [tempVariantsArray addObject:@"0"];
                }
                break;
            }
                
            default:
                break;
        }
        
        if ([textField.text floatValue] > 0.00) {
            CGFloat pointY = yunTextField.pointXY.y;
            
            [tempVariantsArray replaceObjectAtIndex:(int)pointY withObject:textField.text];
            
            YunLog(@"tempVariantsArray = %@", tempVariantsArray);
            
            [_saveProductVariantsArray replaceObjectAtIndex:rowCountTag - 1 withObject:tempVariantsArray];
        } else {
            if ([textField isFirstResponder]) {
                NSInteger pointY = yunTextField.pointXY.y;
                _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                [_hud addErrorString:[NSString stringWithFormat:@"%@不能为空", _variantsNameArray[pointY]] delay:1.5];
            }
        }
    } else {
        textField.text = @"";
    }
    
    YunLog(@"saveProducts = %@", _saveProductVariantsArray);
}

#pragma mark - BackPrev -

- (void)backToPrev
{
    [self.navigationController popViewControllerAnimated:YES];
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
