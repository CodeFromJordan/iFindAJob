//
//  AppDelegate.h
//  iFindAJob
//
//  Created by Jordan Hancock on 18/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "SearchViewController.h"
#import "SavedJobViewController.h"
#import "ExtraMethods.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

// My objects
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tabController;

// Core data objects
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
