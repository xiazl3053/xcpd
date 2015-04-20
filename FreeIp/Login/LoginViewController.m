//
//  LoginViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/17.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "LoginViewController.h"
#import "XCNotification.h"
#import "UIView+Extension.h"
#import "XCTextField.h"
#import "RegViewController.h"
#import "QCheckBox.h"
#import "LoginService.h"
#import "ProgressHUD.h"
#import "LoginInfo.h"
#import "Toast+UIView.h"
#import "LoginUserDB.h"
//#import "IQKeyboardManager.h"
#import "LoginUserDB.h"
#import "IndexViewController.h"
#import "AppDelegate.h"
#import "UtilsMacro.h"
#import "GuessLoginService.h"
#import "UserModel.h"

@interface LoginViewController ()<QCheckBoxDelegate,UITextFieldDelegate>
{
    UITextField *_txtFieldView;
    GuessLoginService *_guessService;
}

@property (nonatomic,strong) LoginService *loginSev;
@property (nonatomic,strong) XCTextField *txtUser;
@property (nonatomic,strong) XCTextField *txtPwd;
@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,strong) QCheckBox *pwdCheck;
@property (nonatomic,strong) QCheckBox *loginCheck;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUIHead];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(void)initUIHead
{
    CGFloat fWidth,fHeight;
    if (IOS_SYSTEM_8)
    {
        fWidth = kScreenSourchWidth;
        fHeight = kScreenSourchHeight;
    }
    else
    {
        fWidth = kScreenSourchHeight;
        fHeight = kScreenSourchWidth;
    }
    _imgView = [[UIImageView alloc] initWithFrame:Rect(0, 0, fWidth, fHeight)];
    [_imgView setImage:[UIImage imageNamed:@"login_bg"]];
    [self.view addSubview:_imgView];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(fWidth/2-kTextfieldWidth/2,203,150, 30)];
    [lblName setText:XCLocalized(@"Loginbtn")];
    [lblName setTextColor:[UIColor whiteColor]];
    [lblName setFont:XCFONT(25)];
    [self.view addSubview:lblName];
    
    UILabel *lblContent = [[UILabel alloc] initWithFrame:Rect(lblName.x,lblName.y+lblName.height+15, kTextfieldWidth, 1)];
    [lblContent setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:lblContent];
    
    _txtUser = [[XCTextField alloc] initWithFrame:Rect(lblContent.x,lblContent.y+lblContent.height+29, kTextfieldWidth, 51.5)];
    [self.view addSubview:_txtUser];
    _txtPwd = [[XCTextField alloc] initWithFrame:Rect(_txtUser.x,_txtUser.y+_txtUser.height+20, _txtUser.width, _txtUser.height)];
    [self.view addSubview:_txtPwd];
    //189 194 200
    UIColor *color = [UIColor whiteColor];
    _txtUser.attributedPlaceholder = [[NSAttributedString alloc] initWithString:XCLocalized(@"Loginuser") attributes:@{NSForegroundColorAttributeName: color}];
    _txtPwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:XCLocalized(@"Loginpwd") attributes:@{NSForegroundColorAttributeName: color}];
    _txtPwd.secureTextEntry=YES;
    _txtPwd.delegate = self;
    _txtUser.delegate = self;
    [_txtUser setReturnKeyType:UIReturnKeyNext];
    [_txtPwd setReturnKeyType:UIReturnKeyDone];
    _txtUser.tag = 10001;
    _txtPwd.tag = 10002;
    _pwdCheck = [[QCheckBox alloc] initWithDelegate:self];
    _pwdCheck.frame = Rect(_txtPwd.x, _txtPwd.y+_txtPwd.height+24, 100, 20);
    [_pwdCheck setTitle:XCLocalized(@"saveLogin") forState:UIControlStateNormal];
    [_pwdCheck setTitleColor:color forState:UIControlStateNormal];
    _pwdCheck.titleLabel.font = XCFONT(15);
    CGSize labelsize = [XCLocalized(@"autoLogin") sizeWithFont:XCFONT(15) constrainedToSize:CGSizeMake(200.0f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    _loginCheck = [[QCheckBox alloc] initWithDelegate:self];
    _loginCheck.titleLabel.font = XCFONT(15);
    _loginCheck.frame = Rect(_txtPwd.x+_txtPwd.width-labelsize.width-33, _txtPwd.y+_txtPwd.height+24, 100, 15);
    
    [_loginCheck setTitle:XCLocalized(@"autoLogin") forState:UIControlStateNormal];
    [_loginCheck setTitleColor:color forState:UIControlStateNormal];
    [self.view addSubview:_pwdCheck];
    [self.view addSubview:_loginCheck];
    
    UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *btnReg = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReg.frame = Rect(_txtPwd.x, _pwdCheck.y+_pwdCheck.height+24, 151.5,47);
    btnLogin.frame = Rect(_txtPwd.x+_txtPwd.width-151.5, btnReg.y, btnReg.width, btnReg.height);
    UIColor *orange = RGB(225, 183, 15);
    [btnLogin setBackgroundColor:orange];
    [btnReg setBackgroundColor:orange];
    [btnLogin setTitleColor:color forState:UIControlStateNormal];
    [btnLogin addTarget:self action:@selector(loginServer) forControlEvents:UIControlEventTouchUpInside];
    [btnReg addTarget:self action:@selector(registerView) forControlEvents:UIControlEventTouchUpInside];
    [btnReg setTitleColor:color forState:UIControlStateNormal];
    [btnLogin setTitle:XCLocalized(@"Loginbtn") forState:UIControlStateNormal];
    [btnReg setTitle:XCLocalized(@"RegisterView") forState:UIControlStateNormal];
    btnLogin.titleLabel.font = XCFONT(17);
    btnReg.titleLabel.font = XCFONT(17);
    [self.view addSubview:btnLogin];
    [self.view addSubview:btnReg];
    
    UIButton *guessBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize guessSize = [XCLocalized(@"Visitors") sizeWithFont:XCFONT(17) constrainedToSize:CGSizeMake(150.0f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    guessBtn.frame = Rect(btnReg.x,btnReg.height+btnReg.y+38,guessSize.width, 20);
    [guessBtn setTitle:XCLocalized(@"Visitors") forState:UIControlStateNormal];
    [guessBtn setTitleColor:color forState:UIControlStateNormal];
    guessBtn.titleLabel.font = XCFONT(17);
    CGSize forgetSize = [XCLocalized(@"find_pwd") sizeWithFont:XCFONT(17) constrainedToSize:CGSizeMake(150.0f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    forgetBtn.frame = Rect(btnLogin.x+btnLogin.width-forgetSize.width, guessBtn.y, forgetSize.width, 20);
    [forgetBtn setTitleColor:color forState:UIControlStateNormal];
    [forgetBtn setTitle:XCLocalized(@"find_pwd") forState:UIControlStateNormal];
  forgetBtn.titleLabel.font = XCFONT(17);
    [self.view addSubview:guessBtn];
//    [self.view addSubview:forgetBtn];
    [guessBtn addTarget:self action:@selector(loginGuess) forControlEvents:UIControlEventTouchUpInside];
}

-(void)loginGuess
{
    if (!_guessService) {
        _guessService = [[GuessLoginService alloc] init];
    }
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [ProgressHUD show:XCLocalized(@"logining")];
                   });
    __weak LoginViewController *__weakSelf = self;
    _guessService.httpGuessBlock = ^(int nStatus)
    {
        [ProgressHUD dismiss];
        if (nStatus==1)
        {
            DLog(@"登录成功");
            IndexViewController *index = [[IndexViewController alloc] init];
            [__weakSelf presentViewController:index animated:YES completion:^{}];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),
               ^{
                   [__weakSelf.view makeToast:XCLocalized(@"ServerException")];
               });
            
        }
    };
    [_guessService connectionHttpLogin];
}

-(void)registerView
{
    RegViewController *regView = [[RegViewController alloc] init];
    [self presentViewController:regView animated:YES completion:nil];
}

-(void)closeKeyBoard:(NSNotification*)notify
{
    UITextField *textfield = (UITextField*)[notify object];
    [textfield resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyBoard:) name:NSKEY_BOARD_RETURN_VC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
   
}

-(void)KeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    //获取高度
    NSValue *value = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    /*关键的一句，网上关于获取键盘高度的解决办法，多到这句就over了。系统宏定义的UIKeyboardBoundsUserInfoKey等测试都不能获取正确的值。不知道为什么。。。*/
    CGSize keyboardSize = [value CGRectValue].size;
    if (_txtFieldView==nil)
    {
        return ;
    }
    CGFloat move = (_txtFieldView.y+_txtFieldView.height)-(self.view.height-keyboardSize.height);
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
    _txtFieldView = notification.object;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    int nLogin,nSave;
    NSString *strUsername = [LoginUserDB querySaveInfo:&nSave login:&nLogin];
    if(strUsername!=nil)
    {
        DLog(@"strUsername:%@",strUsername);
        _txtUser.text = strUsername;
        if(nSave)
        {
             _txtPwd.text = [LoginUserDB queryUserPwd:strUsername];
            _pwdCheck.checked = YES;
        }
        if (nLogin)
        {
            _loginCheck.checked = YES;
            [self loginServer];
        }
    }
}

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
        [_txtPwd resignFirstResponder];
    }
    return YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)systemVersion:(NSString*)strInfo
{
    __weak LoginViewController *__weakSelf = self;
    __block NSString *__strInfo = strInfo;
    if (IOS_SYSTEM_8) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressHUD show:strInfo];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressHUD showPlayRight:__strInfo viewInfo:__weakSelf.view];
        });
    }
}
-(void)loginServer
{
    NSString *strUser = _txtUser.text;
    NSString *strPwd = _txtPwd.text;
    if ([strUser isEqualToString:@""])
    {
        [self.view makeToast:@""];
    }
    if ([strPwd isEqualToString:@""])
    {
        [self.view makeToast:@""];
    }
    
    if (!_loginSev) {
        _loginSev = [[LoginService alloc] init];
    }
    __weak NSString *__strName = strUser;
    __weak NSString *__strPwd = strPwd;
    __weak LoginViewController *__weakSelf = self;
    [self systemVersion:XCLocalized(@"logining")];
    _loginSev.httpBlock = ^(LoginInfo* lgInfo, int nStatus)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressHUD dismiss];
        });
        switch (nStatus)
        {
            case 1:
            {
                DLog(@"登录成功");
                UserModel *usModel = [[UserModel alloc] initWithUser:__strName pwd:__strPwd];
                BOOL bReturn = [LoginUserDB addLoginUser:usModel];
                if (bReturn)
                {
                    [LoginUserDB updateSaveInfo:__strName save:__weakSelf.pwdCheck.checked login:__weakSelf.loginCheck.checked];
                }
                IndexViewController *indexView = [[IndexViewController alloc] init];
                [__weakSelf presentViewController:indexView animated:YES completion:nil];
//                [[UIApplication sharedApplication] keyWindow].rootViewController = indexView;
            }
            break;
            case 0:
            {
                DLog(@"密码错误");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [__weakSelf.view makeToast:XCLocalized(@"authError")];
                });
            }
            break;
            default:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [__weakSelf.view makeToast:XCLocalized(@"loginTime")];
                });
            }
            break;
        }
    };

    [_loginSev connectionHttpLogin:strUser pwd:strPwd];

}




@end
