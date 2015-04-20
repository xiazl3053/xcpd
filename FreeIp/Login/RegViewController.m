//
//  RegViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/31.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "RegViewController.h"
#import "XCTextField.h"
#import "RegisterAuthCode.h"
#import "UIView+Extension.h"
#import "Toast+UIView.h"
#import "XCNotification.h"
#import "UtilsMacro.h"
#import "IQKeyboardManager.h"
#import "ProgressHUD.h"


@interface RegViewController ()<UITextFieldDelegate>
{
    UIImageView *imgView;
    CGFloat fWidth,fHeight;
    RegisterAuthCode *regService;
    UITextField *txtTemp;
}
@property (nonatomic,strong) XCTextField *txtUsername;

@property (nonatomic,strong) XCTextField *txtPwd;

@property (nonatomic,strong) XCTextField *txtAuthPwd;

@property (nonatomic,strong) XCTextField *txtAuthCode;

@property (nonatomic,strong) UIImageView *imgCode;

@property (nonatomic,strong) NSString *strAuthCode16;

@property (nonatomic,assign) BOOL bError;

@property (nonatomic,assign) BOOL bPwdLength;

@property (nonatomic,assign) BOOL bPwd;

@end

@implementation RegViewController


-(void)initViewInfo
{
    if (IOS_SYSTEM_8) {
        fWidth = kScreenSourchWidth;
        fHeight = kScreenSourchHeight;
    }
    else
    {
        fWidth = kScreenSourchHeight;
        fHeight = kScreenSourchWidth;
    }
    
    imgView = [[UIImageView alloc] initWithFrame:Rect(0,0,fWidth,fHeight)];
    [self.view addSubview:imgView];
    [imgView setImage:[UIImage imageNamed:@"login_bg"]];
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(fWidth/2-kTextfieldWidth/2,130,150, 30)];
    [lblName setText:XCLocalized(@"RegisterView")];
    [lblName setTextColor:[UIColor whiteColor]];
    [lblName setFont:XCFONT(25)];
    [self.view addSubview:lblName];
    
    UILabel *lblContent = [[UILabel alloc] initWithFrame:Rect(lblName.x,lblName.y+lblName.height+15, kTextfieldWidth, 1)];
    [lblContent setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:lblContent];
    
    _txtUsername = [[XCTextField alloc] initWithFrame:Rect(lblContent.x,lblContent.y+lblContent.height+29, kTextfieldWidth, 51.5)];
    [self.view addSubview:_txtUsername];
    _txtPwd = [[XCTextField alloc] initWithFrame:Rect(_txtUsername.x,_txtUsername.y+_txtUsername.height+20, _txtUsername.width, _txtUsername.height)];
    [self.view addSubview:_txtPwd];
    
    _txtAuthPwd = [[XCTextField alloc] initWithFrame:Rect(_txtPwd.x,_txtPwd.y+_txtPwd.height+20, _txtPwd.width, _txtPwd.height)];
    [self.view addSubview:_txtAuthPwd];
    
    _txtAuthCode = [[XCTextField alloc] initWithFrame:Rect(_txtAuthPwd.x,_txtAuthPwd.y+_txtAuthPwd.height+20, _txtAuthPwd.width-100, _txtPwd.height)];
    [self.view addSubview:_txtAuthCode];
    
    _imgCode = [[UIImageView alloc] initWithFrame:Rect(_txtAuthCode.x+_txtAuthCode.width+1, _txtAuthCode.y,100, _txtAuthCode.height)];
    [self.view addSubview:_imgCode];
    [_imgCode.layer setMasksToBounds:YES];
    _imgCode.layer.cornerRadius = 5.0f;
    
    _txtPwd.delegate = self;
    _txtUsername.delegate = self;
    _txtAuthPwd.delegate = self;
    _txtAuthCode.delegate = self;
    
    _txtPwd.tag = 10002;
    _txtUsername.tag = 10001;
    _txtAuthPwd.tag = 10003;
    _txtAuthCode.tag = 10004;
    
    UIButton *btnReg = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnReg addTarget:self action:@selector(authRegServer) forControlEvents:UIControlEventTouchUpInside];
    [btnReg setTitle:XCLocalized(@"RegisterView") forState:UIControlStateNormal];
    UIColor *orange = RGB(225, 183, 15);
    [btnReg setBackgroundColor:orange];
 //   [btnReg setBackgroundColor:orange];
    [btnReg setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel addTarget:self action:@selector(navBack) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setTitle:XCLocalized(@"cancel") forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel setBackgroundColor:orange];
    btnReg.titleLabel.font = XCFONT(17);
    btnCancel.titleLabel.font = XCFONT(17);
    
    [self.view addSubview:btnReg];
    [self.view addSubview:btnCancel];
    btnReg.frame = Rect(_txtAuthCode.x, _txtAuthCode.y+_txtAuthCode.height+20, 151 , 47);
    btnCancel.frame = Rect(_txtPwd.x+_txtPwd.width-151, btnReg.y, 151, 47);
    
    UIColor *color = [UIColor whiteColor];
    
    _txtUsername.attributedPlaceholder = [[NSAttributedString alloc] initWithString:XCLocalized(@"regUser") attributes:@{NSForegroundColorAttributeName: color}];
    _txtPwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:XCLocalized(@"Loginpwd") attributes:@{NSForegroundColorAttributeName: color}];
    _txtAuthPwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:XCLocalized(@"LoginpwdAgain") attributes:@{NSForegroundColorAttributeName: color}];
    _txtAuthCode.attributedPlaceholder = [[NSAttributedString alloc] initWithString:XCLocalized(@"RegiAuth") attributes:@{NSForegroundColorAttributeName: color}];
    [_txtPwd setSecureTextEntry:YES];
    [_txtAuthPwd setSecureTextEntry:YES];
    
    
    regService = [[RegisterAuthCode alloc] init];
    __weak RegViewController *__self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [__self authCodeFresh];
    });
    
}

