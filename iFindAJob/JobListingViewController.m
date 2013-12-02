//
//  JobListingViewController.m
//  iFindAJob
//
//  Created by Jordan Hancock on 02/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "JobListingViewController.h"
#import "JobSearchService.h"

@interface JobListingViewController ()

@end

@implementation JobListingViewController

@synthesize location;

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
    
    // Create job and search result array
    jobs = [NSMutableArray arrayWithCapacity:100];
    searchResults = [NSMutableArray arrayWithCapacity:100];
    
    // Set up service queue
    serviceQueue = [[NSOperationQueue alloc] init];
    [serviceQueue setMaxConcurrentOperationCount:1];
    
    // Perform search
    JobSearchService *service = [[JobSearchService alloc] init];
    [service setSearchTerm:[location valueForKey:@"job_location_id"]];
    NSString *test = [service searchTerm];
    [service setDelegate:self];
    [serviceQueue addOperation:service];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)serviceFinished:(id)service withError:(BOOL)error forSearchTerm:(NSString*)searchTerm {
    if(!error) {
        [searchResults removeAllObjects];
        
        for (NSDictionary *job in [service results]) {
            // Create dictionary to store multiple values for a film
            NSMutableDictionary *job_info = [[NSMutableDictionary alloc] initWithCapacity:3];
            
            NSString* idOfJobToAdd = [job valueForKey:@"id"]; // Used to check if already exists
            
            if(![idOfJobToAdd length] == 0) // If job result has a location
            {
                [job_info setValue:[job valueForKey:@"id"] forKey:@"job_id"];
                [job_info setValue:[[job valueForKey:@"category"] valueForKey:@"name"] forKey:@"job_title"];
                [job_info setValue:[[job valueForKey:@"company"] valueForKey:@"name"] forKey:@"job_company_name"];
                [job_info setValue:[job valueForKey:@"post_date"] forKey:@"job_post_date"];
                
                // Add movie info to main list
                if(![[searchResults valueForKey:@"job_id"] containsObject:idOfJobToAdd]) // Only add location to search results array if it doesn't already exist in it
                {
                    [searchResults addObject:job_info];
                }
            }
        }
        
        [[self tableView] reloadData];
    } else { // Serious error, show error message
        [searchResults removeAllObjects];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a serious error." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        [[self tableView] reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [jobs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *job = [jobs objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[job valueForKey:@"job_title"]];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"Posted by %@ on %@", [job valueForKey:@"job_job_company_name"], [job valueForKey:@"post_date"]]] ;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
