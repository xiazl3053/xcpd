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
    dispatch_async(dispatch_get_global_queue(0, 0),
    ^{
          [__weakSelf initDecodeInfo];
    });
}

-(void)initDecodeInfo
{
    BOOL bFlag = [self.decodeImp connection:_ptpSource];
    __weak P2PPlayViewController *__weakSelf = self;
    if (bFlag)
    {
        DLog(@"连接成功?");
        _decoder = [[XLDecoder alloc] initWithDecodeSource:_ptpSource];
        self.bPlaying= YES;
        [self.decodeImp decoder_init:_decoder];
        [self startPlay];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectFail:) name:NSCONNECT_P2P_FAIL_VC object:nil];
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

@end
