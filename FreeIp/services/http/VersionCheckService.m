//
//  VersionCheckService.m
//  FreeIp
//
//  Created by xiongchi on 15-4-27.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "VersionCheckService.h"

#import "DecodeJson.h"

#import "UserInfo.h"


@implementation VersionCheckService



-(void)requestVersion
{
    NSString *strUrl = [NSString stringWithFormat:@"%@index.php?r=login/login/AppVersion",XCLocalized(@"httpserver")];
//    NSString *strUrl = [NSString stringWithFormat:@"http://www.freeip.com/index.php?r=login/login/AppVersion"];
    DLog(@"strUrl:%@",strUrl);
    [self sendRequest:strUrl];
}

-(void)reciveHttp:(NSURLResponse *)response data:(NSData *)data error:(NSError *)connectionError
{
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    if (!connectionError && responseCode == 200)
    {
        NSString *strInfo=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        NSString *strDecry = [DecodeJson decryptUseDES:strInfo key:[UserInfo sharedUserInfo].strMd5];
        [self authBlock:strInfo];
    }
    else
    {
        [self authBlock:nil];
        DLog(@"check version fail");
    }
    
}
-(void)authBlock:(NSString *)strVersion
{
    if (_httpBlock)
    {
        _httpBlock(strVersion);
    }
}
@end
