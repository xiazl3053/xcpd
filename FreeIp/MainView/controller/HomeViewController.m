//
//  HomeViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/19.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "HomeViewController.h"
#import "DeviceCell.h"
#import "UIView+Extension.h"
#import "DeviceInfoModel.h"
#import "DeviceService.h"
#import "MJRefresh.h"
#import "Toast+UIView.h"
#import "DeviceViewController.h"
#import "UtilsMacro.h"
#import "XCNotification.h"
#import "VideoView.h"
#import "P2PPlayViewController.h"
#import "XCAddDevViewController.h"
#import "PDTopview.h"
#import "PlayDownView.h"
#import "XCHiddenView.h"

#define kHomeViewHeight   317

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,VideoViewDelegate>
{
    NSMutableArray *aryDevice;
    CGFloat fWidth,fHeight;
    NSMutableArray *aryView;
    UILabel *_borderLabel;
    PlayDownView *downView;
    PDTopview *topView;
    NSMutableDictionary *dict;
    CGFloat fSrcVideoWidth,fSrcVideoHeight;
    CGFloat fDestVideoWidth,fDestVideoHeight;
    BOOL bFull;
    UISwipeGestureRecognizer *leftGesture;
    UISwipeGestureRecognizer *rightGesture;
    BOOL bIsOpen;
    XCHiddenView *hiddenView;
    NSInteger nRow;
    NSInteger nSelectType;
    NSIndexPath *selectPath;
}
@property (nonatomic,strong) DeviceViewController *devView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) DeviceService *devService;
@property (nonatomic,assign) int nCount;
@property (nonatomic,strong) UILabel *lblName;
@property (nonatomic,strong) UIView *sonView;
@property (nonatomic,assign) int nIndex;


@end

@implementation HomeViewController


-(void)loadView
{
    if (IOS_SYSTEM_8) {
        fWidth = kScreenSourchWidth;
        fHeight = kScreenSourchHeight;
    }
    else
    {
        fWidth = kScreenSourchHeight;
        fHeight = kScreenSourchWidth;
    }
    self.view = [[UIView alloc] initWithFrame:Rect(0, 0, fWidth-kTabbarWidth, fHeight)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:RGB(32, 39, 42)];
    nRow = -1;
    
    
    _tableView = [[UITableView alloc] initWithFrame:Rect(0,0,kHomeListWidth,fHeight)];
    [self.view addSubview:_tableView];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.delegate = self;
    aryDevice = [NSMutableArray array];
    _tableView.dataSource = self;
    _devService = [[DeviceService alloc] init];
    [_tableView addHeaderWithTarget:self action:@selector(headerTarget)];
    UIView *headView = [[UIView alloc] initWithFrame:Rect(0, 0, kHomeListWidth, 64)];
    UIImageView *headBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_bg"]];
    [headView addSubview:headBack];
    headBack.frame = headView.bounds;
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(15,20,200,14)];
    [lblName setFont:XCFONT(14.0)];
    [lblName setTextColor:RGB(100, 100, 100)];
    [headView addSubview:lblName];
    [lblName setText:[NSString stringWithFormat:@"%@:  %d",XCLocalized(@"deviceInfo"),(int)aryDevice.count]];
    _lblName = lblName;
    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [headView addSubview:btnAdd];
    [btnAdd setImage:[UIImage imageNamed:@"add_device"] forState:UIControlStateNormal];
    [btnAdd setImage:[UIImage imageNamed:@"add_device_h"] forState:UIControlStateHighlighted];
    btnAdd.frame = Rect(kHomeListWidth-48,10,44,44);
    [btnAdd addTarget:self action:@selector(enterAddDevice) forControlEvents:UIControlEventTouchUpInside];
    [_tableView setTableHeaderView:headView];
    
    //使用一个可重用的UIView  加载不同情况的需求
    
    _sonView = [[UIView alloc] initWithFrame:Rect(_tableView.x+_tableView.width+1,0,fWidth-kHomeListWidth-kTabbarWidth,fHeight)];
    [self.view addSubview:_sonView];
    
    _devView = [[DeviceViewController alloc] init];
    [_devView setFrame:_sonView.bounds];
    
    [self initVideoView];
    
    [self setPlayModel];
    
    [self headerTarget];
   
    dict = [NSMutableDictionary dictionary];
}

