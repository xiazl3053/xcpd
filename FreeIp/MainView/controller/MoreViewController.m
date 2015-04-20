//
//  MoreViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/30.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "MoreViewController.h"
#import "UserInfoService.h"

#import "UpdRealService.h"
#import "DecodeJson.h"
#import "LoginUserDB.h"
#import "UserModel.h"
#import "Toast+UIView.h"
#import "LoginViewController.h"
#import "UpdNickService.h"
#import "AppDelegate.h"
#import "RecordViewController.h"
#import "XCDetailsView.h"
#import "UserInfo.h"
#import "UserAllInfoModel.h"
#import "UIView+Extension.h"
#import "UtilsMacro.h"
#import "XCUserInfoView.h"
#import "XCVersionView.h"
#import "ImageViewController.h"
#import "XCUpdView.h"
#import "ProgressHUD.h"
#import "UpdEmailService.h"
#import "UpdPwdService.h"

@interface MoreViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,XCUpdViewDelegate,XCUserInfoViewDelegate,XCDetailsDelegate>
{
    UserInfoService *userService;
    UIButton *btnLogout;
    UIView *headView;
    CGFloat fWidth,fHeight;
    UIView *_sonView;
    int nUpdType;
    ImageViewController *_imgViewController;
    XCUpdView *updView;
    RecordViewController *_recordViewController;
    UpdPwdService *_updService;
    UpdRealService *_updRealService;
    UpdNickService *_updNickService;
    UpdEmailService *_emailServer;
}
@property (nonatomic,strong) UserAllInfoModel *userAll;
@property (nonatomic,strong) UITableView *tableview;
@property (nonatomic,strong) XCUserInfoView *userInfoView;
@property (nonatomic,strong) XCDetailsView *detailsView;


@end

@implementation MoreViewController

-(void)initUpdView
{
    updView = [[XCUpdView alloc] initWithFrame:Rect(100,self.view.height/2-200, self.view.width-200, 400)];
    [updView setTitle:XCLocalized(@"Modify")];
    [updView.txtField setPlaceholder:XCLocalized(@"cameraName")];
    [self.view addSubview:updView];
    updView.delegate = self;
    updView.hidden = YES;
}
-(void)updDetail:(int)nType
{
    if(nType==4)
    {
        [self updateRealName];
    }
    else
    {
        [self updateEmail];
    }
}

-(void)userView:(int)nType
{
    __weak MoreViewController *__self = self;
    __weak XCUpdView *__updView = updView;
    switch (nType) {
        case 1:
        {
            //修改头像
            nUpdType = 1;
        }
        break;
        case 2:
        {
            //修改昵称
            dispatch_async(dispatch_get_main_queue(), ^{
                [__self setUpdView:XCLocalized(@"nickUpd") place:@""];
                [__updView closePassword];
            });
            nUpdType = 2;
        }
            break;
        case 3:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [__self setUpdView:XCLocalized(@"updpwd") place:XCLocalized(@"oldPwd")];
                [__updView addPassword];
            });
            nUpdType = 3;
        }
        break;
        default:
        {
            
        }
        break;
    }
}


-(void)addDeviceInfo
{
    switch (nUpdType) {
        case 2:
            //修改昵称
            [self updateNick];
            break;
        case 3:
            //修改密码
            [self updatePwd];
            break;
        case 4:
            [self updateEmail];
            break;
        case 5:
            [self updateRealName];
            break;
        default:
            break;
    }
}

-(void)updateRealName
{
    if(_updRealService==nil)
    {
        _updRealService = [[UpdRealService alloc] init];
    }
    [updView.txtField resignFirstResponder];
    NSString *strEmail = [updView.txtField text];
    if ([strEmail isEqualToString:@""])
    {
        [self.view makeToast:XCLocalized(@"nickEmpty")];
        return;
    }
    if ([strEmail length]>kUSER_INFO_MAX_LENGTH) {
        [self.view makeToast:XCLocalized(@"realThan64")];
        return ;
    }
    
    if (_updRealService)
    {
        __weak MoreViewController *__weakSelf = self;
        __weak XCUpdView *__updView = updView;
        __weak XCDetailsView *__detailView = _detailsView;
        _updRealService.httpBlock = ^(int nStatus)
        {
            dispatch_async(dispatch_get_main_queue(), ^{[ProgressHUD dismiss];});
            switch (nStatus) {
                case 1:
                {
                    [__weakSelf.view makeToast:XCLocalized(@"updateOK")];
                    __updView.hidden = YES;
                    [__detailView setRealName:__updView.txtField.text];
                }
                break;
                default:
                {
                    [__weakSelf.view makeToast:XCLocalized(@"deleteDeviceFail_server")];
                }
                break;
            }
        };
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [ProgressHUD show:XCLocalized(@"updnicking")];
                       });
        [_updRealService requestUpdReal:strEmail];
    }
}

