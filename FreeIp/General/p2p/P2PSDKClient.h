#ifndef __P2PSDKClient_h__
#define __P2PSDKClient_h__

#include "P2PSDK.h"
#include <string>
#include <list>


#ifdef WIN32
#define  DLLCLASS_API __declspec(dllexport)
#else
#define  DLLCLASS_API
#endif

class  NatCommunication;
class  BlockingHook;

class  DLLCLASS_API EventHandler
{
public:
    EventHandler() {};
    virtual ~EventHandler() {};
    virtual bool ProcessFrameData(char* aFrameData, int aFrameDataLength) = 0;  
    virtual bool DeviceDisconnectNotify() =0;	//�豸����֪ͨ
};

class  ConnectionImpl;
// ��ʾ���豸��һ������,��ͬһ������ֻ�ܴ�һ·ʵʱ����һ·�ط���.
class DLLCLASS_API Connection
{
public:
    Connection(EventHandler* handler) ;
   // virtual ~Connection() {};
    ~Connection();
    int  Connect(char* channelId);
    // �ر�����
    void Close();
    bool IsConnected();
    /**
	 * ��ָ��ͨ����ʵʱ��
	 * channelId: �豸��ͨ���˺�
	 * streamType: 1:������  2:������
	 * ����: 0:success, -1: fail;
	 */
	int StartRealStream(short channelNo, short streamType);
    // ֹͣʵʱ��
	int StopRealStream(short channelNo, short streamType);

	int PtzContol(PtzControlMsg* ptzmsg);
    // �򿪻ط�¼��
    int PlayBackRecord(PlayRecordMsg* msg);
    // ¼��طſ���,������ͣ����������ˡ�ֹͣ�ȡ����PlayBackControl����.
    int PlayBackRecordCtrl(PlayRecordCtrlMsg* msg);
    
    
private:
    ConnectionImpl* impl;
    friend class P2PSDKClient;
};

class  RelayConnectionImpl;
class DLLCLASS_API RelayConnection
{
public:
    RelayConnection(EventHandler* handler) ;
     ~RelayConnection();	
    //virtual ~RelayConnection() {};
    int  RelayConnect(char* channelId);
    void Close();
    bool IsConnected();	
	int StartRealStream(short channelNo, short streamType);
	int StopRealStream(short channelNo, short streamType);
	int PtzContol(PtzControlMsg* ptzmsg);
    int PlayBackRecord(PlayRecordMsg* msg);
    int PlayBackRecordCtrl(PlayRecordCtrlMsg* msg);
private:
    RelayConnectionImpl* impl;
    friend class P2PSDKClient;
};
class DLLCLASS_API P2PSDKClient 
{
public:
    static P2PSDKClient* CreateInstance();
    static void DestroyInstance(P2PSDKClient* instance);    
      int SendHeartBeat();	
    // ��ʼ��sdk
	bool Initialize(const char* serverName, const char* myId);    

    // ����ָ�����豸, connect���������������ʵ��
    int  Connect(char* channelId, Connection* connect);
    int   RelayConnect(char* channelId, RelayConnection* connect);	

    // �ͷ�sdk��Դ
	void DeInitialize();
private:  
	P2PSDKClient();
	virtual ~P2PSDKClient();    
private: 
	std::string mMyId;
	std::string mServerName;
	NatCommunication* mNatComm;
};

#endif
