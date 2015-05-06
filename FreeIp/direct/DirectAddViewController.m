//
//  DirectAddViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "UIView+Extension.h"
#import "XCNotification.h"
#import "RtspInfo.h"
#import "devdiscovery.h"
#import "Toast+UIView.h"
#import "RtspInfoDb.h"
#import "DirectAddView.h"
#import "UtilsMacro.h"
#import "DirectAddViewController.h"

@interface DirectAddViewController ()<DirectAddDelegate,UITableViewDataSource,UITableViewDelegate>
{
    DirectAddView *addView;
    UIView *searchView;
    UITableView *_tableView;
    UIButton *btnTabAdd;
    NSMutableArray *aryDevice;
    UIButton *btnTabCancel;
    BOOL bEdit;
}
@end

@implementation DirectAddViewController

-(id)initWithType:(BOOL)bType
{
    self = [super init];
    bEdit = bType;
    return self;
}

/*
1.局域网搜索方式
2.手动输入方式
*/

-(void)loadView
{
    CGFloat fWidth,fHeight;
    if(IOS_SYSTEM_8)
    {
        fWidth = kScreenSourchWidth-72-kHomeListWidth;
        fHeight = kScreenSourchHeight;
    }
    else
    {
        fWidth = kScreenSourchHeight-72-kHomeListWidth;
        fHeight = kScreenSourchWidth;
    }
    self.view = [[UIView alloc] initWithFrame:Rect(0, 0, fWidth, fHeight)];
}

-(void)initUIHead
{
    UIImageView *imgBack = [[UIImageView alloc] initWithFrame:Rect(0, 0, self.view.width, 64)];
    [self.view addSubview:imgBack];
    [imgBack setImage:[UIImage imageNamed:@"top_bg"]];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:Rect(50, 30, self.view.width, 20)];
    [lblTitle setText:XCLocalized(@"")];
    [self.view addSubview:lblTitle];
}

-(void)createHeadView
{
    UIView *view = [[UIView alloc] initWithFrame:Rect(0, 0, self.view.width, 64)];
    [self.view addSubview:view];
    [self.view setBackgroundColor:RGB(242, 242, 242)];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.bounds];
    [imgView setImage:[UIImage imageNamed:@"top_bg"]];
    [view addSubview:imgView];
    
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSave setTitle:XCLocalized(@"save") forState:UIControlStateNormal];
    [btnSave setTitleColor:RGB(15, 173, 225) forState:UIControlStateNormal];
    btnSave.frame = Rect(self.view.width-70, 10, 60,44);
    [btnSave addTarget:self action:@selector(saveInfo) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnSave];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(100, 20,self.view.width-200, 20)];
    [lblName setFont:XCFONT(20)];
    [lblName setTextColor:[UIColor blackColor]];
    [lblName setText:XCLocalized(@"addrtsp")];
    [view addSubview:lblName];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:XCLocalized(@"cancel") forState:UIControlStateNormal];
    [btnCancel setTitleColor:RGB(15, 173, 225) forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnCancel];
    btnCancel.frame = Rect(25, 10, 60,44);
    
    UIButton *btnMuma = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMuma setTitle:XCLocalized(@"input") forState:UIControlStateNormal];
    [btnMuma setTitleColor:RGB(15, 173, 225) forState:UIControlStateNormal];
    [btnMuma setBackgroundColor:RGB(255, 255, 255)];
    [self.view addSubview:btnMuma];
    btnMuma.frame = Rect(0,64,self.view.width/2-1,50);
    btnMuma.tag = 10001;
    [btnMuma addTarget:self action:@selector(btnEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnLan = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLan setTitle:XCLocalized(@"lanSearch") forState:UIControlStateNormal];
    [btnLan setTitleColor:RGB(15, 173, 225) forState:UIControlStateNormal];
    [btnLan setBackgroundColor:RGB(255, 255, 255)];
    [self.view addSubview:btnLan];
    btnLan.frame = Rect(btnMuma.x+btnMuma.width+1,btnMuma.y, btnMuma.width, btnMuma.height);
    [btnLan addTarget:self action:@selector(btnEvent:) forControlEvents:UIControlEventTouchUpInside];
    btnLan.tag = 10002;
    
}