-(void)initVideoView
{
    fSrcVideoWidth = (fWidth-kTabbarWidth-kHomeListWidth-6)/2;
    fSrcVideoHeight = (fHeight-131-6)/2;
    
    fDestVideoWidth = (fWidth-kTabbarWidth)/2;
    fDestVideoHeight = (fHeight-131-6)/2;
    [self initGesture];
    aryView = [NSMutableArray array];
    for(int x=0;x<4;x++)
    {
        VideoView *view = [[VideoView alloc] initWithFrame:Rect(2+x%2*(fSrcVideoWidth+2),65+x/2*(2+fSrcVideoHeight),fSrcVideoWidth,fSrcVideoHeight)];
        [aryView addObject:view];
        [view setBackgroundColor:RGB(57,64,66)];
        view.layer.borderColor = RGB(238, 135, 94).CGColor;
        view.nCursel = x;
        view.delegate = self;
    }
    topView = [[PDTopview alloc] initWithFrame:Rect(0,0,self.view.width-kHomeListWidth,64)];
    [_sonView addSubview:topView];
    
    [topView.btnSwitch addTarget:self action:@selector(hiddenHomeView) forControlEvents:UIControlEventTouchUpInside];
    [topView.btnSinger addTarget:self action:@selector(setOnlyView) forControlEvents:UIControlEventTouchUpInside];
    [topView.btnFourer addTarget:self action:@selector(setFourHomeView) forControlEvents:UIControlEventTouchUpInside];
    downView = [[PlayDownView alloc] initWithFrame:Rect(0,fHeight-67,self.view.width-kHomeListWidth,67)];
    [downView.btnCapture addTarget:self action:@selector(captureInfo:) forControlEvents:UIControlEventTouchUpInside];
    [downView.btnStop addTarget:self action:@selector(stopVideoCurent) forControlEvents:UIControlEventTouchUpInside];
    [downView.btnRecord addTarget:self action:@selector(recordingPTP:) forControlEvents:UIControlEventTouchUpInside];
    [_sonView addSubview:downView];
    [downView.btnBD addTarget:self action:@selector(switchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [downView.btnHD addTarget:self action:@selector(switchBtn:) forControlEvents:UIControlEventTouchUpInside];
    downView.btnBD.tag = 2;
    downView.btnHD.tag = 1;
    [_borderLabel setFrame:((UIView*)[aryView objectAtIndex:0]).frame];
}

-(void)initGesture
{
    leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchVideo:)];
    [leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchVideo:)];
    [rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
}

-(void)switchVideo:(UISwipeGestureRecognizer*)sender
{
    if (sender.direction==UISwipeGestureRecognizerDirectionLeft)
    {
        [self switchFullVideo:YES];
    }
    else if (sender.direction==UISwipeGestureRecognizerDirectionRight)
    {
        [self switchFullVideo:NO];
    }
}

#pragma mark 全屏与四屏画面切换
-(void)switchFullVideo:(BOOL)bFlag
{
    if(!bFull)return;
    
    int nTemp = bFlag ? 1 : -1;  //＋1 还是 －1的状态
    while (YES)
    {
        if (_nIndex+nTemp == 4 || _nIndex+nTemp < 0)
        {
            break;
        }
        VideoView *videoView = aryView[_nIndex+nTemp];
        P2PPlayViewController *playControl = [dict objectForKey:videoView.strNO];
        if (playControl)
        {
            VideoView *videoOldView = aryView[_nIndex];
            videoOldView.hidden = YES;
            
            videoView.hidden = NO;
            [playControl setImgFrame:Rect(0,0,_sonView.width-4,_sonView.height-136)];
            videoView.frame = Rect(0, 64, _sonView.width-4, _sonView.height-136);
            
            [videoView addGestureRecognizer:leftGesture];
            [videoView addGestureRecognizer:rightGesture];
            
            //设置当前frame位置
            
            [self clickView:videoView];
            break;
        }
        bFlag ? nTemp++ : nTemp--;
    }
}

