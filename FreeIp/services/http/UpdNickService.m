//
//  UpdNickService.m
//  XCMonit_Ip
//
//  Created by 夏钟林 on 14/10/11.
//  Copyright (c) 2014年 夏钟林. All rights reserved.
//

#import "UpdNickService.h"
#import "UserInfo.h"
#import "DecodeJson.h"
@implementation UpdNickService

-(void)requestUpdNick:(NSString*)strReal
{
    NSString *strUrl = [[NSString alloc] initWithFormat:@"%@index.php?r=service/service/setnickname&session_id=%@&nickname=%@"
                        ,XCLocalized(@"httpserver"),[UserInfo sharedUserInfo].strSessionId,[strReal stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self sendRequest:strUrl];
}

-(void)reciveHttp:(NSURLResponse *)response data:(NSData *)data error:(NSError *)connectionError
{
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    
    if (!connectionError && responseCode == 200)
    {
        NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //解密后的字符串
        NSString *strDecry = [DecodeJson decryptUseDES:str key:[UserInfo sharedUserInfo].strMd5];
        NSData *jsonData = [strDecry dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData)
        {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
            if (dic && dic.count>0)
            {
                NSArray *array = [dic objectForKey:@"data"];
                if (_httpBlock)
                {
                    _httpBlock([array[0] intValue]);
                }
            }
            else
            {
                if (_httpBlock)
                {
                    _httpBlock(999);
                }
                DLog(@"登录失败，通信指令错误");
            }
        }else{
            if (_httpBlock)
            {
                _httpBlock(999);
            }
        }
    }
    else
    {
        if (_httpBlock)
        {
            _httpBlock((int)responseCode);
        }
        DLog(@"responseCode:%li",(long)responseCode);
    }
}


@end
