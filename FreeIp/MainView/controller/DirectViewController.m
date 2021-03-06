//
//  DirectViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "DirectViewController.h"
#import "UtilsMacro.h"
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
    NSMutableArray *aryView;
    CGFloat fSrcWidth,fSrcHeight;
    CGFloat fDestWidth,fDestHeight;
    PDTopview *topView;
    UIView *_sonView;
    UILabel *_borderLabel;
    PlayDownView *downView;
    NSInteger _nIndex;
    DirectAddView *addView;
    BOOL bFull;
    NSMutableDictionary *_aryTable;
//    RTSPPlayViewController *rtspPlay;
    
//    PrivatePlayViewController *privateView;
    NSMutableArray *_aryRtsp;
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
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(17, 30, 100, 20)];
    [lblName setFont:XCFONT(20)];
    [lblName setTextColor:RGB(100,100, 100)];
    [lblName setText:XCLocalized(@"deviceList")];
    [headView addSubview:lblName];
    
    UIButton *btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAdd setImage:[UIImage imageNamed:@"add_dir"] forState:UIControlStateNormal];
    [btnAdd setImage:[UIImage imageNamed:@"add_dir_h"] forState:UIControlStateHighlighted];
    [headView addSubview:btnAdd];
    btnAdd.frame = Rect(kHomeListWidth-50, 20, 44, 44);
    [btnAdd addTarget:self action:@selector(setAddModel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDel setImage:[UIImage imageNamed:@"del_dir"] forState:UIControlStateNormal];
    [btnDel setImage:[UIImage imageNamed:@"del_dir_h"] forState:UIControlStateHighlighted];
    [btnDel setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [btnDel addTarget:self action:@selector(delDevice:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btnDel];
    btnDel.frame = Rect(kHomeListWidth-100, 20, 44, 44);
    [_tableView setTableHeaderView:headView];
    [_tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_bg"]]];
    
    _sonView = [[UIView alloc] initWithFrame:Rect(_tableView.x+_tableView.width+1,0,fWidth-kHomeListWidth-kTabbarWidth,fHeight)];
    [self.view addSubview:_sonView];
    
    [self initVideoView];
    
    [self setPlayModel];
    
    [self updateData];
    
    _aryModel = [NSMutableDictionary dictionary];
    
    
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

-(void)setAddModel
{
    for (UIView *view in _sonView.subviews)
    {
        [view removeFromSuperview];
    }
    addView = [[DirectAddView alloc] initWithFrame:_sonView.bounds];
    [_sonView addSubview:addView];
    addView.delegate = self;
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
    [_borderLabel setFrame:((UIView*)[aryView objectAtIndex:0]).frame];
}

-(void)recordingDirect:(UIButton *)btnSender
{
    NSString *strNO = ((VideoView*)aryView[_nIndex]).strNO;
    PlayViewController *model = [_aryModel objectForKey:strNO];
    if (model)
    {
        if (!btnSender.selected)
        {
            btnSender.selected = YES;
            [model recordStart];
        }
        else
        {
            btnSender.selected = NO;
            [model recordStop];
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
    ((VideoView*)aryView[_nIndex]).frame = Rect(2, 65, _sonView.width-4, _sonView.height-131);
    
    PlayViewController *playView = [_aryModel objectForKey:((VideoView*)aryView[_nIndex]).strNO];
    if (playView)
    {
        [playView setImgFrame:Rect(0,0,_sonView.width-4,_sonView.height-136)];
    }
    
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
    }
    else
    {
        [((VideoView*)aryView[_nIndex]) setFrame:Rect(2, 65, _sonView.width - 4 , _sonView.height - 131)];
        PlayViewController *playViewCon = [_aryModel objectForKey:((VideoView*)aryView[_nIndex]).strNO];
        if (playViewCon)
        {
            [playViewCon setImgFrame:Rect(0, 0,_sonView.width-4, _sonView.height-136)];
        }
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
    [directCell setDeviceInfo:((RtspInfo*)[_aryRtsp objectAtIndex:indexPath.row])];
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
    
    
    [self startPlay:rtspInfo];
}


-(BOOL)changeVideoView:(NSString *)strPath
{
    PlayViewController *playView = [_aryModel objectForKey:strPath];
    if (!playView)//如果没有不替换
    {
        return NO;
    }
    VideoView *oldView = (VideoView*)playView.view.superview;
    oldView.strNO = nil;
    [playView.view removeFromSuperview];
    VideoView *newView = aryView[_nIndex];
    [playView setFrame:newView.frame];
    [newView addSubview:playView.view];
    return YES;
}

-(void)startPlay:(RtspInfo*)rtspInfo
{
    PlayViewController *playViewController;
    NSString *strPath =nil;
    if([rtspInfo.strType isEqualToString:@"DVR"])
    {
        strPath = [NSString stringWithFormat:@"%@@%d@%@@%@",rtspInfo.strAddress,(int)rtspInfo.nPort,rtspInfo.strUser,rtspInfo.strPwd];

        if([self changeVideoView:strPath])
        {
            //执行替换视频动作
            return ;
        }
        playViewController = [[PrivatePlayViewController alloc] initWithPath:strPath name:rtspInfo.strDevName];
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
            strPath = [NSString stringWithFormat:@"rtsp://%@%@:%d/01",strAdmin,rtspInfo.strAddress,(int)rtspInfo.nPort];
            
        }
        DLog(@"strPath:%@",strPath);
        if([self changeVideoView:strPath])
        {
            return ;
        }
        playViewController = [[RTSPPlayViewController alloc] initWithPath:strPath name:rtspInfo.strDevName];
    }
    playViewController.strKey = strPath;
    [playViewController setFrame:((VideoView*)aryView[_nIndex]).frame];
    [aryView[_nIndex] addSubview:playViewController.view];
    [(VideoView*)aryView[_nIndex] setStrNO:playViewController.strKey];
    [_aryModel setObject:playViewController forKey:playViewController.strKey];
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

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_main_queue(),^{
        [__playView stopPlay];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        [__playView.view removeFromSuperview];
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    [_aryModel removeObjectForKey:strKey];
    
    
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
}

-(void)doubleClickVideo:(id)sender
{
    
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
        DLog(@"删除");
        [_aryModel removeObjectForKey:model.strNO];
        model = nil;
    }
}
-(void)closeAllView
{
    for (PlayViewController *model in [_aryModel allValues])
    {
        __weak PlayViewController *__model = model;
        dispatch_async(dispatch_get_main_queue(),
        ^{
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

#pragma mark 去掉
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
}
@end
