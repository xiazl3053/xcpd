//
//  DeviceViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/19.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "DeviceViewController.h"
#import "UIView+Extension.h"
#import "XCNotification.h"
#import "XCUpdView.h"
#import "DevInfoView.h"
#import "DecodeJson.h"
#import "DeviceInfoModel.h"
#import "DeleteDevService.h"
#import "ProgressHUD.h"
#import "XCNotification.h"
#import "UpdNameService.h"
#import "Toast+UIView.h"
@interface DeviceViewController ()<UIAlertViewDelegate,XCUpdViewDelegate,DevNameUpdDelegate>
{
    UIView *topView;
    UIImageView *imgView;
    CGRect _frame;
    DevInfoView *infoView;
    XCUpdView *nameView;
    DeleteDevService *delService;
    UIButton *btnDel;
    
    UpdNameService *updService;
}
@property (nonatomic,strong) DeviceInfoModel *devInfo;
@end

@implementation DeviceViewController

-(id)initWithFrame:(CGRect)frame
{
    self = [super init];
    _frame = frame;
    return self;
}

-(void)setFrame:(CGRect)frame
{
    _frame = frame;
}

-(void)loadView
{
    self.view = [[UIView alloc] initWithFrame:_frame];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:RGB(246, 249, 250)];
    [self initHeadView];
    btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDel addTarget:self action:@selector(deleteDevInfo:) forControlEvents:UIControlEventTouchUpInside];
    [btnDel setTitle:XCLocalized(@"deleteDevice") forState:UIControlStateNormal];
    [btnDel setBackgroundColor:RGB(15,173,225)];
    btnDel.frame = Rect(20,514,self.view.width-40,50);
    btnDel.titleLabel.font = XCFONT(17);
    [self.view addSubview:btnDel];
    [btnDel.layer setMasksToBounds:YES];
    btnDel.layer.cornerRadius = 5.0f;
    
    nameView = [[XCUpdView alloc] initWithFrame:Rect(100,self.view.height/2-200, self.view.width-200, 400)];
    [nameView setTitle:XCLocalized(@"Modify")];
    [nameView.txtField setPlaceholder:XCLocalized(@"cameraName")];
    [self.view addSubview:nameView];
    nameView.delegate = self;
    nameView.hidden = YES;
    updService = [[UpdNameService alloc] init];
    
    
}

-(void)closeTxtField
{
    [nameView.txtField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeTxtField) name:NSKEY_BOARD_RETURN_VC object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)deleteDevInfo:(UIButton*)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:XCLocalized(@"delDeviceQuq") message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:XCLocalized(@"confirm"),XCLocalized(@"cancel"), nil];
    [alert show];
}

-(void)initHeadView
{
    topView = [[UIView alloc] initWithFrame:Rect(0, 0,self.view.width,64)];
    UIImageView *backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_bg"]];
    [topView addSubview:backImg];
    backImg.frame = topView.bounds;
    
    [self.view addSubview:topView];
    UILabel *labInfo = [[UILabel alloc] initWithFrame:Rect(0, 24, self.view.width,20)];
    [labInfo setText:XCLocalized(@"devDetails")];
    [labInfo setTextColor:[UIColor blackColor]];
    [labInfo setFont:XCFONT(20)];
    [labInfo setTextAlignment:NSTextAlignmentCenter];
    [topView addSubview:labInfo];
    [self initBodyView];
    
}

-(void)updateDevName
{
     
}

-(void)closeView
{
    nameView.hidden = YES;
}

-(void)addDeviceInfo
{
    if ([nameView.txtField.text isEqualToString:@""])
    {
        [self.view makeToast:@"设备名不能为空"];
    }
    else
    {
        if (updService==nil)
        {
            updService = [[UpdNameService alloc] init];
        }
        [self updateNameBlock];
    }
}

-(void)updateNameBlock
{
    if (_devInfo==nil)
    {
        return ;
    }
    __weak DeviceViewController *__self = self;
    [ProgressHUD show:XCLocalized(@"Modify")];
    __block NSString *__strDevName = nameView.txtField.text;
    __weak DevInfoView *__devInfoView = infoView;
    updService.httpBlock = ^(int nStatus)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressHUD dismiss];
        });
        NSString *strMsg = nil;
        switch (nStatus)
        {
            case 1:
                strMsg = XCLocalized(@"updateOK");
                break;
            case 74:
                strMsg = XCLocalized(@"ServerException");
                break;
            default:
                strMsg = XCLocalized(@"updateTimeOut");
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [__self.view makeToast:strMsg duration:3.0 position:@"center"];
        });
        if (nStatus==1)
        {
            __self.devInfo.strDevName = __strDevName;
            dispatch_async(dispatch_get_main_queue(), ^{
                [__devInfoView setDeviceInfo:__self.devInfo];
            });
        }
    };
    [updService requestUpdName:_devInfo.strDevNO name:nameView.txtField.text];
}

-(void)showUpdView
{
    nameView.hidden = NO;
}

-(void)setFirstDevInfo:(DeviceInfoModel *)devInfo
{
      _devInfo = devInfo;
}

-(void)initBodyView
{
    imgView = [[UIImageView alloc] initWithFrame:Rect(self.view.width/2-120,64,240,200)];
    [self.view addSubview:imgView];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    infoView = [[DevInfoView alloc] initWithFrame:Rect(20, imgView.height+imgView.y,self.view.width-40,200)];
    [infoView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:infoView];
    if (_devInfo)
    {
        [self setDeviceInfo:_devInfo];
    }
    infoView.delegate = self;
}

-(void)setDeviceInfo:(DeviceInfoModel *)devInfo
{
     NSString *strNewType = [DecodeJson getDeviceTypeByType:[devInfo.strDevType intValue]];
     devInfo.strNewType = strNewType;
    [imgView setImage:[UIImage imageNamed:[strNewType isEqualToString:@"IPC"]?@"IPC_Info":@"DVR_Info"]];
    _devInfo = devInfo;
    [infoView setDeviceInfo:devInfo];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            DLog(@"删除");
            [self deleteDeviceInfo];
        }
        break;
        default:
        {
            
        }
        break;
    }
}

-(void)deleteDeviceInfo
{
    if(delService==nil)
    {
        delService = [[DeleteDevService alloc] init];
    }
    __weak DeviceViewController *__weakSelf = self;
    delService.httpDelDevBlock = ^(int nStatus)
    {
        
        NSString *strMsg = nil;
        switch (nStatus)
        {
            case 1:
                strMsg = XCLocalized(@"deleteDeviceOK");
                break;
            case 54:
                strMsg = XCLocalized(@"deleteDeviceFail");
                break;
            default:
                strMsg = XCLocalized(@"deleteDeviceFail_server");
                break;
        }

        dispatch_async(dispatch_get_main_queue(),
        ^{
           [ProgressHUD dismiss];
        });
        [__weakSelf.view makeToast:strMsg duration:2.0 position:@"center"];
        if (nStatus ==1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NSUPDATE_DEVICE_LIST_VC object:nil];
        }
    };
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"deleteDevice"];
    });
    [delService requestDelDevInfo:_devInfo.strDevNO auth:_devInfo.strDevAuth];
}

@end
