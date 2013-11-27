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

UIApplication *application;

// Array to store region dictionaries {region1ItemsArrayDict, region2ItemsArrayDict} etc..
NSMutableArray *dataArray; 

// Dictionaries to hold job arrays {"job1", job1array} etc..
NSMutableDictionary *savedItemsArrayDict;
NSMutableDictionary *region1ItemsArrayDict;
NSMutableDictionary *region2ItemsArrayDict;
NSMutableDictionary *region3ItemsArrayDict;
NSMutableDictionary *region4ItemsArrayDict;
NSMutableDictionary *region5ItemsArrayDict;
NSMutableDictionary *region6ItemsArrayDict;
NSMutableDictionary *region7ItemsArrayDict;
NSMutableDictionary *region8ItemsArrayDict;
NSMutableDictionary *region9ItemsArrayDict;
NSMutableDictionary *region10ItemsArrayDict;

NSMutableArray *searchResults; // Results returned from API

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
    [searchBar setPlaceholder:@"Enter job keyword.."]; // Reset placeholder for search bar
    [searchBar setDelegate:self]; // Allows search bar to be used
    isSearching = NO;
    performedSearch = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self resetDataForView]; // Get data variables and objects ready
    
    // Begin appearance --
    [self.navigationController.navigationBar setTintColor:[ExtraMethods getColorFromHexString:@"7D3A0A"]]; // Make navigation bar brown
    [self.navigationController.topViewController.navigationItem setRightBarButtonItems:[ExtraMethods getShareButton:NO getSettingsButton:YES]]; // Set buttons on navigation bar
    [[UISearchBar appearance] setTintColor:[ExtraMethods getColorFromHexString:@"6E370F"]]; // Make search bar brown
    // End appearance --
    
    // Begin setup --
    searchResults = [[NSMutableArray alloc] init];
    // Setup service queue
    serviceQueue = [[NSOperationQueue alloc] init];
    [serviceQueue setMaxConcurrentOperationCount:1];
    // End setup
}

-(void)resetDataForView { // Resets all data for the view
    dataArray = [[NSMutableArray alloc] init]; // Clear data array completely
    
    NSMutableArray *templateArray = [[NSMutableArray alloc] initWithObjects:@"No jobs to display..", nil];
    
    // Section 0 - Saved jobs
    [self initializeDataInDictionary:savedItemsArrayDict withData:templateArray];
    // Section 1 - North East
    [self initializeDataInDictionary:region1ItemsArrayDict withData:templateArray];
    // Section 2 - North West
    [self initializeDataInDictionary:region2ItemsArrayDict withData:templateArray];
    // Section 3 - Yorkshire and the Humber
    [self initializeDataInDictionary:region3ItemsArrayDict withData:templateArray];
    // Section 4 - East Midlands
    [self initializeDataInDictionary:region4ItemsArrayDict withData:templateArray];
    // Section 5 - West Midlands
    [self initializeDataInDictionary:region5ItemsArrayDict withData:templateArray];
    // Section 6 - East of England
    [self initializeDataInDictionary:region6ItemsArrayDict withData:templateArray];
    // Section 7 - London
    [self initializeDataInDictionary:region7ItemsArrayDict withData:templateArray];
    // Section 8 - South East
    [self initializeDataInDictionary:region8ItemsArrayDict withData:templateArray];
    // Section 9 - South West
    [self initializeDataInDictionary:region9ItemsArrayDict withData:templateArray];
    // Section 10 - Outside of UK
    [self initializeDataInDictionary:region10ItemsArrayDict withData:templateArray];
    
    isSearching = NO;
}

-(void)initializeDataInDictionary:(NSMutableDictionary*)dictionary withData:(NSArray*)array { // Resets data in a specific dictionary
    //[self clearDataInDictionary:dictionary]; // Ensure that dictionary is empty before re-initializing
    
    dictionary = [NSMutableDictionary dictionaryWithObject:array forKey:@"job_0"]; // Set up initial row
    [dataArray addObject: dictionary]; // Add it to dataArray
}

-(void)clearAllDictionaries{
    // Section 1 - North East
    [self clearDataInDictionary:region2ItemsArrayDict];
    // Section 2 - North West
    [self clearDataInDictionary:region3ItemsArrayDict];
    // Section 3 - Yorkshire and the Humber
    [self clearDataInDictionary:region4ItemsArrayDict];
    // Section 4 - East Midlands
    [self clearDataInDictionary:region5ItemsArrayDict];
    // Section 5 - West Midlands
    [self clearDataInDictionary:region6ItemsArrayDict];
    // Section 6 - East of England
    [self clearDataInDictionary:region7ItemsArrayDict];
    // Section 7 - London
    [self clearDataInDictionary:region8ItemsArrayDict];
    // Section 8 - South East
    [self clearDataInDictionary:region9ItemsArrayDict];
    // Section 9 - South West
    [self clearDataInDictionary:region10ItemsArrayDict];
    // Section 10 - Outside of UK
    [self clearDataInDictionary:region1ItemsArrayDict];
}

