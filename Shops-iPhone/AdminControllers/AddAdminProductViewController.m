//
//  AddAdminProductViewController.m
//  Shops-iPhone
//
//  Created by xxy on 15/8/13.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "AddAdminProductViewController.h"

// Comones
#import "LibraryHeadersForCommonController.h"

// Controllers
#import "EditProductViewController.h"
#import "LMContainsLMComboxScrollView.h"

// Views
#import "LMComBoxView.h"

#define kSpace 10
#define kDropDownListTag 100

@interface AddAdminProductViewController () <LMComBoxViewDelegate>

@property (nonatomic, strong) UILabel *naviTitle;

@property (nonatomic, strong) LMContainsLMComboxScrollView *scrollView;

@property (nonatomic, strong) UIButton *nextBtn;
/// 一级标题选中的分类名称
@property (nonatomic, copy) NSString *selectedFrist;
/// 一级标题选中的分类ID
@property (nonatomic, copy) NSString *selectedFirstId;

/// 二级标题选中的分类名称
@property (nonatomic, copy) NSString *selectedTwo;
/// 二级标题选中的分类ID
@property (nonatomic, copy) NSString *selectedTwoId;

/// 三级标题选中的分类名称
@property (nonatomic, copy) NSString *selectedThree;
/// 三级标题选中的分类ID
@property (nonatomic, copy) NSString *selectedThreeId;

@property (nonatomic, assign) NSInteger height;

@property (nonatomic, strong) MBProgressHUD *hud;

/// 一级标题的数据源
@property (nonatomic, strong) NSMutableArray *dataFirstSource;

/// 二级标题的数据源
@property (nonatomic, strong) NSMutableArray *dataTwoSource;

/// 三级标题的数据源
@property (nonatomic, strong) NSMutableArray *dataThreeSource;

/// 一级标题包含的所有分类名称
@property (nonatomic, strong) NSMutableArray *firstCateArray;
/// 一级标题包含的所有分类ID
@property (nonatomic, strong) NSMutableArray *firstCateIdArray;

/// 二级标题包含的所有分类名称
@property (nonatomic, strong) NSMutableArray *twoCateArray;
/// 二级标题包含的所有分类ID
@property (nonatomic, strong) NSMutableArray *twoCateIdArray;

/// 三级标题包含的所有分类名称
@property (nonatomic, strong) NSMutableArray *threeCateArray;
/// 三级标题包含的所有分类ID
@property (nonatomic, strong) NSMutableArray *threeCateIdArray;

/// 商家信息
@property (nonatomic, strong) NSDictionary *SaleUserInfo;

/// 商品一级分类获取到的ID
@property (nonatomic, copy) NSString *productFirstID;

@end

@implementation AddAdminProductViewController

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
        _naviTitle.text = @"添加商品";
        
        self.navigationItem.titleView = _naviTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kWhiteColor;
    
    _firstCateArray = [NSMutableArray array];
    _twoCateArray = [NSMutableArray array];
    _threeCateArray = [NSMutableArray array];
    
    _firstCateIdArray = [NSMutableArray array];
    _twoCateIdArray = [NSMutableArray array];
    _threeCateIdArray = [NSMutableArray array];
    
    _dataFirstSource = [NSMutableArray array];
    _dataTwoSource = [NSMutableArray array];
    _dataThreeSource = [NSMutableArray array];
    _SaleUserInfo = [NSDictionary dictionary];
    
    // 设置一级分类默认选中的id为哦
    _productFirstID = @"0";
    
    /// 设置默认的选中
    _selectedFirstId = @"0";
    _selectedTwoId = @"0";
    _selectedThreeId = @"0";
    
    // 添加左边退出图标
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 25, 25);
    [button setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backToPrev) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    backItem.style = UIBarButtonItemStylePlain;
    
    self.navigationItem.leftBarButtonItem = backItem;

    [self getData];
}

#pragma mark - CreateUI -

