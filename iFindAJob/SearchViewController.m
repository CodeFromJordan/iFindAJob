//
//  SearchViewController.m
//  SearchView
//
//  Created by Jordan Hancock on 02/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "SearchViewController.h"
#import "JobListingViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize searchBar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup Search Bar for users
    [searchBar setPlaceholder:@"Enter job keyword.."];
    [searchBar setDelegate:self];
    isSearching = NO;
    
    // Setup button
    settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:nil action:nil]; // Create the button
    
    // Create basic Film list for testing display
    locations = [NSMutableArray arrayWithCapacity:100];
    searchResults = [NSMutableArray arrayWithCapacity:100];
    
    // Set up service queue
    serviceQueue = [[NSOperationQueue alloc] init];
    [serviceQueue setMaxConcurrentOperationCount:1];
    
    // Restore saved job list
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*documentsDirectory = [paths objectAtIndex:0];
    NSString *yourArrayFileName = [documentsDirectory stringByAppendingPathComponent:@"locations.xml"];
    locations = [[NSMutableArray alloc] initWithContentsOfFile: yourArrayFileName];
    if(locations == nil) {
        locations = [NSMutableArray arrayWithCapacity:0];
    }
    
    // Sort films
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"job_title" ascending:YES];
    [locations sortUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    
    [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
    
    // Begin appearance --
    [self.navigationController.navigationBar setTintColor:[ExtraMethods getColorFromHexString:@"7D3A0A"]]; // Make navigation bar brown
    [self.navigationController.topViewController.navigationItem setRightBarButtonItem:settingsButton]; // Add settings button
    [[UISearchBar appearance] setTintColor:[ExtraMethods getColorFromHexString:@"6E370F"]]; // Make search bar brown
    // End appearance --
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // Set the state to be searching
    isSearching = YES;
    
    // Clear the search bar
    [searchBar setText:@""];
    
    // Add Cancel/Done button to navigation bar
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(searchDone:)]];
    [[self navigationItem] setLeftBarButtonItem:nil];
    
    // Force Table to reload and withdraw
    [searchResults removeAllObjects];
    [[self tableView] reloadData];
}

