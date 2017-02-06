//
//  ProductListCell.m
//  Shops-iPhone
//
//  Created by xxy on 15/6/16.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "ProductListCell.h"

// Common
#import "LibraryHeadersForCommonController.h"

#define kSpace 5
#define kCellHeight 100
#define kSpaceDouble 10

@implementation ProductListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)config:(ProductListDetailModel *)productListDetailModel
{
    [self.productImageIcon setImageWithURL:[NSURL URLWithString:productListDetailModel.large_icon] placeholderImage:[UIImage imageNamed:@"default_image"]];
    
    self.productNameLabel.text   = productListDetailModel.name;

    self.productDetailLabel.text = productListDetailModel.subtitle;

    self.productPriceLabel.text  = [NSString stringWithFormat:@"￥%@",productListDetailModel.price];

    self.workOffLabel.text       = [NSString stringWithFormat:@"已售出: %@",productListDetailModel.sales_quantity];
    
    // 判断是否显示
    if ((![productListDetailModel.price isEqualToString:productListDetailModel.market_price]))
    {
        self.marketPriceView.hidden = NO;
        self.marketPriceLabel.text  = [NSString stringWithFormat:@"￥%@",productListDetailModel.market_price];
    }
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellID = @"productList";

    ProductListCell *cell   = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[ProductListCell alloc] init];
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
 创建cell的子控件
 */
- (void)createSubViews
{
    // 添加图标
    self.productImageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(kSpace, kSpaceDouble, kCellHeight - 2 * kSpaceDouble, kCellHeight - 2 * kSpaceDouble)];
    
    [self.contentView addSubview:self.productImageIcon];
    
    CGFloat labelX             = CGRectGetMaxX(self.productImageIcon.frame) + kSpaceDouble;

    // 添加商品名称
    self.productNameLabel      = [[UILabel alloc] initWithFrame:CGRectMake(labelX, kSpace, kScreenWidth - labelX, kSpaceDouble * 2)];
    self.productNameLabel.font = [UIFont boldSystemFontOfSize:15];
    
    [self.contentView addSubview:self.productNameLabel];
    
    // 添加详细标题
    self.productDetailLabel           = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(self.productNameLabel.frame), self.productNameLabel.bounds.size.width, kSpaceDouble + kSpace)];

    self.productDetailLabel.font      = [UIFont systemFontOfSize:12];
    self.productDetailLabel.textColor = [UIColor lightGrayColor];
    
    [self.contentView addSubview:self.productDetailLabel];
    
    // 添加售价
    self.productPriceLabel           = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(self.productDetailLabel.frame) + kSpace, kCellHeight - 2 * kSpaceDouble, kSpaceDouble * 2)];
    self.productPriceLabel.textColor = [UIColor orangeColor];
    self.productPriceLabel.font      = [UIFont boldSystemFontOfSize:15];
    
    [self.contentView addSubview:self.productPriceLabel];
    
    // 添以前的售价
    self.marketPriceLabel           = [[UILabel alloc] initWithFrame:CGRectMake(labelX + self.productPriceLabel.bounds.size.width - kSpaceDouble, CGRectGetMaxY(self.productDetailLabel.frame) + kSpace, kCellHeight - 2 * kSpaceDouble, kSpaceDouble * 2)];
    self.marketPriceLabel.textColor = [UIColor lightGrayColor];
    self.marketPriceLabel.font      = [UIFont systemFontOfSize:15];
    
    [self.contentView addSubview:self.marketPriceLabel];
    
    // 添加黑色的横行
    self.marketPriceView = [[UIView alloc] initWithFrame:CGRectMake(labelX + self.productPriceLabel.bounds.size.width - kSpaceDouble, CGRectGetMidY(self.marketPriceLabel.frame), kCellHeight - 4 * kSpaceDouble, 1.5)];
    self.marketPriceView.backgroundColor = [UIColor lightGrayColor];
    self.marketPriceView.hidden          = YES;
    
    [self.contentView addSubview:self.marketPriceView];
    
    // 添加已出售数量
    self.workOffLabel           = [[UILabel alloc] initWithFrame:CGRectMake(labelX, CGRectGetMaxY(self.productPriceLabel.frame) + kSpaceDouble, kScreenWidth - labelX, kSpaceDouble * 2)];
    self.workOffLabel.font      = [UIFont systemFontOfSize:12];
    self.workOffLabel.textColor = [UIColor colorWithRGBHex:0x4c4343];

    [self.contentView addSubview:self.workOffLabel];
}

@end