-(void)clearDataInDictionary:(NSMutableDictionary*)dictionary { // Removes all objects from passed dictionary
    [dictionary removeAllObjects];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar { // When the user clicks search bar to perform text
    [searchBar setText:@""]; // Clear text box when clicked
    isSearching = YES; // Set searching to YES
    
    [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(searchDone:)]]; // Add Cancel/Done button to navigation bar
    
    [searchResults removeAllObjects];
    
    //[[self tableView] reloadData]; // Force table to reload and redraw contents
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)sb {
    // Retrieve search term from search bar
    NSString *searchTerm = [searchBar text];
    
    [self resetDataForView]; // Reset data dictionaries ready for new search
    [self clearAllDictionaries]; // Clear dictionaries
    
    JobSearchService *service = [[JobSearchService alloc] init];
    [service setSearchTerm:searchTerm];
    [service setDelegate:self];
    [serviceQueue addOperation:service];
    
    //[[self tableView] reloadData]; // Refresh table
    
    // Interface changes
    [searchBar resignFirstResponder];
    [[self navigationItem] setLeftBarButtonItem:nil]; 
    [searchBar setText:[NSString stringWithFormat:@"Searching for '%@'..", searchTerm]];
    
    // Change search booleans
    isSearching = NO;
    performedSearch = YES;
}

-(void)serviceFinished:(id)service withError:(BOOL)error forSearchTerm:(NSString*)searchTerm {
    if(!error) {
      
        for (NSDictionary *job in [service results]) {
            // Create dictionary to store multiple values for a job
            NSMutableDictionary *j_info = [[NSMutableDictionary alloc] init];
            
            // Store given variables in search results
            [j_info setValue:[job valueForKey:@"id"] forKey:@"job_id"];
            [j_info setValue:[[job valueForKey:@"category"] valueForKey:@"name"] forKey:@"job_title"];
            [j_info setValue:[[job valueForKey:@"company"] valueForKey:@"name"] forKey:@"job_company_name"];
            [j_info setValue:[job valueForKey:@"post_date"] forKey:@"job_post_date"];
            [j_info setValue:[[[job valueForKey:@"company"] valueForKey:@"location"] valueForKey:@"city"] forKey:@"job_location"];
            
            // Add job to search results array
            [searchResults addObject:j_info];
            
            // Add job to main data
            [self addJobToDataArray:j_info];
        }
        
        // If there are no results found
        if([searchResults count] == 0) {
            [searchBar setText:[NSString stringWithFormat:@"No results for '%@'..", searchTerm]];
        }
        else
        {
            [searchBar setText:[NSString stringWithFormat:@"Searching completed for '%@'..", searchTerm]];
        }
    } else {
        [self resetDataForView]; // Reset to default data to save from error
        [searchResults removeAllObjects]; // Clear search result array
        [searchBar setText:[NSString stringWithFormat:@"Error for '%@'..", searchTerm]];
    }
    
    [[self tableView] reloadData]; // Refresh table
}

