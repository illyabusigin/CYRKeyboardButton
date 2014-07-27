//
//  ViewController.m
//  Example
//
//  Created by Illya Busigin  on 7/19/14.
//  Copyright (c) 2014 Cyrillian, Inc. All rights reserved.
//

#import "ViewController.h"
#import "QEDKeyboardButton.h"
#import "CYRKeyboardButton.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSArray *keys = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"];
    
    UIInputView *numberView = [[UIInputView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 80) inputViewStyle:UIInputViewStyleKeyboard];
    
//    QEDKeyboardButton *aButton = [[QEDKeyboardButton alloc] initWithFrame:CGRectMake(95, 25, 60, 60) input:@"Q" inputOptions:@[@"A", @"B", @"C"]];
//    aButton.textInput = self.textField;
//    
//    [numberView addSubview:aButton];
    
//    QEDKeyboardButton *zButton = [[QEDKeyboardButton alloc] initWithFrame:CGRectMake(3 + (320 - 32), 5, 26, 40) input:@"P" inputOptions:@[@"A", @"B", @"C"]];
//    QEDKeyboardButton *tButton = [[QEDKeyboardButton alloc] initWithFrame:CGRectMake(3 + 128, 5, 26, 40) input:@"T" inputOptions:@[@"A", @"B", @"C"]];
//    
//    //[numberView addSubview:aButton];
//    [numberView addSubview:zButton];
//    [numberView addSubview:tButton];
    
    self.textField.inputAccessoryView = numberView;
    
    CYRKeyboardButton *newKeyboardButton = [[CYRKeyboardButton alloc] initWithFrame:CGRectMake(3, 5, 26, 40)];
    newKeyboardButton.input = @"Q";
    newKeyboardButton.textInput = self.textField;
    [numberView addSubview:newKeyboardButton];
    
    CYRKeyboardButton *newKeyboardButton2 = [[CYRKeyboardButton alloc] initWithFrame:CGRectMake(200, 5, 26, 40)];
    newKeyboardButton2.input = @"S";
    newKeyboardButton2.inputOptions = @[@"s", @"ß", @"ś", @"š"];
    newKeyboardButton2.textInput = self.textField;
    [numberView addSubview:newKeyboardButton2];
    
    CYRKeyboardButton *newKeyboardButton3 = [[CYRKeyboardButton alloc] initWithFrame:CGRectMake(291, 5, 26, 40)];
    newKeyboardButton3.input = @"P";
    newKeyboardButton3.textInput = self.textField;
    [numberView addSubview:newKeyboardButton3];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