-(void)recordingPTP:(UIButton *)btnSender
{
    VideoView *viewPlay = (VideoView*)aryView[_nIndex];
    NSString *strNO = viewPlay.strNO;
    P2PPlayViewController *playControl = [dict objectForKey:strNO];
    if (playControl)
    {
        if (!playControl.bRecording)
        {
            btnSender.selected = YES;
            [playControl recordStart];
            [viewPlay setRecording:YES];
        }
        else
        {
            btnSender.selected = NO;
            [playControl recordStop];
            [viewPlay setRecording:NO];
        }
    }
}

-(void)captureInfo:(UIButton *)btnSender
{
    NSString *strNO = ((VideoView*)aryView[_nIndex]).strNO;
    P2PPlayViewController *playControl = [dict objectForKey:strNO];
    if (playControl)
    {
        BOOL bFLag = [playControl captureView];
        if (bFLag) {
            __weak P2PPlayViewController *__playCon = playControl;
            dispatch_async(dispatch_get_main_queue(), ^{
                [__playCon.imgView makeToast:XCLocalized(@"captureS")];
            });
        }
    }
}

-(void)setFourHomeView
{
    for (int i=0; i<4; i++)
    {
        ((VideoView*)aryView[i]).hidden = ((VideoView*)aryView[i]).hidden ? NO:NO;
    }
    bFull = NO;
    [self playSwitch:NO];
    
}

-(void)setOnlyView
{
    for (int i=0; i<4; i++)
    {
        if(i==_nIndex)
        {
            continue;
        }
        ((VideoView*)aryView[i]).hidden = YES;
    }
    ((VideoView*)aryView[_nIndex]).frame = Rect(2, 65,_sonView.width-4, _sonView.height-136);
    VideoView *video = (VideoView *)aryView[_nIndex];
    P2PPlayViewController *playControl = [dict objectForKey:video.strNO];
    if (playControl)
    {
        [playControl setImgFrame:Rect(0,0,_sonView.width-4,_sonView.height-136)];
    }
    [video addGestureRecognizer:leftGesture];
    [video addGestureRecognizer:rightGesture];
    bFull = YES;
}

-(void)hiddenHomeView
{
    [self playSwitch:YES];
}

-(void)playSwitch:(BOOL)bTableHiden
{
    
    CGFloat width,height;
    if (bTableHiden)
    {
        width = _tableView.hidden ? fSrcVideoWidth : fDestVideoWidth;
        height = _tableView.hidden ? fSrcVideoHeight : fDestVideoHeight;
        _sonView.frame = Rect(_tableView.hidden ? kHomeListWidth+1 : 0, 0, _tableView.hidden ? (self.view.width - kHomeListWidth):self.view.width, self.view.height);
        _tableView.hidden = !_tableView.hidden;
    }
    else
    {
        width = _tableView.hidden ? fDestVideoWidth : fSrcVideoWidth;
        height = _tableView.hidden ? fDestVideoHeight : fDestVideoHeight;
    }
    int x = 0;
    topView.frame = Rect(0, 0,_sonView.width,64);
    downView.frame = Rect(0,self.view.height-67,_sonView.width, 67);
    
    if(!bFull)
    {
        for (VideoView *view in aryView)
        {
            view.frame = Rect(2+x%2*(width+2),65+x/2*(2+height),width,height);
            x++;
        }
        DLog(@"key:%@",[dict allKeys]);
        for (P2PPlayViewController *playControl in [dict allValues])
        {
            [playControl setImgFrame:Rect(0, 0, width, height)];
        }
    }
    else
    {
        [((VideoView*)aryView[_nIndex]) setFrame:Rect(2, 65,_sonView.width-4, _sonView.height-136)];
        P2PPlayViewController *playControl = [dict objectForKey:((VideoView*)aryView[_nIndex]).strNO];
        if (playControl)
        {
            [playControl setImgFrame:Rect(0, 0,_sonView.width-4, _sonView.height-136)];
        }
    }
}


