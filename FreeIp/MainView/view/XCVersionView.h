//
//  XCVersionView.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/30.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VersionCheckDelegate <NSObject>

-(void)requestVersion;

@end



@interface XCVersionView : UIView


@property (nonatomic,assign) id<VersionCheckDelegate> delegate;


@end
