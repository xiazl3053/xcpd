//
//  DirectViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "DirectViewController.h"
#import "UtilsMacro.h"
#import "DirectAddViewController.h"
#import "XCHIddenView.h"
#import "XCBtnChannel.h"
#import "UIView+Extension.h"
#import "VideoView.h"
#import "XCNotification.h"
#import "PDTopview.h"
#import "DirectCell.h"
#import "Toast+UIView.h"
#import "RtspInfoDb.h"
#import "DirectAddView.h"
#import "IQKeyboardManager.h"
#import "PlayDownView.h"
#import "RTSPPlayViewController.h"
#import "PrivatePlayViewController.h"



@interface DirectViewController ()<UITableViewDelegate,UITableViewDataSource,VideoViewDelegate,DirectAddDelegate>
{
    UIView *headView;
    CGFloat fWidth,fHeight;
    UIView *sonView;
    BOOL bIsOpen;
    NSMutableArray *aryView;
    CGFloat fSrcWidth,fSrcHeight;
    CGFloat fDestWidth,fDestHeight;
    PDTopview *topView;
    UIView *_sonView;
    UILabel *_borderLabel;
    PlayDownView *downView;
    DirectAddViewController *directAdd;
    UIView *grayView;
    NSInteger _nIndex;
    DirectAddView *addView;
    BOOL bFull;
    NSMutableDictionary *_aryTable;
//    RTSPPlayViewController *rtspPlay;
    NSInteger nRow;
    NSIndexPath *selectPath;
    NSInteger nSelectType;
//    PrivatePlayViewController *privateView;
    NSMutableArray *_aryRtsp;
    UISwipeGestureRecognizer *leftGesture;
    UISwipeGestureRecognizer *rightGesture;
    UIPinchGestureRecognizer *pinchGesture;
    UIPanGestureRecognizer *panGesture;
}
@property (nonatomic,strong) NSMutableDictionary *aryModel;
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation DirectViewController


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
    _aryRtsp = [NSMutableArray array];
    _aryTable = [NSMutableDictionary dictionary];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    _tableView = [[UITableView alloc] initWithFrame:Rect(0,0,kHomeListWidth,self.view.height)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    headView = [[UIView alloc] initWithFrame:Rect(0, 0, kHomeListWidth, 64)];
    UIImageView *imgBgHead = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_bg"]];
    imgBgHead.frame = headView.bounds;
    [headView addSubview:imgBgHead];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(17, 20, 100, 20)];
    [lblName setFont:XCFONT(14)];
    [lblName setTextColor:RGB(100,100, 100)];
    [lblName setText:XCLocalized(@"deviceList")];
    [headView addSubview:lblName];
    
    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAdd setImage:[UIImage imageNamed:@"add_dir"] forState:UIControlStateNormal];
    [btnAdd setImage:[UIImage imageNamed:@"add_dir_h"] forState:UIControlStateHighlighted];
    [headView addSubview:btnAdd];
    btnAdd.frame = Rect(kHomeListWidth-50, 10, 44, 44);
    [btnAdd addTarget:self action:@selector(setAddModel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDel setImage:[UIImage imageNamed:@"del_dir"] forState:UIControlStateNormal];
    [btnDel setImage:[UIImage imageNamed:@"del_dir_h"] forState:UIControlStateHighlighted];
    [btnDel setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [btnDel addTarget:self action:@selector(delDevice:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btnDel];
    btnDel.frame = Rect(kHomeListWidth-100, 10, 44, 44);
    [_tableView setTableHeaderView:headView];
    [_tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_bg"]]];
    
    _sonView = [[UIView alloc] initWithFrame:Rect(_tableView.x+_tableView.width+1,0,fWidth-kHomeListWidth-kTabbarWidth,fHeight)];
    [self.view addSubview:_sonView];
    
    [self initVideoView];
    
    [self setPlayModel];
    
    [self updateData];
    
    [self initGesture];
    
    _aryModel = [NSMutableDictionary dictionary];
    
    grayView = [[UIView alloc] initWithFrame:Rect(kHomeListWidth, 0, 1, fHeight)];
    [self.view addSubview:grayView];
    [grayView setBackgroundColor:RGB(179, 197, 180)];
    
}
-(void)initGesture
{
     leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchGestureEvent:)];
    [leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchGestureEvent:)];
    [rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchEvent:)];
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEvent:)];
}

