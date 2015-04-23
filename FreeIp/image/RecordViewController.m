//
//  RecordViewController.m
//  FreeIp
//
//  Created by 夏钟林 on 15/4/2.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "RecordViewController.h"
#import "UtilsMacro.h"
#import "RecordPlayViewController.h"
#import "XCButton.h"
#import "ImageCell.h"
#import "XCNotification.h"
#import "Picture.h"
#import "PhoneDb.h"
#import "RecordDb.h"
#import "RecordModel.h"
#import "Toast+UIView.h"
#import "NSDate+convenience.h"
#import "RecordView.h"
#import "PictureView.h"
#import "XCPhoto.h"
#import "XCPhotoViewController.h"
#import "UIView+Extension.h"
#import "VRGCalendarView.h"
@interface RecordViewController ()<VRGCalendarViewDelegate,UITableViewDataSource,UITableViewDelegate,RecordCellDelegate>
{
    int nSelect;
    BOOL bDel;
    NSMutableDictionary *deletePic;
    NSMutableDictionary *deleteRec;
    UILabel *lblNoImage;
    UIImageView *imgNo;
    CGFloat fWidth,fHeight;
}
// Do any additional setup after loading the view.
@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *arrayInfo;
@property (nonatomic,strong) NSMutableArray *arrayRecord;
@property (nonatomic,strong) VRGCalendarView *vrgCalendar;
@property (nonatomic,strong) NSMutableArray *arySet;
@property (nonatomic,strong) NSMutableDictionary *tablePic;
@property (nonatomic,strong) NSMutableDictionary *tableRec;
@property (nonatomic,strong) UIView *queryView;

@end

@implementation RecordViewController

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
    self.view = [[UIView alloc] initWithFrame:Rect(0, 0, fWidth-kHomeListWidth-kTabbarWidth-1, fHeight)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:RGB(239, 239, 204)];
    [self initUI];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,64, self.view.width, fHeight-64)];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _arrayInfo = [[NSMutableArray alloc] init];
    _vrgCalendar = [[VRGCalendarView alloc] init];
    _vrgCalendar.delegate=self;
    _vrgCalendar.frame = CGRectMake(0, 64, self.view.width, 260);
    [self.view addSubview:_vrgCalendar];
    _vrgCalendar.hidden = YES;
    
    //查询面板
    [self addQueryView];
    
    deletePic = [NSMutableDictionary dictionary];
    deleteRec = [NSMutableDictionary dictionary];
    _arySet = [NSMutableArray array];
    _tablePic = [NSMutableDictionary dictionary];
    _tableRec = [NSMutableDictionary dictionary];
    
    imgNo = [[UIImageView alloc] initWithFrame:Rect((self.view.width-99)/2, (fHeight-64-70)/2, 99, 70)];
    [imgNo setImage:[UIImage imageNamed:@"noImage"]];
    imgNo.contentMode = UIViewContentModeScaleAspectFit;
    
    imgNo.tag = 3059;
    
    lblNoImage = [[UILabel alloc] initWithFrame:Rect(0, imgNo.frame.origin.y+imgNo.frame.size.height+10, self.view.width, 20)];
    [lblNoImage setFont:[UIFont fontWithName:@"Helvetica" size:15.0f]];
    [lblNoImage setText:XCLocalized(@"noRecording")];
    [lblNoImage setTextAlignment:NSTextAlignmentCenter];
    
    lblNoImage.tag = 3060;
    [_tableView addSubview:imgNo];
    [_tableView addSubview:lblNoImage];
    imgNo.hidden = YES;
    lblNoImage.hidden = YES;
    
    [self initData];
}

