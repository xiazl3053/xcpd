//
//  P2PPlyaViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/23.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "P2PPlayViewController.h"
#import "PTPSource.h"
#import "ProgressHUD.h"
#import "UIView+Extension.h"
#import "XLDecoder.h"
#import "UtilsMacro.h"
#import "Toast+UIView.h"
#import "XCNotification.h"

@interface P2PPlayViewController ()
{
    XLDecoder *_decoder;
    NSString *strDevInfo;
}

@property (nonatomic,strong) PTPSource *ptpSource;

@end

@implementation P2PPlayViewController

-(id)initWithNO:(NSString *)strNO name:(NSString *)strDevName channel:(int)nChannel code:(int)nCode
{
    self = [super initWithNO:strNO name:strDevName channel:nChannel code:nCode];
    _ptpSource = [[PTPSource alloc] initWithNo:strNO name:strDevName channel:nChannel codeType:nCode];
    strDevInfo = strDevName;
    self.strNO = strNO;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   // [self.imgView setFrame:Rect(0, 0, self.view.width, self.view.height)];
  //  DLog(@"frame:%@",NSStringFromCGRect(self.imgView.frame));
    [self P2PInitConnection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self playLayout];
    //P2P打洞
//    [self P2PInitConnection];
}

-(void)P2PInitConnection
{
    __weak P2PPlayViewController *__weakSelf = self;
    //bScreen)//bScreen no 竖屏   yes 横屏

    dispatch_async(dispatch_get_main_queue(),
    ^{
         [__weakSelf.imgView makeToastActivity];
    });
    __weak PTPSource *__ptpSource = _ptpSource;
    dispatch_async(dispatch_get_global_queue(0, 0),
    ^{
        [__weakSelf initDecodeInfo:__ptpSource];
    });
}

-(void)initDecodeInfo:(PTPSource *)ptpsource
{
    BOOL bFlag = [self.decodeImp connection:ptpsource];
    __weak P2PPlayViewController *__weakSelf = self;
    if (bFlag)
    {
        DLog(@"连接成功?");
        self.bPlaying= YES;
        self.bDecoding = NO;
        if(!_decoder)
        {
            _decoder = [[XLDecoder alloc] initWithDecodeSource:ptpsource];
            [self.decodeImp decoder_init:_decoder];
            //发送一次点击通知
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NS_PLAY_VIEW_CLICK_VC object:self];
        [self startPlay];
        if (_ptpSource == nil)
        {
            _ptpSource = ptpsource;
        }
    }
    else
    {
        DLog(@"连接失败");
        dispatch_async(dispatch_get_main_queue(),
        ^{
              [__weakSelf.imgView hideToastActivity];
              [__weakSelf.imgView makeToast:XCLocalized(@"connectFail")];
        });
        
        [self stopVideo];
    }
}

#pragma mark 旋转之后的第一次界面显示
-(void)playLayout
{
//    self.imgView.frame = Rect(0, 0, self.view.width, self.view.height);
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectFail:) name:NSCONNECT_P2P_FAIL_VC object:nil];
    
}
-(void)connectFail:(NSNotification*)notify
{
    NSDictionary *dict = notify.object;
    if ([[dict objectForKey:@"NO"] isEqualToString:self.strNO] && [[dict objectForKey:@"channel"] intValue]==self.nChannel)
    {
        DLog(@"停止");
    }
    else
    {
        return;
    }
    DLog(@"notify:%@",[dict objectForKey:@"reason"]);
    __weak P2PPlayViewController *__weakSelf =self ;
    dispatch_async(dispatch_get_global_queue(0,0),
    ^{
        [__weakSelf stopVideo];
    });
    __weak NSString *strInfo = [dict objectForKey:@"reason"];
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [__weakSelf.imgView makeToast:strInfo duration:1.5 position:@"center"];
    });
}

-(void)stopVideo
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DLog(@"视频停止:%@",strDevInfo);
    self.bPlaying = NO;
    [_ptpSource releaseDecode];
    _ptpSource = nil;
    __weak P2PPlayViewController *__weakSelf = self;
    dispatch_async(dispatch_get_main_queue(),
    ^{
         [__weakSelf.imgView hideToastActivity];
         [__weakSelf.imgView setImage:nil];
    });
    [[NSNotificationCenter defaultCenter] postNotificationName:NS_CLOSE_P2P_HOME object:self];
}

-(void)setStrKey:(NSString *)strKey
{
    [super setStrKey:strKey];
    _ptpSource.strKey = self.strKey;
}

-(BOOL)captureView
{
    return [super captureView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)switchCode:(int)nCode
{
    if (nCode == self.nCodeType) {
        return YES;
    }
    self.bPlaying = NO;
    self.bDecoding = YES;
    //根据两种情况去判断如何切换视频码流
    //1.如果是p2p的方式，那么使用sdk
    //2.如果是转发的方式，那么使用重连
    __weak P2PPlayViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(),
       ^{
           [__self.imgView makeToast:XCLocalized(@"videoSwitch") duration:2.0f position:@"center"];
       });
    
    if([_ptpSource getSource]==1)
    {
        __block int __nCode = nCode;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f*NSEC_PER_SEC)), dispatch_get_global_queue(0, 0),
        ^{
            BOOL bReturn = [__self.ptpSource switchP2PCode:__nCode];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressHUD dismiss];
            });
            if (bReturn)
            {
                __self.nCodeType = __nCode;
                __self.bPlaying = YES;
                __self.bDecoding = NO;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [__self startPlay];
                });
                [[NSNotificationCenter defaultCenter] postNotificationName:NS_PLAY_VIEW_CLICK_VC object:self];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [__self.imgView makeToast:XCLocalized(@"switchError")];
                });
                [__self stopVideo];
            }
        });
    }
    else
    {
        [_ptpSource releaseDecode];
        [_decoder stopDecode];
        _ptpSource = nil;
        _decoder = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [ProgressHUD dismiss];
        });
        PTPSource *ptpSource = [[PTPSource alloc] initWithNo:self.strNO name:self.strDevName channel:self.nChannel codeType:nCode];
        _ptpSource = ptpSource;
        self.nCodeType = nCode;
        _ptpSource.nCodeType = nCode;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [__self initDecodeInfo:__self.ptpSource];
        
        });
    }
    return YES;
}

-(void)switchTran
{
    BOOL bReturn = [_ptpSource connectTran];
    if (bReturn) {
        self.bPlaying =YES;
        self.bDecoding = NO;
        [self startPlay];
        [[NSNotificationCenter defaultCenter] postNotificationName:NS_PLAY_VIEW_CLICK_VC object:self];
    }
    else
    {
        [self stopVideo];
    }
}

@end