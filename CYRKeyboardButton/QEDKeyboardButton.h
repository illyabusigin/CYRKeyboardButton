//
//  QEDKeyboardButton.h
//  QED Solver
//
//  Created by Illya Busigin on 3/28/14.
//  Copyright (c) 2014 Cyrillian, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QEDKeyboardButtonPosition) {
    QEDKeyboardButtonPositionLeft,
    QEDKeyboardButtonPositionInner,
    QEDKeyboardButtonPositionRight,
    QEDKeyboardButtonPositionCount
};

@interface QEDKeyboardButton : UIControl <UIInputViewAudioFeedback>

@property (nonatomic, strong) UIFont *font UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *inputOptionsFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *keyColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *keyTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *keyShadowColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, readonly) QEDKeyboardButtonPosition position;
@property (nonatomic, strong) NSString *input;
@property (nonatomic, strong) NSArray *inputOptions;
@property (nonatomic, weak) id<UITextInput> textInput;

- (instancetype)initWithFrame:(CGRect)frame input:(NSString *)input;
- (instancetype)initWithFrame:(CGRect)frame input:(NSString *)input inputOptions:(NSArray *)inputOptions;

@end
