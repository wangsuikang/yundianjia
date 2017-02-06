//
//  YUNSegmentView.m
//  Shops-iPhone
//
//  Created by Tsao Jiaxin on 15/7/10.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "YUNSegmentView.h"
#import "YUNSegmentButton.h"
#import "ShopInfoNewController.h"

#define kBottomLineHeight 2.0
#define kOrange [UIColor colorWithRed:250/255.0 green:158/255.0 blue:68/255.0 alpha:1.0]
@interface YUNSegmentView()

/// 底部indicator
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, weak) UIButton *priceButton;

@end
@implementation YUNSegmentView
- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)title icons:(NSArray *)icon
{
    if (self = [super initWithFrame:frame]) {
        self.titles = title;
        self.icons = icon;
        UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height - kBottomLineHeight, frame.size.width * 1.0f / self.titles.count, kBottomLineHeight)];
        _bottomLine = bottomLine;
        [bottomLine setBackgroundColor:kOrange];
        [self createButtons];
        [self addSubview:bottomLine];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectPriceOrderDirectionNone) name:kJumpOutPriceOrderNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectPriceOrderDirectionLowToHigh) name:kPriceFromLowToHighNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectPriceOrderDirectionHighToLow) name:kPriceFromHighToLowNotification object:nil];

    }
    return self;
}

- (void)detectPriceOrderDirectionNone
{
    [[self.priceButton titleLabel] setText:@"价格排行"];
}

- (void)detectPriceOrderDirectionLowToHigh
{
    [[self.priceButton titleLabel] setText:@"从低到高"];
}

- (void)detectPriceOrderDirectionHighToLow
{
    [[self.priceButton titleLabel] setText:@"从高到低"];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  生成segment按钮
 */
- (void)createButtons
{
    self.buttons = [[NSMutableArray alloc] init];
    NSInteger count = self.titles.count;
    CGRect frame = self.frame;
    if (count) {
        for(int i = 0;i < count;i++){
            YUNSegmentButton *button = [[YUNSegmentButton alloc]initWithFrame:CGRectMake(i * 1.0f / count * self.frame.size.width, 0, 1.0f / count * self.frame.size.width, frame.size.height - kBottomLineHeight) icon:self.icons[i]];
            [self.buttons addObject:button];
            button.tag = i;
            [button setTitle:_titles[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:0.6 alpha:1] forState:UIControlStateNormal];
            [button setTitleColor:kOrange forState:UIControlStateHighlighted];
            [button setTitleColor:kOrange forState:UIControlStateSelected];
            [[button titleLabel]setFont:[UIFont fontWithName:@"Helvetica" size:14]];
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            if (i == 0) {
                [button setSelected:YES];
            }
            else if (i == 3){
                self.priceButton = button;
            }
        }
    }
}

- (void)highlightButtonAtIndex:(NSInteger)index
{
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)obj;
            [button setSelected:NO];
        }
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        _bottomLine.frame = CGRectMake(index * 1.0f / self.titles.count * self.frame.size.width, self.frame.size.height - kBottomLineHeight, self.frame.size.width * 1.0f / self.titles.count, kBottomLineHeight);
    }];
    [[self.buttons objectAtIndex:index] setSelected:YES];
}

/**
 segmentButton的点击事件回调
 
 @param sender 被点击的那个按钮
 */
- (void)buttonClick:(UIButton*)sender
{
    NSInteger index = sender.tag;

    if (self.delegate) {
        [self.delegate segmentButtonDidClick:sender index:index];
    }
    
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton*)obj;
                [button setSelected:NO];
            }
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        _bottomLine.frame = CGRectMake(index * 1.0f / self.titles.count * self.frame.size.width, self.frame.size.height - kBottomLineHeight, self.frame.size.width * 1.0f / self.titles.count, kBottomLineHeight);
    }];
    
    [sender setSelected:YES];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
