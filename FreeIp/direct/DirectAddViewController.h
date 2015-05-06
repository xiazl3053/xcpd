//
//  DirectAddViewController.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RtspInfo.h"
@interface DirectAddViewController : UIViewController

@property (nonatomic,assign) BOOL bType;
@property (nonatomic,strong) RtspInfo *rtsp;


-(id)initWithType:(BOOL)bType;



@end
