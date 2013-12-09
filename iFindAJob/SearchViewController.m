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

#import "Location.h"
#import "AppDelegate.h"


@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize searchBar;

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

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup instance of app delegate for core data
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // Setup animation objects
    imageNames = @[@"search_anim_1.png", @"search_anim_2.png", @"search_anim_3.png", @"search_anim_4.png", @"search_anim_3.png", @"search_anim_2.png"];
    images = [[NSMutableArray alloc] init];
    for(int i = 0; i < imageNames.count; i++)
    {
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    }
    animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(140, 180, 35, 35)];
    animationImageView.animationImages = images;
    animationImageView.animationDuration = 0.7;
    animationImageView.animationRepeatCount = 100;
    
    [self.view addSubview:animationImageView];
    
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
        
    // Restore saved job list from core data
    [self readAllLocationsFromPersistance];
    
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
    [[self tableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)searchDone:(id)sender {
    [animationImageView stopAnimating]; // Get rid of animation
    
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
    [[self tableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
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

                // Add location info to main list
                // Search result location cannot be duplicate in searchResults OR locations, it also must actually have a city
                if(![[searchResults valueForKey:@"job_location_id"] containsObject:idOfLocationToAdd] && ![[location valueForKey:@"name"] isEqual:nil]) // Only add location to search results array if it doesn't already exist in it
                {                    
                    if([locations count] > 0) // If locations actually contains an item
                    {
                        // Store all locations and keywords which currently exist
                        NSArray *locationsArray = [locations valueForKey:@"job_location_id"];
                        NSArray *keywordsArray = [locations valueForKey:@"job_keyword"];
                        
                        bool pairExists = NO; // Store if pair already exists or not
                        
                        for(int i = 0; i < [locationsArray count]; i++) // Loop through each pair
                        {
                            // If location exists with keyword to be searched
                            if([[locationsArray objectAtIndex:i] isEqualToString:idOfLocationToAdd] && [[keywordsArray objectAtIndex:i] isEqualToString:searchTerm])
                            {
                                pairExists = YES; // Pair does exists
                            }
                        }
                        
                        if(pairExists == NO) // If loop reaches end without finding already existing pair
                        {
                            [searchResults addObject:location_info]; // Add search result to be shown
                        }
                    }
                    else
                    {
                        [searchResults addObject:location_info]; // Add search result to be shown
                    }
                }
            }
        }
        
        // If there are no results found
        if ([searchResults count] == 0) {
            [animationImageView stopAnimating]; // Force animation to go away
            [searchBar setText:[NSString stringWithFormat:@"No results for '%@'..", searchTerm]];
        }
        else{
            [searchBar setText:[NSString stringWithFormat:@"'%@' jobs found in these locations..", searchTerm]];
        }

        [[self tableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    } else { // Serious error, show error message
        [searchResults removeAllObjects];
        [animationImageView stopAnimating]; // Force animation to go away
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a serious error." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        [[self tableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)sb {
    // Retrieve search term for search bar
    NSString *searchTerm = [searchBar text];
    [animationImageView startAnimating];
    
    LocationSearchService *service = [[LocationSearchService alloc] init];
    [service setSearchTerm:searchTerm];
    [service setDelegate:self];
    [serviceQueue addOperation:service];
    
    [searchResults removeAllObjects];
    [searchBar setText:[NSString stringWithFormat:@"Searching for '%@'..", searchTerm]];
    [[self tableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
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
    if(isSearching) // Only when user is searching
    {
        [animationImageView stopAnimating]; // Force animation to go away
        [[cell textLabel] setText:[location valueForKey:@"job_location"]]; // Populate cells with search results
        [[cell detailTextLabel] setText:@""]; // Clear detail text label
    }
    else
    {
        [[cell textLabel] setText:[NSString stringWithFormat:@"%@", [[location valueForKey:@"job_keyword"] uppercaseString]]]; // Populate cells with saved results in upper case
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", [location valueForKey:@"job_location"]]];
    }
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
        
        // Call save to core data method for locations
        [self deleteLocationFromPersistance:[location valueForKey:@"job_location_id"] withSearchTerm:[location valueForKey:@"job_keyword"]];
        
        // Trigger remove animation on table
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
            [[self tableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            
            // Sort films
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"job_count" ascending:YES];
            [locations sortUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
            
            // Call save to core data method for location
            [self saveLocationToPersistance:location];
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
    [super viewWillAppear:animated];
}

-(void)deleteLocationFromPersistance:(NSString*)idOfLocationToDelete withSearchTerm:(NSString*)searchTerm{
    // Core data
    // Setup fetch request and entity objects
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *deleteQuery = [NSPredicate predicateWithFormat:@"id == %@ AND keyword == %@", idOfLocationToDelete, searchTerm]; // Must match location AND keyword
    [fetchRequest setPredicate:deleteQuery]; // Query match predicate
    
    NSError *fetchError; // Save for fetch operation
    NSArray *fetchedProducts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];

    for (NSManagedObject *product in fetchedProducts) { // Loop through each matched object and delete it
        [managedObjectContext deleteObject:product];
    }
    
    // Save/error handling
    NSError *deleteError;
    if(![managedObjectContext save:&fetchError]) {
        NSLog(@"Failed to delete record: %@", [deleteError localizedDescription]);
    }
}

-(void)readAllLocationsFromPersistance { // Reads all locations from data persistence
    // Original restore saved job list from xml
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString*documentsDirectory = [paths objectAtIndex:0];
    //NSString *yourArrayFileName = [documentsDirectory stringByAppendingPathComponent:@"locations.xml"];
    //locations = [[NSMutableArray alloc] initWithContentsOfFile: yourArrayFileName];
    //if(locations == nil) {
    //locations = [NSMutableArray arrayWithCapacity:0];
    //}
    
    // Core data
    // Setup fetch request and entity objects
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *fetchError; // Error for fetch operation
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&fetchError]; // Read all location object from core data
    
    for(Location *location in fetchedObjects) { // For each location object in core data
        NSMutableDictionary *locationToAdd = [[NSMutableDictionary alloc] init]; // Dictionary to temporarily store read in items
        
        // Take each read-in value and put them into dictionary
        [locationToAdd setValue:[location valueForKey:@"id"] forKey:@"job_location_id"];
        [locationToAdd setValue:[location valueForKey:@"name"] forKey:@"job_location"];
        [locationToAdd setValue:[location valueForKey:@"count"] forKey:@"job_count"];
        [locationToAdd setValue:[location valueForKey:@"keyword"] forKey:@"job_keyword"];
        
        [locations addObject:locationToAdd]; // Add dictionary to locations array
    }
}

-(void)saveLocationToPersistance:(NSDictionary*)locationToSave { // Saves all locations into data persietence
    // Original save to XML
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *yourArrayFileName = [documentsDirectory stringByAppendingPathComponent:@"locations.xml"];
    //[locations writeToFile:yourArrayFileName atomically:YES];

    // Core data
    // Create managed object
    Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
    
    // Read values from location dictionary
    [location setValue:[locationToSave valueForKey:@"job_location_id"] forKey:@"id"];
    [location setValue:[locationToSave valueForKey:@"job_location"] forKey:@"name"];
    [location setValue:[locationToSave valueForKey:@"job_count"] forKey:@"count"];
    [location setValue:[locationToSave valueForKey:@"job_keyword"] forKey:@"keyword"];
    
    // Save/error handling
    NSError *saveError; // Error for save operation
    if(![managedObjectContext save:&saveError]) {
        NSLog(@"Failed to save record: %@", [saveError localizedDescription]);
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !isSearching;
}

@end