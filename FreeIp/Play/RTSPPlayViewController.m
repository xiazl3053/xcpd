//
//  RTSPPlayViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/31.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "RTSPPlayViewController.h"
#import "RTSPSource.h"
#import "XCNotification.h"
#import "XLDecoder.h"
#import "Toast+UIView.h"


@interface RTSPPlayViewController ()
{
    XLDecoder *_decoder;
}

@property (nonatomic,strong) RTSPSource *rtspSrc;

@end

@implementation RTSPPlayViewController
-(id)initWithPath:(NSString *)strPath name:(NSString *)strDevName
{
    self = [super initWithPath:strPath name:strDevName];
    
    _rtspSrc = [[RTSPSource alloc] initWithPath:strPath devName:strDevName];
    
    self.strNO = strPath;
    self.strDevName = strDevName;
    self.nCodeType = 1;
    
    return self;
}
-(void)setStrKey:(NSString *)strKey
{
    [super setStrKey:strKey];
    _rtspSrc.strKey = self.strKey;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    __weak RTSPPlayViewController *__self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [__self RTSPInitDecoder];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
 
}

-(void)RTSPInitDecoder
{
    __weak RTSPPlayViewController *__self = self;
    //bScreen)//bScreen no 竖屏   yes 横屏
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [__self.imgView makeToastActivity];
    }); 
    dispatch_async(dispatch_get_global_queue(0, 0),
    ^{
         [__self initDecodeInfo];
    });
}


-(void)initDecodeInfo
{
    BOOL bFlag = [self.decodeImp connection:_rtspSrc];
    __weak RTSPPlayViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [__self.imgView makeToastActivity];
    });
    if(bFlag)
    {
        if(_decoder==nil)
        {
            _decoder = [[XLDecoder alloc] initWithDecodeSource:_rtspSrc];
            [self.decodeImp decoder_init:_decoder];
         }
        [[NSNotificationCenter defaultCenter] postNotificationName:NS_PLAY_VIEW_CLICK_VC object:self];
        self.bPlaying = YES;
        [self startPlay];
    }
    else
    {
        DLog(@"链接失败");
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [__self.imgView hideToastActivity];
            [__self.imgView makeToast:XCLocalized(@"connectFail")];
        });
        [self stopPlay];
    }
}
-(BOOL)stopVideo
{
    self.bPlaying = NO;
    _rtspSrc = nil;
    __weak RTSPPlayViewController *__weakSelf = self;
    dispatch_async(dispatch_get_main_queue(),
    ^{
         [__weakSelf.imgView hideToastActivity];
         [__weakSelf.imgView setImage:nil];
    });
    [[NSNotificationCenter defaultCenter] postNotificationName:NS_CLOSE_DIRECT_VC object:self.strKey];
    return YES;
}

-(BOOL)switchCode:(int)nCode
{
    if (self.nCodeType == nCode) {
        return YES;
    }
    self.bPlaying = NO;
    self.bDecoding = YES;
    __weak RTSPPlayViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [__self.imgView makeToast:XCLocalized(@"videoSwitch")];
    });
    _rtspSrc = nil;
    [_decoder stopDecode];
    _decoder = nil;
    NSString *strPath = nil;
    NSString *strAdmin = [@"" isEqualToString:self.rtsp.strUser] ? @"" : [NSString stringWithFormat:@"%@:%@@",self.rtsp.strUser,self.rtsp.strUser];
    if ([self.rtsp.strType isEqualToString:@"IPC"])
    {
        strPath = [NSString stringWithFormat:@"rtsp://%@%@:%d/%d",strAdmin,self.rtsp.strAddress,(int)self.rtsp.nPort,nCode];
    }
    else
    {
        strPath = [NSString stringWithFormat:@"rtsp://%@%@:%d/%d%d",strAdmin,self.rtsp.strAddress,(int)self.rtsp.nPort,self.rtsp.nRequest,nCode];
    }
    DLog(@"strPath:%@",strPath);
    RTSPSource *privateSrc = [[RTSPSource alloc] initWithPath:strPath devName:self.strDevName];
    privateSrc.strKey = self.strKey;
    self.bDecoding = NO;
    _rtspSrc = privateSrc;
    self.nCodeType = nCode;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [__self initDecodeInfo];
    });
    
    return YES;
}
/*
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
 
 
 */


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
