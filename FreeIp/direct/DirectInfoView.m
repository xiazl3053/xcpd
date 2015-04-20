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

@interface DirectInfoView()<UITextFieldDelegate>
{
    DirectTxtField *txtName;
    DirectTxtField *txtAddress;
    DirectTxtField *txtPort;
    DirectTxtField *txtUser;
    DirectTxtField *txtPwd;
    UISegmentedControl *segChannel;
    NSArray *aryChannel;
    XCLabel *lblPort;
    UITextField *_txtFieldView;
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
    lblPort = [[XCLabel alloc] initWithFrame:Rect(20,115, 150, 20)];
    XCLabel *lblUser = [[XCLabel alloc] initWithFrame:Rect(20,165, 150, 20)];
    XCLabel *lblPwd = [[XCLabel alloc] initWithFrame:Rect(20,215, 150, 20)];
    XCLabel *lblChannel = [[XCLabel alloc] initWithFrame:Rect(20,265, 150, 20)];
    
    [lblName setText:XCLocalized(@"devName")];
    [lblAddress setText:XCLocalized(@"devAddr")];
    [lblPort setText:XCLocalized(@"devPort")];
    [lblUser setText:XCLocalized(@"devUser")];
    [lblPwd setText:XCLocalized(@"devPwd")];
    [lblChannel setText:@"通道数"];
    CGFloat fWidth = frame.size.width ;
    txtName = [[DirectTxtField alloc] initWithFrame:Rect(200,0,fWidth-210,50)];
    txtAddress = [[DirectTxtField alloc] initWithFrame:Rect(txtName.x,50,txtName.width, 50)];
    txtPort = [[DirectTxtField alloc] initWithFrame:Rect(txtName.x,100,txtName.width, 50)];
    txtUser = [[DirectTxtField alloc] initWithFrame:Rect(txtName.x,150,txtName.width, 50)];
    txtPwd = [[DirectTxtField alloc] initWithFrame:Rect(txtName.x,200,txtName.width, 50)];
    aryChannel = [[NSArray alloc] initWithObjects:@"1",@"4",@"8",@"16",@"24", nil];
    segChannel = [[UISegmentedControl alloc] initWithItems:aryChannel];
    segChannel.frame = Rect(frame.size.width-300,260,280,30);
    segChannel.selectedSegmentIndex = 0;//设置默认选择项索引
    segChannel.segmentedControlStyle = UISegmentedControlStyleBezeled;
    
    [txtName setText:@"IPC_1"];

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
    txtPwd.delegate = self;
    
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
    
    if (nType == 1)
    {
        [lblPort setText:XCLocalized(@"dvrPort")];
        [txtName setText:@"DVR_1"];
    }
    else
    {
        [lblPort setText:XCLocalized(@"devPort")];
        if (nType == 2)
        {
            [txtName setText:@"NVR_1"];
        }
        else
        {
            [txtName setText:@"IPC_1"];
        }
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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == txtPwd)
    {
        
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDelay:0.5f];
        self.superview.frame = Rect(0, -50, self.superview.width, self.superview.height);
//        self.frame = CGRectMake(0.0f, -50, self.width, self.height);
        [UIView commitAnimations];
    }
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDelay:0.5f];
//        self.frame = CGRectMake(0.0f, 0, self.width, self.height);
        self.superview.frame = Rect(0, 0, self.superview.width, self.superview.height);
        [UIView commitAnimations];
}

//
//-(void)KeyboardWillShow:(NSNotification *)notification
//{
//    NSDictionary *info = [notification userInfo];
//    //获取高度
//    NSValue *value = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
//    /*关键的一句，网上关于获取键盘高度的解决办法，多到这句就over了。系统宏定义的UIKeyboardBoundsUserInfoKey等测试都不能获取正确的值。不知道为什么。。。*/
//    CGSize keyboardSize = [value CGRectValue].size;
//    if (_txtFieldView==nil)
//    {
//        return ;
//    }
//    CGFloat move = (_txtFieldView.y+_txtFieldView.height)-(self.height-keyboardSize.height);
//    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//    [UIView setAnimationDuration:0.30f];
//    
//    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
//    if(move > 0)
//    {
//        self.frame = CGRectMake(0.0f, -move, self.width, self.height);
//    }
//    [UIView commitAnimations];
//}
//
//-(void)KeyboardEditing:(NSNotification *)notification
//{
//    _txtFieldView = notification.object;
//}
//
//-(void)textFieldDidEndEditing:(UITextField *)textField
//{
//      if(self.y<0)
//      {
//          [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
//          [UIView setAnimationDuration:0.30f];
//          self.frame = CGRectMake(0.0f, 0, self.width, self.height);
//          [UIView commitAnimations];
//      }
//}
//


@end
