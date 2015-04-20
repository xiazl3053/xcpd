//
//  DeviceCell.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/19.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "DeviceCell.h"
#import "DecodeJson.h"
@implementation DeviceCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    _bSon = YES;
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(14, 21, 62, 50)];
    [self.contentView addSubview:imgView];
    imgView.tag = 10001;
    
    UIImageView *imgStatus = [[UIImageView alloc] initWithFrame:Rect(82, 21,13.5,13.5)];
    [self.contentView addSubview:imgStatus];
    imgStatus.tag = 10002;
    
    UILabel *lblDevName = [[UILabel alloc] initWithFrame:Rect(106,21, 200, 13)];
    [self.contentView addSubview:lblDevName];
    [lblDevName setTextColor:RGB(48, 48,48)];
    [lblDevName setFont:XCFONT(13.0f)];
    lblDevName.tag = 10003;
    
    UILabel *lblType = [[UILabel alloc] initWithFrame:Rect(106, 56, 100,11)];
    [self.contentView addSubview:lblType];
    [lblType setTextColor:RGB(169, 169, 169)];
    [lblType setFont:XCFONT(11.0f)];
    lblType.tag = 10004;
    return self;
}

-(void)addLine
{
    [self addViewLine:self.contentView.frame.size.height-1];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self addViewLine:82];
    
    if (!_bSon) {
        UIView *view = [self.contentView viewWithTag:10089];
        if(view)
        {
            [view removeFromSuperview];
        }
    }
    
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDevName:(NSString *)strDevName
{
    [(UILabel*)[self.contentView viewWithTag:10003] setText:strDevName];
}

-(void)setType:(NSString *)strType
{
    [(UILabel*)[self.contentView viewWithTag:10004] setText:strType];
}

-(void)setDevImg:(NSString *)strImg
{
    [(UIImageView*)[self.contentView viewWithTag:10001] setImage:[UIImage imageNamed:strImg]];
}

-(void)setStatusImg:(NSString *)strImg
{
    [(UIImageView*)[self.contentView viewWithTag:10002] setImage:[UIImage imageNamed:strImg]];
}

-(void)setDeviceInfo:(DeviceInfoModel *)devInfo
{
    [self setDevName:devInfo.strDevName];
    [self setStatusImg:devInfo.iDevOnline ? @"status_ON" : @"status_OFF"];
    NSString *strType = [DecodeJson getDeviceTypeByType:[devInfo.strDevType intValue]];
    NSString *strAllType = [NSString stringWithFormat:@"%@: %@",XCLocalized(@"type"),strType];
    [self setType:strAllType];
    if([strType isEqualToString:@"IPC"])
    {
        [self setDevImg:@"IPC_home"];
    }
    else
    {
        [self setDevImg:@"DVR_home"];
    }
}

-(void)addViewLine:(CGFloat)fHight
{
    UILabel *sLine3 = [[UILabel alloc] initWithFrame:CGRectMake(21, fHight, kScreenWidth, 0.2)];
    sLine3.backgroundColor = [UIColor colorWithRed:198/255.0
                                             green:198/255.0
                                              blue:198/255.0
                                             alpha:1.0];
    UILabel *sLine4 = [[UILabel alloc] initWithFrame:CGRectMake(21, fHight+0.2, kScreenWidth ,0.2)] ;
    sLine4.backgroundColor = [UIColor whiteColor];
    sLine3.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    sLine4.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:sLine3];
    [self.contentView addSubview:sLine4];
}

@end
