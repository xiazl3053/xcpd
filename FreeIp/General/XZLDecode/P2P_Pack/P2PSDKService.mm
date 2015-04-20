
//
//  P2PSDKService.cpp
//  XCMonit_Ip
//
//  Created by xia zhonglin  on 14-5-14.
//  Copyright (c) 2014年 xia zhonglin . All rights reserved.
//

#include "P2PSDKService.h"
#include <stdio.h>
#import <Foundation/Foundation.h>
#import "XCNotification.h"
#import "P2PInitService.h"
//#import "RecordModel.h"
//#import "RecordDb.h"
using namespace std;

#define HEART_SECOND   30

bool RecvFile::ProcessFrameData(char* aFrameData, int aFrameDataLength)
{
    if( aFrameDataLength <= 0 )
    {
        return YES;
    }
    unsigned char *unFrame = (unsigned char *)aFrameData;
    if(unFrame[3] == 0x67 || unFrame[4] == 0x67)
    {
        aryData = [NSMutableData data];
        [aryData appendBytes:aFrameData length:aFrameDataLength];
    }
    else if(unFrame[3] == 0x61 || unFrame[4] == 0x61)
    {
        NSData *dataInfo = [NSData dataWithBytes:aFrameData length:aFrameDataLength];
        if(aryData)
        {
            @synchronized(aryVideo)
            {
                [aryVideo addObject:aryData];
            }
            aryData = nil;
        }
        @synchronized(aryVideo)
        {
            [aryVideo addObject:dataInfo];
        }
    }
    else
    {
        [aryData appendBytes:aFrameData length:aFrameDataLength];
    }
    return true;
}

bool RecvFile::DeviceDisconnectNotify()
{
    printf("device is disconnect\n");
    if (!conn)
    {
        bDevDisConn = YES;
        StopRecv();
    }
    else if(!relayconn)
    {
        bDevDisConn = YES;
        StopRecv();
    }
    DLog(@"发送");
   
    
    DLog(@"delete:%@",strKey);
    [[NSNotificationCenter defaultCenter] postNotificationName:NSCONNECT_P2P_DISCONNECT object:strKey];
    
    
    return true;
}


void RecvFile::StopRecv()
{
//    DLog(@"结束");
    sendheartinfoflag = NO;
    bDevDisConn = YES;
    if (conn)
    {
        if(streamType == 0)
        {
            int ret = conn->StopRealStream(nChannel, nCode);
            if(ret == 0)
            {
                printf("success stop real stream \n");
            }
            else
                printf("error stop real stream \n");
        }
        else if(streamType == 1)
        {
            PlayRecordCtrlMsg msg;
            msg.ctrl = PB_STOP;
            conn->PlayBackRecordCtrl(&msg);
        }
        conn->Close();
        delete conn;
        conn = NULL;
    }
    if(relayconn)
    {
        if(streamType == 0)
        {
            int ret = relayconn->StopRealStream(nChannel, nCode);
            
            if(ret == 0)
            {
                printf("success stop relay stream \n");
            }
        }
        else if(streamType == 1)
        {
            PlayRecordCtrlMsg msg;
            msg.ctrl = PB_STOP;
            relayconn->PlayBackRecordCtrl(&msg);
        }
        relayconn->Close();
        delete relayconn;
        relayconn = NULL;
    }
    [aryVideo removeAllObjects];
    aryVideo = nil;
}

void RecvFile::closeP2P()
{
    if (conn)
    {
        if(streamType == 0)
        {
            int ret = conn->StopRealStream(nChannel, nCode);
            if(ret == 0)
            {
                printf("success stop real stream \n");
            }
            else
                printf("error stop real stream \n");
        }
        else if(streamType == 1)
        {
            PlayRecordCtrlMsg msg;
            msg.ctrl = PB_STOP;
            conn->PlayBackRecordCtrl(&msg);
        }
        conn->Close();
        delete conn;
        conn = NULL;
    }
}