-(void)createUI
{
    CGFloat titleLabelX = kSpace;
    CGFloat titleLabelWidth = 120;
    CGFloat titleLabelHeight = 30;
    CGFloat titleLabelY = 3 * kSpace + kNavTabBarHeight;
    
    UILabel *firstTitleLabel= [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelWidth, titleLabelHeight)];
    firstTitleLabel.textColor = kBlackColor;
    firstTitleLabel.text = @"商品一级分类";
    firstTitleLabel.font = kBigBoldFont;
    firstTitleLabel.tag = 1;
    
    [self.view addSubview:firstTitleLabel];
    
    // 添加下一步按钮
    _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 100, CGRectGetMaxY(firstTitleLabel.frame) + 4 * kSpace, 80, 40)];
    _nextBtn.backgroundColor = kOrangeColor;
    _nextBtn.tag = 1001;
    [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    _nextBtn.titleLabel.font = kSizeBoldFont;
    [_nextBtn setTintColor:kWhiteColor];
    _nextBtn.layer.masksToBounds = YES;
    _nextBtn.layer.cornerRadius = 5;
    _nextBtn.enabled = YES;
    [_nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_nextBtn];
    
    // 添加右边选择器
    CGFloat comBoxX = CGRectGetMaxX(firstTitleLabel.frame) + 10;
    LMComBoxView *comBox = [[LMComBoxView alloc] initWithFrame:CGRectMake(comBoxX, titleLabelY, kScreenWidth - comBoxX - 20, 30)];
    comBox.arrowImgName = @"downArrow.png";
    comBox.titlesList = _firstCateArray;
    comBox.delegate = self;
    comBox.supView = self.view;
    [comBox defaultSettings];
    comBox.tag = kDropDownListTag;
    
    [self selectAtIndex:0 inCombox:comBox];

    [self.view addSubview:comBox];
    
    _height = CGRectGetMaxY(_nextBtn.frame) + 2 * kSpace;
}

#pragma mark - GetData -

- (void)getData
{
    _hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    _hud.labelText = @"努力加载中...";
    // 商品组正式环境下地URL ： http://api.yundianjia.com/public/api/v1/product_categories.json
    NSString *productCateURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1 requestURL:kProductCatefories params:nil];
    
    YunLog(@"productCateURL = %@", productCateURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:productCateURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            
            _dataFirstSource = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"product_categories"]);
            
            for (NSDictionary *dict in _dataFirstSource) {
                NSString *name = dict[@"name"];
                NSString *cateId = dict[@"id"];
                
                [_firstCateArray addObject:name];
                [_firstCateIdArray addObject:cateId];
            }
            
            [_hud hide:YES];
            
            [self createUI];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
        [_hud hide:YES];
    }];
}

- (void)getSalerInfoData
{
    AppDelegate *appDelegate = kAppDelegate;
    
    NSDictionary *params = @{@"user_session_key"        :    kNullToString(appDelegate.user.userSessionKey),
                             @"terminal_session_key"    :    kNullToString(appDelegate.terminalSessionKey),
                             @"code"                    :     kNullToString(_shopCode)};
    
    NSString *productUserInfoURL = [Tool buildRequestURLHost:kRequestHostWithPublic APIVersion:kAPIVersion1WithShops requestURL:[NSString stringWithFormat:kGetSalerInfoURL, _shopCode] params:params];
    
    YunLog(@"productUserInfoURL = %@", productUserInfoURL);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    
    [manager GET:productUserInfoURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *code = [[responseObject objectForKey:@"status"] objectForKey:@"code"];
        if ([code isEqualToString:kSuccessCode]) {
            
            _SaleUserInfo = kNullToArray([[responseObject objectForKey:@"data"] objectForKey:@"shop"]);
            
            _nextBtn.enabled = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        YunLog(@"error = %@", error);
    }];
}

#pragma mark - BtnClick -