-(void)authCodeFresh
{
    __weak RegViewController *__self =self;
    regService.httpBlock = ^(NSString *strImg, int nStatus)
    {
        switch (nStatus)
        {
            case 1:
            {
                __self.strAuthCode16 = strImg;
                NSString *strUrl = [[NSString alloc] initWithFormat:@"%@class/yzm2/phone_yzm.php?captchacheck=%@",
                                    XCLocalized(@"httpserver"),strImg];
                NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
                UIImage *image=[UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __self.imgCode.image = image;
                });
            }
            break;
            default:
            {
                __self.strAuthCode16 = @"";
            }
            break;
        }
    };
    [regService requestAuthCode];
}

-(void)navBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViewInfo];
                                                      
    // Do any additional setup after loading the view.
}

-(void)regThread
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyBoard) name:NSKEY_BOARD_RETURN_VC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)closeKeyBoard
{
    if ([_txtUsername isFirstResponder]) {
        [_txtUsername resignFirstResponder];
    }
    else if([_txtPwd isFirstResponder])
    {
        [_txtPwd resignFirstResponder];
    }
    else if([_txtAuthPwd isFirstResponder])
    {
        [_txtAuthPwd resignFirstResponder];
    }
    else
    {
        [_txtAuthCode resignFirstResponder];
    }
}

-(void)KeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    //获取高度
    NSValue *value = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    /*关键的一句，网上关于获取键盘高度的解决办法，多到这句就over了。系统宏定义的UIKeyboardBoundsUserInfoKey等测试都不能获取正确的值。不知道为什么。。。*/
    CGSize keyboardSize = [value CGRectValue].size;
    if (txtTemp==nil)
    {
        return ;
    }
    CGFloat move = (txtTemp.y+txtTemp.height)-(fHeight-keyboardSize.height);
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.30f];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(move > 0)
    {
        self.view.frame = CGRectMake(0.0f, -move, self.view.width, self.view.height);
    }
    [UIView commitAnimations];
}

-(void)KeyboardEditing:(NSNotification *)notification
{
    txtTemp = notification.object;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 重力感应
-(BOOL)shouldAutorotate
{
    return  YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(self.view.y<0)
    {
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:0.30f];
        self.view.frame = CGRectMake(0.0f, 0, self.view.width, self.view.height);
        [UIView commitAnimations];
    }
    if(textField.tag==10001)
    {
        //账号检测
        if ([_txtUsername.text isEqualToString:@""])
        {
            return ;
        }
        __weak RegViewController *__self = self;
        if (![DecodeJson validateEmail:_txtUsername.text])
        {
            dispatch_async(dispatch_get_main_queue(),
            ^{
                [__self.view makeToast:XCLocalized(@"emailError")];
                __self.bError = NO;
            });
            return ;
        }
        
        //authUser
        
        dispatch_async(dispatch_get_global_queue(0, 0),
       ^{
           [__self usernameAuth];
       });
    }
    else if(textField.tag==10003)
    {
        if(![_txtPwd.text isEqualToString:_txtAuthPwd.text])
        {
            _bPwd = NO;
            __weak RegViewController *__self = self;
            dispatch_async(dispatch_get_main_queue(),
            ^{
                [__self.view makeToast:XCLocalized(@"TwoPwd")];
            });
            return;
        }
        _bPwd = YES;
    }
    else if(textField.tag == 10002)
    {
        if ([_txtPwd.text length]<6)
        {
            _bPwdLength = NO;
            __weak RegViewController *__self = self;
            dispatch_async(dispatch_get_main_queue(),
            ^{
                 [__self.view makeToast:XCLocalized(@"pwdLength")];
            });
        }
        else
        {
            _bPwdLength = YES;
        }
    }
}


