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
{
    BOOL bStatus;
    BOOL bGGLogin;
}

@property (nonatomic,unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic,strong) NSTimer *myTimer;

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
    dispatch_async(dispatch_get_main_queue(), ^{
        [window makeToast:XCLocalized(strName)];
    });
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


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    [[NSNotificationCenter defaultCenter] postNotificationName:NS_APPLITION_ENTER_BACK object:nil];
}


-(void)setEndBackground
{
    if (bStatus)
    {
        DLog(@"等待时间不够");
        return ;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NS_APPLITION_ENTER_BACK object:nil];
    
    
   
    bGGLogin = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    bStatus = NO;
    self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^(void)
    {
         [self endBackgroundTask];
    }];
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                target:self
                                              selector:@selector(timerMethod:)
                                              userInfo:nil
                                               repeats:YES];
    [self performSelector:@selector(setEndBackground) withObject:nil afterDelay:30.0f];
}

-(void)timerMethod:(NSTimer *)paramSender
{
    NSTimeInterval backgroundTimeRemaining =[[UIApplication sharedApplication] backgroundTimeRemaining];
    if (backgroundTimeRemaining == DBL_MAX)
    {
        DLog(@"Background Time Remaining = Undetermined");
    }
    else
    {
        DLog(@"Background Time Remaining = %.02f Seconds", backgroundTimeRemaining);
        if (backgroundTimeRemaining<110) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    }
}

-(void)endBackgroundTask
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    AppDelegate *weakSelf = self;
    dispatch_async(mainQueue, ^(void) {
        AppDelegate *strongSelf = weakSelf;
        if (strongSelf != nil){
            [strongSelf.myTimer invalidate];// 停止定时器
            // 每个对 beginBackgroundTaskWithExpirationHandler:方法的调用,必须要相应的调用 endBackgroundTask:方法。这样，来告诉应用程序你已经执行完成了。
            // 也就是说,我们向 iOS 要更多时间来完成一个任务,那么我们必须告诉 iOS 你什么时候能完成那个任务。
            // 也就是要告诉应用程序：“好借好还”嘛。
            // 标记指定的后台任务完成
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            // 销毁后台任务标识符
            strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    });
}
-(void)applicationWillEnterForeground:(UIApplication *)application
{
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    DLog(@"返回");
//    [self cancelPreviousPerformRequestsWithTarget:self];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NS_APPLITION_BECOME_ACTIVE object:nil];
    bStatus = YES;
    [self.myTimer invalidate];
    if (bGGLogin)
    {
         //发送重新登录请求
        [[NSNotificationCenter defaultCenter] postNotificationName:NS_APPLITION_BECOME_ACTIVE object:nil];
    }
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

@end
