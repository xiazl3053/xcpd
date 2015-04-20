//
//  DirectAddView.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "DirectAddView.h"
#import "DirectInfoView.h"
#import "UIView+Extension.h"

@implementation DirectAddView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)createHeadView:(NSString *)strName
{
    UIView *view = [[UIView alloc] initWithFrame:Rect(0, 0, self.frame.size.width, 64)];
    [self addSubview:view];
    
    [view setBackgroundColor:RGB(15, 173, 225)];
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSave setTitle:XCLocalized(@"save") forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSave.frame = Rect(self.width-50, 20, 44,44);
    [btnSave addTarget:self action:@selector(saveInfo) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnSave];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(100, 30,self.width-200, 20)];
    [lblName setFont:XCFONT(20)];
    [lblName setTextColor:[UIColor whiteColor]];
    [lblName setText:strName];
    [view addSubview:lblName];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:XCLocalized(@"cancel") forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnCancel];
    btnCancel.frame = Rect(25, 20, 44,44);
}

-(void)closeView
{
//    self.hidden = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(closeDirectView)]) {
        [_delegate closeDirectView];
    }
}

-(void)saveInfo
{
    DirectInfoView *direct = ((DirectInfoView*)[self viewWithTag:10001]);
    if ([direct addDirect])
    {
        NSString *strType;
        UISegmentedControl* segControl = ((UISegmentedControl*)[self viewWithTag:10009]);
        switch(segControl.selectedSegmentIndex)
        {
        case 0:
                strType = @"IPC";
            break;
        case 1:
                strType = @"DVR";
                break;
            case 2:
                strType = @"NVR";
                break;
        default:
                strType = @"IPC";
            break;
        }
        direct.rtsp.strType = strType;
        if (_delegate && [_delegate respondsToSelector:@selector(addDirectView:)])
        {
            [_delegate addDirectView:direct.rtsp];
        }
    }
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self setBackgroundColor:RGB(246, 249, 250)];
    
    [self createHeadView:XCLocalized(@"addrtsp")];
    
    [self createBody];
    
    return self;
}

-(void)createBody
{

    NSArray *array = [[NSArray alloc] initWithObjects:@"IPC",@"DVR",@"NVR", nil];
    UISegmentedControl *segType = [[UISegmentedControl alloc]initWithItems:array];
    segType.frame = CGRectMake(23.0, 103, self.width-46, 30.0);
    segType.selectedSegmentIndex = 0;//设置默认选择项索引
    segType.segmentedControlStyle = UISegmentedControlStyleBezeled;
    segType.tag = 10009;
    [self addSubview:segType];
    
    [segType addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    DirectInfoView *directInfo = [[DirectInfoView alloc] initWithFrame:Rect(23, segType.y+segType.height+30, self.width-46, 300)];
    [self addSubview:directInfo];
    directInfo.tag = 10001;
    
}



-(void)segmentAction:(UISegmentedControl*)sender
{
    NSInteger Index = sender.selectedSegmentIndex;
    NSLog(@"Seg.selectedSegmentIndex:%d",Index);
   [((DirectInfoView*)[self viewWithTag:10001]) setDevType:Index];
}




@end