-(void)updateEmail
{
    if(_emailServer==nil)
    {
        _emailServer = [[UpdEmailService alloc] init];
    }
    [updView.txtField resignFirstResponder];
    NSString *strEmail = [updView.txtField text];
    if ([strEmail isEqualToString:@""]) {
        [self.view makeToast:XCLocalized(@"emailEmpty")];
        return;
    }
    
    if (![DecodeJson validateEmail:strEmail])
    {
        [self.view makeToast:XCLocalized(@"emailError")];
        return;
    }
    
    if ([strEmail length]>kUSER_INFO_MAX_LENGTH)
    {
        [self.view makeToast:XCLocalized(@"emailThan64")];
        return ;
    }
    
    if (_emailServer)
    {
        __weak MoreViewController *__weakSelf = self;
        __weak XCUpdView *__updView = updView;
        __weak XCDetailsView *__detailView = _detailsView;
        _emailServer.httpBlock = ^(int nStatus)
        {
            dispatch_async(dispatch_get_main_queue(), ^{[ProgressHUD dismiss];});
            switch (nStatus) {
                case 1:
                {
                    [__weakSelf.view makeToast:XCLocalized(@"updateOK")];
                    __updView.hidden = YES;
                    [__detailView setEmail:__updView.txtField.text];
                }
                break;
                case 141:
                {
                    [__weakSelf.view makeToast:XCLocalized(@"emailBind")];
                }
                    break;
                default:
                {
                    [__weakSelf.view makeToast:XCLocalized(@"deleteDeviceFail_server")];
                }
                    break;
            }
        };
        [_emailServer requestUpdEmail:strEmail];
        [ProgressHUD show:XCLocalized(@"updemailing")];
    }
}

-(void)updateNick
{
    if (_updNickService==nil)
    {
        _updNickService = [[UpdNickService alloc] init];
    }
    [updView.txtField resignFirstResponder];
    NSString *strEmail = [updView.txtField text];
    if ([strEmail isEqualToString:@""])
    {
        [self.view makeToast:XCLocalized(@"realEmpty")];
        return;
    }
    
    if ([strEmail length]>kUSER_INFO_MAX_LENGTH)
    {
        [self.view makeToast:XCLocalized(@"nickThan64")];
        return ;
    }
    
    if (_updNickService)
    {
        __weak MoreViewController *__weakSelf = self;
        __weak XCUserInfoView *__userInfoView = _userInfoView;
        __block NSString *__strOnlyName = strEmail;
        __weak XCUpdView *__updView = updView;
        _updNickService.httpBlock = ^(int nStatus)
        {
            dispatch_async(dispatch_get_main_queue(),
               ^{
                   [ProgressHUD dismiss];
               });
            switch (nStatus)
            {
                case 1:
                {
                    [__weakSelf.view makeToast:XCLocalized(@"updateOK")];
                    __weakSelf.userAll.strOnlyName = __strOnlyName;
                    [__userInfoView setNickName:__strOnlyName];
                    __updView.hidden = YES;
                }
                break;
                default:
                {
                    [__weakSelf.view makeToast:XCLocalized(@"deleteDeviceFail_server")];
                }
                    break;
            }
        };
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [ProgressHUD show:XCLocalized(@"updnicking")];
                       });
        [_updNickService requestUpdNick:strEmail];
    }
    
}


