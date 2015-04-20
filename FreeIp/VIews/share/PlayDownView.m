//
//  PlayDownView.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "PlayDownView.h"
#import "XCButton.h"
#import "UserInfo.h"
#import "UIView+Extension.h"

@implementation PlayDownView

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
    image.image = [UIImage imageNamed:@"top_bg"];
    [self addSubview:image];
    image.tag = 10005;
//    [self setBackgroundColor:RGB(128, 128, 128)];

    _btnBD = [[XCButton alloc] initWithFrame:Rect(320, 0, 78, 67) normal:@"play_bd"];
    _btnHD =[[XCButton alloc] initWithFrame:Rect(420, 0, 78, 67) normal:@"play_hd"];
    _btnStop = [[XCButton alloc] initWithFrame:Rect(19, 11, 44, 44) normal:@"stop"];
    _btnCapture = [[XCButton alloc] initWithFrame:Rect(120,0, 78, 67) normal:@"capture" high:@"capture_h"];
    _btnRecord = [[XCButton alloc] initWithFrame:Rect(220, 0, 78, 67) normal:@"recording" high:@"recording_h" select:@"recording_h"];
    if ([UserInfo sharedUserInfo].bGuess ) {
        _btnBD.enabled = NO;
        _btnHD.enabled = NO;
        _btnCapture.enabled = NO;
        _btnRecord.enabled = NO;
    }
    [self addSubview:_btnRecord];
    [self addSubview:_btnStop];
    [self addSubview:_btnCapture];
    [self addSubview:_btnBD];
    [self addSubview:_btnHD];
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    UIImageView *imageView = (UIImageView *)[self viewWithTag:10005];
    imageView.frame = self.bounds;
    CGFloat fWidth = self.width/5;
    _btnStop.frame = Rect((fWidth-78)/2, 0, 78, 67);
    _btnCapture.frame = Rect(_btnStop.x+fWidth, 0, 78, 67);
    _btnRecord.frame = Rect(_btnCapture.x+fWidth, 0, 78, 67);
    _btnBD.frame = Rect(_btnRecord.x+fWidth, 0, 78, 67);
    _btnHD.frame = Rect(_btnBD.x+fWidth, 0, 78, 67);
}

@end
