//
//  XCTextField.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/17.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "XCTextField.h"

@implementation XCTextField

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self setTextColor:[UIColor whiteColor]];
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.layer setMasksToBounds:YES];
    self.layer.cornerRadius = 5.0f;
    self.layer.borderWidth = 1.0;
    UIView *leftView = [[UIView alloc] initWithFrame:Rect(0, 0, 10, frame.size.height)];
    self.leftView = leftView;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.leftViewMode = UITextFieldViewModeAlways;
    self.keyboardType = UIKeyboardTypePhonePad;
    return self;
}

@end
