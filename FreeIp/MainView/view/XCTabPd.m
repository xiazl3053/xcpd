//
//  XCTabPd.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/19.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "XCTabPd.h"
#import "XCButtonPd.h"

@implementation XCTabPd


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
    
    
    
    
    return self;
}

-(id)initWithArrayItem:(NSArray *)item frame:(CGRect)srcFrame
{
    self = [super initWithFrame:srcFrame];
    [self setBackgroundColor:RGB(57, 64, 66)];
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.frame];
//    [self addSubview:imgView];
//    [imgView setImage:[UIImage imageNamed:@"bar_bg"]];
    int nNumber=0;
    for (BtnInfo *bInfo in item)
    {
        UIView *view = [[UIView alloc] initWithFrame:Rect(0,64+100*nNumber, kTabbarWidth, 100)];
        XCButtonPd *xcBP = [[XCButtonPd alloc] initWithTbBtn:Rect(0, 15, kTabbarWidth, kTabbarWidth) nor:bInfo.strNorImg high:bInfo.strHighImg select:bInfo.strSelectImg title:bInfo.strTitle];
        [view addSubview:xcBP];
        xcBP.tag = 1000+nNumber;
        [xcBP addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        view.tag = 11000+nNumber;
        [self addSubview:view];
        nNumber ++;
    }
    return self;
}

-(void)clickBtn:(UIButton*)btn
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickView:index:)])
    {
        [_delegate clickView:btn index:btn.tag-1000];
    }
}


@end



@implementation BtnInfo

-(id)initWithItem:(NSArray *)item
{
    self = [super init];
    _strNorImg = item[0];
    _strHighImg = item[1];
    _strSelectImg = item[2];
    _strTitle = item[3];
    return self;
}

@end


