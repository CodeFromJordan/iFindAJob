//
//  JobDetailViewController.m
//  iFindAJob
//
//  Created by Jordan Hancock on 03/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "JobDetailViewController.h"
#import <Social/Social.h>

@interface JobDetailViewController ()

@end

@implementation JobDetailViewController

@synthesize txtJobTitle;
@synthesize txtJobCompany;
@synthesize txtJobPostDate;
@synthesize swtRelocation;
@synthesize swtCommuting;
@synthesize txtJobDescription;
@synthesize btnOpenBrowser;

@synthesize job;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Setup navigation bar
    // Setup button
    shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share Job" style:UIBarButtonItemStylePlain target:self action:@selector(postJobToSocial:)]; // Create the button
    
    [self.navigationController.topViewController.navigationItem setRightBarButtonItem:shareButton]; // Add share button to left side of screen
    
    // Setup text boxes
    [txtJobTitle setText:[job valueForKey:@"job_title"]];
    [txtJobCompany setText:[NSString stringWithFormat:@"For Company: %@", [job valueForKey:@"job_company_name"]]];
    [txtJobPostDate setText:[NSString stringWithFormat:@"Post Date: %@", [job valueForKey:@"job_post_date"]]];
    [txtJobDescription setText:[self stripHTMLFromString:[job valueForKey:@"job_description"]]];
    
    // Setup switches
    // Relocation assistance
    if([[job valueForKey:@"job_has_relocation_assistance"] isEqual:@"1"])
    {
        [swtRelocation setOn:YES];
    }
    else
    {
        [swtRelocation setOn:NO];
    }
    
    // Commuting
    if([[job valueForKey:@"job_requires_telecommuting"] isEqual:@"1"])
    {
        [swtCommuting setOn:YES];
    }
    else
    {
        [swtCommuting setOn:NO];
    }
    
    // Setup web opening button
    [btnOpenBrowser addTarget:self action:@selector(openURLInSafari:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)openURLInSafari:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[job valueForKey:@"job_post_url"]]];
}

- (IBAction)postJobToSocial:(UIButton *)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"iFindAJob iOS: Want to be an '%@'? Check out: %@", [job valueForKey:@"job_title"], [job valueForKey:@"job_post_url"]]];
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

-(NSString *) stripHTMLFromString:(NSString*)string { // Remove HTML from string
    NSRange r;
    while ((r = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        string = [string stringByReplacingCharactersInRange:r withString:@""];
    return string;
}

@end
