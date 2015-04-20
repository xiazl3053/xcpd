//
//  DevInfoView.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/20.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DeviceInfoModel;


@protocol DevNameUpdDelegate <NSObject>

-(void)showUpdView;

@end

@interface DevInfoView : UIView

@property (nonatomic,assign) id<DevNameUpdDelegate> delegate;

-(void)setDeviceInfo:(DeviceInfoModel*)devInfo;

@end




@interface XCDevLabel : UILabel


@end


@interface XCInfoLabel : UILabel

@end