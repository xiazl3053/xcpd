//
//  XLDecoder.m
//  XCMonit_Ip
//
//  Created by 夏钟林 on 15/3/13.
//  Copyright (c) 2015年 夏钟林. All rights reserved.
//

#import "XLDecoder.h"
#import "IDecodeSource.h"
#import "DecoderPublic.h"
#import "P2PInitService.h"
#import "XCNotification.h"

extern "C"
{
    #include "libavformat/avformat.h"
    #include "libswscale/swscale.h"
}

@interface XLDecoder()
{
    AVFrame *pFrame;
    AVPicture _picture;
    struct SwsContext *_swsContext;
    BOOL _pictureValid;
    BOOL bStop;
    AVCodecContext *pCodecCtx;
    CGFloat pts;
    CGFloat fSrcWidth,fSrcHeight;
    
}
@end



@implementation XLDecoder


//-(void)dealloc
//{
//    [self closeScaler];
//    avcodec_free_frame(&pFrame);
//    [[[P2PInitService sharedP2PInitService] getTheLock] lock];
//    if(pCodecCtx)
//    {
//        avcodec_close(pCodecCtx);
//    }
//    [[[P2PInitService sharedP2PInitService] getTheLock] unlock];
//    _decodeSrc = nil;
//}

-(id)initWithDecodeSource:(IDecodeSource *)source
{
    self = [super initWithDecodeSource:source];
    _decodeSrc = source;
    av_register_all();
    avcodec_register_all();
    return self;
}
-(void)decoderInit
{
    AVCodec *pCodec = avcodec_find_decoder(AV_CODEC_ID_H264);
    pCodecCtx = avcodec_alloc_context3(pCodec);
    [[[P2PInitService sharedP2PInitService] getTheLock] lock];
    if(avcodec_open2(pCodecCtx,pCodec, nil)!=0)
    {
        DLog(@"error");
    }
    [[[P2PInitService sharedP2PInitService] getTheLock] unlock];
    
    pFrame = avcodec_alloc_frame();
}
-(NSArray*)decodeFrame
{
    NSMutableArray *result = [NSMutableArray array];
    AVPacket packet;
    av_init_packet(&packet);
    int nGot;
    BOOL bFinish=NO;
    CGFloat fStart = 0;
    while (!bFinish)
    {
        if (bStop)
        {
            DLog(@"从解码器中退出");
            return result;
        }
        NSData *frameData = [_decodeSrc getNextFrame];
        if (!pCodecCtx || !pFrame)
        {
            return result;
        }
        if (frameData)
        {
            packet.size = (int)frameData.length;
            unsigned char* pub = (unsigned char*)malloc(frameData.length);
            memcpy(pub,[frameData bytes],frameData.length);
            packet.data = pub;
            
            int nTemp = avcodec_decode_video2(pCodecCtx,pFrame,&nGot,&packet);
            if (nGot)
            {
                KxVideoFrame *frame = [self handleVideoFrame];
                if(frame)
                {
                    bFinish = YES;
                   [result addObject:frame];
                }
                if(nTemp==0 || nTemp ==-1)
                {
                    free(pub);
                    frameData = nil;
                    continue;
                }
            }
            else
            {
                free(pub);
                return result;
            }
            free(pub);
        }
        else
        {
            //等待多次没有数据，直接返回
            [NSThread sleepForTimeInterval:0.03f];
            fStart += 0.03f;
            if (fStart>=60 && !bStop)
            {
                DLog(@"send Message,%@---%d",_decodeSrc.strName,_decodeSrc.nChannel);
                NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[XCLocalized(@"Disconnect"),_decodeSrc.strName,[NSString stringWithFormat:@"%d",_decodeSrc.nChannel]] forKeys:@[@"reason",@"NO",@"channel"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:NSCONNECT_P2P_DISCONNECT object:dict];
                bStop = YES;
            }
        }
        frameData = nil;
    }
    av_free_packet(&packet);
    return result;
}

#pragma mark rgb
- (BOOL) setupScaler
{
    [self closeScaler];
    DLog(@"新的:%d-%d",pCodecCtx->width,pCodecCtx->height);
    _pictureValid = avpicture_alloc(&_picture,
                                    PIX_FMT_RGB24,
                                    pCodecCtx->width,
                                    pCodecCtx->height) == 0;
    if (!_pictureValid)
        return NO;
    _swsContext = sws_getCachedContext(_swsContext,
                                       pCodecCtx->width,
                                       pCodecCtx->height,
                                       pCodecCtx->pix_fmt,
                                       pCodecCtx->width,
                                       pCodecCtx->height,
                                       PIX_FMT_RGB24,
                                       SWS_FAST_BILINEAR,
                                       NULL, NULL, NULL);
    
    return _swsContext != NULL;
}
#pragma mark 关闭转换
- (void) closeScaler
{
    if (_swsContext) {
        sws_freeContext(_swsContext);
        _swsContext = NULL;
    }
    
    if (_pictureValid) {
        avpicture_free(&_picture);
        _pictureValid = NO;
    }
}

#pragma mark yuv 转换
- (KxVideoFrame *) handleVideoFrame
{
    if (!pFrame->data[0])
        return nil;
    
    KxVideoFrame *frame;
    if (fSrcWidth != pCodecCtx->width || fSrcHeight != pCodecCtx->height)
    {
        DLog(@"111111 reset!");
        avcodec_flush_buffers(pCodecCtx);
        [self setupScaler];
        fSrcWidth = pCodecCtx->width;
        fSrcHeight = pCodecCtx->height;
        DLog(@"fail setup video scaler");
        return nil;
    }
    sws_scale(_swsContext,
              (const uint8_t **)pFrame->data,
              pFrame->linesize,
              0,
              pCodecCtx->height,
              _picture.data,
              _picture.linesize);
    KxVideoFrameRGB *rgbFrame = [[KxVideoFrameRGB alloc] init];
    rgbFrame.linesize = _picture.linesize[0];
    rgbFrame.rgb = [NSData dataWithBytes:_picture.data[0]
                                  length:rgbFrame.linesize * pCodecCtx->height];
    frame = rgbFrame;
    frame.width = pCodecCtx->width;
    frame.height = pCodecCtx->height;

    frame.duration = 1.0 / 25;
    pts += frame.duration;
    frame.position = pts;
    return frame;
}

-(void)stopDecode
{
    bStop = YES;
    
}

-(CGFloat)getPosition
{
    return pts;
}

-(void)dealloc
{
    [self closeScaler];
    [[[P2PInitService sharedP2PInitService] getTheLock] lock];
    avcodec_close(pCodecCtx);
    [[[P2PInitService sharedP2PInitService] getTheLock] unlock];
    pCodecCtx = NULL;
    avcodec_free_frame(&pFrame);
    _decodeSrc = nil;
    DLog(@"释放ffmpeg");
}

-(void)setPosition:(CGFloat)fValue
{
    pts = fValue;
}


@end