void RecvFile::closeTran()
{
    if(relayconn)
    {
        if(streamType == 0)
        {
            int ret = relayconn->StopRealStream(nChannel, nCode);
            if(ret == 0)
            {
                printf("success stop relay stream \n");
            }
        }
        else if(streamType == 1)
        {
            PlayRecordCtrlMsg msg;
            msg.ctrl = PB_STOP;
            relayconn->PlayBackRecordCtrl(&msg);
        }
        if(relayconn!=NULL)
        {
            relayconn->Close();
            delete relayconn;
            relayconn = NULL;
        }
    }
}


void RecvFile::backword()
{
    PlayRecordCtrlMsg msg;
    msg.ctrl = PB_BACKWARD;
    conn->PlayBackRecordCtrl(&msg);
}
void RecvFile::forword()
{
    PlayRecordCtrlMsg msg;
    msg.ctrl = PB_FORWARD;
    conn->PlayBackRecordCtrl(&msg);
}
void RecvFile::pause()
{
    PlayRecordCtrlMsg msg;
    msg.ctrl = PB_PAUSE;
    conn->PlayBackRecordCtrl(&msg);
}
void RecvFile::seek()
{
    PlayRecordMsg msg;
    msg.channelNo = 0;
    msg.startTime = 1372219200;
    msg.endTime = 1372222800;
    conn->PlayBackRecord(&msg);
}
void RecvFile::pause2play()
{
    PlayRecordCtrlMsg msg;
    msg.ctrl = PB_PLAY;
    conn->PlayBackRecordCtrl(&msg);
}

BOOL RecvFile::testConnection()
{
    BOOL bReturn  = TRUE;
    if(conn == NULL)
    {
		conn = new Connection(this);
    }
    int ret = mSdk->Connect((char*)peerName.c_str(), conn); //œÚIPC¡¨Ω”
    if(ret != 0)
    {
        bReturn = FALSE;
    }
    return bReturn;
}


int RecvFile::initTranServer()
{
    if (mSdk)
    {
        mSdk->SendHeartBeat();
    }
    if(relayconn == NULL)
    {
        if(!bExit)
        {
            relayconn = new RelayConnection(this);
        }
        if(!bExit)
        {
            int ret = mSdk->RelayConnect((char*)peerName.c_str(),relayconn);
            return ret;
        }
    }
    delete relayconn;
    relayconn = NULL;
    return -1;
    
}
BOOL RecvFile::connectTranServer(int nCodeType)
{
    int ret = 0;
    if(streamType == 0 && relayconn)
    {
        if(!bExit)
        {
            ret = relayconn->StartRealStream(nChannel, nCodeType);   //0 «Õ®µ¿∫≈,2 «∏®¬Î¡˜
            nCode = nCodeType;
            if(ret == 0)
            {
                DLog(@"StartRelayStream success \n");
                if(!aryVideo)
                {
                    aryVideo = [NSMutableArray array];
                }
            }
            else if(ret < 0)
            {
                DLog(@"StartRelayStream failed, ret=%d \n", ret);
                closeTran();
                DLog(@"关闭转发");
                return FALSE;
            }
        }
    }
    return TRUE;
}


BOOL RecvFile::tranServer(int nCodeType)
{
    BOOL bReturn = TRUE;
    int ret = this->initTranServer();
    if(ret == 0)
    {
        DLog(@"sdk relayconnect success");
        if(this->connectTranServer(nCodeType))//如果失败，connectTranServer有关闭转发的动作
        {
            
        }
        else
        {
            bReturn = NO;
        }
    }
    else
    {
        DLog(@"relayconnect init failed");
        sendheartinfoflag = FALSE;
        delete relayconn;
        relayconn = NULL;
        bReturn = FALSE;
    }
    return bReturn;
}
//心跳线程
BOOL RecvFile::sendHeart()
{
//    dispatch_async(_dispath, ^
//    {
//        int nNumber = 0;
//        while(sendheartinfoflag)
//        {
//            while (sendheartinfoflag && nNumber< HEART_SECOND)
//            {
//                [NSThread sleepForTimeInterval:0.5];
//                nNumber++;
//            }
//            nNumber = 0;
//            mSdk->SendHeartBeat();
//        }
//        DLog(@"心跳销毁");
//    });
   return YES;
}