-(void)setPlayModel
{
    for (UIView *view in _sonView.subviews) {
        [view removeFromSuperview];
    }
    [_sonView addSubview:topView];
    [_sonView addSubview:downView];

    for (VideoView *videoView in aryView) {
        [_sonView addSubview:videoView];
    }
    _borderLabel.hidden = NO;
    [self setFourHomeView];
    
}

-(void)setDevInfo
{
    for (UIView *view in _sonView.subviews) {
        [view removeFromSuperview];
    }
    _tableView.hidden = NO;
    _sonView.frame = Rect(kHomeListWidth+1, 0, self.view.width-kHomeListWidth, self.view.height);
    if (![_devView isViewLoaded])
    {
        if (aryDevice.count>0)
        {
            [_devView setFirstDevInfo:[aryDevice objectAtIndex:0]];
        }
    }
    
    if(nRow!=-1)
    {
        if (selectPath!=nil)
        {
            DeviceCell *cell = (DeviceCell*)[_tableView cellForRowAtIndexPath:selectPath];
            cell.bSon = NO;
            bIsOpen = NO;
            NSArray *indexPaths = [NSArray arrayWithObjects:selectPath,nil];
            [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    nRow = -1;
    nSelectType = 0;
    
    [_sonView addSubview:_devView.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)updateListView
{
    if ([_devView isViewLoaded])
    {
        if(aryDevice.count >0 )
        {
            [_devView setDeviceInfo:[aryDevice objectAtIndex:0]];
        }
    }
    //请求列表
    [self headerTarget];
}

-(void)headerTarget
{
    [self updateDeviceInfo];
}

-(void)updateDeviceInfo
{
    __block int nForCount = 0;
    __weak HomeViewController *__weakSelf = self;
    __block NSMutableArray *aryList = [NSMutableArray array];
    __weak NSMutableArray *__aryDevice = aryDevice;
    _devService.httpDeviceBlock = ^(DeviceInfoModel *devInfo,NSInteger nCount)
    {
        if(nCount<0)
        {
            dispatch_async(dispatch_get_main_queue(),
            ^{
                [__weakSelf.view makeToast:XCLocalized(@"deviceinfotimeout")];
                [__weakSelf.tableView headerEndRefreshing];
            });
            return ;
        }
        if(devInfo)
        {
            [aryList addObject:devInfo];
            nForCount ++;
            __weakSelf.nCount++;
        }
        if(nCount == nForCount)
        {
            [__weakSelf sortedArray:aryList];
            [__aryDevice removeAllObjects];
            [__aryDevice addObjectsFromArray:aryList];
            dispatch_async(dispatch_get_main_queue(),
            ^{
                [__weakSelf.tableView headerEndRefreshing];
                [__weakSelf.tableView reloadData];
                [__weakSelf.lblName setText:[NSString stringWithFormat:@"%@:  %d",XCLocalized(@"deviceInfo"),(int)__aryDevice.count]];
            });
            
        }
    };
    [_devService requestDeviceLimit:0 count:20000];
}

//排序
NSComparator cmptr = ^(id obj1, id obj2)
{
    DeviceInfoModel *dev1 = obj1;
    DeviceInfoModel *dev2 = obj2;
    if (dev1.iDevOnline < dev2.iDevOnline)//1 0
    {
        return (NSComparisonResult)NSOrderedDescending;//降序
    }
    
    if (dev1.iDevOnline > dev2.iDevOnline) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};

-(void)sortedArray:(NSMutableArray*)aryTemp
{
    NSArray *array = [aryTemp sortedArrayUsingComparator:cmptr];
    [aryTemp removeAllObjects];
    [aryTemp addObjectsFromArray:array];
}

#pragma mark tableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (aryDevice.count>0 && [[aryDevice objectAtIndex:0] isKindOfClass:[DeviceInfoModel class]]) {
        return aryDevice.count;
    }
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *deviceIdentifier = @"deviceCellIdentifier";
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:deviceIdentifier];
    if (cell==nil)
    {
        cell = [[DeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deviceIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    DeviceInfoModel *devInfo = [aryDevice objectAtIndex:indexPath.row];

    [cell setDeviceInfo:devInfo];
    
    if(nRow == indexPath.row)
    {
//        DLog(@"nRow:%li",(long)nRow);
        if(bIsOpen)
        {
            cell.bSon = YES;
            //1 2 3 4 5    4 8 16 24 32 2100/100%10
            int nCount = [devInfo.strDevType intValue]/100%10 <=2 ? ([devInfo.strDevType intValue]/100%10+1) * 4 : [devInfo.strDevType intValue]/100%10*8;
//            DLog(@"设备名:%@----通道个数:%d",devInfo.strDevName,nCount);
            CGFloat hdViewHigh = nCount <= 8 ? kSonHomeListheight*nCount : kSonHomeListheight * 8;
            XCHiddenView *hdView = [[XCHiddenView alloc] initWithFrame:Rect(0, 82.5, kHomeListWidth,hdViewHigh) number:nCount];
            [cell.contentView addSubview:hdView];
            hdView.tag = 10089;
        }
    }
    
    return cell;
}


#pragma mark tableViewData source


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (bIsOpen)
    {
        
        if (indexPath.row == nRow) {
            DeviceInfoModel *devInfo = [aryDevice objectAtIndex:nRow];
            int nCount = [devInfo.strDevType intValue]/100%10 <=2 ? ([devInfo.strDevType intValue]/100%10+1) * 4 : [devInfo.strDevType intValue]/100%10*8;
//            DLog(@"nRow:%li",(long)nRow);
            return 82.5+55*(nCount>8?8:nCount);
        }
    }
    return 82.5;
}

#pragma mark 视频播放与切换
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果上次选择的同样是DVR
    DeviceInfoModel *devInfo = [aryDevice objectAtIndex:indexPath.row];
    //如果当前显示设备通道展示,那么不做控件效果
    if([_devView.view superview] == _sonView)
    {
        if(nRow!=-1)
        {
            if (selectPath!=nil)
            {
                    DeviceCell *cell = (DeviceCell*)[_tableView cellForRowAtIndexPath:selectPath];
                    cell.bSon = NO;
            }
            bIsOpen = NO;
            NSArray *indexPaths = [NSArray arrayWithObjects:indexPath,nil];
            selectPath = indexPath;
            [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        nRow = -1;
        nSelectType = 0;
        [_devView setDeviceInfo:devInfo];
        return ;
    }
    if ([devInfo.strDevType intValue]>2000)
    {
        NSArray *indexPaths = nil;
        //如果上一次点击的是多通道设备
        //这次点击继续是多通道设备,两次不是同一行，需要先设置隐藏
        if (nSelectType==2 && selectPath != indexPath)
        {
            //找到上一次记录,隐藏
            DeviceCell *cell = (DeviceCell*)[_tableView cellForRowAtIndexPath:selectPath];
            cell.bSon = NO;
            if (!bIsOpen)
            {
                bIsOpen = !bIsOpen;
            }
        }
        else
        {
            if (selectPath!=nil) {
                DeviceCell *cell = (DeviceCell*)[_tableView cellForRowAtIndexPath:selectPath];
                cell.bSon = NO;
            }
            bIsOpen = !bIsOpen;
        }
        indexPaths = [NSArray arrayWithObjects:indexPath,nil];
        selectPath = indexPath;
        nRow = indexPath.row;
        nSelectType = 2;
        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        return;
    }
    
    //1 2 3 4 5    4 8 16 24 32 2100/100%10
    
    
    nSelectType = 1;
    if (bIsOpen)
    {
         //如果之前已经打开了通道界面
         //删除此界面
        DeviceCell *cell = (DeviceCell*)[_tableView cellForRowAtIndexPath:selectPath];
        cell.bSon = NO;
        NSArray *indexPaths = [NSArray arrayWithObjects:indexPath,selectPath,nil];
        selectPath = indexPath;
        nRow = -1;
        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        bIsOpen = NO;
    }
    //先判断原有视频框是否播放
    [self connectAllStart:devInfo];
}


-(void)connectAllStart:(DeviceInfoModel *)devInfo
{
    [self connectAllStart:devInfo channel:0];
}

#pragma mark  封装连接方法
-(void)connectAllStart:(DeviceInfoModel *)devInfo channel:(int)nDvrChannel
{
    VideoView *video = (VideoView*)[aryView objectAtIndex:_nIndex];
    BOOL bIPC = NO;
    NSString *strNewKey=nil;
    if ([devInfo.strDevType intValue]<2000)
    {
        strNewKey = devInfo.strDevNO;
        bIPC = YES;
    }
    else
    {
        strNewKey = [NSString stringWithFormat:@"%@_%d",devInfo.strDevNO,nDvrChannel];
    }
    if ([video.strNO isEqualToString:strNewKey])
    {
        return ;
    }
    if(![self checkStopVideo:video])//如果有正在播放的视频，先停止,然后检测选择的视频，是否正在播放中
    {
         [self.view makeToast:@"正在建立P2P连接"];
         return ;
    }
    P2PPlayViewController *playControl = [dict objectForKey:strNewKey];
    if (playControl)
    {
         //改变视频框
         [self changeVideoview:playControl video:video];
         return ;
    }
     //视频播放   创建解码  加入某一个视频框
    if (bIPC)
    {
         [self connectIPC:devInfo];
    }
    else
    {
        [self connect_Oper_dvr:devInfo channel:nDvrChannel];
    }
    
}

-(void)changeVideoview:(P2PPlayViewController *)playControl video:(VideoView *)newVideo
{
    VideoView *oldView = (VideoView*)playControl.view.superview;
    oldView.strNO = nil;
    [playControl.view removeFromSuperview];
    [playControl setFrame:newVideo.frame];
    [newVideo addSubview:playControl.view];
}

-(BOOL)checkStopVideo:(VideoView*)video
{
     P2PPlayViewController *playControl = [dict objectForKey:video.strNO];
     if (playControl)
     {
         if (!playControl.bPlaying) {
             return NO;
         }
         __weak P2PPlayViewController *__playControl = playControl;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group,dispatch_get_global_queue(0, 0),
         ^{
             [__playControl stopPlay];
         });
        for (UIView *view in video.subviews)
        {
             [view removeFromSuperview];
        }
        dispatch_group_wait(group,DISPATCH_TIME_FOREVER);
        DLog(@"删除:%@",playControl.strKey);
        
        [dict removeObjectForKey:playControl.strKey];
        playControl = nil;
     }
    return YES;
}

-(void)connectIPC:(DeviceInfoModel*)devInfo
{
    //视频播放   创建解码  加入某一个视频框
    P2PPlayViewController *playControl = [[P2PPlayViewController alloc] initWithNO:devInfo.strDevNO name:devInfo.strDevName channel:0 code:2];
    playControl.strKey = devInfo.strDevNO;
    [playControl setFrame:((VideoView*)aryView[_nIndex]).frame];
    playControl.nChannel = 0;
    [aryView[_nIndex] addSubview:playControl.view];
    ((VideoView*)aryView[_nIndex]).strNO = devInfo.strDevNO;
    [dict setObject:playControl forKey:devInfo.strDevNO];
}

-(void)connect_Oper_dvr:(DeviceInfoModel *)devInfo channel:(int)nChannel
{
    P2PPlayViewController *playControl = [[P2PPlayViewController alloc] initWithNO:devInfo.strDevNO name:devInfo.strDevName channel:nChannel code:2];
    playControl.strKey = [NSString stringWithFormat:@"%@_%d",devInfo.strDevNO,nChannel];
    playControl.nChannel = nChannel;
    
    VideoView *video = (VideoView *)aryView[_nIndex];
    
    [playControl setFrame:video.frame];
    [video addSubview:playControl.view];
    
    video.strNO = playControl.strKey;
    [dict setObject:playControl forKey:playControl.strKey];

}

-(void)connectDVR:(NSNotification*)notify
{
    NSNumber *number = (NSNumber*)[notify object];
    DLog(@"点播的通道:%d",[number intValue]);
    
    DeviceInfoModel *devInfo = [aryDevice objectAtIndex:nRow];
    
    if ([devInfo.strDevType intValue]<2000) {
        return ;
    }
    __weak HomeViewController *__self = self;
    __block DeviceInfoModel *__devInfo = devInfo;
    __block int __nIndex = [number intValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [__self connectAllStart:__devInfo channel:__nIndex];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateListView) name:NSUPDATE_DEVICE_LIST_VC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectFailHome:) name:NS_CLOSE_P2P_HOME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectDVR:) name:NS_CONNECT_DVR_CHANNEL_VC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ptpDisConnect:) name:NSCONNECT_P2P_DISCONNECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNotifyClick:) name:NS_PLAY_VIEW_CLICK_VC object:nil];
}

