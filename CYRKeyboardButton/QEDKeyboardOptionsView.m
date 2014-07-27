//
//  QEDKeyboardButtonsView.m
//  QED Solver
//
//  Created by Illya Busigin on 3/30/14.
//  Copyright (c) 2014 Cyrillian, Inc. All rights reserved.
//

#import "QEDKeyboardOptionsView.h"
#import "QEDKeyboardButton.h"



@interface QEDKeyboardOptionsView ()

@property (nonatomic, weak) QEDKeyboardButton *button;
@property (nonatomic, assign) QEDKeyboardButtonPosition position;
@property (nonatomic, strong) NSMutableArray *keyOptionRects;
@property (nonatomic, assign) NSInteger selectedInputIndex;

@end

@interface QEDKeyboardButton ()

@property (nonatomic, strong) UIImageView *buttonBubbleView;

@end

@implementation QEDKeyboardOptionsView

#pragma mark - Initialization & Setup

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectedInputIndex = 0;
    }

    return self;
}

- (instancetype)initWithKeyboardButton:(QEDKeyboardButton *)button
{
    QEDKeyboardOptionsView *keyboardButtonsView = [[QEDKeyboardOptionsView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    keyboardButtonsView.button = button;
    keyboardButtonsView.tintColor = button.tintColor;

    if (button.position != QEDKeyboardButtonPositionInner) {
        keyboardButtonsView.position = button.position;
    } else {
        // Determine the position
        CGFloat leftPadding = CGRectGetMinX(button.frame);
        CGFloat rightPadding = CGRectGetMaxX(button.superview.frame) - CGRectGetMaxX(button.frame);

        keyboardButtonsView.position = (leftPadding > rightPadding ? QEDKeyboardButtonPositionLeft : QEDKeyboardButtonPositionRight);
    }

    return keyboardButtonsView;
}

- (void)determineKeyGeometries
{
    CGRect keyRect = [self convertRect:self.button.frame fromView:self.button.superview];

    __block NSMutableArray *keyOptionRects = [NSMutableArray arrayWithCapacity:self.button.inputOptions.count];

    CGFloat offset = CGRectGetWidth(keyRect);
    CGFloat spacing = 6;
    __block CGRect optionRect = CGRectOffset(CGRectInset(keyRect, 0, 0.5), 0, -(CGRectGetHeight(keyRect) - 0.5 + 15));

    [self.button.inputOptions enumerateObjectsUsingBlock:^(NSString *option, NSUInteger idx, BOOL *stop) {

        [keyOptionRects addObject:[NSValue valueWithCGRect:optionRect]];

        // Offset the option rect
        switch (self.position) {
        case QEDKeyboardButtonPositionRight:
            optionRect = CGRectOffset(optionRect, +(offset + spacing), 0);
            break;

        case QEDKeyboardButtonPositionLeft:
            optionRect = CGRectOffset(optionRect, -(offset + spacing), 0);
            break;

        default:
            break;
        }
    }];

    self.keyOptionRects = keyOptionRects;
}

#pragma mark - UIView

- (void)didMoveToSuperview
{
    [self determineKeyGeometries];
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

#pragma mark - Gesture

- (void)updateSelectedInputIndexForPoint:(CGPoint)point
{
    __block NSInteger selectedInputIndex = NSNotFound;

    CGRect testRect = CGRectMake(point.x, point.y, 0, 0);

    CGPoint location = [self convertRect:testRect fromView:self.button.superview].origin;

    [self.keyOptionRects enumerateObjectsUsingBlock:^(NSValue *rectValue, NSUInteger idx, BOOL *stop) {
        CGRect keyRect = [rectValue CGRectValue];
        CGRect infiniteKeyRect = CGRectMake(CGRectGetMinX(keyRect), 0, CGRectGetWidth(keyRect), NSIntegerMax);
        infiniteKeyRect = CGRectInset(infiniteKeyRect, -3, 0);

        if (CGRectContainsPoint(infiniteKeyRect, location)) {
            selectedInputIndex = idx;
            *stop = YES;
        }
    }];

    if (self.selectedInputIndex != selectedInputIndex) {
        self.selectedInputIndex = selectedInputIndex;
        [self setNeedsDisplay];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGRect keyRect = [self convertRect:self.button.frame fromView:self.button.superview];

    TurtleBezierPath *path = nil;

    switch (self.position) {
    case QEDKeyboardButtonPositionRight: {
        path = [self rightOptionKeyboardPath];

        CGFloat translationX = 0, translationY = 0;

        translationX = CGRectGetMinX(keyRect) - 12;
        translationY = CGRectGetMinY(keyRect) + 10 - (CGRectGetHeight(path.bounds) - CGRectGetHeight(self.button.frame)) - 1;

        [path applyTransform:CGAffineTransformMakeTranslation(translationX, translationY)];
    } break;

    case QEDKeyboardButtonPositionLeft: {
        path = [self leftOptionKeyboardPath];

        CGFloat translationX = 0, translationY = 0;

        translationX = CGRectGetMaxX(keyRect) - CGRectGetWidth(path.bounds) + 15;
        translationY = CGRectGetMinY(keyRect) + 10 - (CGRectGetHeight(path.bounds) - CGRectGetHeight(self.button.frame)) - 1;

        [path applyTransform:CGAffineTransformMakeTranslation(translationX, translationY)];
    } break;

    default:
        break;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(context, CGSizeMake(0, 3), 10, [[UIColor colorWithWhite:0 alpha:0.2] CGColor]);

    // Draw the key options background
    [self.button.keyColor setFill];
    [path fill];

    // Stroke the key options border
    [[UIColor colorWithWhite:0 alpha:0.35] setStroke];
    [path stroke];

    [self drawInputOptions];
}

- (void)drawInputOptions
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(context, CGSizeZero, 0, [[UIColor clearColor] CGColor]);
    CGContextSaveGState(context);

    NSArray *inputOptions = self.button.inputOptions;

    [inputOptions enumerateObjectsUsingBlock:^(NSString *optionString, NSUInteger idx, BOOL *stop) {
        CGRect optionRect = [self.keyOptionRects[idx] CGRectValue];

        BOOL selected = (idx == self.selectedInputIndex);

        if (selected) {
            // Draw selection background
            UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:optionRect cornerRadius:4];

            [self.tintColor setFill];
            [roundedRectanglePath fill];
        }

        // Draw the text
        UIColor *stringColor = (selected ? [UIColor whiteColor] : self.button.keyTextColor);

        CGSize stringSize = [optionString sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:24.f]}];
        CGRect stringRect = CGRectMake(
            CGRectGetMidX(optionRect) - stringSize.width / 2, CGRectGetMidY(optionRect) - stringSize.height / 2, stringSize.width, stringSize.height);

        NSMutableParagraphStyle *p = [NSMutableParagraphStyle new];
        p.alignment = NSTextAlignmentCenter;

        NSAttributedString *attributedString = [[NSAttributedString alloc]
            initWithString:optionString
                attributes:
                    @{NSFontAttributeName : [UIFont systemFontOfSize:24.f], NSForegroundColorAttributeName : stringColor, NSParagraphStyleAttributeName : p}];
        [attributedString drawInRect:stringRect];
    }];

    CGContextRestoreGState(context);
}

- (TurtleBezierPath *)rightOptionKeyboardPath
{
    TurtleBezierPath *path = [TurtleBezierPath new];
    [path home];
    path.lineWidth = 0;
    path.lineCapStyle = kCGLineCapRound;
    
    
    CGRect keyRect = self.button.frame;
    keyRect = CGRectInset(keyRect, 0, 0.5);

    // 8px top/bottom
    // 16px side to side
    // 6px in between
    UIEdgeInsets insets = UIEdgeInsetsMake(8, 12, 8, 12);
    CGFloat margin = 7.f;
    CGFloat topArcRadius = 10.f;
    CGFloat bottomArcRadius = 5.f;

    CGFloat width = insets.left + insets.right;
    width += self.button.inputOptions.count * CGRectGetWidth(keyRect);
    width += margin * (self.button.inputOptions.count - 1);
    
    [path rightArc:topArcRadius turn:90]; // #1
    [path forward:width - 2 * topArcRadius]; // #2 top
    [path rightArc:topArcRadius turn:90]; // #3
    [path forward:CGRectGetHeight(keyRect) - 2 * topArcRadius + insets.top + insets.bottom]; // #4 right big
    [path rightArc:topArcRadius turn:90]; // #5
    [path forward:width -  2 * topArcRadius - CGRectGetWidth(keyRect) - insets.right]; // #6
    [path leftArc:topArcRadius turn:90]; // #7
    [path forward:CGRectGetHeight(keyRect) - (topArcRadius + bottomArcRadius) + margin]; // #8
    [path rightArc:bottomArcRadius turn:90]; // #9
    [path forward:CGRectGetWidth(keyRect) - 2 * bottomArcRadius]; // #10 bottom
    [path rightArc:bottomArcRadius turn:90]; // #11
    [path forward:CGRectGetHeight(keyRect) - bottomArcRadius]; // #12
    [path leftArc:topArcRadius turn:50]; // #13
    [path forward:6]; // #14
    [path rightArc:topArcRadius turn:50]; // #15
    [path forward:path.currentPoint.y]; // #16 left big
    

    return path;
}

- (TurtleBezierPath *)leftOptionKeyboardPath
{
    TurtleBezierPath *path = [TurtleBezierPath new];
    [path home];
    path.lineWidth = 0;
    path.lineCapStyle = kCGLineCapRound;
    
    CGRect keyRect = self.button.frame;
    keyRect = CGRectInset(keyRect, 0, 0.5);
    
    // 8px top/bottom
    // 16px side to side
    // 6px in between
    UIEdgeInsets insets = UIEdgeInsetsMake(8, 12, 8, 12);
    CGFloat margin = 7.f;
    CGFloat topArcRadius = 10.f;
    CGFloat bottomArcRadius = 5.f;
    
    CGFloat width = insets.left + insets.right;
    width += self.button.inputOptions.count * CGRectGetWidth(keyRect);
    width += margin * (self.button.inputOptions.count - 1);
    
    [path rightArc:topArcRadius turn:90]; // #1
    [path forward:width - 2 * topArcRadius]; // #2 top
    [path rightArc:topArcRadius turn:90]; // #3
    [path forward:CGRectGetHeight(keyRect) - 2 * topArcRadius + insets.top + insets.bottom - margin]; // #4 right big
    
    [path rightArc:2 * topArcRadius turn:50]; // #5
    [path forward:6]; // #6
    [path leftArc:topArcRadius turn:50]; // #7
    
    [path forward:CGRectGetHeight(keyRect) - (topArcRadius + bottomArcRadius) + margin]; // #8
    [path rightArc:bottomArcRadius turn:90]; // #9
    [path forward:CGRectGetWidth(keyRect) - 2 * bottomArcRadius]; // #10
    [path rightArc:bottomArcRadius turn:90]; // #11
    [path forward:CGRectGetHeight(keyRect) - (topArcRadius + bottomArcRadius) + margin]; // #12
    [path leftArc:topArcRadius turn:90]; // #13
    [path forward:path.currentPoint.x - topArcRadius]; // #14
    [path rightArc:topArcRadius turn:90]; // #15
    [path forward:path.currentPoint.y]; // #16 left big
    
    return path;
}

- (TurtleBezierPath *)innerKeyboardButtonPath
{
    TurtleBezierPath *path = [TurtleBezierPath new];
    [path home];
    path.lineWidth = 1.0f;
    path.lineCapStyle = kCGLineCapRound;

    [path rightArc:10 turn:90];
    [path forward:32]; // top
    [path rightArc:10 turn:90];
    [path forward:32]; // right big
    [path rightArc:10 turn:50];
    [path forward:3];
    [path leftArc:20 turn:50];
    [path forward:29];
    [path rightArc:5 turn:90];
    [path forward:16]; // bottom
    [path rightArc:5 turn:90];
    [path forward:29];
    [path leftArc:20 turn:50];
    [path forward:3];
    [path rightArc:10 turn:50];
    [path forward:32]; // left big

    return path;
}

@end
