//
//  LineSpaceLabel.h
//  Shops-iPhone
//
//  Created by rujax on 14-9-29.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineSpaceLabel : UILabel

@property (nonatomic, assign) CGFloat charSpace;
@property (nonatomic, assign) CGFloat lineSpace;

- (CGFloat)labelHight:(CGFloat)width;

@end