-(void)addJobToDataArray:(NSMutableDictionary*)job { // Loop through all jobs and add them to dictionary
    // Read dictionary values into string objects
    NSString *job_id = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_id"]];
    
    NSString *job_title = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_title"]];
    
    NSString *job_company_name = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_company_name"]];   
    job_company_name = [job_company_name length] > 26 ? [NSString stringWithFormat:@"%@..", [job_company_name substringToIndex:26]] : job_company_name; // More than 26 characters for company name pushes date out of cell, so cut it down
    
    NSString *job_location = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_location"]];
    
    NSString *job_post_date = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_post_date"]]; // Returns date and time
    job_post_date = [job_post_date substringToIndex:10]; // Cut time from string
       
    // Temporary array used to store jobs. Must be initialized to stop crash
    NSMutableArray *jobToAddArray = [[NSMutableArray alloc] initWithObjects: job_id, job_title, job_company_name, job_location, job_post_date, nil];
    
    // Add item to dictionary
    switch([self whichRegion:job_location]) // Figure out which array to put into and do it
    {
        case 1: // North East
            //[self clearDataInDictionary:region1ItemsArrayDict];
            [region1ItemsArrayDict setObject:jobToAddArray forKey:[self getNextKeyForDictionary:region1ItemsArrayDict]];
            break;
        case 2: // North West
            //[self clearDataInDictionary:region2ItemsArrayDict];
            [region2ItemsArrayDict setObject:jobToAddArray forKey:[self getNextKeyForDictionary:region2ItemsArrayDict]];
            break;
        case 3: // Yorkshire and the Humber
            [self clearDataInDictionary:region3ItemsArrayDict];
            [region3ItemsArrayDict setObject:jobToAddArray forKey:[self getNextKeyForDictionary:region3ItemsArrayDict]];
            break;
        case 4: // East Midlands
            [self clearDataInDictionary:region4ItemsArrayDict];
            [region4ItemsArrayDict setObject:jobToAddArray forKey:[self getNextKeyForDictionary:region4ItemsArrayDict]];
            break;
        case 5: // West Midlands
            [self clearDataInDictionary:region5ItemsArrayDict];
            [region5ItemsArrayDict setObject:jobToAddArray forKey:[self getNextKeyForDictionary:region5ItemsArrayDict]];
            break;
        case 6: // East of England
            [self clearDataInDictionary:region6ItemsArrayDict];
            [region6ItemsArrayDict setObject:jobToAddArray forKey:[self getNextKeyForDictionary:region5ItemsArrayDict]];
            break;
        case 7: // London
            [self clearDataInDictionary:region7ItemsArrayDict];
            [region7ItemsArrayDict setObject:jobToAddArray forKey:[self getNextKeyForDictionary:region7ItemsArrayDict]];
            break;
        case 8: // South East
            [self clearDataInDictionary:region8ItemsArrayDict];
            [region8ItemsArrayDict setObject:jobToAddArray forKey:[self getNextKeyForDictionary:region8ItemsArrayDict]];
            break;
        case 9: // South West
            [self clearDataInDictionary:region9ItemsArrayDict];
            [region9ItemsArrayDict setObject:jobToAddArray forKey:[self getNextKeyForDictionary:region9ItemsArrayDict]];
            break;
        case 10: // Outside of UK
            [self clearDataInDictionary:region10ItemsArrayDict];
            [region10ItemsArrayDict setObject:jobToAddArray forKey:[self getNextKeyForDictionary:region10ItemsArrayDict]];
            break;
        default: // Any number other than ones above, then not in any of the regions
            break;
    }
    
}

-(NSInteger)whichRegion:(NSString*)jobLocation { // Uses the location posted with the job to decide which world region to put job into
    return 1; // Temporary
}

-(NSString*)getNextKeyForDictionary:(NSDictionary*)dictionary {
    return [NSString stringWithFormat:@"job_%d", [dictionary count]]; // Calculates next key in dictionary for passed dictionary
}

-(void)searchDone:(id)sender { // Called when search done button clicked
    [searchBar setText:@""]; // Clear search text
    
    [searchBar resignFirstResponder]; // Hide the keyboard from the search bar
    [searchResults removeAllObjects];
    
    isSearching = NO;
    
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
    // Dictionary contains ["job#", ["Job 1", "Job 2", "Job 3", nil]]
    NSDictionary *dictionary = [dataArray objectAtIndex:section];
    // NSArray *array = [dictionary objectForKey:@"job"];
    return isSearching ? 1 : [dictionary count]; // If searching, number of search results. Else number of jobs in each region to populate results.
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
    if(section==10)
    {
        return @"Outside of UK";
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

    NSDictionary *dictionary = [dataArray objectAtIndex:[indexPath section]]; // Create new dictionary for each individual section
    NSArray *array = [dictionary objectForKey:[NSString stringWithFormat:@"job_%d", [indexPath row]]]; // Get the actual job data from the dictionary
    
    if(performedSearch == NO) // If user hasn't searched yet
    {
        cell.textLabel.text = [array objectAtIndex:0]; // Main title of cell (job title)
        cell.detailTextLabel.text = @"";
    }
    else // If the user has searched 
    {
        if([array count] > 1) // If the array has more than one element, it means there is a job in the section.
        {
            // Populate cells
            cell.textLabel.text = [array objectAtIndex:1]; // Main title of cell (job title)
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@", [array objectAtIndex:2], [array objectAtIndex:4]]; // Details of cell, company and date posted
        }
        else // If the array has only one element, it means that there are no jobs to display.
        {
            cell.textLabel.text = @"No jobs to display..";
            cell.detailTextLabel.text = @"";
        }
    }
    
    
    // Cell formatting
    cell.textLabel.textColor = [ExtraMethods getColorFromHexString:@"7D3A0A"]; // Change color of main title
    
    return cell; // Pass back cell contents
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath // Row selected
{
    // Get selected job
    NSString *selectedCell = nil; // String to store selected cell details
    NSDictionary *dictionary = [dataArray objectAtIndex:[indexPath section]]; // Get details of selected row, add to dictionary
    NSArray *array = [dictionary objectForKey:[NSString stringWithFormat:@"job_%d", [indexPath row]]]; // Get rows of data section from dictionary
    
    selectedCell = [array objectAtIndex:[indexPath row]]; // Dump contents of selected row into string
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // Deselect chosen row animation
    
    if([array count] > 1) // If the section array has more than one element
    {
        // Do whatever needs to be done when the cell is clicked
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Job Details" message:@"This alert is here temporarily to show the difference between a job row click and an empty row click." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        
        [av show];
    }
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
