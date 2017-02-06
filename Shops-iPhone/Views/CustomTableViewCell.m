//
//  CustomTableViewCell.m
//  Shops-iPhone
//
//  Created by atyun on 14-11-6.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "CustomTableViewCell.h"

@interface CustomTableViewCell()

@end

@implementation CustomTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(19, 0, kScreenWidth - 19, 41)];
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.delegate = self;
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.backgroundColor = kClearColor;
        
        [self addSubview:_textField];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
