//
//  CYRKeyboardButton.h
//  Example
//
//  Created by Guest User  on 7/19/14.
//  Copyright (c) 2014 Cyrillian, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CYRKeyboardButtonPosition) {
    CYRKeyboardButtonPositionLeft,
    CYRKeyboardButtonPositionInner,
    CYRKeyboardButtonPositionRight,
    CYRKeyboardButtonPositionCount
};

@interface CYRKeyboardButton : UIControl

// Styling
@property (nonatomic, strong) UIFont *font UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *inputOptionsFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *keyColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *keyTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *keyShadowColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, readonly) CYRKeyboardButtonPosition position;

// Configurable
@property (nonatomic, strong) NSString *input;
@property (nonatomic, strong) NSArray *inputOptions;
@property (nonatomic, weak) id<UITextInput> textInput;

@end
