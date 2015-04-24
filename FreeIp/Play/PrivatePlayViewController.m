//
//  PrivatePlayViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/31.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "PrivatePlayViewController.h"
#import "XLDecoder.h"
#import "XCNotification.h"
#import "PrivateSource.h"

#import "Toast+UIView.h"


@interface PrivatePlayViewController ()
{
    XLDecoder *_decoder;
    
}


@property (nonatomic,strong) PrivateSource *privateSrc;

@end

@implementation PrivatePlayViewController

-(void)dealloc
{
    DLog(@"删除私有协议");
}

-(void)setStrKey:(NSString *)strKey
{
    [super setStrKey:strKey];
    _privateSrc.strKey = self.strKey;
}

-(id)initWithPath:(NSString *)strPath name:(NSString *)strDevName
{
    self = [super initWithPath:strPath name:strDevName];
    _privateSrc = [[PrivateSource alloc] initWithPath:strPath devName:strDevName code:1];
    self.strNO = strPath;
    self.nCodeType = 1;
    self.strDevName = strDevName;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    __weak PrivatePlayViewController *__self =self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [__self initDecoder];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)initDecoder
{
    __weak PrivatePlayViewController *__self =self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [__self.imgView makeToastActivity];
    });
    dispatch_async(dispatch_get_global_queue(0 ,0), ^{
        [__self connection];
    });
}

-(void)connection
{
    BOOL bFlag = [self.decodeImp connection:_privateSrc];
    __weak PrivatePlayViewController *__self =self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [__self.imgView hideToastActivity];
    });
    if (bFlag)
    {
        DLog(@"连接成功");
        self.bPlaying = YES;
   //     self.bDecoding = NO;
        if(_decoder==nil)
        {
            _decoder = [[XLDecoder alloc] initWithDecodeSource:_privateSrc];
            [self.decodeImp decoder_init:_decoder];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NS_PLAY_VIEW_CLICK_VC object:self];
        [self startPlay];
    }
    else
    {
        DLog(@"连接失败");
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [__self.imgView makeToast:XCLocalized(@"connectFail")];
        });
        [self stopVideo];
        //停止视频操作,发送失败通知
    }
}

-(BOOL)stopVideo
{
    self.bPlaying = NO;
    _privateSrc = nil;
    __weak PrivatePlayViewController *__weakSelf = self;
    dispatch_async(dispatch_get_main_queue(),
    ^{
         [__weakSelf.imgView hideToastActivity];
         [__weakSelf.imgView setImage:nil];
    });
    [[NSNotificationCenter defaultCenter] postNotificationName:NS_CLOSE_DIRECT_VC object:self.strKey];
    return YES;
}
#pragma mark 视频切换
-(BOOL)switchCode:(int)nCode
{
    if (self.nCodeType == nCode) {
        return YES;
    }
    self.bPlaying = NO;
    self.bDecoding = YES;
    
    
    
    __weak PrivatePlayViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [__self.imgView makeToast:XCLocalized(@"videoSwitch")];
    });
    _privateSrc = nil;
    [_decoder stopDecode];
    _decoder = nil;
    
    PrivateSource *privateSrc = [[PrivateSource alloc] initWithPath:self.strNO devName:self.strDevName code:nCode];
    self.bDecoding = NO;
    _privateSrc = privateSrc;
    _privateSrc.strKey = self.strKey;
    self.nCodeType = nCode;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [__self initDecoder];
    });
    return YES;
}

@end
