//
//  DirectCell.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/30.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RtspInfo.h"
@interface DirectCell : UITableViewCell

@property (nonatomic,assign) BOOL bSon;

-(void)setDeviceInfo:(RtspInfo *)devInfo;
-(void)addLine;
@end
