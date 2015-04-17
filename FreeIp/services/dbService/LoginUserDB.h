//
//  LoginUserDB.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/18.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserModel;
@interface LoginUserDB : NSObject


+(BOOL)addLoginUser:(UserModel*)userModel;

+(NSString*)querySaveInfo:(int *)nSave login:(int *)nLogin;
+(NSString*)queryUserPwd:(NSString *)strUser;
+(BOOL)updateSaveInfo:(NSString*)strUsername save:(int)nSave login:(int)nLogin;
@end
