//
//  UserInfo.h
//  XCMonit_Ip
//
//  Created by 夏钟林 on 14/6/11.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilsMacro.h"
@class UserAllInfoModel;
@interface UserInfo : NSObject

DEFINE_SINGLETON_FOR_HEADER(UserInfo);



@property (nonatomic,assign) BOOL bGuess;
@property (nonatomic,copy) NSString *strUser;
@property (nonatomic,copy) NSString *strPwd;
@property (nonatomic,copy) NSString *strMd5;
@property (nonatomic,copy) NSString *strSessionId;
@property (nonatomic,copy) NSString *strEmail;

@property (nonatomic,strong) UserAllInfoModel *userAllInfo;


@end
