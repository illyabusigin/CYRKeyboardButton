//
//  QEDKeyboardButton.m
//  QED Solver
//
//  Created by Illya Busigin on 3/28/14.
//  Copyright (c) 2014 Cyrillian, Inc. All rights reserved.
//

#import "QEDKeyboardButton.h"
#import "QEDKeyboardOptionsView.h"

#import "TurtleBezierPath.h"

@interface QEDKeyboardButton () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) QEDKeyboardButtonPosition position;
@property (nonatomic, assign) BOOL touching;

@property (nonatomic, strong) UILongPressGestureRecognizer *optionsViewRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) QEDKeyboardOptionsView *inputOptionsView;

@property (nonatomic, strong) UILabel *inputLabel;
@property (nonatomic, strong) UIImageView *buttonBubbleView;
@property (nonatomic, strong) UILabel *buttonBubbleLabel;

@end

@implementation QEDKeyboardButton

#pragma mark - NSObject

- (instancetype)initWithFrame:(CGRect)frame
{
    NSLog(@"<%@> %s Can only be initialized with the designated initializer. Returning nil!", NSStringFromClass([self class]), __PRETTY_FUNCTION__);

    return nil;
}

#pragma mark - Instantiation

+ (void)initialize
{
    if (self == [QEDKeyboardButton class]) {
        QEDKeyboardButton *keyboardButtonAppearance = [QEDKeyboardButton appearance];
        [keyboardButtonAppearance setFont:[UIFont fontWithName:@"STHeitiSC-Light" size:24]];
        [keyboardButtonAppearance setInputOptionsFont:[UIFont systemFontOfSize:24.f]];
        [keyboardButtonAppearance setKeyColor:[UIColor whiteColor]];
        [keyboardButtonAppearance setKeyTextColor:[UIColor blackColor]];
        [keyboardButtonAppearance setKeyShadowColor:[UIColor colorWithRed:136 / 255.f green:138 / 255.f blue:142 / 255.f alpha:1]];
    }
}

- (instancetype)initWithFrame:(CGRect)frame input:(NSString *)input
{
    return [[[self class] alloc] initWithFrame:frame input:input inputOptions:nil];
}

- (instancetype)initWithFrame:(CGRect)frame input:(NSString *)input inputOptions:(NSArray *)inputOptions
{
    self = [super initWithFrame:frame];

    if (self) {
        _touching = NO;

        // Styling
        self.layer.cornerRadius = 4;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;

        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

        // Setup defaults
        _position = QEDKeyboardButtonPositionInner;

        UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
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

        _input = input;
        _inputOptions = inputOptions;
        _inputLabel.text = input;
        _keyColor = [[[self class] appearance] keyColor];

        // Only add gesture recognizers if input options are present
        if (self.inputOptions.count > 0) {
            UILongPressGestureRecognizer *longPressGestureRecognizer =
                [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showInputOptions)];
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

    return self;
}

#pragma mark - Actions

- (void)_handleTouchDown
{
    _touching = YES;
    
    [[UIDevice currentDevice] playInputClick];

    [self.superview bringSubviewToFront:self];

    [self setNeedsDisplay];

    [self _updateButtonState];
}

- (void)_handleTouchUpInside
{
    [self.textInput insertText:self.input];
}

- (void)showInputOptions
{
    if (!self.inputOptionsView && self.inputOptions.count > 0) {
        [self.inputOptionsView removeFromSuperview];
        self.inputOptionsView = [[QEDKeyboardOptionsView alloc] initWithKeyboardButton:self];

        [self.window addSubview:self.inputOptionsView];

        self.optionsViewRecognizer.enabled = NO;
        self.buttonBubbleView.hidden = YES;
    }
}

- (void)hideInputOptions
{
    // Remove the buttons view if visible
    [self.inputOptionsView removeFromSuperview];
    self.inputOptionsView = nil;
    self.optionsViewRecognizer.enabled = YES;
}

- (void)_handlePanning:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        if (self.inputOptionsView.selectedInputIndex != NSNotFound) {
            NSString *inputOption = self.inputOptions[self.inputOptionsView.selectedInputIndex];

            [self.textInput insertText:inputOption];
        }

        [self _updateButtonState];
        [self hideInputOptions];
    } else {
        CGPoint location = [recognizer locationInView:self.superview];
        [self.inputOptionsView updateSelectedInputIndexForPoint:location];
    };
}

