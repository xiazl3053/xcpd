//
//  RecordViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/4/7.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "RecordPlayViewController.h"
#import "UtilsMacro.h"
#import "Toast+UIView.h"
#import "XCNotification.h"
#import "HistoryViewController.h"
#import "PlayViewController.h"
#import "UIView+Extension.h"
#import "RecordCell.h"
#import "RecordModel.h"

#import "XCTextField.h"
#import "XCButton.h"

@interface RecordPlayViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIView *queryView;
    UIView *headView;
    UIView *recordView;
    NSMutableArray *aryRecord;
    UIView *playView;
    PlayViewController *_playViewCon;
}
@property (nonatomic,strong) UITableView *tableView;

@end

@implementation RecordPlayViewController


-(id)initWithItems:(NSArray*)items
{
    self = [super init];
    
    aryRecord = [NSMutableArray arrayWithArray:items];
    
    return self;
}

-(void)loadView
{
    if (IOS_SYSTEM_8) {
        self.view = [[UIView alloc] initWithFrame:Rect(0, 0, kScreenSourchWidth, kScreenSourchHeight)];
    }
    else
    {
        self.view = [[UIView alloc] initWithFrame:Rect(0, 0, kScreenSourchHeight, kScreenSourchWidth)];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initHeadView];
    [self initTableView];
    playView = [[UIView alloc] initWithFrame:Rect(0, 64, 700,self.view.height-64)];
    [self.view addSubview:playView];
}

-(void)initRecordView
{
//    recordView = [[UIView alloc] initWithFrame:Rect(0, self.view.height-136, 700, 136)];
//    [recordView setBackgroundColor:RGB(37, 40, 41)];
//    
//    UILabel *lblStart = [[UILabel alloc] initWithFrame:Rect(25, 38, 80, 20)];
//    
//    UILabel *lblEnd = [[UILabel alloc] initWithFrame:Rect(605, 38, 80, 20)];
//    
//    UIProgressView *progrossView = [[UIProgressView alloc] initWithFrame:Rect(110, 48, 480, 20)];
//    
//    [recordView addSubview:lblStart];
//    [lblStart setTextColor:[UIColor whiteColor]];
//    [lblStart setText:@"00:00:00"];
//    
//    [recordView addSubview:lblEnd];
//    [lblEnd setText:@"00:00:00"];
//    [lblEnd setTextColor:[UIColor whiteColor]];
//    
//    [recordView addSubview:progrossView];
//    [progrossView setBackgroundColor:RGB(24, 26, 27)];
//    
//    XCButton *btnPlay = [[XCButton alloc] initWithFrame:Rect(328, 70, 44, 44) normal:@"his_play" high:@"" select:@"his_pause"];
//    btnPlay.tag = 10001;
//    
//    XCButton *btnSlow = [[XCButton alloc] initWithFrame:Rect(224,70,44,44) normal:@"his_back" high:@"his_back_h"];
//    
//    XCButton *btnForward = [[XCButton alloc] initWithFrame:Rect(432, 70, 44, 44) normal:@"his_forward" high:@"his_forward_h"];
//    
//    [recordView addSubview:btnPlay];
//    
//    [recordView addSubview:btnSlow];
//    
//    [recordView addSubview:btnForward];
//    
//    [self.view addSubview:recordView];
//   
//    playView = [[UIView alloc] initWithFrame:Rect(0, 64, 700,self.view.height-136-64)];
//    [self.view addSubview:playView];
//    [playView setBackgroundColor:RGB(0, 0, 0)];
    
}

-(void)initTableView
{
    UILabel *lblContent = [[UILabel alloc] initWithFrame:Rect(self.view.width-324, 64, 1,self.view.height-64)];
//    [lblContent setBackgroundColor:RGB(255,255,255)];
    [lblContent setBackgroundColor:RGB(24, 26, 27)];
    [self.view addSubview:lblContent];
    
    _tableView = [[UITableView alloc] initWithFrame:Rect(self.view.width-323, 64, 323 ,self.view.height-64)];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellAccessoryNone;
    
    [_tableView setBackgroundColor:RGB(36, 40, 41)];
    

}