-(void)updatePwd
{
    NSString *oldPwd = updView.txtField.text;
    NSString *newPwd = updView.txtNewPwd.text;
    NSString *authPwd = updView.txtConPwd.text;
    if ([oldPwd isEqualToString:@""])
    {
        [self.view makeToast:XCLocalized(@"oldEmpty")];
        return;
    }
    if ([newPwd isEqualToString:@""]) {
        [self.view makeToast:XCLocalized(@"newEmpty")];
        return;
    }
    if ([authPwd isEqualToString:@""]) {
        [self.view makeToast:XCLocalized(@"comEmpty")];
        return;
    }
    
    if ([newPwd length]<6)
    {
        [self.view makeToast:XCLocalized(@"pwdLength")];
        return;
    }
    
    if ([newPwd length]>kUSER_INFO_MAX_LENGTH)
    {
        [self.view makeToast:XCLocalized(@"pwdThan64")];
        return;
    }
    
    if([oldPwd isEqualToString:@""])
    {
        [self.view makeToast:XCLocalized(@"oldError")];
        return;
    }
    
    if (![authPwd isEqualToString:newPwd])
    {
        [self.view makeToast:XCLocalized(@"newError")];
        return;
    }
    __block NSString *__strNewPwd = newPwd;
    __weak XCUpdView *__updView = updView;
    if (_updService==nil)
    {
        _updService = [[UpdPwdService alloc] init];
    }
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [ProgressHUD show:XCLocalized(@"updpwding")];
                       });
        __weak MoreViewController *__weakSelf = self;
        _updService.httpBlock = ^(int nStatus)
        {
            dispatch_async(dispatch_get_main_queue(), ^{[ProgressHUD dismiss];});
            switch (nStatus)
            {
                case 1:
                {
                    [__weakSelf.view makeToast:XCLocalized(@"updateOK")];
                    UserModel *user = [[UserModel alloc] initWithUser:[UserInfo sharedUserInfo].strUser pwd:__strNewPwd];
                    [LoginUserDB addLoginUser:user];
                    DLog(@"更改数据库记录");
                    [UserInfo sharedUserInfo].strPwd = __strNewPwd;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __updView.hidden = YES;
                    });
                }
                    break;
                case 94:
                {
                    [__weakSelf.view makeToast:XCLocalized(@"oldPwdError")];//密码错误
                }
                    break ;
                default:
                {
                    [__weakSelf.view makeToast:XCLocalized(@"deleteDeviceFail_server")];
                }
                    break;
            }
        };
        [_updService requestUpdPwd:newPwd old:oldPwd];
    
}


-(void)closeView
{
    updView.hidden = YES;
}

-(void)setUpdView:(NSString *)strTitle place:(NSString *)strPlace
{
    [updView setTitle:strTitle];
    [updView.txtField setPlaceholder:strPlace];
    updView.hidden = NO;
}

-(void)loadView
{
    if(IOS_SYSTEM_8)
    {
        fWidth = kScreenSourchWidth;
        fHeight = kScreenSourchHeight;
    }
    else
    {
        fWidth = kScreenSourchHeight;
        fHeight = kScreenSourchWidth;
    }
    self.view = [[UIView alloc] initWithFrame:Rect(0, 0, fWidth-kTabbarWidth, fHeight)];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:RGB(246, 249, 250)];
    UIView *moreView = [[UIView alloc] initWithFrame:Rect(0, 0, kHomeListWidth, 64)];
    [self.view addSubview:moreView];
    UIImageView *topImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_bg"]];
    [topImg setFrame:moreView.bounds];
    [moreView addSubview:topImg];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:Rect(50,20, kHomeListWidth-100, 20)];
    [lblTitle setText:XCLocalized(@"more")];
    [lblTitle setTextColor:RGB(0, 0, 0)];
    [moreView addSubview:lblTitle];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    
    _tableview = [[UITableView alloc] initWithFrame:Rect(0, 65, kHomeListWidth,fHeight-64) style:UITableViewStyleGrouped];
    
    [self.view addSubview:_tableview];
    [_tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    
    _sonView = [[UIView alloc] initWithFrame:Rect(kHomeListWidth+1, 0,self.view.width-kHomeListWidth-1, fHeight)];
    [self.view addSubview:_sonView];
    [_sonView setBackgroundColor:RGB(240, 240, 240)];
    
    headView = [[UIView alloc] initWithFrame:Rect(0, 0, _sonView.width,64)];
    UIImageView *backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_bg"]];
    [headView addSubview:backImg];
    backImg.frame = headView.bounds;
    
    UILabel *lblSonTitle = [[UILabel alloc] initWithFrame:Rect(50, 20, _sonView.width-100, 20)];
    [lblSonTitle setText:XCLocalized(@"userinfo")];
    [lblSonTitle setTextAlignment:NSTextAlignmentCenter];
    [lblSonTitle setTextColor:[UIColor blackColor]];
    [lblSonTitle setFont:XCFONT(17)];
    [headView addSubview: lblSonTitle];
    [_sonView addSubview:headView];
    
    _userInfoView = [[XCUserInfoView alloc] initWithFrame:Rect(24, 84, _sonView.width - 48, 200)];
    [_sonView addSubview:_userInfoView];
    _userInfoView.delegate = self;
    
    btnLogout = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogout setTitle:XCLocalized(@"logout") forState:UIControlStateNormal];
    [btnLogout setBackgroundColor:RGB(15, 173, 225)];
    [_sonView addSubview:btnLogout];
    btnLogout.frame = Rect(50,450, _sonView.width-100, 50);
    [btnLogout addTarget:self action:@selector(showLogoutAlert) forControlEvents:UIControlEventTouchUpInside];
    
    
    _detailsView = [[XCDetailsView alloc] initWithFrame:Rect(24, 314, _sonView.width-48, 100)];
    _detailsView.delegate = self;
    [_sonView addSubview:_detailsView];
    [self initUpdView];
    __weak MoreViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [__self updateUserInfo];
    });
}

