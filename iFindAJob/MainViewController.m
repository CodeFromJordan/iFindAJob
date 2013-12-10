//
//  MainViewController.m
//  iFindAJob
//
//  Created by Jordan Hancock on 18/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "MainViewController.h"
#import "ExtraMethods.h"
#import <Social/Social.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Setup button
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController.navigationBar setTintColor:[ExtraMethods getColorFromHexString:@"7D3A0A"]]; // Make navigation bar brown
    
    shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share App" style:UIBarButtonItemStylePlain target:self action:@selector(postAppToSocial:)]; // Create the button
    
    [self.navigationController.topViewController.navigationItem setRightBarButtonItem:shareButton]; // Add Twitter and Facebook buttons to left side of screen
}

- (IBAction)postAppToSocial:(UIButton *)sender
{
    NSString *texttoshare = @"Live somewhere on Planet Earth? Looking for a job in I.T.? You should download iFindAJob from Apple's app store!"; //this is your text string to share
    NSArray *activityItems = @[texttoshare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint];
    [self presentViewController:activityVC animated:TRUE completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
