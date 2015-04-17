//
//  LoginUserDB.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/18.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "LoginUserDB.h"
#import "UserModel.h"
#import "UtilsMacro.h"
#import "FMResultSet.h"
#import "FMDatabase.h"
#define kDataLoginPath [kDocumentPath stringByAppendingPathComponent:@"xc.db"]
@implementation LoginUserDB
+(FMDatabase *)initDatabaseUser
{
    FMDatabase *db= [FMDatabase databaseWithPath:kDataLoginPath];
    if(![db open])
    {
        DLog(@"open fail");
    }
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS userInfo (id integer primary key asc autoincrement, username text unique, pwd text)"];
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS UserSave (id integer primary key,username text,save integer,login integer)"];
    return db;
}
+(BOOL)addLoginUser:(UserModel *)userModel
{
    //INSERT OR ignore
    NSString *strSql = @"insert or replace into userInfo (username,pwd) values (?,?)";
    FMDatabase *db = [LoginUserDB initDatabaseUser];
    
    [db beginTransaction];
    BOOL bReturn = [db executeUpdate:strSql,userModel.strUser,userModel.strPwd];
    [db commit];
    [db close];
    return bReturn ;
}

+(BOOL)updateSaveInfo:(NSString*)strUsername save:(int)nSave login:(int)nLogin
{
    NSString *strSql = @"insert or replace into UserSave (id,username,save,login) values (1,?,?,?);";
    FMDatabase *db = [LoginUserDB initDatabaseUser];
    [db beginTransaction];
    BOOL bRetrun = [db executeUpdate:strSql,strUsername,[NSNumber numberWithInt:nSave],[NSNumber numberWithInt:nLogin]];
    [db commit];
    [db close];
    return bRetrun;
}

+(NSString*)querySaveInfo:(int *)nSave login:(int *)nLogin
{
    NSString *strSql = @"select * from UserSave";
    FMDatabase *db = [LoginUserDB initDatabaseUser];
    FMResultSet *rs = [db executeQuery:strSql];
    if(rs.next)
    {
        *nSave = [[rs stringForColumn:@"save"] intValue];
        *nLogin = [[rs stringForColumn:@"login"] intValue];
        NSString *strUserName = [[NSString alloc] initWithString:[rs stringForColumn:@"username"]];
        [rs close];
        [db close];
        return strUserName;
    }
    return nil;
}

+(NSString*)queryUserPwd:(NSString *)strUser
{
    NSString *strSql = @"select * from userInfo where username = ?";
    FMDatabase *db = [LoginUserDB initDatabaseUser];
    FMResultSet *rs = [db executeQuery:strSql,strUser];
    if (rs.next) {
        NSString *strPwd = [NSString stringWithString:[rs stringForColumn:@"pwd"]];
        return strPwd;
    }
    
    
    return nil;
}

@end
