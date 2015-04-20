//
//  DirectInfoView.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RtspInfo.h"
@interface DirectInfoView : UIView

@property (nonatomic,strong) RtspInfo *rtsp;

-(void)setDevType:(int)nType;

-(BOOL)addDirect;

@end
