//
//  RTSPPlayViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/31.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "RTSPPlayViewController.h"
#import "RTSPSource.h"
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
        _decoder = [[XLDecoder alloc] initWithDecodeSource:_rtspSrc];
        self.bPlaying = YES;
        [self.decodeImp decoder_init:_decoder];
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


-(BOOL)stopPlay
{
    [super stopPlay];
     
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

@end
