//
//  XCLabel.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "XCLabel.h"

@implementation XCLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame
{
    self= [super initWithFrame:frame];
    [self setTextColor:RGB(100, 100, 100)];
    [self setFont:XCFONT(16)];
    return self;
}
@end
