//
//  DirectAddViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "UIView+Extension.h"
#import "XCNotification.h"
#import "RtspInfoDb.h"
#import "DirectAddView.h"
#import "UtilsMacro.h"
#import "DirectAddViewController.h"

@interface DirectAddViewController ()<DirectAddDelegate>
{
    DirectAddView *addView;
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
    addView = [[DirectAddView alloc] initWithFrame:Rect(0, 64, self.view.width, self.view.height-64)];
    [self.view addSubview:addView];
    addView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(bEdit)
    {
        
    }
    else
    {
        [addView setTxtRtspNull];
    }
}


-(BOOL)addDirectView:(RtspInfo*)rtsp
{
    BOOL bReturn = [RtspInfoDb addRtsp:rtsp];
    if (bReturn) {
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

@end
