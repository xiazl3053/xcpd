//
//  XCUpdView.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/26.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "XCUpdView.h"
#import "XCTextField.h"
#import "UIView+Extension.h"




@implementation XCUpdView

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
    UIButton *btnCansel= [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:btnCansel];
    [btnCansel setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [btnCansel setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [btnCansel setFrame:Rect(25, 20, 60, 20)];
    [btnCansel setTitle:XCLocalized(@"cancel") forState:UIControlStateNormal];
    [btnCansel setTitleColor:RGB(15, 173, 225) forState:UIControlStateNormal];
    [btnCansel addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [btnDone setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [btnDone setTitleColor:RGB(15,173,255) forState:UIControlStateNormal];
    [btnDone setTitle:XCLocalized(@"keyboardDone") forState:UIControlStateNormal];
    [self addSubview:btnDone];
    btnDone.frame = Rect(frame.size.width-75, 20, 60, 20);
    [btnDone addTarget:self action:@selector(goDone) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(90,20,frame.size.width-180, 20)];
    [lblName setFont:XCFONT(20.0)];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:lblName];
    lblName.tag = 10001;
    [lblName setTextColor:RGB(48, 48, 48)];
   
    UIView *view= [[UIView alloc] initWithFrame:Rect(0, 64, frame.size.width, frame.size.height-64)];
    [view setBackgroundColor:RGB(244, 244, 244)];
    [self addSubview:view];
    view.tag = 10089;
    
    _txtField = [[UITextField alloc] initWithFrame:Rect(40, 51, frame.size.width-80, 52)];
    UIView *leftView = [[UIView alloc] initWithFrame:Rect(0, 0, 20, 52)];
    _txtField.leftView = leftView;
    _txtField.keyboardType = UIKeyboardTypeDefault;
    _txtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _txtField.leftViewMode = UITextFieldViewModeAlways;
    _txtField.keyboardType = UIKeyboardTypePhonePad;
    [_txtField setFont:XCFONT(16.0)];
    [view addSubview:_txtField];
    [_txtField setBackgroundColor:[UIColor whiteColor]];
    [_txtField setTextColor:RGB(100, 100, 100)];
    
    UIView *leftView1 = [[UIView alloc] initWithFrame:Rect(0, 0, 20,52)];
    
    _txtNewPwd = [[UITextField alloc] initWithFrame:Rect(40, _txtField.y+_txtField.height+20, _txtField.width, _txtField.height)];
    [_txtNewPwd setFont:XCFONT(16)];
    _txtNewPwd.leftView = leftView1;
     _txtNewPwd.keyboardType = UIKeyboardTypeDefault;
     _txtNewPwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
     _txtNewPwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
     _txtNewPwd.leftViewMode = UITextFieldViewModeAlways;
     _txtNewPwd.keyboardType = UIKeyboardTypePhonePad;
     [_txtNewPwd setBackgroundColor:[UIColor whiteColor]];
     [_txtNewPwd setTextColor:RGB(100, 100, 100)];
    [_txtNewPwd setPlaceholder:XCLocalized(@"newpwd")];
    
    
    _txtConPwd = [[UITextField alloc] initWithFrame:Rect(40, _txtNewPwd.y+_txtNewPwd.height+20, _txtField.width, _txtField.height)];
    [_txtConPwd setFont:XCFONT(16)];
    
    UIView *leftView2 = [[UIView alloc] initWithFrame:Rect(0, 0, 20,52)];
    _txtConPwd.leftView = leftView2;
    _txtConPwd.keyboardType = UIKeyboardTypeDefault;
    _txtConPwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _txtConPwd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _txtConPwd.leftViewMode = UITextFieldViewModeAlways;
    _txtConPwd.keyboardType = UIKeyboardTypePhonePad;
    [_txtConPwd setBackgroundColor:[UIColor whiteColor]];
    [_txtConPwd setTextColor:RGB(100, 100, 100)];
    [_txtConPwd setPlaceholder:XCLocalized(@"confirmNewPwd")];
    return  self;
}

-(void)addPassword
{
    [[self viewWithTag:10089] addSubview:_txtNewPwd];
    [[self viewWithTag:10089] addSubview:_txtConPwd];
    _txtNewPwd.secureTextEntry = YES;
    _txtField.secureTextEntry = YES;
    _txtConPwd.secureTextEntry = YES;
}

-(void)closePassword
{
    _txtField.secureTextEntry = NO;
    [_txtNewPwd removeFromSuperview];
    [_txtConPwd removeFromSuperview];
}

-(void)txtSetDelegate:(id<UITextFieldDelegate>)delegate
{
    _txtField.delegate  = delegate;
}

-(void)setPlaceText:(NSString *)strPlace
{
    [_txtField setPlaceholder:strPlace];
}

-(void)setTitle:(NSString *)strTitle
{
    ((UILabel*)[self viewWithTag:10001]).text = strTitle;
}

-(void)goBack
{
    self.hidden = YES;
     if (_delegate && [_delegate respondsToSelector:@selector(closeView)]) {
        [_delegate closeView];
    }
}

-(void)goDone
{
    if (_delegate && [_delegate respondsToSelector:@selector(addDeviceInfo)]) {
        [_delegate addDeviceInfo];
    }
}




@end
