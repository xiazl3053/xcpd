//
//  XCVersionView.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/30.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "XCVersionView.h"

@implementation XCVersionView

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
    [self setBackgroundColor:RGB(244, 244, 244)];
   
    UIView *view = [[UIView alloc] initWithFrame:Rect(0, 0, frame.size.width, 64)];
    [self addSubview:view];
    
    UIImageView *imgViewBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_bg"]];
    [view addSubview:imgViewBack];
    imgViewBack.frame = view.bounds;
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(0, 20,frame.size.width, 20)];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    [lblName setText:XCLocalized(@"version")];
    [lblName setFont:XCFONT(20.0f)];
    [view addSubview:lblName];
    [lblName setTextColor:[UIColor blackColor]];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(frame.size.width/2-120, 200, 240, 240)];
    [imgView setImage:[UIImage imageNamed:@"version"]];
    
    [self addSubview:imgView];
    
    UILabel *lblVersion = [[UILabel alloc] initWithFrame:Rect(0, imgView.frame.size.height+imgView.frame.origin.y+20, frame.size.width
                                                              , 20)];
    [self addSubview:lblVersion];
    NSString *strVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *strInfo = [NSString stringWithFormat:@"V%@",strVersion];
    [lblVersion setText:strInfo];
    [lblVersion setFont:XCFONT(20.0f)];
    [lblVersion setTextAlignment:NSTextAlignmentCenter];

    UIButton *btnCheck = [UIButton buttonWithType: UIButtonTypeCustom];
    [self addSubview:btnCheck];
    
    [btnCheck setTitle:@"版本检测..." forState:UIControlStateNormal];
    btnCheck.frame = Rect(50, lblVersion.frame.origin.y+50, frame.size.width-100, 45);
    [btnCheck setBackgroundColor:RGB(234,98,84)];
    btnCheck.titleLabel.font = XCFONT(17);
    [btnCheck addTarget:self action:@selector(touchEvent:) forControlEvents:UIControlEventTouchUpInside];
    [btnCheck.layer setMasksToBounds:YES];
    btnCheck.layer.cornerRadius = 5.0f;
    return self;
}

-(void)touchEvent:(UIButton *)sender
{
    if(_delegate)
    {
        [_delegate requestVersion];
    }
}

@end
