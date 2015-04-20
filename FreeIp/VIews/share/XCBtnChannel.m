//
//  XCBtnChannel.m
//  FreeIp
//
//  Created by 夏钟林 on 15/4/17.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "XCBtnChannel.h"

@implementation XCBtnChannel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(id)initWithFrame:(CGRect)frame  title:(NSString *)strTitle normal:(NSString *)strNorlmal
{
    self = [super initWithFrame:frame];
    
    [self setTitle:strTitle forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:strNorlmal] forState:UIControlStateNormal];
    self.titleLabel.font = XCFONT(14);
    [self setTitleColor:RGB(0, 0, 0) forState:UIControlStateNormal];
    
    return self;
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return Rect(71, 20, 80, 15);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return Rect(10, 7.5, 50, 40);
}

@end