- (void)nextBtnClick:(UIButton *)sender
{
    YunLog(@"等待处理");
    
    YunLog(@"_selectedFristId = %@, _selectedTwoId = %@, _selectedThreeId = %@", _selectedFirstId, _selectedTwoId, _selectedThreeId);
    NSMutableDictionary *optionDict = [NSMutableDictionary dictionary];
    
    if (![_selectedTwoId isEqualToString:@"no"] && ![_selectedThreeId isEqualToString:@"no"]) { // 二三级分类都有数据
        [optionDict setObject:_selectedFirstId forKey:@"product_category_grade_1"];
        [optionDict setObject:_selectedTwoId forKey:@"product_category_grade_2"];
        [optionDict setObject:_selectedThreeId forKey:@"product_category_grade_3"];
    }
    
    if (![_selectedTwoId isEqualToString:@"no"] && [_selectedThreeId isEqualToString:@"no"]) {  // 二级分类有数据，三级分类没哟数据
        [optionDict setObject:_selectedFirstId forKey:@"product_category_grade_1"];
        [optionDict setObject:_selectedTwoId forKey:@"product_category_grade_2"];
    }
    
    if ([_selectedTwoId isEqualToString:@"no"] && [_selectedThreeId isEqualToString:@"no"]) {  // 二三级分类都没有数据
        [optionDict setObject:_selectedFirstId forKey:@"product_category_grade_1"];
    }
    
    
    EditProductViewController *vc = [[EditProductViewController alloc] init];
//    vc.saleUserInfoDict = _SaleUserInfo;
    vc.optionCateDict = optionDict;
    vc.productFirstId = _productFirstID;
    vc.shopCode = _shopCode;
    vc.shopID = _shopID;
   
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - LMComBaxDelegate -

- (void)selectAtIndex:(NSInteger)index inCombox:(LMComBoxView *)_combox
{
    YunLog(@"comBox.tag = %ld", (long)_combox.tag);
    
    NSInteger tag = _combox.tag;
    
    YunLog(@"count = %ld", (long)tag);
    
    NSDictionary *dict = [NSDictionary dictionary];
    NSMutableArray *childArray = [NSMutableArray array];
    NSString *titleStr;
    
    if (tag == 1 * kDropDownListTag)
    {
        _selectedFrist = [_firstCateArray objectAtIndex:index];
        _selectedFirstId = [_firstCateIdArray objectAtIndex:index];
        
        // 获取一级分类的ID
        for (int i = 0 ; i < _dataFirstSource.count; i ++) {
            NSDictionary *dictCategory = _dataFirstSource[i];
            if ([_selectedFrist isEqualToString:[dictCategory safeObjectForKey:@"name"]]) {
                _productFirstID = [dictCategory safeObjectForKey:@"id"];
            }
        }
        
        dict = [[_dataFirstSource objectAtIndex:index] objectForKey:@"children"];
        
        childArray = dict[@"product_categories"];
        
        if (childArray.count > 0) {
            titleStr = @"商品二级分类";
            tag += kDropDownListTag;
            
            if (_twoCateArray) {
                [_twoCateArray removeAllObjects];
                [_twoCateIdArray removeAllObjects];
            }
            
            for (NSDictionary *dictTwo in childArray) {
                NSString *name = dictTwo[@"name"];
                NSString *cateTwoId = dictTwo[@"id"];
                
                [_twoCateArray addObject:name];             // 获取标题的数据
                [_twoCateIdArray addObject:cateTwoId];      // 获取二级所有的分类ID
                
                // 构建第二个数据源
                _dataTwoSource = childArray;
            }
            
            _selectedTwo = [_twoCateArray firstObject];
            _selectedTwoId = [_twoCateIdArray firstObject];

            // 选中一级标题的某个分类，这个分类有二级标题
            // 需要将之前创建的二级分类进行删除
            [self deleteTitleAndComBox:_combox.tag isHaveCate:NO];
            
            [self createCateComBox:titleStr frame:_combox.frame array:_twoCateArray tag:tag];
        } else {
            // 如果选中的一级分类的某个分类没有二级分类，则需要删除之前创建的二级分类，然后，将下一步按钮上移动
            [self deleteTitleAndComBox:_combox.tag isHaveCate:YES];
            
            // 设置二级 三级选中的ID为no, 这里的no表示没有选中的二三 级标题
            _selectedTwoId = @"no";
            _selectedThreeId = @"no";
            
            return;
        }
    } else if (tag  == 2 * kDropDownListTag) {
        _selectedTwo = [_twoCateArray objectAtIndex:index];
        _selectedTwoId = [_twoCateIdArray objectAtIndex:index];
        
        dict = [[_dataTwoSource objectAtIndex:index] objectForKey:@"children"];
        
        childArray = dict[@"product_categories"];
        
        if (_threeCateArray) {
            [_threeCateArray removeAllObjects];
            [_threeCateIdArray removeAllObjects];
        }
        
        if (childArray.count > 0) {
            titleStr = @"商品三级分类";
            tag += kDropDownListTag;
            
            for (NSDictionary *dictTwo in childArray) {
                NSString *name = dictTwo[@"name"];
                NSString *cateThreeId = dictTwo[@"id"];
                
                [_threeCateArray addObject:name];               // 获取标题的数据
                [_threeCateIdArray addObject:cateThreeId];      // 获取第三级分类所有的ID
                
                // 构建第二个数据源
                _dataThreeSource = childArray;
            }
            _selectedThree = [_threeCateArray firstObject];
            _selectedThreeId = [_threeCateIdArray firstObject];

            // 选中一级标题的某个分类，这个分类有二级标题
            // 需要将之前创建的二级分类进行删除
            [self deleteTitleAndComBox:_combox.tag isHaveCate:NO];
            
            [self createCateComBox:titleStr frame:_combox.frame array:_threeCateArray tag:tag];
        } else {
            // 如果选中的一级分类的某个分类没有二级分类，则需要删除之前创建的二级分类，然后，将下一步按钮上移动
            [self deleteTitleAndComBox:_combox.tag isHaveCate:YES];
            
            // 设置三级选中的标题为no
            _selectedThreeId = @"no";
            
            return;
        }
    } else {
        _selectedThree = [_threeCateArray objectAtIndex:index];
        _selectedThreeId = [_threeCateIdArray objectAtIndex:index];
    }
    
    YunLog(@"_selectedFrist = %@, _selectedTwo = %@, _selectedThree = %@", _selectedFrist, _selectedTwo, _selectedThree);
    YunLog(@"_selectedFristId = %@, _selectedTwoId = %@, _selectedThreeId = %@", _selectedFirstId, _selectedTwoId, _selectedThreeId);
    
}

- (void)deleteTitleAndComBox:(NSInteger)index isHaveCate:(BOOL)isHaveCate
{
    LMComBoxView *comBox = (LMComBoxView *)[self.view viewWithTag:index];
    
    /// 被点击的时一级分类，那么他下面的二级分类 和三级分类全都需要取消
    if (index == kDropDownListTag) {
        UILabel *twoTitleLable = (UILabel *)[self.view viewWithTag:(index * 2 / 100)];
        LMComBoxView *twoComBox = (LMComBoxView *)[self.view viewWithTag:index * 2];
        
        UILabel *threeTitleLable = (UILabel *)[self.view viewWithTag:(index * 3 / 100)];
        LMComBoxView *threeComBox = (LMComBoxView *)[self.view viewWithTag:index * 3];
        
        if (twoTitleLable) {
            [twoTitleLable removeFromSuperview];
            [twoComBox removeFromSuperview];
        }
        
        if (threeTitleLable) {
            [threeTitleLable removeFromSuperview];
            [threeComBox removeFromSuperview];
        }
        
        if (isHaveCate) {
            CGRect nextFrame = _nextBtn.frame;
            [UIView animateWithDuration:0.5 animations:^{
                _nextBtn.frame = CGRectMake(nextFrame.origin.x, CGRectGetMaxY(comBox.frame) + 4 * kSpace, nextFrame.size.width, nextFrame.size.height);
            } completion:^(BOOL finished) {
                _height = CGRectGetMaxY(_nextBtn.frame) + 2 * kSpace;
            }];
        }
    }
    /// 被点击的时二级分类，那么他下面的三级分类全都需要取消
    if (index == kDropDownListTag * 2) {
        UILabel *threeTitleLable = (UILabel *)[self.view viewWithTag:((index + kDropDownListTag) / 100)];
        LMComBoxView *threeComBox = (LMComBoxView *)[self.view viewWithTag:(index + kDropDownListTag)];
        if (threeTitleLable) {
            [threeTitleLable removeFromSuperview];
            [threeComBox removeFromSuperview];
        }
        if (isHaveCate) {
            CGRect nextFrame = _nextBtn.frame;
            [UIView animateWithDuration:0.5 animations:^{
                _nextBtn.frame = CGRectMake(nextFrame.origin.x, CGRectGetMaxY(comBox.frame) + 4 * kSpace, nextFrame.size.width, nextFrame.size.height);
            } completion:^(BOOL finished) {
                _height = CGRectGetMaxY(_nextBtn.frame) + 2 * kSpace;
            }];
        }
    }
    
}

- (void)createCateComBox:(NSString *)str frame:(CGRect)frame array:(NSMutableArray *)array tag:(NSInteger)tag
{
    YunLog(@"haohaohaoaho");
    CGFloat titleLabelX = kSpace;
    CGFloat titleLabelWidth = 120;
    CGFloat titleLabelHeight = 30;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, frame.origin.y + 8 * kSpace, titleLabelWidth, titleLabelHeight)];
    titleLabel.text = str;
    titleLabel.textColor = kBlackColor;
    titleLabel.font = kBigBoldFont;
    titleLabel.tag = tag / 100;
    
    [self.view addSubview:titleLabel];
    
    LMComBoxView *comBox = [[LMComBoxView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + 8 * kSpace, frame.size.width, frame.size.height)];
    comBox.arrowImgName = @"downArrow.png";
    comBox.titlesList = array;
    comBox.delegate = self;
    comBox.supView = self.view;
    [comBox defaultSettings];
    comBox.tag = tag;
    [self.view addSubview:comBox];
    
    // 按钮下偏移
    CGRect nextFrame = _nextBtn.frame;
    [UIView animateWithDuration:0.5 animations:^{
        _nextBtn.frame = CGRectMake(nextFrame.origin.x, CGRectGetMaxY(comBox.frame) + 4 * kSpace, nextFrame.size.width, nextFrame.size.height);
    } completion:^(BOOL finished) {
        _height = CGRectGetMaxY(_nextBtn.frame) + 2 * kSpace;

    }];
    
    // 自动选中第一个分类以便于查询并创建下一分类
    [self selectAtIndex:0 inCombox:(LMComBoxView *)[self.view viewWithTag:tag]];
}

- (void)removeTitleAndComBox:(NSInteger)tag
{
    
}

-(void)closeAllTheComBoxView
{
    for(UIView *subView in self.view.subviews)
    {
        if([subView isKindOfClass:[LMComBoxView class]])
        {
            LMComBoxView *combox = (LMComBoxView *)subView;
            if(combox.isOpen)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    CGRect frame = combox.listTable.frame;
                    frame.size.height = 0;
                    [combox.listTable setFrame:frame];
                } completion:^(BOOL finished){
                    [combox.listTable removeFromSuperview];
                    combox.isOpen = NO;
                    combox.arrow.transform = CGAffineTransformRotate(combox.arrow.transform, DEGREES_TO_RADIANS(180));
                }];
            }
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeAllTheComBoxView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