-(void)usernameAuth
{
    __weak RegViewController *__self =self;
    if([_txtUsername.text length] > kUSER_INFO_MAX_LENGTH)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [__self.view makeToast:XCLocalized(@"regThan64")];
        });
    }
    if(regService)
    {
        regService.httpAuthBlock = ^(int nStatus)
        {
            if(nStatus!=1)
            {
                [__self.view makeToast:XCLocalized(@"UsernameAlready")];
                __self.bError = NO;
            }else
            {
                __self.bError = YES;
            }
        };
        [regService requestAuthUsername:_txtUsername.text];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag==10001)
    {
        //下一个
        [_txtPwd becomeFirstResponder];
    }
    else if(textField.tag == 10002)
    {
        [_txtAuthPwd becomeFirstResponder];
    }
    else if(textField.tag == 10003)
    {
        [_txtAuthCode becomeFirstResponder];
    }
    else
    {
        [_txtAuthCode resignFirstResponder];
    }
    return YES;
}


-(void)authRegServer
{
    if ([_strAuthCode16 isEqualToString:@""])
    {
        [self.view makeToast:XCLocalized(@"ImageFail")];
        return;
    }
    
    NSString *strName = _txtUsername.text;
    if ([strName isEqualToString:@""])
    {
        [self.view makeToast:XCLocalized(@"userNull")];
        return;
    }
    
    NSString *strPwd = _txtPwd.text;
    if ([strPwd isEqualToString:@""]) {
        [self.view makeToast:XCLocalized(@"pwdNull")];
        return;
    }
    
    NSString *strAuthPwd = _txtAuthPwd.text;
    if ([strAuthPwd isEqualToString:@""]) {
        [self.view makeToast:XCLocalized(@"confirmPwd")];
        return ;
    }
    
    NSString *strAuthCode = _txtAuthCode.text;
    if ([strAuthCode isEqualToString:@""]) {
        [self.view makeToast:XCLocalized(@"picNull")];
        return ;
    }
    if (!_bError)
    {
        [self.view makeToast:XCLocalized(@"UsernameAlready")];
        return;
    }
    else if(!_bPwdLength)
    {
        [self.view makeToast:XCLocalized(@"pwdLength")];
        return;
    }
    else if(!_bPwd)
    {
        [self.view makeToast:XCLocalized(@"TwoPwd")];
        return ;
    }
    __weak RegViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:XCLocalized(@"Registering")];
    });
    __block NSString *_strName = strName;
    __block NSString *_strPwd = strPwd;
    __block NSString *__strAuthCode = strAuthCode;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [__self authRegister:_strName pwd:_strPwd code:__strAuthCode];
    });
}


-(void)authRegister:(NSString *)strUser pwd:(NSString*)strPwd code:(NSString *)strCode
{
    
    __weak RegViewController *__self = self;
    regService.httpReg = ^(int nStatus)
    {
        switch (nStatus) {
            case 1:
            {
                [ProgressHUD dismiss];
                dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [__self.view makeToast:XCLocalized(@"RegSuc")];
                   });
                [__self performSelector:@selector(navBack) withObject:nil afterDelay:2.0f];
            }
                break;
            case 161:
            {
                //验证码错误
                [ProgressHUD dismiss];
                [__self.view makeToast:XCLocalized(@"RegPic")];
            }
                break;
            case 162:
            {
                //数据错误
                [ProgressHUD dismiss];
                [__self.view makeToast:XCLocalized(@"RegData")];
            }
                break;
            default:
            {
                //超时
                [ProgressHUD dismiss];
                [__self.view makeToast:XCLocalized(@"RegTimeout")];
            }
                break;
        }
    };
    [regService requestRegister:strUser pwd:strPwd auth:strCode code:_strAuthCode16];
}

@end