-(void)panEvent:(UIPanGestureRecognizer*)sender
{
    if (!bFull) {
        return ;
    }
    VideoView *video = (VideoView*)sender.view;
    PlayViewController *playControl = [_aryModel objectForKey:video.strNO];
    if (!playControl) {
        return ;
    }
    CGPoint curPoint = [sender locationInView:sender.view];
    if ([sender state] == UIGestureRecognizerStateBegan) {
        [playControl panStart:curPoint];
        return ;
    }
    [playControl setImgPan:curPoint];
}

-(void)pinchEvent:(UIPinchGestureRecognizer*)pinchSender
{
    if (!bFull)
    {
        return ;
    }
    if ([pinchSender numberOfTouches]!=2)
    {
        return ;
    }
    VideoView *video = (VideoView*) pinchSender.view;
    PlayViewController *playControl = [_aryModel objectForKey:video.strNO];
    if (!playControl) {
        return ;
    }
    if ([pinchSender state] == UIGestureRecognizerStateBegan) {
        return ;
    }
    CGPoint p1 = [pinchSender locationOfTouch:0 inView:pinchSender.view ];
    
    CGPoint p2 = [pinchSender locationOfTouch:1 inView:pinchSender.view ];
    
    CGPoint newCenter = CGPointMake( (p1.x+p2.x)/2,(p1.y+p2.y)/2);
    CGFloat fScale = 0;
    if([pinchSender scale]>1)
    {
        fScale = ([pinchSender scale]-1)/2;
    }
   [playControl setImgScale:fScale point:newCenter];
    if ([pinchSender state] == UIGestureRecognizerStateEnded)
    {
        if(playControl.imgView.width > video.width)
        {
            [video addGestureRecognizer:panGesture];
        }
        else
        {
            [video removeGestureRecognizer:panGesture];
        }
    }
}

-(void)switchGestureEvent:(UISwipeGestureRecognizer*)sender
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
        PlayViewController *playControl = [_aryModel objectForKey:videoView.strNO];
        if (playControl)
        {
            VideoView *videoOldView = aryView[_nIndex];
            videoOldView.hidden = YES;
            
            videoView.hidden = NO;
            [playControl setImgFrame:Rect(0,0,_sonView.width-4,_sonView.height-136)];
            videoView.frame = Rect(0, 64, _sonView.width-4, _sonView.height-136);
            
            [videoView addGestureRecognizer:leftGesture];
            [videoView addGestureRecognizer:rightGesture];
            [videoView addGestureRecognizer:pinchGesture];
            //设置当前frame位置
            [self clickView:videoView];
            break;
        }
        bFlag ? nTemp++ : nTemp--;
    }
}

-(void)delDevice:(UIButton*)btnSender
{
    if (btnSender.selected)
    {
        [_tableView setEditing:NO animated:YES];
        NSArray *array = [_aryTable allValues];
        for (RtspInfo *info in array)
        {
            [RtspInfoDb removeByIndex:info.nId];
        }
        [self updateData];
        btnSender.selected = NO;
    }
    else
    {
        [_aryTable removeAllObjects];
        [_tableView setEditing:YES animated:YES];
        btnSender.selected = YES;
    }
}

-(void)updateData
{
     _aryRtsp = [RtspInfoDb queryAllRtsp];
    __weak DirectViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(),^{
        [__self.tableView reloadData];
    
    });
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
}

//添加设备
#pragma mark 添加设备－－修改
-(void)setAddModel
{
//    for (UIView *view in _sonView.subviews)
//    {
//        [view removeFromSuperview];
//    }
    if(directAdd==nil)
    {
        directAdd = [[DirectAddViewController alloc] init];
    }
    [_sonView addSubview:directAdd.view];
}

