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
#import "ExtraMethods.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tabController;

@end
