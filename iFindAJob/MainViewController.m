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
    
    // Setup button
    shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share App" style:UIBarButtonItemStylePlain target:self action:@selector(postAppToSocial:)]; // Create the button
    
    [self.navigationController.topViewController.navigationItem setRightBarButtonItem:shareButton]; // Add share button to left side of screen
}

- (IBAction)postAppToSocial:(UIButton *)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Live somewhere on Planet Earth? Looking for a job in I.T.? You should download iFindAJob from Apple's app store!"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to Tweet" message:@"Unable to post Tweet right now. Please ensure that you have an internet connection and that the device has a Twitter account registered." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
