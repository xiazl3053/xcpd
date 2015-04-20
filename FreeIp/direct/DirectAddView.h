//
//  DirectAddView.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RtspInfo.h"
@protocol DirectAddDelegate <NSObject>

-(BOOL)addDirectView:(RtspInfo*)rtsp;

-(void)closeDirectView;

@end

@interface DirectAddView : UIView

@property (nonatomic,assign) id<DirectAddDelegate>  delegate;


@end