#pragma mark - Overrides

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    self.inputLabel.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));

    [self _updateButtonPosition];
    [self _updateButtonBubbleState];
}

- (void)setKeyColor:(UIColor *)keyColor
{
    _keyColor = keyColor;

    [self setNeedsDisplay];
}

- (void)setKeyTextColor:(UIColor *)keyTextColor
{
    _keyTextColor = keyTextColor;
    _inputLabel.textColor = keyTextColor;
}

- (void)setKeyShadowColor:(UIColor *)keyShadowColor
{
    _keyShadowColor = keyShadowColor;

    [self setNeedsDisplay];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> Frame: %@, Input: %@, Input Options: %@",
                                      NSStringFromClass([self class]),
                                      NSStringFromCGRect(self.frame),
                                      self.input,
                                      self.inputOptions];
}

#pragma mark - UIView

- (void)didMoveToSuperview
{
    [self _updateButtonPosition];
    [self _updateButtonBubbleState];
}

- (void)tintColorDidChange
{
    // Propogate the tint color to the input options view
    self.inputOptionsView.tintColor = self.tintColor;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

#pragma mark - Touch Handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];

    _touching = NO;

    [self setNeedsDisplay];
    [self _updateButtonState];

    self.panGestureRecognizer.enabled = NO;
    self.panGestureRecognizer.enabled = YES;

    [self hideInputOptions];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];

    _touching = NO;

    [self setNeedsDisplay];

    self.buttonBubbleLabel.hidden = !_touching;
    self.buttonBubbleView.hidden = !_touching;
    self.inputLabel.hidden = _touching;

    if (!self.inputOptionsView) {
        self.panGestureRecognizer.enabled = NO;
        self.panGestureRecognizer.enabled = YES;
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor *color = self.keyColor;

    //// Shadow Declarations
    UIColor *shadow = self.keyShadowColor;
    CGSize shadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat shadowBlurRadius = 0;

    //// Rounded Rectangle Drawing
    UIBezierPath *roundedRectanglePath =
        [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 1) cornerRadius:4];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [color setFill];
    [roundedRectanglePath fill];
    CGContextRestoreGState(context);
}

#pragma mark - Internal

- (void)_updateButtonState
{
    // Update states
    self.buttonBubbleLabel.hidden = !_touching;
    self.buttonBubbleView.hidden = !_touching;
    self.inputLabel.hidden = _touching;

    self.buttonBubbleLabel.textColor = self.keyTextColor;
}

- (void)_updateButtonPosition
{
    // Determine the button sposition state based on the superview padding
    CGFloat leftPadding = CGRectGetMinX(self.frame);
    CGFloat rightPadding = CGRectGetMaxX(self.superview.frame) - CGRectGetMaxX(self.frame);
    CGFloat minimumClearance = CGRectGetWidth(self.frame) / 2 + 8;

    if (leftPadding >= minimumClearance && rightPadding >= minimumClearance) {
        self.position = QEDKeyboardButtonPositionInner;
    } else if (leftPadding > rightPadding) {
        self.position = QEDKeyboardButtonPositionLeft;
    } else {
        self.position = QEDKeyboardButtonPositionRight;
    }
}