-(void)playNotifyClick:(NSNotification *)notify
{
    P2PPlayViewController *playControl = (P2PPlayViewController *) notify.object;
    if (playControl!=nil) {
        __weak P2PPlayViewController *__playControl = playControl;
        __weak HomeViewController *__self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [__self clickView:(VideoView*)__playControl.view.superview];
        });
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)switchBtn:(UIButton *)btnSender
{
    [self swithVideoInfo:(int)btnSender.tag];
}

-(void)swithVideoInfo:(int)nCode
{
    VideoView *video = (VideoView*)aryView[_nIndex];
    P2PPlayViewController *playControl = [dict objectForKey:video.strNO];
    if (!playControl) {
        return ;
    }
    [playControl switchCode:nCode];
    
}

-(void)clickView:(id)sender
{
    VideoView *view = (VideoView*)sender;
    for (VideoView *tempV in aryView)
    {
        tempV.layer.borderWidth = 0;
    }
    view.layer.borderWidth = 2;
    _nIndex = (int)view.nCursel;
    P2PPlayViewController *playControl = [dict objectForKey:view.strNO];
    if (playControl && playControl.bRecording)
    {
        downView.btnRecord.selected = YES;
    }
    else
    {
        downView.btnRecord.selected = NO;
    }
    if (!playControl) {
        downView.btnHD.enabled = NO;
        downView.btnBD.enabled = NO;
        downView.btnRecord.enabled = NO;
        downView.btnCapture.enabled = NO;
        downView.btnStop.enabled = NO;
        return ;
    }
    downView.btnRecord.enabled = YES;
    downView.btnCapture.enabled = YES;
    downView.btnStop.enabled = YES;
    if (playControl.nCodeType == 1) {
        downView.btnBD.enabled = YES;
        downView.btnHD.enabled = NO;
    }
    else if(playControl.nCodeType == 2 )
    {
        downView.btnHD.enabled = YES;
        downView.btnBD.enabled = NO;
    }
}

