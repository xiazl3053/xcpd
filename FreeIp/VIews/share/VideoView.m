//
//  VIdeoView.m
//  XCMonit_Ip
//
//  Created by 夏钟林 on 14/7/29.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "VideoView.h"
#import "UIView+Extension.h"
@interface VideoView()
{
    UIImageView *imgView;
}
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic,strong) UITapGestureRecognizer *doubleGesture;

@end

@implementation VideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:RGB(0, 0,0)];
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOnView)];
        _doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClickView)];
        _tapGesture.numberOfTapsRequired =1;
        _doubleGesture.numberOfTapsRequired = 2;

        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:_tapGesture];
        [self addGestureRecognizer:_doubleGesture];
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    if(imgView)
    {
        imgView.frame = Rect(20, self.height-30, 57, 15);
    }
}

-(void)setRecording:(BOOL)bHidden
{
    if(imgView && !bHidden)
    {
        [imgView removeFromSuperview];
        imgView = nil;
    }
    else
    {
        imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recording_start"]];
        [self addSubview:imgView];
    }
}

-(void)clickOnView
{
    if ([_delegate respondsToSelector:@selector(clickView:)])
    {
        [_delegate clickView:self];
    }
}
-(void)doubleClickView
{
    if ([_delegate respondsToSelector:@selector(doubleClickVideo:)])
    {
        [_delegate doubleClickVideo:self];
    }
}


@end