- (void)_updateButtonBubbleState
{
    // Clear out existing bubble state
    [self.buttonBubbleView removeFromSuperview];
    [self.buttonBubbleLabel removeFromSuperview];

    self.buttonBubbleView = nil;
    self.buttonBubbleLabel = nil;

    // Initialize the bubble label, setup properties
    self.buttonBubbleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, CGRectGetWidth(self.frame) + 13 * 2, 60)];
    self.buttonBubbleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:44];

    [self.buttonBubbleLabel setUserInteractionEnabled:NO];
    [self.buttonBubbleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.buttonBubbleLabel setBackgroundColor:[UIColor clearColor]];
    [self.buttonBubbleLabel setTextColor:self.keyTextColor];
    [self.buttonBubbleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.buttonBubbleLabel setText:self.input];

    // Create the right bubble image based on the button position
    switch (self.position) {
    case QEDKeyboardButtonPositionLeft: {
        self.buttonBubbleView = [[UIImageView alloc] initWithImage:[self createiOS7KeytopImageWithKind:QEDKeyboardButtonPositionLeft]];
        self.buttonBubbleView.frame = CGRectMake(-38, -72, self.buttonBubbleView.frame.size.width, self.buttonBubbleView.frame.size.height);
    } break;

    case QEDKeyboardButtonPositionInner: {
        self.buttonBubbleView = [[UIImageView alloc] initWithImage:[self createiOS7KeytopImageWithKind:QEDKeyboardButtonPositionInner]];
        self.buttonBubbleView.frame = CGRectMake(-28, -72, self.buttonBubbleView.frame.size.width, self.buttonBubbleView.frame.size.height);
    } break;

    case QEDKeyboardButtonPositionRight: {
        self.buttonBubbleView = [[UIImageView alloc] initWithImage:[self testKeyImage]];
        self.buttonBubbleView.frame = CGRectMake(-18, -72, self.buttonBubbleView.frame.size.width, self.buttonBubbleView.frame.size.height);
    } break;

    default:
        break;
    }

    // Configure the bubble image view shadow
    self.buttonBubbleView.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
    self.buttonBubbleView.layer.shadowOffset = CGSizeMake(0, 2.0);
    self.buttonBubbleView.layer.shadowOpacity = 0.30;
    self.buttonBubbleView.layer.shadowRadius = 3.0;
    self.buttonBubbleView.clipsToBounds = NO;

    // Update visibilty state
    self.buttonBubbleLabel.hidden = !_touching;
    self.buttonBubbleView.hidden = !_touching;

    // Add them to the view
    [self.buttonBubbleView addSubview:self.buttonBubbleLabel];
    [self addSubview:self.buttonBubbleView];
}

