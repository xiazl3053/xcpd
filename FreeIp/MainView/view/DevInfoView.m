//
//  DevInfoView.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/20.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "DevInfoView.h"
#import "UIView+Extension.h"
#import "DeviceInfoModel.h"
#import "UIView+BlocksKit.h"
@implementation DevInfoView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self.layer setMasksToBounds:YES];
    self.layer.cornerRadius = 5.0f;
    XCDevLabel *lblName = [[XCDevLabel alloc] initWithFrame:Rect(21, 17,200, 16)];
    //50 16 17 17
    
    XCDevLabel *lblStatus = [[XCDevLabel alloc] initWithFrame:Rect(lblName.x, lblName.y+lblName.height+34,lblName.width,lblName.height)];
    
    XCDevLabel *lblType = [[XCDevLabel alloc] initWithFrame:Rect(lblStatus.x, lblStatus.y+lblStatus.height+34, lblName.width, lblName.height)];
    
    XCDevLabel *lblNO = [[XCDevLabel alloc] initWithFrame:Rect(lblType.x, lblType.y+lblType.height+34, lblName.width, lblName.height)];
    
    [lblName setText:XCLocalized(@"devName_info")];
    [lblStatus setText:XCLocalized(@"statu")];
    [lblType setText:XCLocalized(@"type")];
    [lblNO setText:XCLocalized(@"devNO")];
    
    [self addSubview:lblStatus];
    [self addSubview:lblType];
    [self addSubview:lblName];
    [self addSubview:lblNO];
    
    XCInfoLabel *inLblName = [[XCInfoLabel alloc] initWithFrame:Rect(self.width-350, lblName.y,300, 17)];
    XCInfoLabel *inLblStatus = [[XCInfoLabel alloc] initWithFrame:Rect(self.width-350, lblStatus.y,inLblName.width, inLblName.height)];
    XCInfoLabel *inLblType = [[XCInfoLabel alloc] initWithFrame:Rect(self.width-350, lblType.y,inLblName.width, inLblName.height)];
    XCInfoLabel *inLblNO = [[XCInfoLabel alloc] initWithFrame:Rect(self.width-350, lblNO.y,inLblName.width, inLblName.height)];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(inLblName.x+inLblName.width+15,inLblName.y, 8, 13)];
    [imgView setImage:[UIImage imageNamed:@"upd_Name"]];
    
    [self addSubview:imgView];
    [self addSubview:inLblName];
    [self addSubview:inLblType];
    [self addSubview:inLblNO];
    [self addSubview:inLblStatus];
    
    inLblName.tag = 6001;
    inLblStatus.tag = 6002;
    inLblType.tag = 6003;
    inLblNO.tag = 6004;
    
    [self addViewLine:49.5];
    [self addViewLine:99.5];
    [self addViewLine:149.5];

    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)]];
    
    return self;
}
     
     
-(void)tapEvent:(UITapGestureRecognizer*)sender
{
    CGPoint tapPoint = [sender locationInView:self];
    if(tapPoint.y<50&& tapPoint.x >300)
    {
          //修改设备名
        if(_delegate && [_delegate respondsToSelector:@selector(showUpdView)])
        {
            [_delegate showUpdView];
        }
    }
}

-(void)setDeviceInfo:(DeviceInfoModel*)devInfo
{
    [(UILabel*)[self viewWithTag:6001] setText:devInfo.strDevName];
    [(UILabel*)[self viewWithTag:6002] setText:devInfo.iDevOnline ? XCLocalized(@"online"):XCLocalized(@"offline")];
    [(UILabel*)[self viewWithTag:6003] setText:devInfo.strNewType];
    [(UILabel*)[self viewWithTag:6004] setText:devInfo.strDevNO];
}


-(void)addViewLine:(CGFloat)fHight
{
    UILabel *sLine3 = [[UILabel alloc] initWithFrame:CGRectMake(21, fHight, kScreenWidth, 0.1)];
    sLine3.backgroundColor = [UIColor colorWithRed:198/255.0
                                             green:198/255.0
                                              blue:198/255.0
                                             alpha:1.0];
    UILabel *sLine4 = [[UILabel alloc] initWithFrame:CGRectMake(21, fHight+0.5, kScreenWidth, 0.1)] ;
    sLine4.backgroundColor = [UIColor whiteColor];
    sLine3.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    sLine4.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:sLine3];
    [self addSubview:sLine4];
}

@end



@implementation XCDevLabel

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setFont:XCFONT(16)];
    [self setTextColor:RGB(48, 48, 48)];
    
    return self;
}

@end


@implementation XCInfoLabel

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setFont:XCFONT(16)];
    [self setTextColor:RGB(142, 142, 147)];
    [self setTextAlignment:NSTextAlignmentRight];
    return self;
}

@end