- (void)searchDone:(id)sender {
    // Clear search text
    [searchBar setText:@""];
    
    // Hide the Keyboard from the searchBar
    [searchBar resignFirstResponder];
    
    // Remove the Cancel/Done button from navigation bar
    [[self navigationItem] setRightBarButtonItem:nil];
    [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
    
    // Clear Search Results and reset state
    isSearching = NO;
    [searchResults removeAllObjects];
    
    // Force table to reload and redraw
    [[self tableView] reloadData];
}

- (void)serviceFinished:(id)service withError:(BOOL)error forSearchTerm:(NSString*)searchTerm {
    if(!error) {
        [searchResults removeAllObjects];
        
        for (NSDictionary *location in [service results]) {
            // Create dictionary to store multiple values for a film
            NSMutableDictionary *location_info = [[NSMutableDictionary alloc] initWithCapacity:3];
                     
            /*
            // Store given variables
            [j_info setValue:[job valueForKey:@"id"] forKey:@"job_id"];
            [j_info setValue:[[job valueForKey:@"category"] valueForKey:@"name"] forKey:@"job_title"];
            [j_info setValue:[[job valueForKey:@"company"] valueForKey:@"name"] forKey:@"job_company_name"];
            [j_info setValue:[job valueForKey:@"post_date"] forKey:@"job_post_date"];
            [j_info setValue:[[[job valueForKey:@"company"] valueForKey:@"location"] valueForKey:@"city"] forKey:@"job_location"];
             */
            
            NSString* locationToAdd = [[[location valueForKey:@"company"] valueForKey:@"location"] valueForKey:@"city"]; // Add it to the dictionary to be displayed
            
            if([locationToAdd length] == 0)
            {
                locationToAdd = @"No Location Provided";
                [location_info setValue:@"No Location Provided" forKey:@"job_location"];
            }
            else
            {
                [location_info setValue:[[[location valueForKey:@"company"] valueForKey:@"location"] valueForKey:@"city"] forKey:@"job_location"]; // Add it to the dictionary to be displayed
            }
            
            // Add movie info to main list
            if(![[searchResults valueForKey:@"job_location"] containsObject:locationToAdd]) // Only add location to search results array if it doesn't already exist in it
            {
                [searchResults addObject:location_info];
            }
        }
        
        // If there are no results found
        if ([searchResults count] == 0) {
            [searchBar setText:[NSString stringWithFormat:@"No results for '%@'..", searchTerm]];
        }
        else{
            [searchBar setText:[NSString stringWithFormat:@"Jobs in '%@' found in these locations..", searchTerm]];
        }
        
        [[self tableView] reloadData];
    } else {
        [searchResults removeAllObjects];
        [searchBar setText:[NSString stringWithFormat:@"Error for '%@'..", searchTerm]];
        [[self tableView] reloadData];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)sb {
    // Retrieve search term for search bar
    NSString *searchTerm = [searchBar text];
    
    JobSearchService *service = [[JobSearchService alloc] init];
    [service setSearchTerm:searchTerm];
    [service setDelegate:self];
    [serviceQueue addOperation:service];
    
    [searchResults removeAllObjects];
    [searchBar setText:[NSString stringWithFormat:@"Searching for '%@'..", searchTerm]];
    [[self tableView] reloadData];
    
    // Hide the Keyboard from the searchBar
    [searchBar resignFirstResponder];
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
    return isSearching ? [searchResults count] : [locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *location = isSearching ? [searchResults objectAtIndex:[indexPath row]] : [locations objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[location valueForKey:@"job_location"]];
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list
    if (editingStyle == UITableViewCellEditingStyleDelete){
        // Remove from arrays
        NSDictionary *location = [locations objectAtIndex:[indexPath row]];
        
        // Delete thumbnail if present
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png", docDir, [location valueForKey:@"id"]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:pngFilePath]) {
            [fileManager removeItemAtPath:pngFilePath error:nil];
        }
        
        // Remove from list and save changes
        [locations removeObject:location];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *yourArrayFileName = [documentsDirectory stringByAppendingPathComponent:@"locations.xml"];
        [locations writeToFile:yourArrayFileName atomically:YES];
        
        // Triffer remove animation on table
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
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
    if (isSearching) {
        // Use for interaction with search list
        NSDictionary *location = [searchResults objectAtIndex:[indexPath row]];
        
        // Check label for system messages
        if(![[locations valueForKey:@"job_location"] isEqual:@""]) {
            // Add new film to list
            [locations addObject:location];
            
            // Clear search text
            [searchBar setText:@""];
            
            // Remove the Cancel/Done button from navigation bar
            [[self navigationItem] setRightBarButtonItem:nil];
            
            // Clear search results and reset state
            isSearching = NO;
            [searchResults removeAllObjects];
            
            // Force table to reload and redraw
            [[self tableView] reloadData];
            
            // Sort films
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"job_location" ascending:YES];
            [locations sortUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
            
            // Store data
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *yourArrayFileName = [documentsDirectory stringByAppendingPathComponent:@"locations.xml"];
            [locations writeToFile:yourArrayFileName atomically:YES];
        }
    } else {
        // Use for interaction with film list
        NSDictionary *location = [locations objectAtIndex:[indexPath row]];
        
        JobListingViewController *jobListingVC = [[JobListingViewController alloc] initWithNibName:@"JobListingViewController" bundle:nil];
        UINavigationController *jobListingNC = [[UINavigationController alloc] initWithRootViewController:jobListingVC];
        [jobListingVC setTitle:@"Job Results"]; // Navigation bar title
        [jobListingNC setTitle:@"Job Results"]; // Tab bar title
        
        // [jobListingView setLocation:location];
        
        [[self navigationController] pushViewController:jobListingNC animated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    // Save films list once returned to list view
    [super viewWillAppear:animated];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *yourArrayFileName = [documentsDirectory stringByAppendingPathComponent:@"locations.xml"];
    [locations writeToFile:yourArrayFileName atomically:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !isSearching;
}

@end