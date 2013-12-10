//
//  SavedJobViewController.m
//  iFindAJob
//
//  Created by Jordan Hancock on 10/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "SavedJobViewController.h"

#import "ExtraMethods.h"
#import "JobDetailViewController.h"

#import "Job.h"
#import "AppDelegate.h"

@interface SavedJobViewController ()

@end

@implementation SavedJobViewController

// Used for core data
@synthesize managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize job result array
    savedJobs = [NSMutableArray arrayWithCapacity:100];
    
    // Setup instance of app delegate for core data
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]]; // Put edit button on navigation bar
    
    // Begin appearance --
    [self.navigationController.navigationBar setTintColor:[ExtraMethods getColorFromHexString:@"7D3A0A"]]; // Make navigation bar brown
    [[UISearchBar appearance] setTintColor:[ExtraMethods getColorFromHexString:@"6E370F"]]; // Make search bar brown
    // End appearance --
}

-(void)viewDidAppear:(BOOL)animated
{
    [savedJobs removeAllObjects]; // Clear saved jobs list to stop list doubling when view opened
    [self readAllJobsFromPersistance]; // Restore saved job list from core data
    [[self tableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES]; // Reset table
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [savedJobs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *job = [savedJobs objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[job valueForKey:@"job_title"]];
    
    NSString *job_company_name = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_company_name"]];
    job_company_name = [job_company_name length] > 23 ? [NSString stringWithFormat:@"%@..", [job_company_name substringToIndex:23]] : job_company_name; // More than 26 characters for company name pushes date out of cell, so cut it down
    NSString *job_post_date = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_post_date"]]; // Returns date and time
    job_post_date = [job_post_date substringToIndex:10]; // Cut time from string
    
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"posted by %@ on %@", job_company_name, job_post_date]] ;
    
    // Cell text formatting
    cell.textLabel.textColor = [ExtraMethods getColorFromHexString:@"7D3A0A"];
    cell.detailTextLabel.textColor = [ExtraMethods getColorFromHexString:@"000000"];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list
    if (editingStyle == UITableViewCellEditingStyleDelete){
        // Remove from arrays
        NSDictionary *job = [savedJobs objectAtIndex:[indexPath row]];
        
        // Remove from list and save changes
        [savedJobs removeObject:job];
        
        // Call save to core data method for locations
        [self deleteLocationFromPersistance:[job valueForKey:@"job_id"]];
        
        // Trigger remove animation on table
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}


-(void)deleteLocationFromPersistance:(NSString*)idOfJobToDelete {
    // Core data
    // Setup fetch request and entity objects
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Job" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *deleteQuery = [NSPredicate predicateWithFormat:@"id == %@", idOfJobToDelete]; // Must match location AND keyword
    [fetchRequest setPredicate:deleteQuery]; // Query match predicate
    
    NSError *fetchError; // Save for fetch operation
    NSArray *fetchedJobs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    for (NSManagedObject *job in fetchedJobs) { // Loop through each matched object and delete it
        [managedObjectContext deleteObject:job];
    }
    
    // Save/error handling
    NSError *deleteError;
    if(![managedObjectContext save:&fetchError]) {
        NSLog(@"Failed to delete record: %@", [deleteError localizedDescription]);
    }
}

-(void)readAllJobsFromPersistance { // Reads all jobs from data persistence
    // Core data
    // Setup fetch request and entity objects
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Job" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *fetchError; // Error for fetch operation
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&fetchError]; // Read all location object from core data
    
    for(Job *job in fetchedObjects) { // For each location object in core data
        NSMutableDictionary *jobToAdd = [[NSMutableDictionary alloc] init]; // Dictionary to temporarily store read in items
        
        // Take each read-in value and put them into dictionary
        [jobToAdd setValue:[job valueForKey:@"id"] forKey:@"job_id"];
        [jobToAdd setValue:[job valueForKey:@"title"] forKey:@"job_title"];
        [jobToAdd setValue:[job valueForKey:@"company_name"] forKey:@"job_company_name"];
        [jobToAdd setValue:[job valueForKey:@"city"] forKey:@"job_city"];
        [jobToAdd setValue:[job valueForKey:@"post_date"] forKey:@"job_post_date"];
        [jobToAdd setValue:[job valueForKey:@"relocation_assistance"] forKey:@"job_has_relocation_assistance"];
        [jobToAdd setValue:[job valueForKey:@"requires_commuting"] forKey:@"job_requires_commuting"];
        [jobToAdd setValue:[job valueForKey:@"j_description"] forKey:@"job_description"];
        [jobToAdd setValue:[job valueForKey:@"url"] forKey:@"job_post_url"];
        
        [savedJobs addObject:jobToAdd]; // Add dictionary to locations array
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Use for interaction with film list
    NSDictionary *job = [savedJobs objectAtIndex:[indexPath row]];
    
    JobDetailViewController *jobDetailVC = [[JobDetailViewController alloc] initWithNibName:@"JobDetailViewController" bundle:nil];
    [jobDetailVC setTitle:@"Saved Job"]; // Navigation bar title
    
    [jobDetailVC setJob:job];
    [jobDetailVC setOpenedFromSavedJobs:YES];
    
    [[self navigationController] pushViewController:jobDetailVC animated:YES];
}

@end