-(void)closeDirectView
{
    [addView removeFromSuperview];
    addView = nil;
    __weak DirectViewController *__self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [__self setPlayModel];
        [__self updateData];
    });
}

-(BOOL)addDirectView:(RtspInfo *)rtsp
{
    if([RtspInfoDb addRtsp:rtsp])
    {
        [self.view makeToast:XCLocalized(@"devAddOk")];
    }
    [self closeDirectView];
    
    return YES;
    
}

-(void)initVideoView
{
    fSrcWidth = (fWidth-kTabbarWidth-kHomeListWidth-6)/2;
    fSrcHeight = (fHeight-131-6)/2;
    
    fDestWidth = (fWidth-kTabbarWidth)/2;
    fDestHeight = (fHeight-131-6)/2;
    
    aryView = [NSMutableArray array];
    for(int x=0;x<4;x++)
    {
        VideoView *view = [[VideoView alloc] initWithFrame:Rect(2+x%2*(fSrcWidth+2),65+x/2*(2+fSrcHeight),fSrcWidth,fSrcHeight)];
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
    [topView.btnFourer addTarget:self action:@selector(setFourView) forControlEvents:UIControlEventTouchUpInside];
    downView = [[PlayDownView alloc]initWithFrame:Rect(0,fHeight-67,self.view.width-kHomeListWidth,67)];
    [downView.btnCapture addTarget:self action:@selector(captureInfo:) forControlEvents:UIControlEventTouchUpInside];
    [downView.btnStop addTarget:self action:@selector(stopVideoCurent) forControlEvents:UIControlEventTouchUpInside];
    [downView.btnRecord addTarget:self action:@selector(recordingDirect:) forControlEvents:UIControlEventTouchUpInside];
    [_sonView addSubview:downView];
    [downView.btnBD addTarget:self action:@selector(switchVideo:) forControlEvents:UIControlEventTouchUpInside];
    [downView.btnHD addTarget:self action:@selector(switchVideo:) forControlEvents:UIControlEventTouchUpInside];
    downView.btnBD.tag = 2;
    downView.btnHD.tag = 1;
    [_borderLabel setFrame:((UIView*)[aryView objectAtIndex:0]).frame];
}

-(void)recordingDirect:(UIButton *)btnSender
{
    VideoView *video = (VideoView *)aryView[_nIndex];
    NSString *strNO = video.strNO;
    PlayViewController *model = [_aryModel objectForKey:strNO];
    if (model)
    {
        if (!btnSender.selected)
        {
            if(![model recordStart])
            {
                [video makeToast:XCLocalized(@"recordFail")];
                return ;
            }
            btnSender.selected = YES;
            [video setRecording:YES];
        }
        else
        {
            btnSender.selected = NO;
            [model recordStop];
            [video setRecording:NO];
        }
    }
}

-(void)captureInfo:(UIButton *)btnSender
{
    NSString *strNO = ((VideoView*)aryView[_nIndex]).strNO;
    PlayViewController *model = [_aryModel objectForKey:strNO];
    if (model)
    {
        BOOL bFLag = [model captureView];
        if (bFLag) {
            __weak PlayViewController *__playCon = model;
            dispatch_async(dispatch_get_main_queue(),
            ^{
                [__playCon.imgView makeToast:XCLocalized(@"captureS")];
            });
        }
    }
}


-(void)setFourView
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
    VideoView *video = (VideoView*)aryView[_nIndex];
    video.frame = Rect(2, 65, _sonView.width-4, _sonView.height-131);
    
    PlayViewController *playView = [_aryModel objectForKey:((VideoView*)aryView[_nIndex]).strNO];
    if (playView)
    {
        [playView setImgFrame:Rect(0,0,_sonView.width-4,_sonView.height-136)];
    }
    grayView.hidden = YES;
    bFull = YES;
    //添加手势
    [video addGestureRecognizer:leftGesture];
    [video addGestureRecognizer:rightGesture];
    [video addGestureRecognizer:pinchGesture];
    
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
        width = _tableView.hidden ? fSrcWidth : fDestWidth;
        height = _tableView.hidden ? fSrcHeight : fDestHeight;
        _sonView.frame = Rect(_tableView.hidden ? kHomeListWidth+1 : 0, 0, _tableView.hidden ? (self.view.width - kHomeListWidth):self.view.width, self.view.height);
        _tableView.hidden = !_tableView.hidden;
    }
    else
    {
        width = _tableView.hidden ? fDestWidth : fSrcWidth;
        height = _tableView.hidden ? fDestHeight : fDestHeight;
        
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
        for (PlayViewController *playView in [_aryModel allValues])
        {
            [playView setImgFrame:Rect(0, 0, width, height)];
        }
        grayView.hidden = _tableView.hidden;
    }
    else
    {
        [((VideoView*)aryView[_nIndex]) setFrame:Rect(2, 65, _sonView.width - 4 , _sonView.height - 131)];
        PlayViewController *playViewCon = [_aryModel objectForKey:((VideoView*)aryView[_nIndex]).strNO];
        if (playViewCon)
        {
            [playViewCon setImgFrame:Rect(0, 0,_sonView.width-4, _sonView.height-136)];
        }
        grayView.hidden = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskLandscapeRight;
}

