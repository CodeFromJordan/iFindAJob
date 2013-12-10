//
//  AppDelegate.m
//  iFindAJob
//
//  Created by Jordan Hancock on 18/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

// Core data property synthesis

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Required core --
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    // Begin custom code --
    // Navigation controllers --
    
    // Main
    MainViewController *mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    UINavigationController *mainNC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    [mainVC setTitle:@"Home"]; // Navigation bar title
    [mainNC setTitle:@"Home"]; // Tab bar title
    [mainNC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"home_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"home_unselected.png"]];
    
    // Search
    SearchViewController *searchVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    UINavigationController *searchNC = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [searchVC setTitle:@"Jobs In.."]; // Navigation bar title
    [searchNC setTitle:@"Find Jobs"]; // Tab bar title
    [searchNC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"search_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"search_unselected.png"]];
    
    // Saved
    SavedJobViewController *savedjobVC = [[SavedJobViewController alloc] initWithNibName:@"SavedJobViewController" bundle:nil];
    UINavigationController *savedjobNC = [[UINavigationController alloc] initWithRootViewController:savedjobVC];
    [savedjobVC setTitle:@"Saved Jobs"]; // Navigation bar title
    [savedjobNC setTitle:@"Saved Jobs"]; // Tab bar title
    [savedjobNC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"shortlist_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"shortlist_unselected.png"]];
    
    NSArray *allViewControllers = [[NSArray alloc] initWithObjects: mainNC, searchNC, savedjobNC, nil];
    
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

// Core data methods
- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"iFindAJob.sqlite"]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end
