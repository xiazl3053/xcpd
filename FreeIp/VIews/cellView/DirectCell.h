//
//  DirectCell.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/30.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RtspInfo.h"

@protocol DirectCellDelegate <NSObject>

-(void)tapEventUpdata:(NSInteger)nRtspRow;

@end


@interface DirectCell : UITableViewCell

@property (nonatomic,assign) id<DirectCellDelegate> delegate;
@property (nonatomic,assign) BOOL bSon;
@property (nonatomic,assign) NSInteger nRow;



-(void)setDeviceInfo:(RtspInfo *)devInfo;
-(void)addLine;
@end