-(BOOL)shouldAutorotate
{
    return  YES;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _aryRtsp.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strIdentifier = @"DirectCellIdentifier";
    DirectCell *directCell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if (directCell==nil) {
        directCell = [[DirectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
    }
    directCell.backgroundColor = [UIColor clearColor];
    RtspInfo *rtsp = (RtspInfo*)[_aryRtsp objectAtIndex:indexPath.row];
    [directCell setDeviceInfo:rtsp];
    
    if(nRow == indexPath.row)
     {
         if (bIsOpen)
         {
            CGFloat fHdHight = kSonHomeListheight * (rtsp.nChannel > 8 ? 8 :rtsp.nChannel);
            DLog(@"fHdHeight:%f",fHdHight);
            XCHiddenView *hdView = [[XCHiddenView alloc] initWithFrame:Rect(0, 82.5, kHomeListWidth,fHdHight) number:(int)rtsp.nChannel];
            hdView.tag = 10089;
            directCell.bSon = YES;
            [directCell.contentView addSubview:hdView];
        }
    }
    return directCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing)
    {
        [_aryTable setObject:[_aryRtsp objectAtIndex:indexPath.row] forKey:indexPath];
        return ;
    }
    //DVR的情况
    //明日工作内容:
    //1:对这类加入一个字典集合   包含一个PlayViewController 的父类
    //1.先查看strKey  是否已经存在
    
    RtspInfo *rtspInfo = (RtspInfo*)[_aryRtsp objectAtIndex:indexPath.row];
    if(![rtspInfo.strType isEqualToString:@"IPC"])
    {
             NSArray *indexPaths = nil;
            //如果上一次点击的是多通道设备
            //这次点击继续是多通道设备,两次不是同一行，需要先设置隐藏
            if (nSelectType==2 && selectPath != indexPath)
            {
                //找到上一次记录,隐藏
                DirectCell *cell = (DirectCell*)[_tableView cellForRowAtIndexPath:selectPath];
                cell.bSon = NO;
                if (!bIsOpen)
                {
                    bIsOpen = !bIsOpen;
                }
            }
            else
            {
                if (selectPath!=nil) {
                    DirectCell *cell = (DirectCell*)[_tableView cellForRowAtIndexPath:selectPath];
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
    nSelectType = 1;
    if (bIsOpen)
    {
         //如果之前已经打开了通道界面
         //删除此界面
        DirectCell *cell = (DirectCell*)[_tableView cellForRowAtIndexPath:selectPath];
        cell.bSon = NO;
        NSArray *indexPaths = [NSArray arrayWithObjects:indexPath,selectPath,nil];
        selectPath = indexPath;
        nRow = -1;
        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        bIsOpen = NO;
    }
    [self startPlay:rtspInfo];

}


-(BOOL)changeVideoView:(NSString *)strPath
{
    PlayViewController *playView = [_aryModel objectForKey:strPath];
    if(!playView)
    {
        return NO;
    }
    VideoView *oldView = (VideoView*)playView.view.superview;
    oldView.strNO = nil;
    [playView.view removeFromSuperview];
    VideoView *newView = aryView[_nIndex];
    newView.strNO = playView.strKey;
    [playView setFrame:newView.frame];
    [newView addSubview:playView.view];
    return YES;
}


-(void)startPlay:(RtspInfo *)rtspInfo
{
    [self startPlay:rtspInfo channel:0];
}

-(BOOL)checkStopVideo:(VideoView *)video
{
     PlayViewController *playControl = [_aryModel objectForKey:video.strNO];
     if (playControl)
     {
         if (!playControl.bPlaying)
         {
             return NO;
         }
         __weak PlayViewController *__playControl = playControl;
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
        
        [_aryModel removeObjectForKey:playControl.strKey];
        playControl = nil;
     }
    return YES;
}

-(void)startPlay:(RtspInfo*)rtspInfo channel:(int)nChannel
{
    PlayViewController *playViewController;
    NSString *strPath =nil;
    if([rtspInfo.strType isEqualToString:@"DVR"])
    {
        strPath = [NSString stringWithFormat:@"%@@%d@%@@%@@%d",rtspInfo.strAddress,(int)rtspInfo.nPort,rtspInfo.strUser,rtspInfo.strPwd,nChannel];
    }
    else
    {
        NSString *strAdmin = [@"" isEqualToString:rtspInfo.strUser] ? @"" : [NSString stringWithFormat:@"%@:%@@",rtspInfo.strUser,rtspInfo.strUser];
        if ([rtspInfo.strType isEqualToString:@"IPC"])
        {
            strPath = [NSString stringWithFormat:@"rtsp://%@%@:%d/1",strAdmin,rtspInfo.strAddress,(int)rtspInfo.nPort];
        }
        else
        {
            strPath = [NSString stringWithFormat:@"rtsp://%@%@:%d/%d1",strAdmin,rtspInfo.strAddress,(int)rtspInfo.nPort,nChannel];
        }
    }
    DLog(@"请求:%@",strPath);
    
    //先检测当前视频框状态
    VideoView *curVideo = aryView[_nIndex];
    if ([curVideo.strNO isEqualToString:strPath]) {
        //如果是一致的，视频不做变化
        return ;
    }
    DLog(@"curVideo:%@",curVideo.strNO);
       //如果当前通道正在播放其他视频,停止
    if (![self checkStopVideo:curVideo])
    {
        DLog(@"curVideo:%@",curVideo.strNO);
        [curVideo makeToast:XCLocalized(@"connectionDevice")];
        return ;
    }
    
    //如果请求的设备，在其他视频框中播放
    if ([self changeVideoView:strPath])
    {
        return ;
    }
    //通过不同方式播放视频
    if ([rtspInfo.strType isEqualToString:@"DVR"]) {
        playViewController = [[PrivatePlayViewController alloc] initWithPath:strPath name:rtspInfo.strDevName];
    }
    else
    {
        playViewController = [[RTSPPlayViewController alloc] initWithPath:strPath name:rtspInfo.strDevName];
        rtspInfo.nRequest = nChannel;
        playViewController.rtsp = rtspInfo;
    }
    playViewController.strKey = strPath;
    [playViewController setFrame:((VideoView*)aryView[_nIndex]).frame];
    [aryView[_nIndex] addSubview:playViewController.view];
    [(VideoView*)aryView[_nIndex] setStrNO:playViewController.strKey];
    [_aryModel setObject:playViewController forKey:playViewController.strKey];
}


#pragma mark 链接失败
-(void)connectFailDirect:(NSNotification*)notify
{
    NSString *strKey = notify.object;
    PlayViewController *playView = [_aryModel objectForKey:strKey];
     if (!playView)
     {
        return ;
    }
    VideoView *video = (VideoView*)playView.view.superview;
    __weak PlayViewController *__playView = playView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [__playView.view removeFromSuperview];
    });
    DLog(@"关闭一路视频:%@",video.strNO);
    __weak VideoView *__view = video;
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [__view makeToast:XCLocalized(@"connectFail") duration:1.5 position:@"center"];
    });
    video.strNO = nil; // 关闭STRNO
    [_aryModel removeObjectForKey:strKey];
}

