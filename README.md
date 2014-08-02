# CYRKeyboardButton

[![Version](https://img.shields.io/cocoapods/v/CYRKeyboardButton.svg?style=flat)](https://github.com/illyabusigin/CYRKeyboardButton)
[![License](https://img.shields.io/cocoapods/l/CYRKeyboardButton.svg?style=flat)](https://github.com/illyabusigin/CYRKeyboardButton)
[![Platform](https://img.shields.io/cocoapods/p/CYRKeyboardButton.svg?style=flat)](https://github.com/illyabusigin/CYRKeyboardButton)

by **Illya Busigin**

- Visit my blog at [http://illyabusigin.com/](http://illyabusigin.com/)
- Follow [@illyabusigin on Twitter](http://twitter.com/illyabusigin)

Purpose
--------------

CYRKeyboardButton is a drop-in keyboard button that mimics the look, feel, and functionality of the native iOS keyboard buttons. When building QED Solver for iOS I needed to replicate the look and feel of the native keyboard buttons. CYRKeyboardButton aims to be the definitive keyboard button control for those looking to replicate the standard keyboard functionality. Features include:
- Ridiculously simple configuration
- UIAppearance protocol support
- Extended input options support
- Robust documentation


Screenshot
--------------
<img src="https://raw.github.com/illyabusigin/CYRKeyboardButton/master/Screenshots/CYRKeyboardButton.gif">


Requirements
-----------------------------

iOS 7.0 or later (**with ARC**) for iPhone, iPad and iPod touch


Installation
---------------

To use CYRKeyboardButton, just drag the class files into your project.. You can create CYRKeyboardButton instances programatically, or create them in Interface Builder by dragging an ordinary UIView into your view and setting its class to CYRKeyboardButton.

If you are using Interface Builder, to set the custom properties of CYRKeyboardButton (ones that are not supported by regular UIViews) either create an IBOutlet for your view and set the properties in code, or use the User Defined Runtime Attributes feature in Interface Builder (introduced in Xcode 4.2 for iOS 5+).

Usage
---------------

``` objective-c
CYRKeyboardButton *keyboardButton = [CYRKeyboardButton new];
keyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
keyboardButton.input = @"A";
keyboardButton.inputOptions = @[@"A", @"B", @"C", @"D"];
keyboardButton.textInput = self.textView;
[self.view addSubview:keyboardButton];
```

Example
---------------

CYRKeyboardButton includes an iPhone example project that demonstrates how to use CYRKeyboardButtons in an input accessory view with nifty autolayout sizing/spacing.

Bugs & Feature Requests
---------------

There is **no support** offered with this component. If you would like a feature or find a bug, please submit a feature request through the [GitHub issue tracker](http://github.com/illyabusigin/CYRKeyboardButton/issues).

Pull-requests for bug-fixes and features are welcome!

Attribution
--------------

CYRKeyboardButton uses portions of code from the following sources.

| Component     | Description   | License  |
| ------------- |:-------------:| -----:|
| [TurtleBezierPath](https://github.com/mindbrix/TurtleBezierPath)      | UIBezierPath subclass for Turtle Graphics | [MIT](https://github.com/mindbrix/TurtleBezierPath/blob/master/LICENSE) |