-(void)showLogoutAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:XCLocalized(@"Remind") message:XCLocalized(@"logoutRemind") delegate:self cancelButtonTitle:XCLocalized(@"cancel") otherButtonTitles:XCLocalized(@"logout"), nil];
    alert.tag = 1050;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==1050) {
        switch (buttonIndex) {
            case 1:
            {
                [self exitApplication];
            }
                break;
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47;
}

-(void)exitApplication
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    [self.view.superview removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self removeFromParentViewController];
//    window.rootViewController = [[LoginViewController alloc] init];
}
-(void)updateUIView
{
    if (_userAll)
    {
        __weak MoreViewController *__self = self;
        __weak XCUserInfoView *__userInfoView = _userInfoView;
        __weak XCDetailsView *__detailsView = _detailsView;
        dispatch_async(dispatch_get_main_queue(), ^{

            [__userInfoView setNickName:__self.userAll.strOnlyName];
            [__detailsView setRealName:__self.userAll.strName];
            [__detailsView setEmail:__self.userAll.strEmail];
        });
        
        dispatch_async(dispatch_get_global_queue(0, 0),
        ^{
            UIImage *avatarImage = nil;
            NSURL *url = [NSURL URLWithString:__self.userAll.strFile];
            NSData *responseData = [NSData dataWithContentsOfURL:url];
            avatarImage = [UIImage imageWithData:responseData];
            dispatch_async(dispatch_get_main_queue(),
            ^{
                [__userInfoView setImageInfo:avatarImage];
            });
        });
    }
}

-(void)updateUserInfo
{
    if(userService==nil)
    {
        userService = [[UserInfoService alloc] init];
    }
    __weak MoreViewController *__self = self;
    userService.httpBlock = ^(UserAllInfoModel *user,int nStatus)
    {
        switch (nStatus) {
            case 1:
            {
                __self.userAll = user;
                [__self updateUIView];
            }
            break;
                
            default:
            {
                
            }
            break;
        }
    };
    [userService requestUserInfo];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableview)
    {
        static NSString *moreViewIdentifier = @"moreviewidentifier";
        UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:moreViewIdentifier];
        
        if (tableCell==nil) {
            tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:moreViewIdentifier];
        }
        UIView *view = [[UIView alloc] initWithFrame:tableCell.bounds];
        [view setBackgroundColor:RGB(15, 173, 225)];
        [tableCell setSelectedBackgroundView:view];
        switch (indexPath.section) {
            case 0:
                tableCell.textLabel.text = XCLocalized(@"userinfo");
                break;
            case 1:
            {
                tableCell.textLabel.text = XCLocalized(@"picture");
            }
            break;
            case 2:
            {
                tableCell.textLabel.text = XCLocalized(@"recordInfo");
            }
            break;
            case 3:
            {
                tableCell.textLabel.text = XCLocalized(@"version");
            }
            break;
            case 4:
            {
               tableCell.textLabel.text = XCLocalized(@"help");
            }
            break;
        }
        tableCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return tableCell;
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UIView *view in _sonView.subviews) {
        [view removeFromSuperview];
    }
    _imgViewController = nil;
    switch (indexPath.section)
    {
        case 0:
        {
            [_sonView addSubview:headView];
            [_sonView addSubview:_userInfoView];
            [_sonView addSubview:_detailsView];
            [_sonView addSubview:btnLogout];
        }
        break;
        case 1:
        {
            [self setViewAllPic];
        }
        break;
        case 2:
        {
            [self setViewAllRecord];
        }
        break;
        case 3:
        {
            [self setViewVersion];
        }
        break;
        default:
        {
            
        }
        break;
    }
}

-(void)setViewAllPic
{
    if(_imgViewController==nil)
    {
        _imgViewController = [[ImageViewController alloc] init];
    }
    [_sonView addSubview:_imgViewController.view];
}

-(void)setViewAllRecord
{
    if(_recordViewController==nil)
    {
        _recordViewController = [[RecordViewController alloc] init];
        [self addChildViewController:_recordViewController];
    }
    [_sonView addSubview:_recordViewController.view];
    
}

-(void)setViewHelp
{
    
}

-(void)setViewVersion
{
    XCVersionView *versionView = [[XCVersionView alloc] initWithFrame:Rect(0, 0, fWidth-kHomeListWidth-1, fHeight)];
    [_sonView addSubview:versionView];
}




@end
