//
//  RecordingService.m
//  FreeIp
//
//  Created by 夏钟林 on 15/4/2.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "RecordingService.h"
#import "RecordModel.h"
#import "UtilsMacro.h"
#import "RecordDb.h"

@implementation RecordingService

+(BOOL)startRecordInfo:(RecordModel *)record
{
    if (!record) {
        return NO;
    }
    NSDate *senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH-mm-ss"];
    NSString *  morelocationString=[dateformatter stringFromDate:senddate];
    NSDateFormatter  *fileformatter=[[NSDateFormatter alloc] init];
    [fileformatter setDateFormat:@"YYYYMMddHHmmss"];
    NSString *filePath = [NSString stringWithFormat:@"%@.mp4",[fileformatter stringFromDate:senddate]];
    
    NSString *strDir = [kLibraryPath  stringByAppendingPathComponent:@"record"];
    BOOL bFlag = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:strDir isDirectory:&bFlag])
    {
        DLog(@"目录不存在");
        [[NSFileManager defaultManager] createDirectoryAtPath:strDir withIntermediateDirectories:NO attributes:nil error:nil];
        BOOL success = [[NSURL fileURLWithPath:strDir] setResourceValue: [NSNumber numberWithBool: YES]
                                                                 forKey: NSURLIsExcludedFromBackupKey error:nil];
        if(!success)
        {
            DLog(@"Error excluding不备份文件夹");
        }
    }
    //视频文件保存路径
    NSString *strFile  = [strDir stringByAppendingPathComponent:filePath];
    //开始时间与文件名
    
    record.strStartTime = [NSString stringWithFormat:@"%@",morelocationString];
    record.strFile = [NSString stringWithFormat:@"%@",filePath];
    
    if ([[NSFileManager defaultManager] createFileAtPath:strFile contents:nil attributes:nil])
    {
        DLog(@"创建文件成功:%@",strFile);
    }
    record.strAbltFile = strFile;
    
    return YES;
}


+(BOOL)stopRecordInfo:(RecordModel *)record
{
    if (!record)
    {
        return NO;
    }
    BOOL success = [[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/record/%@",kLibraryPath,record.strFile]] setResourceValue: [NSNumber numberWithBool: YES]
                                                              forKey: NSURLIsExcludedFromBackupKey error:nil];
    if(!success)
    {
        DLog(@"Error excluding文件");
    }
    NSDate *senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH-mm-ss"];
    NSString *  morelocationString=[dateformatter stringFromDate:senddate];
    
    record.strEndTime = [NSString stringWithFormat:@"%@",morelocationString];
    record.allTime = 0;
    
   [RecordDb insertRecord:record];
    
    return YES;
}




@end
