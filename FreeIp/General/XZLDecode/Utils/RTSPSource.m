



#import "RTSPSource.h"

#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#import "RecordModel.h"
#import "XCNotification.h"
#import "RecordingService.h"


@interface RTSPSource()
{
    BOOL bRecord;
    NSFileHandle *fileHandle;
    NSUInteger nAllCount;
    RecordModel *recordModel;
    AVFormatContext *pFormatContext;
}

@end


@implementation RTSPSource


/**
 *  建立连接
 *
 *  @param strSource NO或者其他内容
 *
 *  @return
 */
-(BOOL)connection:(NSString*)strSource
{
    av_register_all();
    avcodec_register_all();
    avformat_network_init();
    pFormatContext = avformat_alloc_context();
    AVDictionary* options = NULL;
    av_dict_set(&options, "rtsp_transport", "tcp", 0);
    av_dict_set(&options, "stimeout", "3500000", 0);
    if(avformat_open_input(&pFormatContext,[self.strPath UTF8String],NULL,&options)!=0)
    {
        return NO;
    }
    return YES;
}

/**
 *  获取下一帧码流
 *
 *  @return
 */
-(NSData*)getNextFrame
{
    AVPacket packet;
    av_init_packet(&packet);
    int nRef ;
    if (!pFormatContext)
    {
        return nil;
    }
    while (YES)
    {
        nRef = av_read_frame(pFormatContext,&packet);
        if (nRef>=0)
        {
            NSData *data = [NSData dataWithBytes:packet.data length:packet.size];
            if (bRecord)
            {
                [fileHandle writeData:data];
                [fileHandle seekToEndOfFile];
                nAllCount++;
            }
            av_free_packet(&packet);
            return data;
        }
        else
        {
            [self sendMessage];
            break;
        }
    }
    av_free_packet(&packet);
    return  nil;
}
/**
 *    消息推送
 */
-(void)sendMessage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NSCONNECT_P2P_DISCONNECT object:self.strKey];
}
/**
 *  资源释放
 */
-(void)destorySource
{
  
}

-(id)initWithPath:(NSString *)strPath devName:(NSString *)strDevName
{
    self = [super init];
    self.strPath = strPath ;
    self.strName = strDevName;
    return self;
}


-(void)dealloc
{
    if(bRecord)
    {
        [self stopRecording];
    }
    if(pFormatContext)
    {
        avformat_close_input(&pFormatContext);
    }
}
-(void)startRecording:(NSString *)strFile
{
    if (recordModel)
    {
        recordModel = nil;
    }
    DLog(@"strpath;%@",self.strPath);
    recordModel = [[RecordModel alloc] init];
    recordModel.imgFile = strFile;
    recordModel.strDevName = self.strName;
    if([RecordingService startRecordInfo:recordModel])
    {
        if(fileHandle)
        {
            [fileHandle closeFile];
            fileHandle= nil;
        }
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:recordModel.strAbltFile];
        
        bRecord = YES;
    }
    nAllCount ++;
}

-(void)stopRecording
{
    bRecord = NO;
    [fileHandle closeFile];
    recordModel.strDevNO = self.strPath;
    recordModel.nFrameBit = 25;
    recordModel.nFramesNum = nAllCount;
    [RecordingService stopRecordInfo:recordModel];
}

@end