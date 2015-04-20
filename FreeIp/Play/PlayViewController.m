//
//  PlayViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/23.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "PlayViewController.h"
#import "DecoderPublic.h"
#import "UIView+Extension.h"
#import "UtilsMacro.h"
#import "Toast+UIView.h"
#import "CaptureService.h"

@interface PlayViewController ()
{
    CGFloat lastX,lastY,lastScale;
    CGFloat fWidth,fHeight;
    BOOL bFlag;
    CGFloat fLongTime;
}

@end

@implementation PlayViewController

-(id)initWithNO:(NSString *)strNO name:(NSString *)strDevName channel:(int)nChannel code:(int)nCode
{
    self = [super init];
    _decodeImp = [[XLDecoderServiceImpl alloc] init];
    _strNO = strNO;
    _nChannel = nChannel;
    _strDevName = strDevName;
    fLongTime = 0.025;
    return  self;
}

-(id)initWithPath:(NSString *)strPath name:(NSString *)strDevName
{
    self = [super init];
    _decodeImp = [[XLDecoderServiceImpl alloc] init];
    _strNO = strPath;
    _strDevName = strDevName;
    fLongTime = 0.025;
    return self;
}

-(id)initWithRecordInfo:(RecordModel *)record
{
    self = [super init];
    _decodeImp = [[XLDecoderServiceImpl alloc] init];
    _strNO = record.strFile;
    fLongTime = 0.04;
    _strDevName = record.strDevName;
    return self;
}

-(void)setFrame:(CGRect)frame
{
    _frame = frame;
}

//-(void)loadView
//{
//    self.view = [[UIView alloc] initWithFrame:Rect(0, 0, _frame.size.width, _frame.size.height)];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _videoFrames = [NSMutableArray array];
    _imgView = [[UIImageView alloc] initWithFrame:Rect(0, 0, _frame.size.width, _frame.size.height)];
    _imgView.contentMode = UIViewContentModeScaleToFill;
    [_imgView setUserInteractionEnabled:YES];
    [self.view addSubview:_imgView];
    
//    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchEvent:)];
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEvent:)];
//    [_imgView addGestureRecognizer:panGesture];
//    [_imgView addGestureRecognizer:pinchGesture];
}

-(void)panEvent:(UIPanGestureRecognizer*)sender
{
    if ([sender state] == UIGestureRecognizerStateBegan) {
        CGPoint curPoint = [sender locationInView:self.view];
        lastX = curPoint.x;
        lastY = curPoint.y;
        return;
    }
    CGPoint curPoint = [sender locationInView:self.view];
    CGFloat frameX = (_imgView.x + (curPoint.x-lastX)) > 0 ? 0 : (abs(_imgView.x+(curPoint.x-lastX))+fWidth >= _imgView.width ? -(_imgView.width-fWidth) : (_imgView.x+(curPoint.x-lastX)));
    CGFloat frameY =(_imgView.y + (curPoint.y-lastY))>0?0: (abs(_imgView.y+(curPoint.y-lastY))+fHeight >= _imgView.height ? -(_imgView.height-fHeight) : (_imgView.y+(curPoint.y-lastY)));
    _imgView.frame = Rect(frameX,frameY , _imgView.width, _imgView.height);
    lastX = curPoint.x;
    lastY = curPoint.y;
}

-(void)pinchEvent:(UIPinchGestureRecognizer*)sender
{
    DLog(@"点击事件");
    if([sender state] == UIGestureRecognizerStateBegan) {
        //   lastScale = 1.0;
        return;
    }
    CGFloat glWidth = _imgView.frame.size.width;
    CGFloat glHeight = _imgView.frame.size.height;
    CGFloat fScale = [sender scale];
    
    if (_imgView.frame.size.width * [sender scale] <= fWidth)
    {
        lastScale = 1.0f;
        _imgView.frame = Rect(0, 0, fWidth, fHeight);
    }
    else
    {
        lastScale = 1.5f;
        CGPoint point = [sender locationInView:self.view];
        DLog(@"point:%f--%f",point.x,point.y);
        CGFloat nowWidth = glWidth*fScale>fWidth*4?fWidth*4:glWidth*fScale;
        CGFloat nowHeight =glHeight*fScale >fHeight* 4?fHeight*4:glHeight*fScale;
        _imgView.frame = Rect(fWidth/2 - nowWidth/2,fHeight/2- nowHeight/2,nowWidth,nowHeight);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startPlay
{
    if(_bPlaying)
    {
        if(_videoFrames.count>0)
        {
            if(!bFlag)
            {
                __weak PlayViewController *__weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [__weakSelf.imgView hideToastActivity];
                });
            }
            [self updatePlayUI];
        }
        if (_videoFrames.count==0)
        {
            //解码开启
            [self decodeAsync];
        }
        __weak PlayViewController *__weakSelf = self;
        dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, fLongTime * NSEC_PER_SEC );
        dispatch_after(after, dispatch_get_global_queue(0, 0),
        ^{
           [__weakSelf startPlay];
        });
    }
}
-(CGFloat)updatePlayUI
{
    CGFloat interval = 0;
    KxVideoFrame *frame;
    @synchronized(_videoFrames)
    {
        if (_videoFrames.count > 0)
        {
            frame = _videoFrames[0];
            [_videoFrames removeObjectAtIndex:0];
        }
    }
    if (frame)
    {
        __weak PlayViewController *__weakSelf = self;
        KxVideoFrameRGB *rgbFrame = (KxVideoFrameRGB*)frame;
        __weak KxVideoFrameRGB *__rgbFrame = rgbFrame;
        dispatch_sync(dispatch_get_main_queue(),
                      ^{
                          [__weakSelf.imgView setImage:[__rgbFrame asImage]];
                      });
        rgbFrame = nil;
        interval = frame.duration;
        frame = nil;
        
    }
    return interval;
}
-(void)decodeAsync
{
    if (!_bPlaying || _bDecoding)
    {
        return ;
    }
    _bDecoding = YES;
    __weak PlayViewController *__weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL bGood = YES;
        while (bGood)
        {
            NSArray *array = [__weakSelf.decodeImp decodeFrame];
            bGood = NO;
            if (array && array.count>0)
            {
                @synchronized(__weakSelf.videoFrames)
                {
                    for (KxVideoFrame *frame in array)
                    {
                        [__weakSelf.videoFrames addObject:frame];
                    }
                }
            }
        }
        __weakSelf.bDecoding = NO;
    });
}

-(void)dealloc
{
    _bPlaying = NO;
    _bDecoding = NO;
    _imgView = nil;
    _decodeImp = nil;
    @synchronized(_videoFrames)
    {
        [_videoFrames removeAllObjects];
    }
    _videoFrames = nil;
}
-(BOOL)stopPlay
{
    _bPlaying = NO;
    __weak PlayViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [__self.imgView setHidden:YES];
    });
    self.imgView = nil;
    [self.decodeImp destory];
    
    return  YES;
}
-(BOOL)captureView
{
    return [CaptureService captureToPhotoRGB:_imgView devName:_strDevName];
}


-(BOOL)recordStart
{
    NSString *strFile = [CaptureService captureRecordRGB:_imgView];
    if (strFile==nil)
    {
        return NO;
    }
    self.bRecording = YES;
    [self.decodeImp startRecord:strFile];
    return YES;
}

-(BOOL)recordStop
{
    [self.decodeImp stopRecord];
    self.bRecording = NO;
    return NO;
}

-(void)setImgFrame:(CGRect)frame
{
    self.imgView.frame = frame;
}

@end

