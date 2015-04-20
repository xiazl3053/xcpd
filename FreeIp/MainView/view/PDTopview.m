//
//  PDTopview.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/25.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "PDTopview.h"

#import "UIView+Extension.h"

@implementation PDTopview

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
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:frame];
    [self addSubview:image];
    image.tag = 10005;
    image.image = [UIImage imageNamed:@"top_bg"];
    
    _btnSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_btnSwitch];
    [_btnSwitch setImage:[UIImage imageNamed:@"list_open"] forState:UIControlStateHighlighted];
    [_btnSwitch setImage:[UIImage imageNamed:@"list_open_h"] forState:UIControlStateNormal];
    
    _btnSinger = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_btnSinger];
    [_btnSinger setImage:[UIImage imageNamed:@"sing_play"] forState:UIControlStateHighlighted];
    [_btnSinger setImage:[UIImage imageNamed:@"sing_play_h"] forState:UIControlStateNormal];
    
    _btnFourer = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_btnFourer];
    [_btnFourer setImage:[UIImage imageNamed:@"four_play"] forState:UIControlStateHighlighted];
    [_btnFourer setImage:[UIImage imageNamed:@"four_play_h"] forState:UIControlStateNormal];
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    UIImageView *imageView = (UIImageView *)[self viewWithTag:10005];
    imageView.frame = self.bounds;
    _btnSwitch.frame = Rect(8,10,44, 44);
    _btnSinger.frame = Rect(self.width-128, 10, 44, 44);
    _btnFourer.frame = Rect(self.width-64, 10, 44, 44);
}

@end
