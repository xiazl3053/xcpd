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
#import "UIView+Extension.h"
#import "UtilsMacro.h"
#import "Toast+UIView.h"
#import "CaptureService.h"

#define kScaleMax 2.0

@interface PlayViewController ()
{
    CGFloat lastX,lastY,lastScale;
    CGFloat fWidth,fHeight;
    BOOL bFlag;
    CGFloat fLongTime;
    CGFloat fSrcWidth,fSrcHeight;
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
    _nCodeType = nCode;
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
//
//-(void)setFrame:(CGRect)frame
//{
//    _frame = frame;
//}

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
    [self.view insertSubview:_imgView atIndex:0];
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
    self.imgView.frame = Rect(0, 0, frame.size.width, frame.size.height);
    fSrcWidth = frame.size.width;
    fSrcHeight = frame.size.height;
    
}

-(BOOL)switchCode:(int)nCode
{
    if (nCode ==_nCodeType) {
        return NO;
    }
    
    return NO;
}

-(void)setImgScale:(CGFloat)fScale
{
    CGFloat glWidth = _imgView.width;
    CGFloat glHeight = _imgView.height;
    
    if (_imgView.width * fScale <= fSrcWidth) {
        _imgView.frame = Rect(0, 0, fSrcWidth, fSrcHeight);
    }
    else
    {
        CGFloat nowWidth = glWidth * fScale > fSrcWidth * kScaleMax ? fSrcWidth * kScaleMax : glWidth * fScale ;
        
        CGFloat nowHeight = glHeight * fScale > fSrcHeight * kScaleMax ? fSrcHeight * kScaleMax : glHeight * fScale ;
        
        _imgView.frame = Rect(fSrcWidth/2-nowWidth/2, fSrcHeight/2-nowHeight/2, nowWidth, nowHeight);
    }
}

-(void)setImgScale:(CGFloat)fScale point:(CGPoint)curPoint
{
    CGFloat glWidth = _imgView.width;
    CGFloat glHeight = _imgView.height;
    
    if (_imgView.width * fScale <= fSrcWidth) {
        _imgView.frame = Rect(0, 0, fSrcWidth, fSrcHeight);
    }
    else
    {
        CGFloat fOrgX,fOrgY;
        if (curPoint.x <= fSrcWidth/2) {
            fOrgX = curPoint.x;//x正数    1
        }
        else
        {
            fOrgX = fSrcWidth/2-curPoint.x;//X必须为负   2
        }
        
        if (curPoint.y <= fSrcHeight/2) {
            fOrgY = curPoint.y;//3
        }
        else
        {
            fOrgY = fSrcHeight/2-curPoint.y;//至负      4
        }
        //1 3     A     1   4     B
        //2 3     C     2   4     D
        
        //   +x   x或正  或负
        CGFloat nowWidth = glWidth * fScale > fSrcWidth * kScaleMax ? fSrcWidth * kScaleMax : glWidth * fScale ;
        
        CGFloat nowHeight = glHeight * fScale > fSrcHeight * kScaleMax ? fSrcHeight * kScaleMax : glHeight * fScale ;
        
        CGFloat fBit = fSrcWidth/nowWidth;
        
        DLog(@"fBit:%f",fBit);
        
        fBit = 0.5;
        
        
        //1.根据放大比例来调整位移
        //2.fsrcWidth/2-nowWidth/2
        CGFloat lastNewX = fSrcWidth/2-nowWidth/2+fOrgX*fBit;
        CGFloat lastNewY = fSrcHeight/2-nowHeight/2+fOrgY*fBit;
        if (lastNewX >= 0)
        {
            lastNewX = 0;
//            DLog(@"lastNewX = 0;调整");
        }
        else if(lastNewX+nowWidth <= fSrcWidth)
        {
            lastNewX = fSrcWidth-nowWidth;
//            DLog(@"lastNewX = fSrcWidth-nowWidth;调整");
        }
        
        if (lastNewY >=0 ) {
            lastNewY = 0;
//            DLog(@"lastNewY = 0;调整");
        }
        else if(lastNewY + nowHeight <= fSrcHeight)
        {
            lastNewY = fSrcHeight-nowHeight;
//            DLog(@"lastNewY + nowHeight <= fSrcHeight:调整");
        }
        _imgView.frame = Rect(lastNewX,lastNewY, nowWidth, nowHeight);
    }
    
}

-(void)panStart:(CGPoint)curPoint
{
    lastX = curPoint.x;
    lastY = curPoint.y;
}

-(void)setImgPan:(CGPoint)curPoint
{
    CGFloat frameX = (_imgView.x + (curPoint.x-lastX)) > 0 ? 0 : (abs(_imgView.x+(curPoint.x-lastX))+fSrcWidth >= _imgView.width ? -(_imgView.width-fSrcWidth) : (_imgView.x+(curPoint.x-lastX)));
    CGFloat frameY =(_imgView.y + (curPoint.y-lastY))>0?0: (abs(_imgView.y+(curPoint.y-lastY))+fSrcHeight >= _imgView.height ? -(_imgView.height-fSrcHeight) : (_imgView.y+(curPoint.y-lastY)));
    _imgView.frame = Rect(frameX,frameY , _imgView.width, _imgView.height);
    lastX = curPoint.x;
    lastY = curPoint.y;
}

@end

