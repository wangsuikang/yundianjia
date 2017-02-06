//
//  UILabelWithLine.h
//  Shops-iPhone
//
//  Created by rujax on 2013-11-05.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSString+Tools.h"

typedef enum {
    PositionTop = 0,
    PositionCenter,
    PositionBottom
} PositionType;

@interface UILabelWithLine : UILabel

- (id)initWithFrame:(CGRect)frame position:(PositionType)position;

@end
