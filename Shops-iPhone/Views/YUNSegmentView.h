//
//  YUNSegmentView.h
//  Shops-iPhone
//
//  Created by Tsao Jiaxin on 15/7/10.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YUNSegmentViewDelegate <NSObject>

- (void)segmentButtonDidClick:(UIButton *)sender index:(NSInteger)index;

@end

@interface YUNSegmentView : UIView
/// 控件包含的标题
@property (nonatomic,strong) NSArray *titles;

/// 按钮对应的icon
@property (nonatomic,strong) NSArray *icons;

/// 本控件的delegate
@property (nonatomic,assign) NSObject<YUNSegmentViewDelegate> *delegate;

- (void)highlightButtonAtIndex:(NSInteger)index;

/**
 *  根据传入的参数初始化YUNSegmentView，将title填充为标题
 *
 *  @param frame View的尺寸
 *  @param title 要显示的标题(不定参数)
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)title icons:(NSArray *)icon ;
@end
