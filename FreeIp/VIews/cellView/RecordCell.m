//
//  RecordCell.m
//  FreeIp
//
//  Created by 夏钟林 on 15/4/7.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "RecordCell.h"
#import "UtilsMacro.h"

@implementation RecordCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
  //  [self initCell];
   [self initCell];
    
    return  self;
}

-(void)setRecordModel:(RecordModel *)record
{
    UIImageView *imgView = ((UIImageView*)[self.contentView viewWithTag:10001]);
    __weak UIImageView *__imgView = imgView;
    
    NSString *strPath = [NSString stringWithFormat:@"%@/record/%@",kLibraryPath,record.imgFile];
    __block NSString *__strFile = strPath;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *img = [UIImage imageWithContentsOfFile:__strFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            [__imgView setImage:img];
        });
    });
   
    NSString *strTime = [record.strStartTime componentsSeparatedByString:@" "][0];
    [((UILabel *)[self.contentView  viewWithTag:10002]) setText:record.strDevName];
    
    [((UILabel *)[self.contentView viewWithTag:10003]) setText:strTime];
    
    [((UILabel*)[self.contentView viewWithTag:10004]) setText:record.strDevNO];
    
}

-(void)layoutSubviews
{
    [self addViewLine:129];
}

-(void)initCell
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:Rect(16,25,120, 90)];
    [self.contentView addSubview:imgView];
    [imgView setTag:10001];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:Rect(156, 20, 168, 17)];
    [lblTitle setFont:XCFONT(17)];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [self.contentView addSubview:lblTitle];
    [lblTitle setTag:10002];
    
    UILabel *lblTime = [[UILabel alloc] initWithFrame:Rect(156, 60, 168, 14)];
    [lblTime setFont:XCFONT(14)];
    [lblTime setTextColor:RGB(158, 158, 158)];
    [self.contentView addSubview:lblTime];
    [lblTime setTag:10003];
    
    UILabel *lblSource = [[UILabel alloc] initWithFrame:Rect(156, 95, 168, 11)];
    [lblSource setTextColor:RGB(158, 158, 158)];
    [lblSource setFont:XCFONT(11)];
    [self.contentView addSubview:lblSource];
    [lblSource setTag:10004];
    
    UIImageView *defaultImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_play"]];
    [defaultImg setCenter:imgView.center];
    [self.contentView addSubview:defaultImg];
}

-(void)addViewLine:(CGFloat)fHight
{
    
    UILabel *sLine3 = [[UILabel alloc] initWithFrame:CGRectMake(16, fHight,300, 0.2)];
    sLine3.backgroundColor = [UIColor colorWithRed:58/255.0
                                             green:58/255.0
                                              blue:58/255.0
                                             alpha:1.0];
    UILabel *sLine4 = [[UILabel alloc] initWithFrame:CGRectMake(16, fHight+0.2, 300 ,0.2)] ;
    sLine4.backgroundColor = [UIColor whiteColor];
    sLine3.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    sLine4.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self.contentView addSubview:sLine3];
    [self.contentView addSubview:sLine4];
}


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
