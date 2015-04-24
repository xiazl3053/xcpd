



#import "PrivateSource.h"
#import "private_protocol.h"
#include <netdb.h>
#include <sys/socket.h>
#include <sys/types.h>
#import "XCNotification.h"
#include <arpa/inet.h>
#import "RtspInfo.h"
#include <sys/time.h>
#import "RecordingService.h"

#import "RecordModel.h"

#include "libavformat/avformat.h"
#include "libswscale/swscale.h"

int getVideoFrame(void *userData,unsigned char *cFrame,int nLength)
{
    int size = nLength;
    int ret = -1;
    struct timeval tv;
    gettimeofday(&tv,NULL);
    NSMutableArray *aryVideo = (__bridge NSMutableArray *)userData;
    do{
        struct timeval result;
        gettimeofday(&result,NULL);
        @synchronized(aryVideo)
        {
            if (aryVideo.count>0)
            {
                NSData *data = [aryVideo objectAtIndex:0];
                size = (int)data.length;
                memcpy(cFrame, [data bytes], data.length);
                [aryVideo removeObjectAtIndex:0];
                ret = 0;
            }
        }
        if(result.tv_sec-tv.tv_sec>=30)
        {
            DLog(@"退出了");
            return -1;
        }
    }while(ret);
    return size;
}

@interface PrivateSource()
{
    private_protocol_info_t *info;
    NSMutableArray *_aryVideo;
    BOOL _bExit;
    AVFormatContext *pFormatCtx;
    CGFloat _fps;
    
    int nCodeType;
    BOOL bRecord;
    NSFileHandle *fileHandle;
    NSUInteger nAllCount;
    RecordModel *recordModel;
}

@end

@implementation PrivateSource


-(id)initWithPath:(NSString *)strPath devName:(NSString *)strDevName code:(int)nCode
{
    self = [super init];
    self.strPath = strPath;
    self.strName = strDevName;
    nCodeType = nCode;
    _fps=0;
    return self;
   
}

-(NSString *)getIPWithHostName:(const NSString *)hostName
{
    NSString *_strAddress;
    const char *hostN= [hostName UTF8String];
    struct hostent* phot;
    @try
    {
        phot = gethostbyname(hostN);
    }
    @catch (NSException *exception)
    {
        return nil;
    }
    struct in_addr ip_addr;
    if(phot)
    {
        memcpy(&ip_addr, phot->h_addr_list[0], 4);
        char ip[20] = {0};
        inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
        _strAddress = [NSString stringWithUTF8String:ip];
        return _strAddress;
    }
    else
    {
        return nil;
    }
}

/**
 *  建立连接
 *
 *  @param strSource NO或者其他内容
 *
 *  @return
 */
-(BOOL)connection:(NSString*)strSource
{
    //用户名、密码、ip地址、端口、通道、码流
    NSArray *aryCode = [self.strPath componentsSeparatedByString:@"@"];
    RtspInfo *rtspInfo = [[RtspInfo alloc] init];
    rtspInfo.strAddress = aryCode[0];
    rtspInfo.nPort = [aryCode[1] integerValue];
    rtspInfo.strUser = aryCode[2];
    rtspInfo.strPwd = aryCode[3];
    
    int nResult = [self protocolInit:rtspInfo path:@"3456789" channel:[aryCode[4] intValue] code:nCodeType];
    
    if (nResult==1)
    {
        while (!_fps)
        {
            [NSThread sleepForTimeInterval:0.3f];
        }
        
        if (_fps==-1)
        {
            return NO;
        }
        return YES;
    }
    return NO;
}

#pragma mark 私有协议
-(int)protocolInit:(RtspInfo*)rtspInfo path:(NSString *)strPath channel:(int)nChannel code:(int)nCode
{
    info = private_protocol_init();
    int ret = 0;
    if (info==NULL)
    {
        DLog(@"malloc info failed,out of memmory!");
        return 999;
    }
    _aryVideo = [NSMutableArray array];
    DLog(@"start login");
    @synchronized(self)
    {
        //新加入解析
        NSString *strAddress = [self getIPWithHostName:rtspInfo.strAddress];
        if (strAddress)
        {
            ret = private_protocol_login(info, inet_addr([strAddress UTF8String]), (int)rtspInfo.nPort, (char*)[rtspInfo.strUser UTF8String], (char*)[rtspInfo.strPwd UTF8String]);
        }
        else
        {
            ret = private_protocol_login(info, inet_addr([rtspInfo.strAddress UTF8String]), (int)rtspInfo.nPort, (char*)[rtspInfo.strUser UTF8String], (char*)[rtspInfo.strPwd UTF8String]);
        }
    }
    if(ret < 0)
    {
        DLog(@"login failed!");
        return 998;
    }
    DLog(@"login suc");
    if (_bExit)
    {
        return 996;
    }
    __weak PrivateSource *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0),
    ^{
        [weakSelf ffmpegInit];
    });
    ret = private_protocol_getStream(info,nChannel,nCode);
    if(ret==0)
    {
        info->aryVideo = (__bridge void*)_aryVideo;
    }
    else
    {
        return 997;
    }
    return 1;
}

#pragma mark 私有协议解码  ffmpeg初始化
-(BOOL)ffmpegInit
{
    av_register_all();
    avcodec_register_all();
    DLog(@"找到视频信息");
    _fps = 25;
    return YES;
}

/**
 *  获取下一帧码流
 *
 *  @return
 */
-(NSData*)getNextFrame
{
    if (!info)
    {
        return nil;
    }
    CGFloat fTime=0;
    while (YES)
    {
        if(_aryVideo.count==0)
        {
            [NSThread sleepForTimeInterval:0.1f];
            fTime += 0.1;
            if(fTime>30)
            {
                [self sendMessage];
                break;
            }
            continue;
        }
        else
        {
            @synchronized(_aryVideo)
            {
                NSData *data = [_aryVideo objectAtIndex:0];
                [_aryVideo removeObjectAtIndex:0];
                if (bRecord)
                {
                    [fileHandle writeData:data];
                    [fileHandle seekToEndOfFile];
                    nAllCount ++;
                }
                return data;
            }
        }
    }
//    AVPacket packet;
//    av_init_packet(&packet);
//    int nRef ;
//    nRef = av_read_frame(pFormatCtx,&packet);
//    if (nRef>=0)
//    {
//        NSData *data = [NSData dataWithBytes:packet.data length:packet.size];
//        av_free_packet(&packet);
//        if (bRecord)
//        {
//            [fileHandle writeData:data];
//            [fileHandle seekToEndOfFile];
//            nAllCount++;
//        }
//        return data;
//    }
//    else
//    {
//        //发送失败信息
//        [self sendMessage];
//    }
//    av_free_packet(&packet);
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
//    if(pFormatCtx)
//    {
//        avformat_close_input(&pFormatCtx);
//    }
//    private_protocol_stop(&info);
//    
}

-(void)startRecording:(NSString *)strFile
{
    if (recordModel)
    {
        recordModel = nil;
    }
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

-(void)dealloc
{
    if (bRecord)
    {
        [self stopRecording];
    }
    @synchronized(_aryVideo)
    {
        [_aryVideo removeAllObjects];
    }
    _aryVideo = nil;
    private_protocol_stop(&info);
}

@end