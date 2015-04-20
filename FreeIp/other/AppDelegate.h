//
//  AppDelegate.h
//  FreeIp
//
//  Created by 夏钟林 on 15/3/17.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Reachability;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    Reachability *hostReach;
}
@property (strong, nonatomic) UIWindow *window;


@end