-(void)addQueryView
{
 _queryView = [[UIView alloc] initWithFrame:Rect(self.view.width-300,64, 300, 210)];
    [_queryView setBackgroundColor:RGB(255, 255, 255)];
    
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:Rect(50, 10, 200, 20)];
    [lblTitle setText:XCLocalized(@"search")];
    [_queryView addSubview:lblTitle];
    [lblTitle setFont:XCFONT(19)];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];

    UILabel *lblContent = [[UILabel alloc] initWithFrame:Rect(50, 40, 200, 1)];
    [lblContent setBackgroundColor:RGB(128, 128, 128)];
    [_queryView addSubview:lblContent];
  
    UILabel *lblStart = [[UILabel alloc] initWithFrame:Rect(50, 50, 200, 30)];
    [lblStart setTextAlignment:NSTextAlignmentLeft];
    [lblStart setText:XCLocalized(@"startTime")];
    [lblStart setFont:XCFONT(15.0)];
    [_queryView addSubview:lblStart];
    
    UILabel *lblEnd = [[UILabel alloc] initWithFrame:Rect(50, lblStart.y+40, 200, 30)];
    [lblEnd setText:XCLocalized(@"endTime")];
    [lblEnd setFont:XCFONT(15.0)];
    [_queryView addSubview:lblEnd];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = Rect(50, lblEnd.y+40 , 200,30);
    [btn setTitleColor:RGB(255,255,255) forState:UIControlStateNormal];
    [btn setBackgroundColor:RGB(15, 173, 225)];
    [btn setTitle:XCLocalized(@"search") forState:UIControlStateNormal];
    [_queryView addSubview:btn];
    
    lblStart.textColor = RGB(15,173,225);
    lblEnd.textColor = RGB(15, 173, 225);
 
    NSDate *date = [NSDate date];
    NSString *strEnd = [NSString stringWithFormat:@"%d-%02d-%02d",date.year,date.month,date.day];
    NSDate *agoDate = [NSDate dateWithTimeIntervalSinceNow:-7*24*60*60];
    NSString *strStart = [NSString stringWithFormat:@"%d-%02d-%02d",agoDate.year,agoDate.month,agoDate.day];
    lblStart.text = strStart;
    lblEnd.text = strEnd;
    [lblStart addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startDate)]];
    
    [lblEnd addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endDate)]];
    [lblEnd setUserInteractionEnabled:YES];
    [lblStart setUserInteractionEnabled:YES];

    [btn addTarget:self action:@selector(queryRecordInfo) forControlEvents:UIControlEventTouchUpInside];
    
    lblStart.tag = 1003;
    lblEnd.tag = 1004;
    btn.tag = 1005;
    
    [self.view insertSubview:_queryView aboveSubview:_tableView];
    _queryView.hidden = YES;
}

