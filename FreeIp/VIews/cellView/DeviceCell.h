//
//  DeviceCell.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/19.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceInfoModel.h"
@interface DeviceCell : UITableViewCell

@property (nonatomic,assign) BOOL bSon;

-(void)setType:(NSString*)strType;
-(void)setDevImg:(NSString*)strImg;
-(void)setStatusImg:(NSString*)strImg;
-(void)setDevName:(NSString*)strDevName;

-(void)setDeviceInfo:(DeviceInfoModel*)devInfo;

-(void)addLine;

@end
