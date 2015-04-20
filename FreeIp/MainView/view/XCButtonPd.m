//
//  XCButtonPd.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/19.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "XCButtonPd.h"

#import "UIView+Extension.h"

@implementation XCButtonPd

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithTbBtn:(CGRect)frame nor:(NSString*)strNorImg high:(NSString*)strHighImg select:(NSString*)strSelectImg title:(NSString *)strTitle
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:9.0f];
        
        [self setTitle:strTitle forState:UIControlStateNormal];
        [self setTitleColor:RGB(146, 146, 146) forState:UIControlStateNormal];
        [self setTitleColor:RGB(15,173,225) forState:UIControlStateSelected];
        
        self.contentMode = UIViewContentModeScaleAspectFit;
        [self setImage:[UIImage imageNamed:strNorImg] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:strSelectImg] forState:UIControlStateSelected];
        [self setImage:[UIImage imageNamed:strHighImg] forState:UIControlStateHighlighted];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = XCFONT(14.0f);
    }
    return self;
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return Rect(0, 49,self.width,14);
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return Rect(14, 0, 44,44);
}

@end