-(void)sortDate:(NSArray*)array
{
    NSMutableArray *dataArray=[[NSMutableArray alloc]initWithCapacity:0];
    
    for (NSString *strTime in array)
    {
        NSMutableDictionary *dir=[[NSMutableDictionary alloc]init];
        [dir setObject:strTime forKey:@"time"];
        [dataArray addObject:dir];
    }
    
    NSMutableArray *myArray=[[NSMutableArray alloc]initWithCapacity:0];
    [myArray addObjectsFromArray:dataArray];
    
    NSSortDescriptor*sorter=[[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
    NSMutableArray *sortDescriptors=[[NSMutableArray alloc]initWithObjects:&sorter count:1];
    NSArray *newArray = [myArray sortedArrayUsingDescriptors:sortDescriptors];
    
    for (NSInteger i=[newArray count]-1; i>=0; i--)
    {
        [_arySet addObject:[[newArray objectAtIndex:i] objectForKey:@"time"]];
    }
    
}

-(void)initUI
{
    UIView *headView = [[UIView alloc] initWithFrame:Rect(0, 0, self.view.width, 64)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_bg"]];
    [imgView setFrame:headView.bounds];
    [headView addSubview:imgView];
    [self.view addSubview:headView];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:Rect(50, 20, self.view.width-100, 20)];
    [lblName setText:XCLocalized(@"recordInfo")];
    [headView addSubview:lblName];
    [lblName setFont:XCFONT(20)];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    [lblName setTextColor:[UIColor blackColor]];
   
    XCButton *btnQuery = [[XCButton alloc] initWithFrame:Rect(self.view.width-112,20, 44, 44) normal:@"his_query_h" high:@"his_query"];
    [headView addSubview:btnQuery];
    
    XCButton *btnDelete = [[XCButton alloc] initWithFrame:Rect(self.view.width-60, 20, 44, 44) normal:@"his_del_h" high:@"his_del" select:@"his_ok"];
    [headView addSubview:btnDelete];
    
    [self.view addSubview:btnQuery];
    [self.view addSubview:btnDelete];

    [btnDelete addTarget:self action:@selector(delReocrd:) forControlEvents:UIControlEventTouchUpInside];
    [btnQuery addTarget:self action:@selector(qryRecord) forControlEvents:UIControlEventTouchUpInside];
}

-(void)delReocrd:(UIButton*)btnSender
{
    if (btnSender.selected)
    {
        btnSender.selected = NO;
        //执行删除操作
        NSArray *aryRecord = [deleteRec allValues];
        [RecordDb deleteRecord:aryRecord];
        [self initData];
    }
    else
    {
        btnSender.selected = YES;
        //执行选择删除
    }
    bDel = !bDel;
}

-(void)qryRecord
{
    _queryView.hidden = !_queryView.hidden;
}

-(void)updateImageList
{
    
    [_arrayInfo removeAllObjects];
    [_arySet removeAllObjects];
    [_tablePic removeAllObjects];
    [_tableRec removeAllObjects];
    
    [self getAllDir];
    
}

-(void)startDate
{
    nSelect = 1;
    _vrgCalendar.hidden = NO;
}
-(void)endDate
{
    nSelect = 2;
    _vrgCalendar.hidden = NO;
}
-(void)queryRecordInfo
{
    UILabel *lblStart = (UILabel*)[_queryView viewWithTag:1003];
    UILabel *lblEnd = (UILabel*)[_queryView viewWithTag:1004];
    
    [_arySet removeAllObjects];
    [_tablePic removeAllObjects];
    [_tableRec removeAllObjects];
    NSMutableSet *set = [NSMutableSet set];
    NSArray *aryRecord = [RecordDb queryRecordByTimeSE:lblStart.text end:lblEnd.text];
    for (RecordModel *record in aryRecord)
    {
        NSString *strFormat = ([record.strStartTime componentsSeparatedByString:@" "])[0];
        [set addObject:strFormat];
        NSMutableArray *array = [_tableRec objectForKey:strFormat];
        if (!array)
        {
            array = [NSMutableArray array];
        }
        [array addObject:record];
        [_tableRec setObject:array forKey:strFormat];
    }
    
    [self sortDate:(NSArray*)set];
    DLog(@"arySet:%@",_arySet);
    __weak RecordViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
       {
           [weakSelf updateBackImage];
       });
}


- (void)didReceiveMemoryWarning {
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
-(void)delRecord:(UIButton*)btn
{
    if (btn.selected)
    {
        //确认删除
        btn.selected = NO;
        NSArray *array = [deletePic allValues];
        for (PictureModel *pic in array) {
            [PhoneDb deleteRecordById:pic.nId];
        }
        NSArray *arrayRecord = [deleteRec allValues];
        [RecordDb deleteRecord:arrayRecord];
        [self initData];
        bDel = NO;
    }
    else
    {
        bDel = YES;
        btn.selected = YES;
    }
}

-(void)initData
{
    [_arySet removeAllObjects];
    [_tablePic removeAllObjects];
    [_tableRec removeAllObjects];
    [self getAllDir];
}
-(void)getAllDir
{
    NSMutableSet *set = [NSMutableSet set];
    NSArray *aryRecord = [RecordDb queryAllRecord];
    for (RecordModel *record in aryRecord)
    {
        NSString *strFormat = ([record.strStartTime componentsSeparatedByString:@" "])[0];
        [set addObject:strFormat];
        NSMutableArray *array = [_tableRec objectForKey:strFormat];
        if (!array)
        {
            array = [NSMutableArray array];
        }
        [array addObject:record];
        [_tableRec setObject:array forKey:strFormat];
    }
    
    [self sortDate:(NSArray*)set];
    DLog(@"sort:%@",_arySet);
    __weak RecordViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
       {
           [weakSelf updateBackImage];
       });
    
}
-(void)getDirByTime:(NSString *)strTime
{
    [_arySet removeAllObjects];
    [_tablePic removeAllObjects];
    [_tableRec removeAllObjects];
    
    NSArray *aryRecord = [RecordDb queryRecordByTime:strTime];
    for (RecordModel *record in aryRecord)
    {
        NSString *strFormat = ([record.strStartTime componentsSeparatedByString:@" "])[0];
        [_arySet addObject:strFormat];
        NSMutableArray *array = [_tableRec objectForKey:strFormat];
        if (!array)
        {
            array = [NSMutableArray array];
        }
        [array addObject:record];
        [_tableRec setObject:array forKey:strFormat];
    }
    
    __weak RecordViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [weakSelf.tableView reloadData];
                   });
}

-(BOOL)isFileExistAtPath:(NSString*)fileFullPath
{
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}

-(void)navBack
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strXCTableViewImagePath = @"XCTableViewImagePathIdentifier";
    ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:strXCTableViewImagePath];
    if (cell==nil)
    {
        cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strXCTableViewImagePath];
    }
    UIView *backView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView = backView;
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    cell.nRow = indexPath.row;
    //先获取日期
    NSString *strTime = [_arySet objectAtIndex:indexPath.section];
    NSArray *aryRecord = [_tableRec objectForKey:strTime];
    [cell setArrayInfo:nil record:aryRecord];
    cell.delegate = self;
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arySet.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!bDel)
    {
        NSString *strTime = [_arySet objectAtIndex:indexPath.section];
        NSArray *aryRecord = [_tableRec objectForKey:strTime];
        RecordPlayViewController *playView = [[RecordPlayViewController alloc] initWithItems:aryRecord];
        [self.parentViewController presentViewController:playView animated:YES completion:nil];
    }
    else
    {
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_arySet objectAtIndex:section];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strTime = [_arySet objectAtIndex:indexPath.section];
    NSArray *aryInfo = [_tablePic objectForKey:strTime];
    NSArray *aryRecord = [_tableRec objectForKey:strTime];
    NSInteger nInfo,nRecord;
    
    nInfo = aryInfo ? aryInfo.count : 0 ;
    nRecord = aryRecord ? aryRecord.count : 0;
    
    
    NSInteger nLength = nInfo+nRecord;
    NSInteger nRow = (nLength%4== 0) ? (nLength/4) : (nLength/4 + 1);
    return 4+nRow * 144;
}

