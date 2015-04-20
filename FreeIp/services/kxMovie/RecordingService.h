//
//  RecordingService.h
//  FreeIp
//
//  Created by 夏钟林 on 15/4/2.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordModel.h"
@interface RecordingService : NSObject



+(BOOL)startRecordInfo:(RecordModel*)record;

+(BOOL)stopRecordInfo:(RecordModel *)record;

@end
