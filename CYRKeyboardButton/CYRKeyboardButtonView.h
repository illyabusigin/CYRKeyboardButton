//
//  CYRKeyboardButtonView.h
//  Example
//
//  Created by Illya Busigin  on 7/19/14.
//  Copyright (c) 2014 Cyrillian, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CYRKeyboardButtonViewType) {
    CYRKeyboardButtonViewTypeInput,
    CYRKeyboardButtonViewTypeExpanded
};

@class CYRKeyboardButton;

@interface CYRKeyboardButtonView : UIView

@property (nonatomic, readonly) NSInteger selectedInputIndex;

- (instancetype)initWithKeyboardButton:(CYRKeyboardButton *)button type:(CYRKeyboardButtonViewType)type;
- (void)updateSelectedInputIndexForPoint:(CGPoint)point;

@end
