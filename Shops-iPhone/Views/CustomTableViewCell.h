//
//  CustomTableViewCell.h
//  Shops-iPhone
//
//  Created by atyun on 14-11-6.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)UILabel *label; 


@end

