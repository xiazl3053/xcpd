//
//  XCHIddenView.m
//  FreeIp
//
//  Created by 夏钟林 on 15/4/17.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "XCHIddenView.h"

#import "XCBtnChannel.h"


#import "XCNotification.h"



@implementation XCHiddenView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



-(id)initWithFrame:(CGRect)frame number:(int)nNumber
{
    self = [super initWithFrame:frame];
    _scrolView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:_scrolView];
    
    CGFloat fWidth = 150;
    int i=0;
    while(i<nNumber)
    {
        NSString *strTitle = [NSString stringWithFormat:@"%@ %d",XCLocalized(@"channel"),i+1];
        XCBtnChannel *btnChannel =[[XCBtnChannel alloc] initWithFrame:Rect(50, i*kSonHomeListheight, fWidth, kSonHomeListheight) title:strTitle normal:@"smail_channel"];
        [_scrolView addSubview:btnChannel];
        btnChannel.tag = i;
        [btnChannel addTarget:self action:@selector(touchChannelEvent:) forControlEvents:UIControlEventTouchUpInside];
        i++;
    }
    _scrolView.contentSize = CGSizeMake(frame.size.width,nNumber*55);
    return self;
}


-(void)touchChannelEvent:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NS_CONNECT_DVR_CHANNEL_VC object:[NSNumber numberWithInteger:sender.tag]];
}

@end
