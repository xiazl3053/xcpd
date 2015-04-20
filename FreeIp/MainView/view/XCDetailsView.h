//
//  XCDetailsView.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/31.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XCDetailsDelegate <NSObject>

-(void)updDetail:(int)nType;

@end


@interface XCDetailsView :  UIView

@property (nonatomic,assign ) id<XCDetailsDelegate> delegate;

-(void)setRealName:(NSString *)strName;


-(void)setEmail:(NSString *)strEmail;


@end
