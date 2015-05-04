//
//  VersionCheckService.h
//  FreeIp
//
//  Created by xiongchi on 15-4-27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "HttpManager.h"

typedef void(^HttpVersionCheck)(NSString *strVersion);


@interface VersionCheckService : HttpManager

@property (nonatomic,copy) HttpVersionCheck httpBlock;


-(void)requestVersion;
@end
