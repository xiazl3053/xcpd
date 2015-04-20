//
//  XCUserInfoView.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/31.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XCUserInfoViewDelegate <NSObject>

-(void)userView:(int)nType;

@end


@interface XCUserInfoView : UIView

@property (nonatomic,assign) id<XCUserInfoViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame;

-(void)setNickName:(NSString *)strNick;

-(void)setImgView:(NSString *)strImg;

-(void)setImageInfo:(UIImage *)image;


@end
