//
//  LineSpaceLabel.m
//  Shops-iPhone
//
//  Created by rujax on 14-9-29.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import "LineSpaceLabel.h"

#import <CoreText/CoreText.h>

@interface LineSpaceLabel()

@property (nonatomic, strong) NSMutableAttributedString *string;

@end

@implementation LineSpaceLabel

#pragma mark - Initialization -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _lineSpace = 5.0;
        _charSpace = 2.0;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _lineSpace = 5.0;
    _charSpace = 2.0;
}

- (void)initAttributedString
{
    if (!_string) {
        // 创建AttributeString
        _string = [[NSMutableAttributedString alloc] initWithString:self.text];
        
        // 设置字体及大小
        CTFontRef helveticaBold = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
        
        [_string addAttribute:(id)kCTFontAttributeName value:(__bridge id)helveticaBold range:NSMakeRange(0, [_string length])];
        
        // 设置字间距
        if (_charSpace) {
            long number = _charSpace;
            
            CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &number);
            
            [_string addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0, [_string length])];
            
            CFRelease(num);
        }
        
        // 设置字体颜色
        [_string addAttribute:(id)kCTForegroundColorAttributeName value:(id)(self.textColor.CGColor) range:NSMakeRange(0, [_string length])];
        
        // 创建文本对齐方式
        CTTextAlignment alignment = kCTLeftTextAlignment;
        
        if (self.textAlignment == NSTextAlignmentCenter) {
            alignment = kCTCenterTextAlignment;
        }
        
        if (self.textAlignment == NSTextAlignmentRight) {
            alignment = kCTRightTextAlignment;
        }
        
        CTParagraphStyleSetting alignmentStyle;
        alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;
        alignmentStyle.valueSize = sizeof(alignment);
        alignmentStyle.value = &alignment;
        
        // 设置文本行间距
        CGFloat lineSpace = _lineSpace;
        
        CTParagraphStyleSetting lineSpaceStyle;
        lineSpaceStyle.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
        lineSpaceStyle.valueSize = sizeof(lineSpace);
        lineSpaceStyle.value = &lineSpace;
        
        // 设置文本段间距
        CGFloat paragraphSpacing = 5.0;
        
        CTParagraphStyleSetting paragraphSpaceStyle;
        paragraphSpaceStyle.spec = kCTParagraphStyleSpecifierParagraphSpacing;
        paragraphSpaceStyle.valueSize = sizeof(CGFloat);
        paragraphSpaceStyle.value = &paragraphSpacing;
        
        // 创建设置数组
        CTParagraphStyleSetting settings[] = {alignmentStyle, lineSpaceStyle, paragraphSpaceStyle};
        
        CTParagraphStyleRef style = CTParagraphStyleCreate(settings ,3);
        
        // 给文本添加设置
        [_string addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)style range:NSMakeRange(0, [_string length])];
        
        CFRelease(helveticaBold);
    }
}

#pragma mark - Getter & Setter -

-(void)setCharSpace:(CGFloat)charSpace
{
    _charSpace = charSpace;
    
    [self setNeedsDisplay];
}
-(void)setLineSpace:(CGFloat)lineSpace
{
    _lineSpace = lineSpace;
    
    [self setNeedsDisplay];
}

#pragma mark - Override -

-(void) drawTextInRect:(CGRect)requestedRect
{
    [self initAttributedString];
    
    // 排版
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_string);
    
    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
    
    CGPathAddRect(leftColumnPath, NULL ,CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    
    CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), leftColumnPath, NULL);
    
    // 翻转坐标系统（文本原来是倒的要翻转下）
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 画出文本
    CTFrameDraw(leftFrame, context);
    
    // 释放
    CGPathRelease(leftColumnPath);
    
    CFRelease(framesetter);
    
    UIGraphicsPushContext(context);
}

- (CGFloat)labelHight:(CGFloat)width
{
    [self initAttributedString];
    
    CGFloat total_height = 0.0;
    
    // string 为要计算高度的NSAttributedString
    if (_string != nil) {
        YunLog(@"self.text = %@", self.text);

        if ([self.text isEqualToString:@""]) {
            return 0.0;
        }
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_string);
        
        CGRect drawingRect = CGRectMake(0, 0, width, 100000.0);  // 这里的高要设置足够大
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathAddRect(path, NULL, drawingRect);
        
        CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0,0), path, NULL);
        
        CGPathRelease(path);
        
        CFRelease(framesetter);
        
        NSArray *linesArray = (NSArray *)CTFrameGetLines(textFrame);
        
        CGPoint origins[[linesArray count]];
        
        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
        
        // 最后一行line的原点y坐标
        CGFloat line_y = origins[[linesArray count] - 1].y;
        
        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        
        CTLineRef line = (__bridge CTLineRef)[linesArray objectAtIndex:[linesArray count] - 1];
        
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        total_height = 100000.0 - line_y + descent + 1; // +1为了纠正descent转换成int小数点后舍去的值
        
        CFRelease(textFrame);
    }
    
    return total_height;
}

@end
