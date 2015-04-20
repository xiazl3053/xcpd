



#import "RecordSource.h"
#import "UtilsMacro.h"
#import "RecordingService.h"
#include "libavformat/avformat.h"
#include <sys/time.h>
#import "XCNotification.h"

int readFile(void *opaque, uint8_t *buf, int buf_size)
{
    int size = buf_size;
    int ret = -1;
    struct timeval tv;
    gettimeofday(&tv,NULL);
    FILE *recordFile = (FILE *)opaque;
    do{
        size = (int)fread(buf, 1, 1024, recordFile);
        if (size>0)
        {
            ret = 0;
        }
        else if(size==0)
        {
            DLog(@"文件读取完毕");
            return -1;
        }
    }while(ret);
    return size;
}


@interface RecordSource()
{
    FILE *file_record;
    long file_size;
    AVFormatContext *pFormatCtx;
    BOOL bRecord;
    NSFileHandle *fileHandle;
    NSUInteger nAllCount;
    RecordModel *recordModel;
}

@end





@implementation RecordSource


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
    NSString *strFile = [NSString stringWithFormat:@"%@/record/%@",kLibraryPath,self.strPath];
    file_record = fopen([strFile UTF8String], "r");
    if(file_record==nil)
    {
        DLog(@"打开文件失败");
        return NO;
    }
    long curpos;
    curpos = ftell(file_record);
    fseek(file_record, 0, SEEK_END);
    file_size = ftell(file_record);
    fseek(file_record, curpos, SEEK_SET);
    
    AVInputFormat* pAvinputFmt = NULL;
    AVIOContext		*pb = NULL;
    uint8_t	*buf = NULL;
    buf = (uint8_t*)malloc(sizeof(uint8_t)*1024);
    pb = avio_alloc_context(buf, 1024, 0, file_record, readFile,NULL, NULL);
    pAvinputFmt = av_find_input_format("H264");
    pFormatCtx = avformat_alloc_context();
    pFormatCtx->pb = pb;
    pFormatCtx->max_analyze_duration = 1 * AV_TIME_BASE;
    
    if(avformat_open_input(&pFormatCtx,[strFile UTF8String],pAvinputFmt, NULL) != 0 )
    {
        [self closeFile];
        DLog(@"录像数据很短");
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
    if (!pFormatCtx)
    {
        return nil;
    }
    while (YES)
    {
        nRef = av_read_frame(pFormatCtx,&packet);
        if (nRef>=0)
        {
            NSData *data = [NSData dataWithBytes:packet.data length:packet.size];
            av_free_packet(&packet);
            if (bRecord)
            {
                [fileHandle writeData:data];
                [fileHandle seekToEndOfFile];
            }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:NS_RECORD_DONE_VC object:self.strKey];
}
/**
 *  资源释放
 */
-(void)destorySource
{
    [self closeFile];
}

-(id)initWithPath:(NSString *)strPath devName:(NSString *)strDevName
{
    self = [super init];
    self.strPath = strPath ;
    self.strName = strDevName;
    return self;
}

-(void)closeFile
{
    if (pFormatCtx)
    {
        pFormatCtx->interrupt_callback.opaque = NULL ;
        pFormatCtx->interrupt_callback.callback = NULL ;
        avformat_close_input(&pFormatCtx);
        pFormatCtx = NULL;
    }
    fclose(file_record);
}
-(void)dealloc
{
    [self destorySource];
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


-(void)setUpdatePosition:(CGFloat)fValue
{
    long nSize = floor(fValue*file_size);
    fseek(file_record, nSize, SEEK_SET);
}


@end