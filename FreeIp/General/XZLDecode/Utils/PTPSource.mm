


#import "PTPSource.h"
#import "P2PSDKService.h"
#import "XCNotification.h"
#import "RecordModel.h"
#import "RecordingService.h"

#import "P2PInitService.h"
@interface PTPSource()
{
    RecvFile *recv;
    int nconnection;
    BOOL bDestorySDK;
    BOOL bRecord;
    BOOL bRun;
    NSFileHandle *fileHandle;
    NSUInteger nAllCount;
    RecordModel *recordModel;
}
@property (nonatomic,assign) BOOL bNotify;
@property (nonatomic,assign) int nNum;

@property (nonatomic,assign) BOOL bP2P;
@property (nonatomic,assign) BOOL bTran;
@end



@implementation PTPSource

-(id)initWithNo:(NSString *)strNO name:(NSString*)strDevName channel:(int)nChannel codeType:(int)nType
{
    self = [super init];
    if (self)
    {
        bRun = YES;
        self.strPath = strNO;
        self.nChannel = nChannel;
        self.strName = strDevName;
        _nCodeType = nType;
        nconnection = 1;
        _nNum = 0;
        _bNotify = YES;
    }
    return self;
}

-(BOOL)connectTran
{
    BOOL bReturn = recv->threadTran(_nCodeType);
    if (bReturn) {
        self.bTran = YES;
        return  YES;
    }
    return NO;
}

-(void)thread_gcd_PTP
{
    __weak PTPSource *__weakSelf = self;
    BOOL bThread = NO;
    __block BOOL __bThread = bThread;
    dispatch_async(dispatch_get_global_queue(0, 0),
    ^{
       BOOL bReturn = recv->threadP2P(__weakSelf.nCodeType);
       if (bReturn)
       {
           __weakSelf.bP2P = YES;
           DLog(@"P2P打洞成功");
           if (__weakSelf.bTran)//close TRAN
           {
               DLog(@"关闭转发");
               recv->closeTran();
           }
           else
           {
               DLog(@"开始P2P接收码流");
               __bThread = YES;
               //sendMessage
               nconnection = 0;
           }
       }
       else
       {
           DLog(@"P2P出现错误");
           __weakSelf.nNum++;
           if (!__weakSelf.bTran)//close TRAN
           {
               DLog(@"tran-p2p fail");
               if (__weakSelf.bNotify)
               {
                   if(__weakSelf.nNum==2)
                   {
                       recv->bDevDisConn = YES;
                       nconnection = -1;
                   }
               }
           }
           else
           {
               DLog(@"等待转发");
           }
       }
    });
    dispatch_async(dispatch_get_global_queue(0, 0),
    ^{
        DLog(@"start trans");
        BOOL bReturn = recv->threadTran(__weakSelf.nCodeType);
        if (bReturn)
        {
               __weakSelf.bTran = YES;
               DLog(@"转发成功");
               //转发
               if (__weakSelf.bP2P)//close TRAN
               {
                   DLog(@"P2P已成功,关闭转发");
                   recv->closeTran();
               }
               else
               {
                   DLog(@"P2P未成功,开始解码");
                   nconnection = 0;
               }
        }
        else
        {
            DLog(@"tran fail");
           __weakSelf.nNum++;
           if (!__weakSelf.bP2P)//close TRAN
           {
               if (__weakSelf.bNotify)
               {
                   if(__weakSelf.nNum==2)
                   {
                       nconnection = -1;
                   }
               }
           }
        }       
    });
}

-(BOOL)createP2PSdk
{
    P2PSDKClient *sdk = [[P2PInitService sharedP2PInitService] getP2PSDK];
    if (!sdk)
    {
        return  NO;
    }
    if(!recv)
    {
        recv = new RecvFile(sdk,0,self.nChannel);
    }
    return YES;
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
    if(![self createP2PSdk])
    {
        return NO;
    }
    recv->peerName = [self.strPath UTF8String];
    
    [self thread_gcd_PTP];
    
    while (nconnection)
    {
        if (nconnection==-1)
        {
            DLog(@"??????");
            return NO;
        }
        [NSThread sleepForTimeInterval:0.8f];
    }
    recv->strKey = self.strKey;
    return YES;
}

/**
 *  获取下一帧码流
 *
 *  @return
 */
-(NSData*)getNextFrame
{
    if (!recv)
    {
        return nil;
    }
    CGFloat fTime=0;
    while (bRun)
    {
        if (!recv)
        {
            return nil;
        }
        if(recv->aryVideo.count==0)
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
            if(!recv){return nil;}
            @synchronized(recv->aryVideo)
            {
                NSData *data = [recv->aryVideo objectAtIndex:0];
                [recv->aryVideo removeObjectAtIndex:0];
                if (bRecord)
                {
                    unsigned char *cByte=(unsigned char*)malloc(6);
                    [data getBytes:cByte length:6];
                    if(cByte[4]==0x67)
                    {
                        DLog(@"psp Frame!");
                        nAllCount ++;
                    }
                    else if(cByte[4]==0x61 && nAllCount>0)
                    {
                        DLog(@"p FRAME");
                        nAllCount ++;
                    }
                    if(nAllCount!=0)
                    {
                        [fileHandle writeData:data];
                        [fileHandle seekToEndOfFile];
                    }
                }
                return data;
            }
        }
    }
    return nil;
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

-(int)getSource
{
    if (_bP2P)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}
#pragma mark 码流切换
-(BOOL)switchP2PCode:(int)nCode
{
    DLog(@"目标码流:%d",nCode);
    _nSwitchcode = NO;
    if(recv)
    {
          BOOL bReturn = recv->swichCode(nCode);
          if(bReturn)
          {
              _nSwitchcode = YES;
              return YES;
          }
          else
          {
              _nSwitchcode = NO;
              return NO;
          }
    }
    return  NO;
}
#pragma mark 先一步停止P2P或者转发操作，在dealloc前调用
-(void)releaseDecode
{
    DLog(@"外面改了");
    _bNotify = NO;
    if(recv)
    {
        DLog(@"停止");
        recv->bDevDisConn = NO;
        recv->bExit = NO;
        nconnection = 1;
    }
    
}
#pragma mark 销毁Decode
-(void)dealloc
{
    if(bRecord)
    {
        [self stopRecording];
    }
    DLog(@"释放了？");
    if(recv)
    {
        recv->StopRecv();
        recv = NULL;
    }
    if (bDestorySDK)
    {
        [[P2PInitService sharedP2PInitService] setP2PSDKNull];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NS_SWITCH_TRAN_OPEN_VC object:nil];
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
    nAllCount = 0;
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
}

-(void)stopRecording
{
    bRecord = NO;
    [fileHandle closeFile];
    recordModel.strDevNO = self.strPath;
    recordModel.nFrameBit = 25;
    recordModel.nFramesNum = nAllCount;
    DLog(@"nAllCount:%d",(int)nAllCount);
    [RecordingService stopRecordInfo:recordModel];
}

/*
          数据库记录添加编写
          1.开始、包含一个抓拍动作的调用
          2.持续编写，FileHandle
          3.关闭、写入一个数据
 */




@end