-(void)doubleClickVideo:(id)sender
{
    if (bFull) {
        [self setFourHomeView];
    }
    else
    {
        [self setOnlyView];
    }
}

-(void)enterAddDevice
{
    XCAddDevViewController *addDev = [[XCAddDevViewController alloc] init];
    [self presentViewController:addDev animated:YES completion:nil];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark 关闭所有视频
-(void)closeAllView
{
    for (P2PPlayViewController *playControl in [dict allValues])
    {
        __weak P2PPlayViewController *__playControl = playControl;
        VideoView *video = (VideoView*)playControl.view.superview;
        if (playControl.bRecording)
        {
            [playControl recordStop];
            playControl.bRecording = NO;
            __weak VideoView *__videoView = video;
            dispatch_async(dispatch_get_main_queue(), ^{
                    [__videoView setRecording:NO];
            });
        }
        video.strNO = nil;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group,dispatch_get_global_queue(0, 0),
        ^{
            [__playControl stopPlay];
        });
        dispatch_async(dispatch_get_main_queue(),
        ^{
               [__playControl.view removeFromSuperview];
        });
        dispatch_group_wait(group,DISPATCH_TIME_FOREVER);
        DLog(@"delete:%@",playControl.strKey);
        [dict removeObjectForKey:playControl.strKey];
    }
    DLog(@"%@",[dict allKeys]);
}