-(void)initHeadView
{
    CGFloat fWidth,fHeight;
    if (IOS_SYSTEM_8) {
        fWidth = kScreenSourchWidth;
        fHeight = kScreenSourchHeight;
    }
    else
    {
        fHeight = kScreenSourchWidth;
        fWidth = kScreenSourchHeight;
    }
    headView = [[UIView alloc] initWithFrame:Rect(0, 0,fWidth, 64)];
    UIImageView *imgBack = [[UIImageView alloc] initWithFrame:headView.bounds];
    [imgBack setImage:[UIImage imageNamed:@"top_bg"]];
    [headView addSubview:imgBack];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(80, 20,fWidth-160, 20)];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    [lblName setText:@"录像播放"];
    [lblName setTextColor:RGB(0, 0,0)];
    [headView addSubview:lblName];
    
    
    
    XCButton *btnCancel = [[XCButton alloc] initWithFrame:Rect(15, 20, 44, 44) normal:@"his_cancel_h" high:@"his_cancel"];
    [headView addSubview:btnCancel];
    
    XCButton *btnQuery = [[XCButton alloc] initWithFrame:Rect(fWidth-64, 20, 44, 44) normal:@"his_query" high:@"his_query_h"];
//  [headView addSubview:btnQuery];
    
    [self.view addSubview:headView];
    
    queryView = [[UIView alloc] initWithFrame:Rect(fWidth-200, 80, 180, 160)];
    [self.view addSubview:queryView];
    [queryView setBackgroundColor:[UIColor whiteColor]];
    
    XCTextField *txtWord = [[XCTextField alloc] initWithFrame:Rect(15,30,150, 20)];
    [queryView addSubview:txtWord];
    UIColor *color = [UIColor whiteColor];
    txtWord.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"关键字查找" attributes:@{NSForegroundColorAttributeName: color}];
    [queryView addSubview:txtWord];
    
  //  queryView.hidden = YES;
    [self.view insertSubview:queryView atIndex:0];
    [btnQuery addTarget:self action:@selector(queryOper) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
}

-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)queryOper
{
    queryView.hidden = !queryView.hidden;
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryRecord.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strIdentifier = @"RECORDVIEWCONTROLLERIDENTIFIER";
    RecordCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if (cell==nil) {
        cell = [[RecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
    }

    cell.backgroundColor = [UIColor clearColor];
    UIView *selectView = [[UIView alloc] initWithFrame:cell.bounds];
    [selectView setBackgroundColor:[UIColor clearColor]];
    cell.selectedBackgroundView = selectView;
    [cell setRecordModel:[aryRecord objectAtIndex:indexPath.row]];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecordModel *recordMo = [aryRecord objectAtIndex:indexPath.row];
    if(recordMo.nFramesNum<10)
    {
        [self.view makeToast:@""];
        DLog(@"wenjiantaiduan:%d",(int)recordMo.nFramesNum);
        return ;
    }
    [self stopVideo];
    //路径file path
    for (UIView *view in playView.subviews) {
        [view removeFromSuperview];
    }
    _playViewCon = [[HistoryViewController alloc] initWithRecordInfo:recordMo];
    [_playViewCon setFrame:Rect(0, 0, 700, self.view.height-200)];
    [playView addSubview:_playViewCon.view];
    
    
}

-(void)stopVideo
{
    if(_playViewCon)
    {
        [_playViewCon stopPlay];
        //设置按钮禁用
        [self setBtnEnable];
    }
}

-(void)setBtnEnable
{
    __weak PlayViewController *playCon = _playViewCon;
    dispatch_async(dispatch_get_main_queue(), ^{
        [playCon.view removeFromSuperview];
    });
}

-(void)readDone:(NSNotification*)notify
{
     [self stopVideo];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readDone:) name:NS_RECORD_DONE_VC object:nil];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    
}

@end
