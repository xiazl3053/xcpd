//
//  HistoryViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/4/10.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "HistoryViewController.h"
#import "RecordSource.h"
#import "UIView+Extension.h"
#import "XCButton.h"
#import "Toast+UIView.h"
#import "ProgressHUD.h"
#import "XLDecoder.h"
#import "UtilsMacro.h"





static NSString * formatTimeInterval(CGFloat seconds, BOOL isLeft)
{
    seconds = MAX(0, seconds);
    
    int s = seconds;
    int m = s / 60;
    int h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    return [NSString stringWithFormat:@"%@%d:%0.2d:%0.2d", isLeft ? @"-" : @"", h,m,s];
}








@interface HistoryViewController ()
{
    UIView *recordView;
    long lCount;
    RecordModel *_record;
    int nAllTime;
}
@property (nonatomic,strong) RecordSource *recordSrc;
@property (nonatomic,strong) XLDecoder *decoder;
@end

@implementation HistoryViewController

-(id)initWithPath:(NSString *)strPath name:(NSString *)strDevName
{
    self = [super initWithPath:strPath name:strDevName];
    
    _recordSrc = [[RecordSource alloc] initWithPath:strPath devName:strDevName];
    self.strNO = strPath;
    self.strDevName = strDevName;
    return self;
}

-(id)initWithRecordInfo:(RecordModel *)record
{
    self = [super initWithRecordInfo:record];
    _record = record;
    _recordSrc = [[RecordSource alloc] initWithPath:record.strFile devName:record.strDevName];
    self.strDevName = _record.strDevName;
    self.strNO = _record.strFile;
    return self;
}

-(void)setStrKey:(NSString *)strKey
{
    [super setStrKey:strKey];
    _recordSrc.strKey = self.strKey;
}

-(void)loadView
{
    [super loadView];
}

-(void)initRecordView
{
    recordView = [[UIView alloc] initWithFrame:Rect(0,self.view.height-200,700, 136)];
    [recordView setBackgroundColor:RGB(37, 40, 41)];
    
    UILabel *lblStart = [[UILabel alloc] initWithFrame:Rect(25, 38, 80, 20)];
    
    UILabel *lblEnd = [[UILabel alloc] initWithFrame:Rect(605, 38, 80, 20)];
    
    UISlider* mySlider = [ [ UISlider alloc ] initWithFrame:Rect(110, 38, 480, 20)];
    mySlider.tag = 10002;
    
    [recordView addSubview:lblStart];
    [lblStart setTextColor:[UIColor whiteColor]];
    [lblStart setText:@"00:00:00"];
    lblStart.tag = 10001;
    
    nAllTime = (int)_record.nFramesNum/_record.nFrameBit;
    [recordView addSubview:lblEnd];
    
    [lblEnd setText:formatTimeInterval(nAllTime,NO)];
    [lblEnd setTextColor:[UIColor whiteColor]];
    
    [recordView addSubview:mySlider];
    UIImage *thumbImage = [UIImage imageNamed:@"progress_btn"];
    [mySlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [mySlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [mySlider addTarget:self action:@selector(sliderDragUp:) forControlEvents:UIControlEventTouchUpInside];
    
    XCButton *btnPlay = [[XCButton alloc] initWithFrame:Rect(328, 70, 44, 44) normal:@"his_play" high:@"" select:@"his_pause"];
    btnPlay.tag = 10003;
    
    XCButton *btnSlow = [[XCButton alloc] initWithFrame:Rect(224,70,44,44) normal:@"his_back" high:@"his_back_h"];
    
    XCButton *btnForward = [[XCButton alloc] initWithFrame:Rect(432, 70, 44, 44) normal:@"his_forward" high:@"his_forward_h"];
    
    [recordView addSubview:btnPlay];
    
    [recordView addSubview:btnSlow];
    
    [recordView addSubview:btnForward];
    
    [btnPlay addTarget:self action:@selector(playSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [btnForward addTarget:self action:@selector(forwordVideo) forControlEvents:UIControlEventTouchUpInside];
    [btnSlow addTarget:self action:@selector(slowVideo) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:recordView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initRecordView];
    lCount = 0;
    __weak HistoryViewController *__self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [__self RTSPInitDecoder];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)RTSPInitDecoder
{
    
    
    __weak HistoryViewController *__self = self;
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
    BOOL bFlag = [self.decodeImp connection:_recordSrc];
    __weak HistoryViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [__self.imgView makeToastActivity];
    });
    if(bFlag)
    {
        _decoder = [[XLDecoder alloc] initWithDecodeSource:_recordSrc];
        self.bPlaying = YES;
        [self.decodeImp decoder_init:_decoder];
        [self startPlay];
        //控件修改
        __weak UIButton *__btnSender = (UIButton *)[recordView viewWithTag:10003];
        dispatch_async(dispatch_get_main_queue(),
        ^{
               [__btnSender setSelected:YES];
        });
        //[];
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

-(void)startPlay
{
    [super startPlay];
    lCount++;
    if (lCount%5==0)
    {
        [self updatePosition];
    }
}

-(void)playSwitch:(UIButton *)sender
{
    //播放中设置selected=yes，其余selected=no
    if (sender.selected)
    {
        sender.selected = NO;
        [self pauseVideo];
    }
    else
    {
        sender.selected = YES;
        self.bPlaying = YES;
        self.bDecoding = NO;
        __weak HistoryViewController *__weakSelf = self;
        dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 0.025 * NSEC_PER_SEC );
        dispatch_after(after, dispatch_get_global_queue(0, 0),
        ^{
             [__weakSelf startPlay];
        });
    }
}

-(void)pauseVideo
{
    self.bDecoding = YES;
    self.bPlaying = NO;
}

-(void)updatePosition
{
    __weak UILabel *__lblStart = (UILabel *)[recordView viewWithTag:10001];
    __block CGFloat __fProgress = (CGFloat)[_decoder getPosition]/nAllTime;
    __block int __nCurTime = (int)[_decoder getPosition];
    __weak UISlider *__progView = (UISlider *)[recordView viewWithTag:10002];
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
            __progView.value = __fProgress;
            __lblStart.text = formatTimeInterval(__nCurTime, NO);
    });
    
}
-(void)sliderDragUp:(UISlider*)sender
{
          CGFloat fValue = sender.value;
          [_recordSrc setUpdatePosition:fValue];
          CGFloat fPosition = fValue * nAllTime;
          [_decoder setPosition:fPosition];

}

-(void)forwordVideo
{
    CGFloat fTime=[_decoder getPosition]+1;
    if (fTime>nAllTime) {
        return;
    }
    CGFloat fValue = (CGFloat)fTime/nAllTime;
    ((UISlider *)[recordView viewWithTag:10002]).value=fValue;
    [_recordSrc setUpdatePosition:fValue];
    [_decoder setPosition:fTime];
}

-(void)slowVideo
{
    CGFloat fTime=[_decoder getPosition]-1;
    if (fTime<0) {
        fTime = 0;
    }
    
    CGFloat fValue = (CGFloat)fTime/nAllTime;
    ((UISlider *)[recordView viewWithTag:10002]).value=fValue;
    [_recordSrc setUpdatePosition:fValue];
    [_decoder setPosition:fTime];
}

@end
