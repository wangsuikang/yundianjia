//
//  LTableViewCell.m
//  tableview
//
//  Created by mac on 14-9-8.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "LTableViewCell.h"

@implementation LTableViewCell

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        // Initialization code
////        [self creatWithImage:NO];
//    }
//    return self;
//}

- (void)creatWithImage:(BOOL)hasImage{
    if (m_checkImageView == nil)
    {
        m_checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"admin_unselected"]];
        if (hasImage == NO)
        {
            m_checkImageView.frame = CGRectMake(20, 0, 0, 0);
        } else
        {
            m_checkImageView.frame = CGRectMake(60, 50, 50, 50);
        }
        [self addSubview:m_checkImageView];
    }
}



- (void)setChecked:(BOOL)checked{
    if (checked)
	{
		m_checkImageView.image = [UIImage imageNamed:@"admin_selected"];
		self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
	}
	else
	{
		m_checkImageView.image = [UIImage imageNamed:@"admin_unselected"];
		self.backgroundView.backgroundColor = [UIColor whiteColor];
	}
	m_checked = checked;
    
    
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