-(void)btnEvent:(UIButton*)btnSender
{
    if (btnSender.tag == 10001)
    {
        [((UIButton*)[self.view viewWithTag:10002]) setSelected:NO];
        if (addView.superview != self.view)
        {
            [searchView removeFromSuperview];
            [self.view addSubview:addView];
        }   
    }
    else
    {
        [((UIButton*)[self.view viewWithTag:10001]) setSelected:NO];
        if (searchView.superview != self.view)
        {
            [addView removeFromSuperview];
            [self.view addSubview:searchView];
        }
    }
    btnSender.selected = YES;
    
}

-(void)saveInfo
{
    [addView addRtspInfo];
}

-(void)closeView
{
    [self.view removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createHeadView];
    aryDevice = [NSMutableArray array];
    addView = [[DirectAddView alloc] initWithFrame:Rect(0,114, self.view.width, self.view.height-114)];
    [self.view addSubview:addView];
    addView.delegate = self;
    [self createSearchView];
    [self createDirectListView];
    
}

-(void)createSearchView
{
    searchView = [[UIView alloc] initWithFrame:Rect(0, 114, self.view.width, self.view.height)];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(self.view.width/2-65.5,141,131,98)];
    [imgView setImage:[UIImage imageNamed:@"WIFI"]];
    [searchView addSubview:imgView];
    
    UIButton *btnWLan = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchView addSubview:btnWLan];
    [btnWLan setTitle:@"搜索设备" forState:UIControlStateNormal];
    [btnWLan setBackgroundColor:RGB(75, 158, 248)];
    [btnWLan setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnWLan.frame = Rect(22, 300, self.view.width-44,50);
    [btnWLan addTarget:self action:@selector(searchWlan) forControlEvents:UIControlEventTouchUpInside];
}


-(void)searchWlan
{
    discovery();
    DD_SearchDev();
    [self.view makeToast:XCLocalized(@"searching") duration:2.0 position:@"center"];
    [aryDevice removeAllObjects];
}

-(void)createDirectListView
{
    _tableView = [[UITableView alloc] initWithFrame:Rect(0, 114, self.view.width, self.view.height-160)];
    _tableView.delegate = self;
    _tableView.dataSource = self ;
}

-(void)updateSearchData:(NSNotification*)notify
{
    NSMutableArray *aryTemp = notify.object;
    __weak DirectAddViewController *__self = self;
    
    if (aryTemp.count==0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [__self.view makeToast:XCLocalized(@"")];
        });
    }
    for (RtspInfo *rtsp in aryTemp)
    {
        [aryDevice addObject:rtsp];
    }
    __weak UITableView *__tableView = _tableView;
    dispatch_async(dispatch_get_main_queue(), ^{
        [__tableView reloadData];
    });
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_bType)
    {
        [addView setRtspInfo:_rtsp];
    }
    else
    {
        [addView setTxtRtspNull];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSearchData:) name:NS_SEARCH_DEVICE_FOR_WLAN_VC object:nil];
}

-(BOOL)addDirectView:(RtspInfo*)rtsp
{
    if (_bType)
    {
        
        BOOL bReturn = [RtspInfoDb updateRtsp:rtsp];
        [[NSNotificationCenter defaultCenter] postNotificationName:NS_DIRECT_UPDATE_LIST_VC object:nil];
        [self.view.superview removeFromSuperview];
        return bReturn;
    }
    BOOL bReturn = [RtspInfoDb addRtsp:rtsp];
    if (bReturn)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NS_DIRECT_UPDATE_LIST_VC object:nil];
        [self.view.superview removeFromSuperview];
    }
    else
    {
        DLog(@"添加失败");
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryDevice.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strIdentity = @"directSearchIdentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentity];
    if (cell==nil) {
        
    }
    
    
    return cell;
}





@end