/*P2P操作 1.初始化 2.成功就直接获取码流 connectP2PStream 3.失败，采用转发方式*/
int RecvFile::initP2PParam()
{
    if(conn == NULL)
    {
        if (!bExit)
        {
            conn = new Connection(this);
        }
    }
    if (!bExit && mSdk)
    {
        
        if(mSdk->Connect((char*)peerName.c_str(), conn)==0)
        {
            DLog(@"P2P连接设备成功");
            return 0;
        }
        DLog(@"P2P连接设备失败");
    }
    return -1;
}
BOOL RecvFile::connectP2PStream(int nCodeType)
{
    int ret = 0;
    if(streamType == 0 && conn)
    {
        if(!bExit)
        {
            nCode = nCodeType;
            ret = conn->StartRealStream(nChannel, nCode);
        }
        if(ret != 0)
        {
            DLog(@"P2P无法接收码流");
            return FALSE;
        }
        DLog(@"P2P开始接收码流");
    }
    else if(streamType == 1)
    {
        PlayRecordMsg msg;
        msg.channelNo = 0;
        msg.startTime = 1373439705;
        msg.endTime = 1373439861;
        ret = conn->PlayBackRecord(&msg);
        if(ret != 0)
        {
            printf("PlayBackRecord failed \n");
            return FALSE;
        }
    }
    if(!aryVideo)
    {
        aryVideo = [NSMutableArray array];
    }
    return TRUE;
}

void RecvFile::deleteP2PConn()
{
    if(conn != NULL)
    {
        delete conn;
        conn = NULL;
    }
}
BOOL RecvFile::startGcd(int _nType,int nCodeType)
{
    
    BOOL bReturn = TRUE;
    if(_nType==1)
    {

        int ret = this->initP2PParam();
        if(ret == 0)
        {
            bReturn = this->connectP2PStream(nCodeType);
        }
        else
        {
            DLog(@"P2P sdk fail ...    using transerver \n");
            this->deleteP2PConn();
            bReturn = this->tranServer(nCodeType);
        }
    }
    else if(_nType==2)
    {
        bReturn = this->tranServer(nCodeType);
    }
    if (bReturn)
    {
        aryVideo = [[NSMutableArray alloc] init];
    }
    return bReturn;
}

BOOL RecvFile::threadP2P(int nCodeType)
{
    BOOL bReturn = FALSE;
    int ret = this->initP2PParam();
    if(ret == 0)
    {
        bReturn = this->connectP2PStream(nCodeType);
    }
    if(!bReturn)
    {
        this->deleteP2PConn();
    }
    return bReturn;
}

BOOL RecvFile::threadTran(int nCodeType)
{
    BOOL bReturn = this->tranServer(nCodeType);
    if (bReturn)
    {
        return YES;
    }
    return NO;
}

BOOL RecvFile::swichCode(int nType)
{
    //先清空之前的码流
    @synchronized(aryVideo)
    {
        [aryVideo removeAllObjects];
    }
    int nRet = -1;
    DLog(@"通道:%d-目标码流:%d",nChannel,nType);
    if (conn)
    {
        conn->StopRealStream(nChannel, nCode);
        [NSThread sleepForTimeInterval:3.0];
        if(conn)
        {
            DLog(@"conn 切换");
            nRet = conn->StartRealStream(nChannel, nType);//0 -1
            nCode = nType;
        }
        else
        {
            nRet = -1;
            DLog(@"切换失败");
        }
    }
    else if(relayconn)
    {
        relayconn->StopRealStream(nChannel, nCode);
        [NSThread sleepForTimeInterval:2.0];
        nRet = relayconn->StartRealStream(nChannel, nType);
        nCode = nType;
    }
    DLog(@"nRet:%d",nRet);//0是切换成功    
    if (!nRet)
    {
        return YES;
    }
    return NO;
}
int RecvFile::getRealType()
{
    if(conn)
    {
        return 1;
    }
    else
    {
        return 2;
    }
}
void RecvFile::sendPtzControl(PtzControlMsg *ptzMsg)
{
    if(conn)
    {
        conn->PtzContol(ptzMsg);
    }
    else
    {
        if(relayconn)
        {
            relayconn->PtzContol(ptzMsg);
        }
    }
}




