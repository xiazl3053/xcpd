//
//  XCUserInfoView.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/31.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "XCUserInfoView.h"
#import "DevInfoView.h"
#import "UIView+Extension.h"



@implementation XCUserInfoView

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
    [self.layer setMasksToBounds:YES];
    self.layer.cornerRadius = 5.0f;
    [self setBackgroundColor:[UIColor whiteColor]];
    
    XCDevLabel *lblPic = [[XCDevLabel alloc] initWithFrame:Rect(21, 40,200, 16)];
    XCDevLabel *lblNick = [[XCDevLabel alloc] initWithFrame:Rect(lblPic.x, 117 ,lblPic.width,lblPic.height)];
    XCDevLabel *lblPwd = [[XCDevLabel alloc] initWithFrame:Rect(lblNick.x, 167, self.width-42, lblNick.height)];
    
    [lblPic setText:XCLocalized(@"Useravatar")];
    [lblNick setText:XCLocalized(@"Nickname")];
    [lblPwd setText:XCLocalized(@"updpwding")];
    
    [self addSubview:lblPic];
    [self addSubview:lblNick];
    [self addSubview:lblPwd];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(frame.size.width-100, 17 , 66, 66)];
    [imgView.layer setMasksToBounds:YES];
    [imgView.layer setCornerRadius:33];
    
    XCInfoLabel *infoNick = [[XCInfoLabel alloc] initWithFrame:Rect(frame.size.width-350, lblNick.y,300, 20)];
    
    [self addViewLine:99];
    [self addViewLine:149];
    
    [self addSubview:imgView];
    [self addSubview:infoNick];
    
    [self addTag:43.5];
    [self addTag:118.5];
    [self addTag:168.5];
    
    lblPic.tag = 10001;
    lblNick.tag = 10002;
    lblPwd.tag = 10003;
    imgView.tag = 10004;
    infoNick.tag = 10005;
    
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)]];
    
    return self;
}

-(void)tapEvent:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:self];
    if (point.y> 10 && point.y < 100)
    {
         //修改头像
        if(_delegate && [_delegate respondsToSelector:@selector(userView:)])
        {
            [_delegate userView:1];
        }
    }
    else if(point.y>100 && point.y <150 )
    {
        if(_delegate && [_delegate respondsToSelector:@selector(userView:)])
        {
            [_delegate userView:2];
        }
    }
    else if(point.y > 150 && point.y <200)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(userView:)])
        {
            [_delegate userView:3];
        }
    }
}

-(void)addTag:(CGFloat)fHeight
{
    UIImageView *img1 = [[UIImageView alloc] initWithFrame:Rect(self.width-30,fHeight, 8, 13)];
    [img1 setImage:[UIImage imageNamed:@"upd_Name"]];
    [self addSubview:img1];
}

-(void)addViewLine:(CGFloat)fHight
{
    UILabel *sLine3 = [[UILabel alloc] initWithFrame:CGRectMake(21, fHight, self.frame.size.width, 0.2)];
    sLine3.backgroundColor = [UIColor colorWithRed:198/255.0
                                             green:198/255.0
                                              blue:198/255.0
                                             alpha:1.0];
    UILabel *sLine4 = [[UILabel alloc] initWithFrame:CGRectMake(21, fHight+0.2, self.frame.size.width, 0.2)] ;
    sLine4.backgroundColor = [UIColor whiteColor];
    sLine3.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    sLine4.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:sLine3];
    [self addSubview:sLine4];
    
}


-(void)setImgView:(NSString *)strImg
{
    __block NSString *__strImg = strImg;
    __weak UIView *__self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:__strImg]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [((UIImageView*)[__self viewWithTag:10004]) setImage:image];
        });
    });
}

-(void)setImageInfo:(UIImage *)image
{
    [((UIImageView*)[self viewWithTag:10004]) setImage:image];
}

-(void)setNickName:(NSString *)strNick
{
    [((XCInfoLabel*)[self viewWithTag:10005]) setText:strNick];
}

@end