#pragma mark 丢失连接
-(void)directDisConnectView:(NSNotification *)notify
{
    NSString *strKey = notify.object;
    PlayViewController *playView = [_aryModel objectForKey:strKey];
    if (!playView) {
        return ;
    }
    __weak PlayViewController *__playView = playView;
    
    
    VideoView *video = (VideoView*)playView.view.superview;
    __weak VideoView *__view = video;
    if (playView.bRecording)
    {
        [playView recordStop];
        dispatch_async(dispatch_get_main_queue(), ^{
            [__view setRecording:NO];
        });
    }
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_main_queue(),^{
        [__playView stopPlay];//销毁解码器操作
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [__playView.view removeFromSuperview];
    });
    dispatch_async(dispatch_get_main_queue(),
    ^{
        [__view makeToast:XCLocalized(@"Disconnect")];
    });
    
    DLog(@"中断链接:%@",video.strNO);
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    [_aryModel removeObjectForKey:strKey];
    video.strNO = nil; //干掉strPath
    DLog(@"剩余的key%@",[_aryModel allKeys]);
}


-(void)closeAllPlay
{
    for (PlayViewController *playView in [_aryModel allValues])
    {
        __weak DirectViewController *__self  = self ;
        __weak PlayViewController *__playView = playView;
        dispatch_async(dispatch_get_global_queue(0, 0),^{
            [__self clsoePlayView:__playView];
        });
    }
}

