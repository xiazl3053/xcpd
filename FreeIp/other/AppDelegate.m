//
//  AppDelegate.m
//  FreeIp
//
//  Created by 夏钟林 on 15/3/17.
//  Copyright (c) 2015年 xiazl. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#import "XCNotification.h"
#import "LoginViewController.h"
#import "Reachability.h"
#import "Toast+UIView.h"
#import "UtilsMacro.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


//-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    return UIInterfaceOrientationMaskLandscapeRight;
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_window makeKeyAndVisible];
    struct sigaction sa;
    sa.sa_handler = SIG_IGN;
    sigaction(SIGPIPE,&sa,0);
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    
    LoginViewController *loginView = [[LoginViewController alloc] init];
    [_window setRootViewController:loginView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification
                                               object:nil];
    
    hostReach = [Reachability reachabilityWithHostName:@"www.freeip.com"];
    [hostReach startNotifier];
    
    return YES;
}

-(void)setNetwork:(NSString*)strName
{
    __weak UIWindow *window = _window;
//    if (IOS_SYSTEM_8)
//    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [window makeToast:XCLocalized(strName)];
        });
//    }
//    else
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [window makeToast:<#(NSString *)#>];
//        });
//    }
}
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable)
    {
        DLog(@"网络状态:中断");
        [self setNetwork:@"networkstatusNO"];

    }
    else if(status == ReachableViaWiFi)
    {
        DLog(@"网络状态:WIFI");
        [self setNetwork:@"networkstatusWIFI"];
    }
    else
    {
        [self setNetwork:@"networkstatus3G"];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:NS_APPLITION_BECOME_ACTIVE object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
