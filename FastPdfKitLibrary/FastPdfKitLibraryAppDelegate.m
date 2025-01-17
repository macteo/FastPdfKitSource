//
//  FastPdfKitLibraryAppDelegate.m
//  FastPdfKitLibrary
//
//  Created by Nicolò Tosi on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FastPdfKitLibraryAppDelegate.h"
#import "MenuViewController.h"

@interface FastPdfKitLibraryAppDelegate()

@end

@implementation FastPdfKitLibraryAppDelegate


@synthesize window=_window;
@synthesize menuViewController;
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString * bundlePath = [[NSBundle mainBundle]bundlePath];
    
#if DEBUG
    
    __unused NSString * url = @"mobile.de/adadas";
    __unused NSString * url0 = @"mobile.de";
    
#endif
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Simulator application path %@", bundlePath);
    NSLog(@"Simulator home directory %@", NSHomeDirectory());
#endif
    
    NSString * settingsBundlePath = [bundlePath stringByAppendingPathComponent:@"Settings.bundle"];
    NSString * settingsPath = [NSBundle pathForResource:@"Root"
                                                 ofType:@"plist"
                                            inDirectory:settingsBundlePath];
    
    NSDictionary * settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
    [[NSUserDefaults standardUserDefaults] registerDefaults:settingsDictionary];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        MenuViewController * controller = [[MenuViewController alloc]initWithNibName:@"MenuViewController_ipad" bundle:[NSBundle mainBundle]];
        self.menuViewController = controller;
    }
    else
    {
        MenuViewController * controller = [[MenuViewController alloc]initWithNibName:@"MenuViewController_iphone" bundle:[NSBundle mainBundle]];
        self.menuViewController = controller;
    }
    
    UINavigationController * navController = [[UINavigationController alloc]initWithRootViewController:self.menuViewController];
    self.navigationController = navController;
    self.navigationController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navigationController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


@end
