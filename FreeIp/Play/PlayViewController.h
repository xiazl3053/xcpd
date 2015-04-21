//
//  PlayViewController.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/23.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLDecoderServiceImpl.h"
#import "RecordModel.h"

@interface PlayViewController : UIViewController

@property (nonatomic,assign) CGRect frame;
@property (nonatomic,assign) BOOL bPlaying;//标志位
@property (nonatomic,strong) XLDecoderServiceImpl *decodeImp;//解码器
@property (nonatomic,strong) NSMutableArray *videoFrames;
@property (nonatomic,strong) UIImageView *imgView;
@property (nonatomic,assign) BOOL bDecoding;
@property (nonatomic,strong) NSString *strDevName;
@property (nonatomic,copy) NSString *strNO;
@property (nonatomic,assign) int nChannel;
@property (nonatomic,copy) NSString *strKey;
@property (nonatomic,assign) BOOL bRecording;
@property (nonatomic,assign) int nCodeType;

-(void)startPlay;

-(BOOL)stopPlay;

-(id)initWithPath:(NSString *)strPath name:(NSString *)strDevName;

-(id)initWithNO:(NSString *)strNO name:(NSString *)strDevName channel:(int)nChannel code:(int)nCode;

-(id)initWithRecordInfo:(RecordModel *)record;

-(BOOL)captureView;

-(BOOL)switchCode:(int)nCode;

-(BOOL)recordStart;

-(BOOL)recordStop;
-(void)setImgFrame:(CGRect)frame;
@end
