//
//  DirectTxtField.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "DirectTxtField.h"

@implementation DirectTxtField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self setTextColor:RGB(160, 160, 160)];
    [self setTextAlignment:NSTextAlignmentRight];
    [self setKeyboardType:UIKeyboardTypeASCIICapable];
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    [self setKeyboardAppearance:UIKeyboardAppearanceDark]
    return self;
}

@end
