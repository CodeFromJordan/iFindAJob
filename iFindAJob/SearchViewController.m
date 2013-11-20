//
//  SearchViewController.m
//  iFindAJob
//
//  Created by Jordan Hancock on 18/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

@synthesize searchBar;

// Automatic Methods
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
         // Custom initialization
        
    }
    
    return self;
}

- (void)viewDidAppear: (BOOL) animated // Every time view appears
{
    [searchBar setPlaceholder:@"Enter job keywords.."]; // Reset placeholder for search bar
    [searchBar setDelegate:self]; // Allows search bar to be used
    isSearching = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Begin data array initialization --
    dataArray = [[NSMutableArray alloc] init];
    
    // Section 0 - Saved jobs
    NSMutableArray *savedItemsArray = [[NSMutableArray alloc] initWithObjects:@"Nothing saved yet..", nil];
    NSDictionary *savedItemsArrayDict = [NSDictionary dictionaryWithObject:savedItemsArray forKey:@"data"];
    [dataArray addObject: savedItemsArrayDict];
    
    // Section 1 - North East
    NSMutableArray *firstItemsArray = [[NSMutableArray alloc] initWithObjects:@"No results yet..", nil];
    NSDictionary *firstItemsArrayDict = [NSDictionary dictionaryWithObject:firstItemsArray forKey:@"data"];
    [dataArray addObject: firstItemsArrayDict];
    
    // Section 2 - North West
    NSMutableArray *secondItemsArray = [[NSMutableArray alloc] initWithObjects:@"No results yet..", nil];
    NSDictionary *secondItemsArrayDict = [NSDictionary dictionaryWithObject:secondItemsArray forKey:@"data"];
    [dataArray addObject: secondItemsArrayDict];
    
    // Section 3 - Yorkshire and the Humber
    NSMutableArray *thirdItemsArray = [[NSMutableArray alloc] initWithObjects:@"No results yet..", nil];
    NSDictionary *thirdItemsArrayDict = [NSDictionary dictionaryWithObject:thirdItemsArray forKey:@"data"];
    [dataArray addObject: thirdItemsArrayDict];
    
    // Section 4 - East Midlands
    NSMutableArray *fourthItemsArray = [[NSMutableArray alloc] initWithObjects:@"No results yet..", nil];
    NSDictionary *fourthItemsArrayDict = [NSDictionary dictionaryWithObject:fourthItemsArray forKey:@"data"];
    [dataArray addObject: fourthItemsArrayDict];
    
    // Section 5 - West Midlands
    NSMutableArray *fifthItemsArray = [[NSMutableArray alloc] initWithObjects:@"No results yet..", nil];
    NSDictionary *fifthItemsArrayDict = [NSDictionary dictionaryWithObject:fifthItemsArray forKey:@"data"];
    [dataArray addObject: fifthItemsArrayDict];
    
    // Section 6 - East of England
    NSMutableArray *sixthItemsArray = [[NSMutableArray alloc] initWithObjects:@"No results yet..", nil];
    NSDictionary *sixthItemsArrayDict = [NSDictionary dictionaryWithObject:sixthItemsArray forKey:@"data"];
    [dataArray addObject: sixthItemsArrayDict];
    
    // Section 7 - London
    NSMutableArray *seventhItemsArray = [[NSMutableArray alloc] initWithObjects:@"No results yet..", nil];
    NSDictionary *seventhItemsArrayDict = [NSDictionary dictionaryWithObject:seventhItemsArray forKey:@"data"];
    [dataArray addObject: seventhItemsArrayDict];
    
    // Section 8 - South East
    NSMutableArray *eigthItemsArray = [[NSMutableArray alloc] initWithObjects:@"No results yet..", nil];
    NSDictionary *eigthItemsArrayDict = [NSDictionary dictionaryWithObject:eigthItemsArray forKey:@"data"];
    [dataArray addObject: eigthItemsArrayDict];
    
    // Section 9 - South West
    NSMutableArray *ninthItemsArray = [[NSMutableArray alloc] initWithObjects:@"No results yet..", nil];
    NSDictionary *ninthItemsArrayDict = [NSDictionary dictionaryWithObject:ninthItemsArray forKey:@"data"];
    [dataArray addObject: ninthItemsArrayDict];
    // End data array initialization --
    
    // Begin appearance --
    [self.navigationController.navigationBar setTintColor:[ExtraMethods getColorFromHexString:@"7D3A0A"]]; // Make navigation bar brown
    [self.navigationController.topViewController.navigationItem setRightBarButtonItems:[ExtraMethods getShareButton:YES getSettingsButton:YES]]; // Set buttons on navigation bar
    [[UISearchBar appearance] setTintColor:[ExtraMethods getColorFromHexString:@"6E370F"]]; // Make search bar brown
    // End appearance --
    
    // Begin setup --
    searchResults = [[NSMutableArray alloc] init];
    // Setup service queue
    serviceQueue = [[NSOperationQueue alloc] init];
    [serviceQueue setMaxConcurrentOperationCount:1];
    // End setup
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar { // When the user clicks search bar to perform text
    isSearching = YES; // Set searching to YES
    
    [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(searchDone:)]]; // Add Cancel/Done button to navigation bar
    
    [searchResults removeAllObjects];
     [[self tableView] reloadData]; // Force table to reload and redraw contents
}

