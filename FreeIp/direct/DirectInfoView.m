//
//  DirectInfoView.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "DirectInfoView.h"
#import "XCLabel.h"
#import "UIView+Extension.h"
#import "DirectTxtField.h"
#import "Toast+UIView.h"

@interface DirectInfoView()
{
    DirectTxtField *txtName;
    DirectTxtField *txtAddress;
    DirectTxtField *txtPort;
    DirectTxtField *txtUser;
    DirectTxtField *txtPwd;
    UISegmentedControl *segChannel;
    NSArray *aryChannel;
}
//@property (nonatomic,strong)
@end


@implementation DirectInfoView

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
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:5.0f];
    
    XCLabel *lblName = [[XCLabel alloc] initWithFrame:Rect(20,15, 150, 20)];
    XCLabel *lblAddress = [[XCLabel alloc] initWithFrame:Rect(20,65, 150, 20)];
    XCLabel *lblPort = [[XCLabel alloc] initWithFrame:Rect(20,115, 150, 20)];
    XCLabel *lblUser = [[XCLabel alloc] initWithFrame:Rect(20,165, 150, 20)];
    XCLabel *lblPwd = [[XCLabel alloc] initWithFrame:Rect(20,215, 150, 20)];
    XCLabel *lblChannel = [[XCLabel alloc] initWithFrame:Rect(20,265, 150, 20)];
    
    [lblName setText:XCLocalized(@"devName")];
    [lblAddress setText:XCLocalized(@"devAddr")];
    [lblPort setText:XCLocalized(@"devPort")];
    [lblUser setText:XCLocalized(@"devUser")];
    [lblPwd setText:XCLocalized(@"devPwd")];
    [lblChannel setText:@"通道数"];
    
    txtName = [[DirectTxtField alloc] initWithFrame:Rect(frame.size.width-300,15,280, 20)];
    txtAddress = [[DirectTxtField alloc] initWithFrame:Rect(frame.size.width-300,65,280, 20)];
    txtPort = [[DirectTxtField alloc] initWithFrame:Rect(frame.size.width-300,115,280, 20)];
    txtUser = [[DirectTxtField alloc] initWithFrame:Rect(frame.size.width-300,165,280, 20)];
    txtPwd = [[DirectTxtField alloc] initWithFrame:Rect(frame.size.width-300,215,280, 20)];
    aryChannel = [[NSArray alloc] initWithObjects:@"1",@"4",@"8",@"16",@"24", nil];
    segChannel = [[UISegmentedControl alloc] initWithItems:aryChannel];
    segChannel.frame = Rect(frame.size.width-300,260,280,30);
    segChannel.selectedSegmentIndex = 0;//设置默认选择项索引
    segChannel.segmentedControlStyle = UISegmentedControlStyleBezeled;
    
    [txtName setText:@"Device_1"];

    [self addSubview:lblName];
    
    [self addSubview:lblPort];
    [self addSubview:lblAddress];
    [self addSubview:lblUser];
    [self addSubview:lblPwd];
    [self addSubview:lblChannel];
    [self addSubview:txtName];
    [self addSubview:txtAddress];
    [self addSubview:txtPort];
    [self addSubview:txtUser];
    [self addSubview:txtPwd];
    [self addSubview:segChannel];
    
    [self addViewLine:49.5];
    [self addViewLine:99.5];
    [self addViewLine:149.5];
    [self addViewLine:199.5];
    [self addViewLine:249.5];
    
    [txtName becomeFirstResponder];
    _rtsp = [[RtspInfo alloc] init];
    return self;
}


-(void)addViewLine:(CGFloat)fHight
{
    UILabel *sLine3 = [[UILabel alloc] initWithFrame:CGRectMake(21, fHight, self.width-21, 0.1)];
    sLine3.backgroundColor = RGB(198, 198, 198);
    UILabel *sLine4 = [[UILabel alloc] initWithFrame:CGRectMake(21, fHight+0.5, self.width-21, 0.1)] ;
    sLine4.backgroundColor = [UIColor whiteColor];
    sLine3.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    sLine4.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:sLine3];
    [self addSubview:sLine4];
}




-(void)setDevType:(int)nType
{
    if(nType)
    {
        [segChannel setEnabled:NO forSegmentAtIndex:0];
        segChannel.selectedSegmentIndex = 1;
        [segChannel setEnabled:YES forSegmentAtIndex:1];
        [segChannel setEnabled:YES forSegmentAtIndex:2];
        [segChannel setEnabled:YES forSegmentAtIndex:3];
        [segChannel setEnabled:YES forSegmentAtIndex:4];
    }
    else
    {
        [segChannel setEnabled:YES forSegmentAtIndex:0];
        segChannel.selectedSegmentIndex = 0;
        [segChannel setEnabled:NO forSegmentAtIndex:1];
        [segChannel setEnabled:NO forSegmentAtIndex:2];
        [segChannel setEnabled:NO forSegmentAtIndex:3];
        [segChannel setEnabled:NO forSegmentAtIndex:4];
        
    }
}


-(BOOL)addDirect
{
    if ([txtName.text isEqualToString:@""]) {
        [self makeToast:XCLocalized(@"cameranull")];
        return NO;
    }
    if([txtAddress.text isEqualToString:@""])
    {
        [self makeToast:XCLocalized(@"devAddrNULL")];
        return NO;
    }
    if ([txtPort.text isEqualToString:@""]) {
        [self makeToast:XCLocalized(@"devPortNULL")];
        return NO;
    }
    _rtsp.strDevName = txtName.text;
    _rtsp.strAddress = txtAddress.text;
    _rtsp.nPort = [txtPort.text intValue];
    _rtsp.strUser = txtUser.text;
    _rtsp.strPwd = txtPwd.text;
    _rtsp.nChannel = [[aryChannel objectAtIndex:segChannel.selectedSegmentIndex] integerValue];
    return YES;
}




@end
