//
//  XCDetailsView.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/31.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "XCDetailsView.h"
#import "DevInfoView.h"

#import "UIView+Extension.h"


@implementation XCDetailsView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self initBodyView];
    
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)]];
    return self;
}

-(void)initGesture
{
//    [[UITapGestureRecognizer alloc] initBodyView]
//    [self add]
}

-(void)tapEvent:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self];
    int ntype = 0;
    if(point.y<50)
    {
        ntype = 4;
    }
    else if(point.y>50)
    {
        ntype = 5;
    }
    if(_delegate && [_delegate respondsToSelector:@selector(updDetail:)])
    {
        [_delegate updDetail:ntype];
    }
}

-(void)initBodyView
{
    [self.layer setMasksToBounds:YES];
    self.layer.cornerRadius = 5.0f;
    [self setBackgroundColor:[UIColor whiteColor]];
    
    XCDevLabel *lblName = [[XCDevLabel alloc] initWithFrame:Rect(21, 17,200, 16)];
    XCDevLabel *lblEmail = [[XCDevLabel alloc] initWithFrame:Rect(lblName.x, lblName.y+lblName.height+34,lblName.width,lblName.height)];
    
    XCInfoLabel *infoName = [[XCInfoLabel alloc] initWithFrame:Rect(self.frame.size.width-350, lblName.y, 300, 20)];
    
    XCInfoLabel *infoEmail = [[XCInfoLabel alloc] initWithFrame:Rect(self.frame.size.width-350, lblEmail.y, 300, 20)];
    lblName.tag = 10001;
    lblEmail.tag = 10002;
    infoName.tag = 10003;
    infoEmail.tag = 10004;
    
    
    [lblEmail setText:XCLocalized(@"email")];
    [lblName setText:XCLocalized(@"RealName")];
    
    
    [self addSubview:lblName];
    
    [self addSubview:lblEmail];
    
    [self addSubview:infoName];
    
    [self addSubview:infoEmail];
    [self addViewLine:49.5];
    
    
    [self addTag:18.5];
    [self addTag:68.5];
    
}

-(void)setRealName:(NSString *)strName
{
    [((XCInfoLabel*)[self viewWithTag:10003]) setText:strName];
}

-(void)setEmail:(NSString *)strEmail
{
    [((XCInfoLabel *)[self viewWithTag:10004]) setText:strEmail];
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

-(void)addTag:(CGFloat)fHeight
{
    UIImageView *img1 = [[UIImageView alloc] initWithFrame:Rect(self.width-30,fHeight, 8, 13)];
    [img1 setImage:[UIImage imageNamed:@"upd_Name"]];
    [self addSubview:img1];
}


@end
