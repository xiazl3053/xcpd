//
//  XCTabPd.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/19.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol XCTabBarDelegate <NSObject>

-(void)clickView:(UIButton*)btnSender index:(int)nIndex;

@end

@interface XCTabPd : UIView

@property (nonatomic,assign) id<XCTabBarDelegate> delegate;

-(id)initWithArrayItem:(NSArray*)item frame:(CGRect)srcFrame;


@end


@interface BtnInfo : NSObject

@property (nonatomic,copy) NSString *strNorImg;
@property (nonatomic,copy) NSString *strSelectImg;
@property (nonatomic,copy) NSString *strHighImg;
@property (nonatomic,copy) NSString *strTitle;

-(id)initWithItem:(NSArray*)item;


@end