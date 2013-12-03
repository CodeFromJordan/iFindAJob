//
//  SearchViewController.m
//  SearchView
//
//  Created by Jordan Hancock on 02/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "SearchViewController.h"
#import "JobListingViewController.h"
#import "ExtraMethods.h"

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
    
    // Create location and search result array
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
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"job_count" ascending:YES];
    [locations sortUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    
    [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
    
    // Begin appearance --
    [self.navigationController.navigationBar setTintColor:[ExtraMethods getColorFromHexString:@"7D3A0A"]]; // Make navigation bar brown
    [[UISearchBar appearance] setTintColor:[ExtraMethods getColorFromHexString:@"6E370F"]]; // Make search bar brown
    // End appearance --
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // Set the state to be searching
    isSearching = YES;
    
    // Clear the search bar
    [self.searchBar setText:@""];
    
    // Add Cancel/Done button to navigation bar
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(searchDone:)]];
    [[self navigationItem] setLeftBarButtonItem:nil];
    
    // Force Table to reload and redraw
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
            
            NSString* idOfLocationToAdd = [location valueForKey:@"id"]; // Used to check if already exists
            
            // Add items to dictionary
            if(![idOfLocationToAdd length] == 0) // If job result has a location
            {
                // Only used for table view
                [location_info setValue:[location valueForKey:@"id"] forKey:@"job_location_id"];
                [location_info setValue:[location valueForKey:@"name"] forKey:@"job_location"];
                [location_info setValue:[location valueForKey:@"count"] forKey:@"job_count"];
                [location_info setValue:searchTerm forKey:@"job_keyword"];
                
                // Add movie info to main list
                // Search result location cannot be duplicate in searchResults OR locations, it also must actually have a ity
                if(![[searchResults valueForKey:@"job_location_id"] containsObject:idOfLocationToAdd] && ![[location valueForKey:@"name"] isEqual:nil] && ![[locations valueForKey:@"job_location_id"] containsObject:idOfLocationToAdd]) // Only add location to search results array if it doesn't already exist in it
                {
                    [searchResults addObject:location_info];
                }
            }
        }
        
        // If there are no results found
        if ([searchResults count] == 0) {
            [searchBar setText:[NSString stringWithFormat:@"No results for '%@'..", searchTerm]];
        }
        else{
            [searchBar setText:[NSString stringWithFormat:@"'%@' jobs found in these locations..", searchTerm]];
        }
        
        [[self tableView] reloadData];
    } else { // Serious error, show error message
        [searchResults removeAllObjects];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a serious error." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        [[self tableView] reloadData];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)sb {
    // Retrieve search term for search bar
    NSString *searchTerm = [searchBar text];
    
    LocationSearchService *service = [[LocationSearchService alloc] init];
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
    NSNumber *jobCount = [location valueForKey:@"job_count"];
    NSString *jobString = ([jobCount integerValue] > 1) ? @"jobs" : @"job";
    [[cell textLabel] setText:[location valueForKey:@"job_location"]];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@ reported %@", [location valueForKey:@"job_count"], jobString]];
    cell.textLabel.textColor = [ExtraMethods getColorFromHexString:@"7D3A0A"];
    cell.detailTextLabel.textColor = [ExtraMethods getColorFromHexString:@"000000"];
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list
    if (editingStyle == UITableViewCellEditingStyleDelete){
        // Remove from arrays
        NSDictionary *location = [locations objectAtIndex:[indexPath row]];
        
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
        if(![[locations valueForKey:@"job_location"] isEqual:@"N/A"]) {
            // Add new film to list
            [locations addObject:location];
            
            // Clear search text
            [searchBar setText:@""];
            
            // Remove the Cancel/Done button from navigation bar
            [[self navigationItem] setRightBarButtonItem:nil];
            
            // Clear search results and reset state
            isSearching = NO;
            [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
            [searchResults removeAllObjects];
            
            // Force table to reload and redraw
            [[self tableView] reloadData];
            
            // Sort films
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"job_count" ascending:YES];
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
        [jobListingVC setTitle:@"Job Results"]; // Navigation bar title
        
        [jobListingVC setLocation:location];
        
        [[self navigationController] pushViewController:jobListingVC animated:YES];
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