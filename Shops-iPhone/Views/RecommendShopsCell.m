//
//  RecommendShopsCell.m
//  Shops-iPhone
//
//  Created by xxy on 15/6/25.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "RecommendShopsCell.h"

// Common
#import "LibraryHeadersForCommonController.h"

#define kSpace 5
#define kCellHeight (kIsiPhone ? 170 : 300)
#define kBottomViewH (kIsiPhone ? 50 : 70)
#define kTitleH 20

@implementation RecommendShopsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)config:(recommendShopsModel *)recommendShopsModel
{
    [_bigImageView setImageWithURL:[NSURL URLWithString:recommendShopsModel.large_icon] placeholderImage:[UIImage imageNamed:@"default_image"]];
    
    // 计算每个模型中详细描素文字的高度
    NSDictionary *dict = [NSDictionary dictionary];
    if (kIsiPhone) {
        dict = @{NSFontAttributeName: [UIFont systemFontOfSize:kFontMidSize]};
    } else {
        dict = @{NSFontAttributeName: [UIFont systemFontOfSize:kFontSize]};
    }
    CGFloat labelHeight = [recommendShopsModel.short_desc boundingRectWithSize:CGSizeMake(kScreenWidth - kSpace * 2, CGFLOAT_MAX)
                                                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                    attributes:dict context:nil].size.height;
    
    if (labelHeight > kBottomViewH) {
        labelHeight = kBottomViewH;
    }
    
    // 计算下面view的高度（根据文字的内容）
    _bottomView.frame    = CGRectMake(kSpace, kCellHeight - labelHeight - kSpace * 2 - kTitleH, kScreenWidth - kSpace * 2, labelHeight + kTitleH + kSpace);
    
    // 计算标题Label
    _labelTitle.frame    = CGRectMake(kSpace * 2, kCellHeight - labelHeight - kSpace * 2 - kTitleH, kScreenWidth - kSpace * 2, kTitleH);
    _labelTitle.text     = recommendShopsModel.title;
    
    // 计算详细Label frame
    _labelDetail.frame   = CGRectMake(kSpace * 2, CGRectGetMaxY(_labelTitle.frame), kScreenWidth - kSpace * 2, labelHeight);
    _labelDetail.text    = recommendShopsModel.short_desc;
    
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellID  = @"recommendShop";
    
    RecommendShopsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[RecommendShopsCell alloc] init];
    }
    
    return cell;
}

// 重写初始化方法，给cell添加子控件
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self createSubViews];
    }
    
    return self;
}

/**
 *  创建cell的子控件
 */
- (void)createSubViews
{
    // 添加后面背景图片
    _bigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSpace, kSpace, kScreenWidth - kSpace * 2, kCellHeight - kSpace * 2)];
    
    [self.contentView addSubview:_bigImageView];
    
    // 添加下面半透明view
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor blackColor];
    _bottomView.alpha           = 0.4;
    
    [self.contentView addSubview:_bottomView];
    
    // 添加商铺名称Label
    _labelTitle = [[UILabel alloc] init];
    _labelTitle.textColor = [UIColor whiteColor];
    if (kIsiPhone) {
        _labelTitle.font = [UIFont boldSystemFontOfSize:kFontMidSize];
    } else {
        _labelTitle.font = [UIFont boldSystemFontOfSize:kFontSize];
    }
    
    [self.contentView addSubview:_labelTitle];
    
    // 添加商铺详细描素Label
    _labelDetail = [[UILabel alloc] init];
    _labelDetail.textColor     = [UIColor whiteColor];
    if (kIsiPhone) {
        _labelDetail.font = [UIFont boldSystemFontOfSize:kFontMidSize];
    } else {
        _labelDetail.font = [UIFont boldSystemFontOfSize:kFontSize];
    }
    _labelDetail.numberOfLines = 0;
    _labelTitle.lineBreakMode  = NSLineBreakByTruncatingTail;
    
    [self.contentView addSubview:_labelDetail];
    
}

@end