#pragma mark 停止当前视频，主线程中触发，不需要dispatch_get_main_queue
-(void)stopVideoCurent
{
    VideoView *video = (VideoView*)aryView[_nIndex];
    P2PPlayViewController *playControl = [dict objectForKey:video.strNO];
    if (playControl)
    {
        if (playControl.bRecording) {
            [playControl recordStop];
            playControl.bRecording = NO;
            [video setRecording:NO];
        }
        [playControl.view removeFromSuperview];
        __weak P2PPlayViewController *__playControl = playControl;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group,dispatch_get_global_queue(0, 0), ^{
            [__playControl stopPlay];
        });
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        DLog(@"删除:%@",playControl.strKey);
        [dict removeObjectForKey:playControl.strKey];
        video.strNO = nil;
    }
}

#pragma mark 丢失连接
-(void)ptpDisConnect:(NSNotification*)notify
{
    P2PPlayViewController *playControl =  [dict objectForKey:notify.object];
    VideoView *video = (VideoView*)playControl.view.superview;
    DLog(@"p2pControler:%@",notify.object);
    if (playControl.bRecording) {
        [playControl recordStop];
        playControl.bRecording = NO;
        __weak VideoView *__videoView = video;
        dispatch_async(dispatch_get_main_queue(), ^{
             [__videoView setRecording:NO];
        });
    }
    __weak P2PPlayViewController *__playControl = playControl;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group,dispatch_get_global_queue(0, 0),
     ^{
         [__playControl stopPlay];
     });
    dispatch_async(dispatch_get_main_queue(),
    ^{
          [__playControl.view removeFromSuperview];
    });
    dispatch_group_wait(group,DISPATCH_TIME_FOREVER);
    DLog(@"删除:%@",notify.object);
    if(playControl)
    {
        [dict removeObjectForKey:notify.object];
    }
    video.strNO = nil;
    __weak VideoView *__video = video;
    dispatch_async(dispatch_get_main_queue(),
    ^{
          [__video makeToast:XCLocalized(@"Disconnect")];
    });
}

-(void)connectFailHome:(NSNotification*)notify
{
    P2PPlayViewController *p2pControl = (P2PPlayViewController*)notify.object;
    VideoView *videoView = (VideoView*)p2pControl.view.superview;
    videoView.strNO = nil;
    DLog(@"p2pControler:%@--channel:%d",p2pControl.strKey,p2pControl.nChannel);
    if (p2pControl.nChannel==0)
    {
        __weak P2PPlayViewController *__weakPlay = p2pControl;
        dispatch_async(dispatch_get_main_queue(),
        ^{
             [__weakPlay.view removeFromSuperview];
        });
        DLog(@"delete:%@",p2pControl.strKey);
        [dict removeObjectForKey:p2pControl.strKey];
        p2pControl = nil;
    }
}

@end