-(void)clsoePlayView:(PlayViewController *)playView
{
    [playView stopPlay];
    __weak PlayViewController *__playView = playView ;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group,dispatch_get_main_queue(),
    ^{
        [__playView.view removeFromSuperview];
    });
    dispatch_group_wait(group,DISPATCH_TIME_FOREVER);
    [_aryModel removeObjectForKey:playView.strNO];
    playView = nil;
}

-(void)setBtnEnableNO
{
    downView.btnHD.enabled = NO;
    downView.btnBD.enabled = NO;
    downView.btnRecord.enabled = NO;
    downView.btnCapture.enabled = NO;
    downView.btnStop.enabled = NO;
}

#pragma mark 解析  VideoView
-(void)clickView:(id)sender
{
    VideoView *view = (VideoView*)sender;
    for (VideoView *tempV in aryView)
    {
        tempV.layer.borderWidth = 0;
    }
    view.layer.borderWidth = 2;
    _nIndex = view.nCursel;
    if ([view.strNO isEqualToString:@""])
    {
        [self setBtnEnableNO];
        return ;
    }
    PlayViewController *playControl = [_aryModel objectForKey:view.strNO];
    if (!playControl)
    {
        [self setBtnEnableNO];
        return;
    }
    
    if (playControl.nCodeType)
    {
        downView.btnBD.enabled = NO;
        downView.btnHD.enabled = YES;
    }
    else
    {
        downView.btnHD.enabled = NO;
        downView.btnBD.enabled = YES;
    }
    downView.btnStop.enabled = YES;
    downView.btnRecord.enabled = YES;
    downView.btnCapture.enabled = YES;
    if (playControl.bRecording) {
        downView.btnRecord.selected= YES;
    }
    else
    {
        downView.btnRecord.selected = NO;
    }
}

