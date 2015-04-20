//
//  IndexViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/19.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "IndexViewController.h"
#import "XCTabPd.h"
#import "UserInfo.h"
#import "UserInfo.h"
#import "XCNotification.h"
#import "UIView+Extension.h"
#import "HomeViewController.h"
#import "DeviceViewController.h"
#import "UtilsMacro.h"
#import "DirectViewController.h"
#import "MoreViewController.h"
#import "LoginService.h"
#import "DeviceInfoDb.h"
#import "UserModel.h"


@interface IndexViewController ()<XCTabBarDelegate>
{
    NSArray *aryFrame;
    UIButton *_btnTemp;
    XCTabPd *_xcTabPd;
    HomeViewController *homeView;
    CGFloat fWindth,fHeight;
}
@end

@implementation IndexViewController

-(void)connectAgain
{
    
    UserModel *userModel = [[UserModel alloc] init];
    userModel.strUser = [UserInfo sharedUserInfo].strUser;
    userModel.strPwd = [UserInfo sharedUserInfo].strPwd;
    LoginService *loginService = [[LoginService alloc] init];
    loginService.httpBlock = ^(LoginInfo *login,int nstatus)
    {
        DLog(@"重新登录结果:%d",nstatus);
    };
    [loginService connectionHttpLogin:userModel.strUser pwd:userModel.strPwd];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectAgain) name:NS_APPLITION_BECOME_ACTIVE object:nil];
    if (IOS_SYSTEM_8) {
        fWindth = kScreenSourchWidth;
        fHeight = kScreenSourchHeight;
    }
    else
    {
        fWindth = kScreenSourchHeight;
        fHeight = kScreenSourchWidth;
    }
    BtnInfo *bInfo1 = [[BtnInfo alloc] initWithItem:@[@"mine",@"mine_h",@"mine_h",XCLocalized(@"home")]];
    BtnInfo *bInfo2 = [[BtnInfo alloc] initWithItem:@[@"manage",@"manage_h",@"manage_h",XCLocalized(@"device")]];
    BtnInfo *bInfo3 = [[BtnInfo alloc] initWithItem:@[@"direct",@"direct_h",@"direct_h",XCLocalized(@"rtsp")]];
    BtnInfo *bInfo4 = [[BtnInfo alloc] initWithItem:@[@"more",@"more_h",@"more_h",XCLocalized(@"more")]];
    
    aryFrame = [[NSArray alloc] initWithObjects:bInfo1,bInfo2,bInfo3,bInfo4,nil];
    DLog(@"frame:%@",NSStringFromCGRect(self.view.frame));
    
    _xcTabPd = [[XCTabPd alloc] initWithArrayItem:aryFrame frame:Rect(0,0,kTabbarWidth,fHeight)];
    _xcTabPd.delegate = self;
    [self.view addSubview:_xcTabPd];
//    [self.view setBackgroundColor:[UIColor whiteColor]];
    homeView = [[HomeViewController alloc] init];
    
    [self addChildViewController:homeView];
    [self.view addSubview:homeView.view];
    homeView.view.tag = 5000;
    homeView.view.frame = Rect(kTabbarWidth,0,fWindth-kTabbarWidth,fHeight);
    [self clickView:(UIButton*)[[_xcTabPd viewWithTag:11000] viewWithTag:1000] index:0];
    
    DirectViewController *directView = [[DirectViewController alloc] init];
    directView.view.tag = 5002;
    directView.view.frame = Rect(kTabbarWidth, 0, fWindth-kTabbarWidth, fHeight);
    [self addChildViewController:directView];
    
    MoreViewController *moreView = [[MoreViewController alloc] init];
    moreView.view.tag = 5003;
    moreView.view.frame = Rect(kTabbarWidth, 0, fWindth-kTabbarWidth, fHeight);
    [self addChildViewController:moreView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)setIndexTabBarHidden:(BOOL)bHidden
{
     _xcTabPd.hidden = bHidden;
}
-(void)clickView:(UIButton *)btnSender index:(int)nIndex
{
    if([UserInfo sharedUserInfo].bGuess && (nIndex == 1 || nIndex==2))
    {
        return ;
    }
    if (_btnTemp)
    {
        _btnTemp.selected = NO;
    }
    btnSender.selected = YES;
    _btnTemp = btnSender;
    
    UIViewController *viewController ;
    for (UIViewController *sonControl in self.childViewControllers)
    {
        [sonControl.view removeFromSuperview];
        if(nIndex<=1)
        {
            if(sonControl.view.tag == 5000)
            {
                viewController = sonControl;
            }
        }else
        {
            if(sonControl.view.tag == 5000+nIndex)
            {
                viewController = sonControl;
            }
        }
    }
    if (viewController)
    {
        __weak IndexViewController *__weakSelf = self;
        if (nIndex==0)
        {
            [(HomeViewController*)viewController setPlayModel];
        }
        else if(nIndex==1)
        {
            [(HomeViewController*)viewController setDevInfo];
        }
        else
        {
            [homeView closeAllView];
        }
        
        __weak UIViewController *__viewControl = viewController;
        [UIView animateWithDuration:0.2f animations:^{
            if(__viewControl)
            {
                __viewControl.view.frame = Rect(kTabbarWidth, 0, fWindth-kTabbarWidth, fHeight);
                [__weakSelf.view insertSubview:__viewControl.view atIndex:0];
            }
        } completion:^(BOOL finish)
        {
            
        }];
    }
}


-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc
{
    DLog(@"indexViewController dealloc");
}

@end