- (UIImage *)testKeyImage
{
    TurtleBezierPath *path = [TurtleBezierPath new];
    [path home];
    path.lineWidth = 0;
    path.lineCapStyle = kCGLineCapRound;
    
    
    CGRect keyRect = self.frame;
    keyRect = CGRectInset(keyRect, 0, 0.5);
    
    // 8px top/bottom
    // 16px side to side
    // 6px in between
    UIEdgeInsets insets = UIEdgeInsetsMake(8, 12, 8, 12);
    CGFloat margin = 7.f;
    CGFloat topArcRadius = 10.f;
    CGFloat bottomArcRadius = 5.f;
    
    CGFloat width = insets.left + insets.right;
    width += self.inputOptions.count * CGRectGetWidth(keyRect);
    width += margin * (self.inputOptions.count - 1);
    
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
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(context, CGSizeMake(0, 3), 10, [[UIColor colorWithWhite:0 alpha:0.2] CGColor]);
    
    // Draw the key options background
    [self.keyColor setFill];
    [path fill];
    
    // Stroke the key options border
    [[UIColor colorWithWhite:0 alpha:0.35] setStroke];
    [path stroke];
    
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown];
    CGImageRelease(imageRef);
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)createiOS7KeytopImageWithKind:(int)kind
{
    CGFloat __UPPER_WIDTH = ((CGRectGetWidth(self.frame) + 26) * [[UIScreen mainScreen] scale]);
    CGFloat __LOWER_WIDTH = (CGRectGetWidth(self.frame) * [[UIScreen mainScreen] scale]);

    CGFloat __PAN_UPPER_RADIUS = (10.0 * [[UIScreen mainScreen] scale]);
    CGFloat __PAN_LOWER_RADIUS = (5.0 * [[UIScreen mainScreen] scale]);

    CGFloat __PAN_UPPDER_WIDTH = (__UPPER_WIDTH - __PAN_UPPER_RADIUS * 2);
    CGFloat __PAN_UPPER_HEIGHT = (52.0 * [[UIScreen mainScreen] scale]);

    CGFloat __PAN_LOWER_WIDTH = (__LOWER_WIDTH - __PAN_LOWER_RADIUS * 2);
    CGFloat __PAN_LOWER_HEIGHT = (47.0 * [[UIScreen mainScreen] scale]);

    CGFloat __PAN_UL_WIDTH = ((__UPPER_WIDTH - __LOWER_WIDTH) / 2);

    CGFloat __PAN_MIDDLE_HEIGHT = (2.0 * [[UIScreen mainScreen] scale]);

    CGFloat __PAN_CURVE_SIZE = (10.0 * [[UIScreen mainScreen] scale]);

    CGFloat __PADDING_X = (15 * [[UIScreen mainScreen] scale]);
    CGFloat __PADDING_Y = (10 * [[UIScreen mainScreen] scale]);
    CGFloat __WIDTH = (__UPPER_WIDTH + __PADDING_X * 2);
    CGFloat __HEIGHT = (__PAN_UPPER_HEIGHT + __PAN_MIDDLE_HEIGHT + __PAN_LOWER_HEIGHT + __PADDING_Y * 2);

    CGMutablePathRef path = CGPathCreateMutable();

    CGPoint p = CGPointMake(__PADDING_X, __PADDING_Y);
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;

    p.x += __PAN_UPPER_RADIUS;
    CGPathMoveToPoint(path, NULL, p.x, p.y);

    p.x += __PAN_UPPDER_WIDTH;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);

    p.y += __PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL, p.x, p.y, __PAN_UPPER_RADIUS, 3.0 * M_PI / 2.0, 4.0 * M_PI / 2.0, false);

    p.x += __PAN_UPPER_RADIUS;
    p.y += __PAN_UPPER_HEIGHT - __PAN_UPPER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);

    p1 = CGPointMake(p.x, p.y + __PAN_CURVE_SIZE);
    switch (kind) {
    case QEDKeyboardButtonPositionLeft:
        p.x -= __PAN_UL_WIDTH * 2;
        break;

    case QEDKeyboardButtonPositionInner:
        p.x -= __PAN_UL_WIDTH;
        break;

    case QEDKeyboardButtonPositionRight:
        break;
    }

    p.y += __PAN_MIDDLE_HEIGHT + __PAN_CURVE_SIZE * 2;
    p2 = CGPointMake(p.x, p.y - __PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL, p1.x, p1.y, p2.x, p2.y, p.x, p.y);

    p.y += __PAN_LOWER_HEIGHT - __PAN_CURVE_SIZE - __PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);

    p.x -= __PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL, p.x, p.y, __PAN_LOWER_RADIUS, 4.0 * M_PI / 2.0, 1.0 * M_PI / 2.0, false);

    p.x -= __PAN_LOWER_WIDTH;
    p.y += __PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);

    p.y -= __PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL, p.x, p.y, __PAN_LOWER_RADIUS, 1.0 * M_PI / 2.0, 2.0 * M_PI / 2.0, false);

    p.x -= __PAN_LOWER_RADIUS;
    p.y -= __PAN_LOWER_HEIGHT - __PAN_LOWER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);

    p1 = CGPointMake(p.x, p.y - __PAN_CURVE_SIZE);

    switch (kind) {
    case QEDKeyboardButtonPositionLeft:
        break;

    case QEDKeyboardButtonPositionInner:
        p.x -= __PAN_UL_WIDTH;
        break;

    case QEDKeyboardButtonPositionRight:
        p.x -= __PAN_UL_WIDTH * 2;
        break;
    }

    p.y -= __PAN_MIDDLE_HEIGHT + __PAN_CURVE_SIZE * 2;
    p2 = CGPointMake(p.x, p.y + __PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL, p1.x, p1.y, p2.x, p2.y, p.x, p.y);

    p.y -= __PAN_UPPER_HEIGHT - __PAN_UPPER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);

    p.x += __PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL, p.x, p.y, __PAN_UPPER_RADIUS, 2.0 * M_PI / 2.0, 3.0 * M_PI / 2.0, false);
    //----
    CGContextRef context;
    UIGraphicsBeginImageContext(CGSizeMake(__WIDTH, __HEIGHT));
    context = UIGraphicsGetCurrentContext();

    switch (kind) {
    case QEDKeyboardButtonPositionLeft:
        CGContextTranslateCTM(context, 6.0, __HEIGHT);
        break;

    case QEDKeyboardButtonPositionInner:
        CGContextTranslateCTM(context, 0.0, __HEIGHT);
        break;

    case QEDKeyboardButtonPositionRight:
        CGContextTranslateCTM(context, -6.0, __HEIGHT);
        break;
    }
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetLineWidth(context, 0.25f);
    

    CGContextAddPath(context, path);
    
    // Stroke the key options border
    [[UIColor colorWithWhite:0 alpha:0.35] setStroke];
    
    
    CGContextClip(context);

    //----

    CGRect frame = CGPathGetBoundingBox(path);
    CGContextSetFillColorWithColor(context, [self.keyColor CGColor]);
    CGContextFillRect(context, frame);
    CGContextStrokePath(context);

    CGImageRef imageRef = CGBitmapContextCreateImage(context);

    UIImage *image = [UIImage imageWithCGImage:imageRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown];
    CGImageRelease(imageRef);

    UIGraphicsEndImageContext();

    CFRelease(path);

    return image;
}

@end