-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated
{
    
}
-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date
{
    NSString *strTime = [NSString stringWithFormat:@"%d-%02d-%02d",[date year],[date month],[date day]];
    UILabel *lblSatart = (UILabel*)[_queryView viewWithTag:1003];
    UILabel *lblEnd = (UILabel*)[_queryView viewWithTag:1004];
    _vrgCalendar.currentMonth = date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    NSDate *startDate = [dateFormat dateFromString:strTime];
    if (nSelect == 1)
    {
        NSDate *dateEnd = [dateFormat dateFromString:lblEnd.text];
        if(dateEnd.timeIntervalSince1970 >= startDate.timeIntervalSince1970)
        {
            lblSatart.text = strTime;
        }
        else
        {
            //开始日期不能大于结束日期
            [self.view makeToast:XCLocalized(@"startOEnd")];
        }
    }
    else if(nSelect == 2)
    {
        
        NSDate *dateStart = [dateFormat dateFromString:lblSatart.text];
        long lStart = dateStart.timeIntervalSince1970;
        long lTemp = startDate.timeIntervalSince1970;
        if(lStart <= lTemp)
        {
            lblEnd.text = strTime;
        }
        else
        {
            //结束日期不能大于开始日期
            [self.view makeToast:XCLocalized(@"endOStart")];
        }
    }
    _vrgCalendar.hidden = YES;
}

#pragma mark 重力处理
- (BOOL)shouldAutorotate
{
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectTitle) name:NS_CUSTOM_BAR_TITLE_VC object:nil];
}

-(void)selectTitle
{
    if (!_vrgCalendar.hidden)
    {
        return;
    }
    _queryView.hidden = _queryView.hidden ? NO : YES;
    if (!_queryView.hidden)
    {
        _tableView.frame = Rect(0, 112, kScreenWidth, kScreenHeight-64-48+HEIGHT_MENU_VIEW(20, 0));
    }
    else
    {
        _tableView.frame = Rect(0, 64, kScreenWidth, kScreenHeight-64+HEIGHT_MENU_VIEW(20, 0));
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)addPicView:(ImageCell*)imgCell view:(UIView*)view index:(NSInteger)nIndex
{

}



-(void)addRecordView:(ImageCell*)imgCell view:(UIView*)view index:(NSInteger)nIndex
{
    RecordModel *recordModel = [RecordDb queryRecordById:nIndex];
    RecordView *rdView = (RecordView *)[view superview];
    if (!bDel)
    {
        RecordPlayViewController *playView = [[RecordPlayViewController alloc] initWithItems:imgCell.arrayRecord];
        [self.parentViewController presentViewController:playView animated:YES completion:nil];
    }
    else
    {
        if(!rdView.imgSelect.hidden)
        {
            [deleteRec removeObjectForKey:[[NSNumber alloc] initWithInteger:nIndex]];
        }
        else
        {
            [deleteRec setObject:recordModel forKey:[[NSNumber alloc] initWithInteger:nIndex]];
        }
        rdView.imgSelect.hidden = rdView.imgSelect.hidden ? NO : YES;
    }
}


-(void)updateBackImage
{
    [_tableView reloadData];
    lblNoImage.hidden = YES;
    imgNo.hidden = YES;
    if (_arySet.count==0)
    {
        lblNoImage.hidden = NO;
        imgNo.hidden = NO;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *myHeader = [[UIView alloc] initWithFrame:Rect(0, 0, kScreenWidth, 30)];
    [myHeader setBackgroundColor:RGB(236, 236, 236)];
    UILabel *myLabel = [[UILabel alloc] init];
    [myLabel setFrame:CGRectMake(10, 0, kScreenWidth, 30)];
    [myLabel setTag:101];
    [myLabel setBackgroundColor:[UIColor clearColor]];
    NSString *strInfo = [NSString stringWithFormat:@"%@",[_arySet  objectAtIndex:section]];
    [myLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    [myLabel setTextColor:RGB(173, 173, 173)];
    [myLabel setText:strInfo];
    
    [myHeader addSubview:myLabel];
    return myHeader;
}
@end
