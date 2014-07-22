//
//  CYRKeyboardButton.m
//  Example
//
//  Created by Guest User  on 7/19/14.
//  Copyright (c) 2014 Cyrillian, Inc. All rights reserved.
//

#import "CYRKeyboardButton.h"
#import "CYRKeyboardButtonView.h"

@interface CYRKeyboardButton () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *inputLabel;
@property (nonatomic, strong) CYRKeyboardButtonView *buttonView;
@property (nonatomic, strong) CYRKeyboardButtonView *expandedButtonView;

@property (nonatomic, assign) CYRKeyboardButtonPosition position;

// Input options state
@property (nonatomic, strong) UILongPressGestureRecognizer *optionsViewRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

// Internal style
@property (nonatomic, strong) UIColor *highlightedKeyColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat keyCornerRadius UI_APPEARANCE_SELECTOR;

@end

@implementation CYRKeyboardButton

#pragma mark - NSObject

+ (void)initialize
{
    if (self == [CYRKeyboardButton class]) {
        CYRKeyboardButton *keyboardButtonAppearance = [CYRKeyboardButton appearance];
        [keyboardButtonAppearance setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:24]];
        [keyboardButtonAppearance setInputOptionsFont:[UIFont systemFontOfSize:24.f]];
        [keyboardButtonAppearance setKeyColor:[UIColor whiteColor]];
        [keyboardButtonAppearance setKeyTextColor:[UIColor blackColor]];
        [keyboardButtonAppearance setKeyShadowColor:[UIColor colorWithRed:136 / 255.f green:138 / 255.f blue:142 / 255.f alpha:1]];
        [keyboardButtonAppearance setHighlightedKeyColor:[UIColor colorWithRed:213/255.f green:214/255.f blue:216/255.f alpha:1]];
    }
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _style = CYRKeyboardButtonStyleTablet;
        
        
        // Styling
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;
        
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        inputLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        inputLabel.textAlignment = NSTextAlignmentCenter;
        inputLabel.backgroundColor = [UIColor clearColor];
        inputLabel.userInteractionEnabled = NO;
        inputLabel.textColor = [[[self class] appearance] keyTextColor];
        inputLabel.font = [[[self class] appearance] font];
        
        [self addSubview:inputLabel];
        _inputLabel = inputLabel;
        
        // State handling
        [self addTarget:self action:@selector(_handleTouchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(_handleTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        
        [self updateDisplayStyle];
    }
    
    return self;
}

- (void)didMoveToSuperview
{
    [self updateButtonPosition];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // Only allow simulateous recognition with our internal recognizers
    return (gestureRecognizer == _panGestureRecognizer || gestureRecognizer == _optionsViewRecognizer) &&
    (otherGestureRecognizer == _panGestureRecognizer || otherGestureRecognizer == _optionsViewRecognizer);
}

#pragma mark - Overrides

- (void)setInput:(NSString *)input
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(input))];
    _input = input;
    [self didChangeValueForKey:NSStringFromSelector(@selector(input))];
    
    _inputLabel.text = _input;
}

- (void)setInputOptions:(NSArray *)inputOptions
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(inputOptions))];
    _inputOptions = inputOptions;
    [self didChangeValueForKey:NSStringFromSelector(@selector(inputOptions))];
    
    if (_inputOptions.count > 0) {
        [self setupInputOptionsConfiguration];
    } else {
        [self tearDownInputOptionsConfiguration];
    }
}

- (void)setStyle:(CYRKeyboardButtonStyle)style
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(style))];
    _style = style;
    [self didChangeValueForKey:NSStringFromSelector(@selector(style))];
    
    [self updateDisplayStyle];
}

#pragma mark - Internal Actions

- (void)showInputView
{
    if (_style == CYRKeyboardButtonStylePhone) {
        [self hideInputView];
        
        self.buttonView = [[CYRKeyboardButtonView alloc] initWithKeyboardButton:self type:CYRKeyboardButtonViewTypeInput];
        
        [self.window addSubview:self.buttonView];
    } else {
        [self setNeedsDisplay];
    }
    
}

