//
//  AppDelegate.m
//  iFindAJob
//
//  Created by Jordan Hancock on 18/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Required core --
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    // Begin custom code --
    // Navigation controllers --
    MainViewController *mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    UINavigationController *mainNC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    [mainNC setTitle:@"Home"];
    [mainNC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"home_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home_unselected.png"]];
    
    
    SearchViewController *searchVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    UINavigationController *searchNC = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [searchNC setTitle:@"Search"];
    [searchNC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"search_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"search_unselected.png"]];
    
    NSArray *allViewControllers = [[NSArray alloc] initWithObjects: mainNC, searchNC, nil];
    
    // Tab controller
    self.tabController = [[UITabBarController alloc] init];
    [self.tabController setViewControllers:allViewControllers animated:YES];
    [[UITabBar appearance] setTintColor:[ExtraMethods getColorFromHexString:@"5E2700"]];
    self.window.rootViewController = self.tabController;
    // End custom code --
    
    // Required code --
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