-(void)doubleClickVideo:(id)sender
{
    if (bFull)
    {
        [self setFourView];
    }
    else
    {
        [self setOnlyView];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableView.editing)
    {
        [_aryTable removeObjectForKey:indexPath];
    }
}
#pragma mark tableView高度，与选择设置
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (bIsOpen)
    {
        if(nRow == indexPath.row)
        {
            DLog(@"come!");
            RtspInfo *rtsp = (RtspInfo*)[_aryRtsp objectAtIndex:indexPath.row];
            CGFloat fHDView = kSonHomeListheight * (rtsp.nChannel > 8 ? 8 :rtsp.nChannel);
            return 82.5+fHDView;
        }
    }
    return 82.5;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}






#pragma mark 停止当前Video
-(void)stopVideoCurent
{
    VideoView *video = (VideoView*)aryView[_nIndex];
    PlayViewController *model = [_aryModel objectForKey:video.strNO];
    if (model)
    {
        for (UIView *view in video.subviews)
        {
            [view removeFromSuperview];
        }
        __weak PlayViewController *__model = model;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group,dispatch_get_global_queue(0, 0), ^{
            [__model stopPlay];
        });
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        DLog(@"删除Video:%@",video.strNO);
        [_aryModel removeObjectForKey:video.strNO];
        model = nil;
        video.strNO = nil;
    }
}
-(void)closeAllView
{
    for (PlayViewController *model in [_aryModel allValues])
    {
        __weak PlayViewController *__model = model;
        VideoView *video = (VideoView*)model.view.superview;
        video.strNO = nil;
        __weak VideoView *__video = video;
        dispatch_async(dispatch_get_main_queue(),
        ^{
             if (__model.bRecording)
             {
                [__video setRecording:NO];
             }
             [__model.view removeFromSuperview];
        });
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group,dispatch_get_global_queue(0, 0),
        ^{
             [__model stopPlay];
        });
        DLog(@"删除:%@",model.strNO);
        [_aryModel removeObjectForKey:model.strNO];
    }
    DLog(@"%@",[_aryModel allKeys]);

}

#pragma mark 关闭通知，关闭所有播放的
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //关闭所有
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self closeAllView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(directDisConnectView:) name:NSCONNECT_P2P_DISCONNECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectDVR:) name:NS_CONNECT_DVR_CHANNEL_VC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectFailDirect:) name:NS_CLOSE_DIRECT_VC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickViewForNotify:) name:NS_PLAY_VIEW_CLICK_VC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDirectList) name:NS_DIRECT_UPDATE_LIST_VC object:nil];
}

-(void)updateDirectList
{
    [self setPlayModel];
    [self updateData];
}

-(void)clickViewForNotify:(NSNotification *)notify
{
    VideoView *view = (VideoView*)((PlayViewController*)notify.object).view.superview;
    if (![view.strNO isEqualToString:@""]) {
        __weak DirectViewController *__self = self;
        __weak VideoView *__view = view;
        VideoView *checkVideo = aryView[_nIndex];
        if (view != checkVideo) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [__self clickView:__view];
        });
    }
}


-(void)connectDVR:(NSNotification *)notify
{
    RtspInfo *rtsp = (RtspInfo *)[_aryRtsp objectAtIndex:selectPath.row];
    int nChannel = [notify.object intValue];
    DLog(@"connect:%@--%d",rtsp.strAddress,nChannel);
    __block int __nChannel = nChannel;
    __weak DirectViewController *__self = self;
    __weak RtspInfo *__rtsp = rtsp;
    dispatch_async(dispatch_get_main_queue(),
    ^{
         [__self startPlay:__rtsp channel:__nChannel];
    }
    );
}

-(void)switchVideo:(UIButton *)btnSender
{
    int nType = (int)(btnSender.tag - 1);
    [self switchVideoInfo:nType];
}

-(void)switchVideoInfo:(int)nCode
{
    VideoView *video = (VideoView *)aryView[_nIndex];
    if (![video.strNO isEqualToString:@""])
    {
        PlayViewController *playView = [_aryModel objectForKey:video.strNO];
        if (playView)
        {
            [playView switchCode:nCode];
        }
    }
}






    

@end
