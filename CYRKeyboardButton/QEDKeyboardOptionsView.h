//
//  QEDKeyboardButtonsView.h
//  QED Solver
//
//  Created by Illya Busigin on 3/30/14.
//  Copyright (c) 2014 Cyrillian, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TurtleBezierPath.h"

@class QEDKeyboardButton;

@interface QEDKeyboardOptionsView : UIView

@property (nonatomic, readonly) NSInteger selectedInputIndex;

- (instancetype)initWithKeyboardButton:(QEDKeyboardButton *)button;
- (void)updateSelectedInputIndexForPoint:(CGPoint)point;

@end