-(void)serviceFinished:(id)service withError:(BOOL)error {
    if(!error) {
        [searchResults removeAllObjects];
        
        for (NSDictionary *job in [service results]) {
            // Create dictionary to store multiple values for a job
            NSMutableDictionary *j_info = [[NSMutableDictionary alloc] init];
            
            // Store given variables
            [j_info setValue:[job valueForKey:@"id"] forKey:@"id"];
            [j_info setValue:[job valueForKey:@"category"] forKey:@"category"];
            [j_info setValue:[job valueForKey:@"begin_date"] forKey:@"begin_date"];
            [j_info setValue:[job valueForKey:@"location"] forKey:@"location"];
            
            [searchResults addObject:j_info];
        }
        
        // If there are no results found
        if([searchResults count] == 0) {
            [ExtraMethods showErrorMessageWithTitle:@"No Results Found" andMessage:@"There were no jobs found for the keywords that you provided."];
        }
        [[self tableView] reloadData]; // Reload existing table data
    } else {
        [searchResults removeAllObjects]; // Clear search result array
        
        [ExtraMethods showErrorMessageWithTitle:@"Error" andMessage:@"An error has occurred."];

        [[self tableView] reloadData]; // Reload existing table data
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)sb {
    // Retrieve search term from search bar
    NSString *searchTerm = [searchBar text];
    
    JobSearchService *service = [[JobSearchService alloc] init];
    [service setSearchTerm:searchTerm];
    [service setDelegate:self];
    [serviceQueue addOperation:service];
    
    [searchResults removeAllObjects];
    [searchResults addObject: [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"-1", @"Searching..", @"", nil] forKeys:[NSArray arrayWithObjects:@"id", @"category", @"begin_date", @"location", nil]]];
    [[self tableView] reloadData];
    
    // Hide the keyboard from th search bar
    [searchBar resignFirstResponder];
}

-(void)searchDone:(id)sender { // Called when search done button clicked
    [searchBar setText:@""]; // Clear search text
    
    [searchBar resignFirstResponder]; // Hide the keyboard from the search bar
    [searchResults removeAllObjects];
    
    [[self tableView] reloadData];
    
    [[self navigationItem] setLeftBarButtonItem:nil]; // Remove the Cancel/Done button from the navigation bar
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView // Get number of sections
{
    return [dataArray count]; // If searching, one section. Else number of regions (9)
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section // Get number of rows in each section
{
    // Dictionary contains ["data", ["Job 1", "Job 2", "Job 3", nil]]
    NSDictionary *dictionary = [dataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"data"];
    return isSearching ? 1 : [array count]; // If searching, number of search results. Else number of jobs in each region to populate results.
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Section headers for table
    if(section==0)
    {
        return @"Saved Jobs";
    }
    if(section==1)
    {
        return @"North East";
    }
    if(section==2)
    {
        return @"North West";
    }
    if(section==3)
    {
        return @"Yorkshire and the Humber";
    }
    if(section==4)
    {
        return @"East Midlands";
    }
    if(section==5)
    {
        return @"West Midlands";
    }
    if(section==6)
    {
        return @"East of England";
    }
    if(section==7)
    {
        return @"London";
    }
    if(section==8)
    {
        return @"South East";
    }
    if(section==9)
    {
        return @"South West";
    }
    else // Just in case
    {
        return @"There has been a bad error";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath // Populate rows
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) { // If cell is empty
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]; // Initialize cell
    }
    
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section]; // Create new dictionary for each individual section
    NSArray *array = [dictionary objectForKey:@"data"]; // // Get the actual job data from the dictionary
    NSString *cellValue = [array objectAtIndex:indexPath.row]; // Get contents for each individual cell from array
    cell.textLabel.text = cellValue; // Populate main title parts of each cell
    cell.textLabel.textColor = [ExtraMethods getColorFromHexString:@"7D3A0A"]; // Change color of main title
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath // Row selected
{
    // Get selected job
    NSString *selectedCell = nil; // String to store selected cell details
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section]; // Get details of selected row, add to dictionary
    NSArray *array = [dictionary objectForKey:@"data"]; // Get rows of data section from dictionary
    selectedCell = [array objectAtIndex:indexPath.row]; // Dump contents of selected row into string
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // Deselect chosen row animation
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

@end
