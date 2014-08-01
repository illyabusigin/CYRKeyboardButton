//
//  ViewController.m
//  Example
//
//  Created by Illya Busigin  on 7/19/14.
//  Copyright (c) 2014 Cyrillian, Inc. All rights reserved.
//

#import "ViewController.h"
#import "CYRKeyboardButton.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *keyboardButtons;
@property (nonatomic, strong) UIInputView *numberView;

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSArray *keys = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"];
    self.keyboardButtons = [NSMutableArray arrayWithCapacity:keys.count];
    
    self.numberView = [[UIInputView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 45) inputViewStyle:UIInputViewStyleKeyboard];
    
    [keys enumerateObjectsUsingBlock:^(NSString *keyString, NSUInteger idx, BOOL *stop) {
        CYRKeyboardButton *keyboardButton = [CYRKeyboardButton new];
        keyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
        keyboardButton.input = keyString;
        keyboardButton.inputOptions = @[@"A", @"B", @"C", @"D"];
        keyboardButton.textInput = self.textField;
        [self.numberView addSubview:keyboardButton];
        
        [self.keyboardButtons addObject:keyboardButton];
    }];
    
    [self updateConstraintsForOrientation:self.interfaceOrientation];
    
    self.textField.inputAccessoryView = self.numberView;
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateConstraintsForOrientation:toInterfaceOrientation];
}

#pragma mark - Constraint Management

- (void)updateConstraintsForOrientation:(UIInterfaceOrientation)orientation
{
    // Remove any existing constraints
    [self.numberView removeConstraints:self.numberView.constraints];
    
    // Create our constraints
    NSMutableDictionary *bindings = [NSMutableDictionary dictionary];
    NSMutableString *visualFormatConstants = [NSMutableString string];
    NSDictionary *metrics = nil;
    
    // Setup our metrics based on orientation
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        metrics = @{
                    @"margin" : @(3),
                    @"spacing" : @(6)
                    };
    } else {
        metrics = @{
                    @"margin" : @(22),
                    @"spacing" : @(5)
                    };
    }
    
    // Build the visual format string
    [self.keyboardButtons enumerateObjectsUsingBlock:^(CYRKeyboardButton *button, NSUInteger idx, BOOL *stop) {
        NSString *binding = [NSString stringWithFormat:@"keyboardButton%i", idx];
        [bindings setObject:button forKey:binding];
        
        if (idx == 0) {
            [visualFormatConstants appendString:[NSString stringWithFormat:@"H:|-margin-[%@]", binding]];
        } else if (idx < self.keyboardButtons.count - 1) {
            [visualFormatConstants appendString:[NSString stringWithFormat:@"-spacing-[%@]", binding]];
        } else {
            [visualFormatConstants appendString:[NSString stringWithFormat:@"-spacing-[%@]-margin-|", binding]];
        }
    }];
    
    // Apply horizontal constraints
    [self.numberView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormatConstants options:0 metrics:metrics views:bindings]];
    
    // Apply vertical constraints
    [bindings enumerateKeysAndObjectsUsingBlock:^(NSString *binding, id obj, BOOL *stop) {
        NSString *format = [NSString stringWithFormat:@"V:|-6-[%@]|", binding];
        [self.numberView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:bindings]];
    }];
    
    // Add width constraint
    [self.keyboardButtons enumerateObjectsUsingBlock:^(CYRKeyboardButton *button, NSUInteger idx, BOOL *stop) {
        if (idx > 0) {
            CYRKeyboardButton *previousButton = self.keyboardButtons[idx - 1];
            
            [self.numberView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:previousButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        }
    }];
}

@end
