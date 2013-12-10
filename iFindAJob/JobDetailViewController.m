//
//  JobDetailViewController.m
//  iFindAJob
//
//  Created by Jordan Hancock on 03/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "JobDetailViewController.h"
#import "ExtraMethods.h"
#import <Social/Social.h>

#import "Job.h"
#import "AppDelegate.h"

#import <QuartzCore/QuartzCore.h> 

@interface JobDetailViewController ()

@end

@implementation JobDetailViewController

@synthesize txtJobTitle;
@synthesize txtJobCompany;
@synthesize txtJobPostDate;
@synthesize txtRelocationSwitch;
@synthesize txtCommutingSwitch;
@synthesize txtJobDescription;
@synthesize btnOpenBrowser;
@synthesize btnSaveJob;

@synthesize job;
@synthesize openedFromSavedJobs;

// Used for core data
@synthesize managedObjectContext;

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
    
    // Setup instance of app delegate for core data
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // Setup navigation bar
    // Setup buttons
    UIImage *twitterImage = [UIImage imageNamed:@"twitter.png"];
    UIImage *facebookImage = [UIImage imageNamed:@"facebook.png"];
    twitterButton = [[UIBarButtonItem alloc] initWithImage:twitterImage style:UIBarButtonItemStylePlain target:self action:@selector(postJobToTwitter:)]; // Create the button
    facebookButton = [[UIBarButtonItem alloc] initWithImage:facebookImage style:UIBarButtonItemStylePlain target:self action:@selector(postJobToFacebook:)]; // Create the button
    
    NSArray *buttonArray = [[NSArray alloc] initWithObjects:twitterButton, facebookButton, nil];
    
    [self.navigationController.topViewController.navigationItem setRightBarButtonItems:buttonArray]; // Add Twitter and Facebook buttons to left side of screen
    
    // Description box formatting
    [txtJobDescription setOpaque:NO]; // Make background color show
    [txtJobDescription setBackgroundColor:[ExtraMethods getColorFromHexString:@"F0F0F0"]]; // Set the background color to light grey
    [[txtJobDescription layer] setBorderColor:[[UIColor brownColor] CGColor]]; // Set border to grey
    [[txtJobDescription layer] setBorderWidth:1]; // Border 1px width
    
    // Setup text boxes
    [txtJobTitle setText:[job valueForKey:@"job_title"]];
    [txtJobCompany setText:[NSString stringWithFormat:@"for %@", [job valueForKey:@"job_company_name"]]];
    [txtJobPostDate setText:[NSString stringWithFormat:@"Posted: %@", [job valueForKey:@"job_post_date"]]];
    [txtJobDescription loadHTMLString:[job valueForKey:@"job_description"] baseURL:nil];
    
    // Setup switches
    // Relocation assistance
    if([[job valueForKey:@"job_has_relocation_assistance"] isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        [txtRelocationSwitch setText:@"YES"];
        [txtRelocationSwitch setTextColor:[ExtraMethods getColorFromHexString:@"00FF00"]];
    }
    else
    {
        [txtRelocationSwitch setText:@"NO"];
        [txtRelocationSwitch setTextColor:[ExtraMethods getColorFromHexString:@"FF0000"]];
    }
    
    // Commuting
    if([[job valueForKey:@"job_requires_telecommuting"] isEqualToNumber:[NSNumber numberWithInt:1]])
    {
        [txtCommutingSwitch setText:@"YES"];
        [txtCommutingSwitch setTextColor:[ExtraMethods getColorFromHexString:@"00FF00"]];
    }
    else
    {
        [txtCommutingSwitch setText:@"NO"];
        [txtCommutingSwitch setTextColor:[ExtraMethods getColorFromHexString:@"FF0000"]];
    }
    
    // Setup web opening button
    [btnOpenBrowser addTarget:self action:@selector(openURLInSafari:) forControlEvents:UIControlEventTouchUpInside];
    [btnOpenBrowser setTitleColor:[ExtraMethods getColorFromHexString:@"7D3A0A"] forState:UIControlStateNormal];
    
    // Setup save button
    [btnSaveJob addTarget:self action:@selector(saveJobToPersistance:) forControlEvents:UIControlEventTouchUpInside];
    [btnSaveJob setTitleColor:[ExtraMethods getColorFromHexString:@"7D3A0A"] forState:UIControlStateNormal];
    
    if(openedFromSavedJobs) // If the job was opened from the saved jobs list
    {
        [btnSaveJob setHidden:YES]; // Don't let user click save because job is already saved
    }
}

- (IBAction)openURLInSafari:(UIButton *)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[job valueForKey:@"job_post_url"]]];
}

-(IBAction)saveJobToPersistance:(UIButton *)sender { // Save job details into data persistence
    // Core data
    if(![self isJobInDatabase:[job valueForKey:@"job_id"]])
    {
        // Create managed object
        Job *jobToSave = [NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:managedObjectContext];
        
        // Read values from job dictionary
        [jobToSave setValue:[job valueForKey:@"job_id"] forKey:@"id"];
        [jobToSave setValue:[job valueForKey:@"job_title"] forKey:@"title"];
        [jobToSave setValue:[job valueForKey:@"job_company_name"] forKey:@"company_name"];
        [jobToSave setValue:[job valueForKey:@"job_post_date"] forKey:@"post_date"];
        [jobToSave setValue:[job valueForKey:@"job_has_relocation_assistance"] forKey:@"relocation_assistance"];
        [jobToSave setValue:[job valueForKey:@"job_requires_telecommuting"] forKey:@"requires_commuting"];
        [jobToSave setValue:[job valueForKey:@"job_description"] forKey:@"j_description"];
        [jobToSave setValue:[job valueForKey:@"job_post_url"] forKey:@"url"];
    
        // Save/error handling
        NSError *saveError; // Error for save operation
        if(![managedObjectContext save:&saveError]) {
            NSLog(@"Failed to save record: %@", [saveError localizedDescription]);
    }
    }
}

-(bool)isJobInDatabase:(NSString *)idOfJobToCheckExists { // Checks if a job exists in database
    // Core data
    // Setup fetch request and entity objects
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Job" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *getJobQuery = [NSPredicate predicateWithFormat:@"id == %@", idOfJobToCheckExists]; // Must match location AND keyword
    [fetchRequest setPredicate:getJobQuery]; // Query match predicate
    
    NSError *fetchError; // Save for fetch operation
    NSArray *fetchedJobs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if([fetchedJobs count] == 1) // If the number of jobs in the database that match query = 1
    {
        return YES; // Job exists
    }
    else // Else
    {
        return NO; // Job doesn't exist
    }
}

- (IBAction)postJobToTwitter:(UIButton *)sender
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

- (IBAction)postJobToFacebook:(UIButton *)sender
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:[NSString stringWithFormat:@"iFindAJob iOS: Want to be an '%@'? Check out: %@", [job valueForKey:@"job_title"], [job valueForKey:@"job_post_url"]]];
        [self presentViewController:controller animated:YES completion:Nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to Post to Facebook" message:@"Unable to post to Facebook right now. Please ensure that you have an internet connection and that the device has a Facebook account registered." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