- (void)showExpandedInputView:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.expandedButtonView == nil) {
            CYRKeyboardButtonView *expandedButtonView = [[CYRKeyboardButtonView alloc] initWithKeyboardButton:self type:CYRKeyboardButtonViewTypeExpanded];
            
            [self.window addSubview:expandedButtonView];
            self.expandedButtonView = expandedButtonView;
            
            [self hideInputView];
        }
    } else if (recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.panGestureRecognizer.state != UIGestureRecognizerStateRecognized) {
            [self _handleTouchUpInside];
        }
    }
}

- (void)hideInputView
{
    [self.buttonView removeFromSuperview];
    self.buttonView = nil;
    
    [self setNeedsDisplay];
}

- (void)hideExpandedInputView
{
    [self.expandedButtonView removeFromSuperview];
    self.expandedButtonView = nil;
}

- (void)updateDisplayStyle
{
    switch (_style) {
        case CYRKeyboardButtonStylePhone:
            _keyCornerRadius = 4.f;
            break;
            
        case CYRKeyboardButtonStyleTablet:
            _keyCornerRadius = 6.f;
            break;
            
        default:
            break;
    }
    
    [self setNeedsDisplay];
}

#pragma mark - Internal Configuration

- (void)updateButtonPosition
{
    // Determine the button sposition state based on the superview padding
    CGFloat leftPadding = CGRectGetMinX(self.frame);
    CGFloat rightPadding = CGRectGetMaxX(self.superview.frame) - CGRectGetMaxX(self.frame);
    CGFloat minimumClearance = CGRectGetWidth(self.frame) / 2 + 8;
    
    if (leftPadding >= minimumClearance && rightPadding >= minimumClearance) {
        self.position = CYRKeyboardButtonPositionInner;
    } else if (leftPadding > rightPadding) {
        self.position = CYRKeyboardButtonPositionLeft;
    } else {
        self.position = CYRKeyboardButtonPositionRight;
    }
}

- (void)setupInputOptionsConfiguration
{
    [self tearDownInputOptionsConfiguration];
    
    if (self.inputOptions.count > 0) {
        UILongPressGestureRecognizer *longPressGestureRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showExpandedInputView:)];
        longPressGestureRecognizer.minimumPressDuration = 0.3;
        longPressGestureRecognizer.delegate = self;
        
        [self addGestureRecognizer:longPressGestureRecognizer];
        self.optionsViewRecognizer = longPressGestureRecognizer;
        
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanning:)];
        panGestureRecognizer.delegate = self;
        
        [self addGestureRecognizer:panGestureRecognizer];
        self.panGestureRecognizer = panGestureRecognizer;
    }
}

- (void)tearDownInputOptionsConfiguration
{
    [self removeGestureRecognizer:self.optionsViewRecognizer];
    [self removeGestureRecognizer:self.panGestureRecognizer];
}

#pragma mark - Touch Actions

- (void)_handleTouchDown
{
    [[UIDevice currentDevice] playInputClick];
    
    [self showInputView];
}

- (void)_handleTouchUpInside
{
    [self.textInput insertText:self.input];
    
    [self hideInputView];
    [self hideExpandedInputView];
}

- (void)_handlePanning:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (self.expandedButtonView.selectedInputIndex != NSNotFound) {
            NSString *inputOption = self.inputOptions[self.expandedButtonView.selectedInputIndex];
            
            [self.textInput insertText:inputOption];
        }
        
        [self hideExpandedInputView];
    } else {
        CGPoint location = [recognizer locationInView:self.superview];
        [self.expandedButtonView updateSelectedInputIndexForPoint:location];
    };
}

#pragma mark - Touch Handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self hideInputView];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    [self hideInputView];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *color = self.keyColor;
    
    if (_style == CYRKeyboardButtonStyleTablet && self.state == UIControlStateHighlighted) {
        color = self.highlightedKeyColor;
    }
    
    UIColor *shadow = self.keyShadowColor;
    CGSize shadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat shadowBlurRadius = 0;
    
    UIBezierPath *roundedRectanglePath =
    [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 1) cornerRadius:self.keyCornerRadius];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [color setFill];
    [roundedRectanglePath fill];
    CGContextRestoreGState(context);
}

@end
