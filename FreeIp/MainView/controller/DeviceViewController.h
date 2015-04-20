//
//  DeviceViewController.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/19.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  DeviceInfoModel;
@interface DeviceViewController : UIViewController

-(void)setFirstDevInfo:(DeviceInfoModel*)devInfo;

-(void)setFrame:(CGRect)frame;

-(id)initWithFrame:(CGRect)frame;

-(void)setDeviceInfo:(DeviceInfoModel*)devInfo;

@end
