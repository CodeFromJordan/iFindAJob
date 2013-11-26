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
    [searchBar setPlaceholder:@"Enter job keywords.."]; // Reset placeholder for search bar
    [searchBar setDelegate:self]; // Allows search bar to be used
    isSearching = NO;
    performedSearch = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeDataDictionaries];
    
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

-(void)initializeDataDictionaries {
    dataArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *templateArray = [[NSMutableArray alloc] initWithObjects:@"No jobs to display yet.", nil];
    
    // Section 0 - Saved jobs
    savedItemsArrayDict = [NSMutableDictionary dictionaryWithObject:templateArray forKey:@"job_0"];
    [dataArray addObject: savedItemsArrayDict];
    
    // Section 1 - North East
    region1ItemsArrayDict = [NSMutableDictionary dictionaryWithObject:templateArray forKey:@"job_0"];
    [dataArray addObject: region1ItemsArrayDict];
    
    // Section 2 - North West
    region2ItemsArrayDict = [NSMutableDictionary dictionaryWithObject:templateArray forKey:@"job_0"];
    [dataArray addObject: region2ItemsArrayDict];
    
    // Section 3 - Yorkshire and the Humber
    region3ItemsArrayDict = [NSMutableDictionary dictionaryWithObject:templateArray forKey:@"job_0"];
    [dataArray addObject: region3ItemsArrayDict];
    
    // Section 4 - East Midlands
    region4ItemsArrayDict = [NSMutableDictionary dictionaryWithObject:templateArray forKey:@"job_0"];
    [dataArray addObject: region4ItemsArrayDict];
    
    // Section 5 - West Midlands
    region5ItemsArrayDict = [NSMutableDictionary dictionaryWithObject:templateArray forKey:@"job_0"];
    [dataArray addObject: region5ItemsArrayDict];
    
    // Section 6 - East of England
    region6ItemsArrayDict = [NSMutableDictionary dictionaryWithObject:templateArray forKey:@"job_0"];
    [dataArray addObject: region6ItemsArrayDict];
    
    // Section 7 - London
    region7ItemsArrayDict = [NSMutableDictionary dictionaryWithObject:templateArray forKey:@"job_0"];
    [dataArray addObject: region7ItemsArrayDict];
    
    // Section 8 - South East
    region8ItemsArrayDict = [NSMutableDictionary dictionaryWithObject:templateArray forKey:@"job_0"];
    [dataArray addObject: region8ItemsArrayDict];
    
    // Section 9 - South West
    region9ItemsArrayDict = [NSMutableDictionary dictionaryWithObject:templateArray forKey:@"job_0"];
    [dataArray addObject: region9ItemsArrayDict];
    
    // Section 10 - Outside of UK
    region10ItemsArrayDict = [NSMutableDictionary dictionaryWithObject:templateArray forKey:@"job_0"];
    [dataArray addObject: region10ItemsArrayDict];
    
    performedSearch = NO;
}

-(void)clearDataDictionaries {
    [region1ItemsArrayDict removeAllObjects];
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
    
    [self initializeDataDictionaries]; // Reset data dictionaries ready for new search
    [self clearDataDictionaries];
    
    JobSearchService *service = [[JobSearchService alloc] init];
    [service setSearchTerm:searchTerm];
    [service setDelegate:self];
    [serviceQueue addOperation:service];
    
    //[[self tableView] reloadData]; // Refresh table
    
    // Interface changes
    [searchBar resignFirstResponder];
    [[self navigationItem] setLeftBarButtonItem:nil]; 
    [searchBar setText:@"Searching.."];
    
    // Change search booleans
    isSearching = NO;
    performedSearch = YES;
}

-(void)serviceFinished:(id)service withError:(BOOL)error {
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
            [searchBar setText:@"No Results Found.."];
        }
        else
        {
            [searchBar setText:@"Search Completed.."];
        }
    } else {
        [self initializeDataDictionaries]; // Reset to default table data
        [searchResults removeAllObjects]; // Clear search result array
        [searchBar setText:@"An error as occurred.."];
    }

    [[self tableView] reloadData]; // Refresh table
}

-(void)addJobToDataArray:(NSMutableDictionary*)job { // Loop through all jobs and add them to dictionary
    // Read dictionary values into string objects
    NSString *job_id = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_id"]];
    
    NSString *job_title = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_title"]];
    
    NSString *job_company_name = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_company_name"]];
    if([job_company_name length] > 29) // If company name length is more than 29 characters long, it pushes date out of cell
    {
        job_company_name = [job_company_name substringToIndex:27]; // Cut it to 27 characters with two dots
        job_company_name = [NSString stringWithFormat:@"%@..", job_company_name];
    }
    
    NSString *job_location = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_location"]];
    
    NSString *job_post_date = [NSString stringWithFormat:@"%@", [job valueForKey:@"job_post_date"]]; // Returns date and time
    job_post_date = [job_post_date substringToIndex:10]; // Cut time from string
    
    NSString *nextKeyCalculation = [NSString stringWithFormat:@"job_%d", [savedItemsArrayDict count]]; // Calculates next key in dictionary
    
    // Temporary array used to store jobs. Must be initialized to stop crash
    NSMutableArray *jobToAddArray = [[NSMutableArray alloc] initWithObjects: job_id, job_title, job_company_name, job_location, job_post_date, nil];
    
    // Add item to dictionary
    switch([self whichRegion:job_location]) // Figure out which array to put into and do it
    {
        case 1: // North East
            [region1ItemsArrayDict setObject:jobToAddArray forKey:nextKeyCalculation];
            break;
        case 2: // North West
            [region2ItemsArrayDict setObject:jobToAddArray forKey:nextKeyCalculation];
            break;
        case 3: // Yorkshire and the Humber
            [region3ItemsArrayDict setObject:jobToAddArray forKey:nextKeyCalculation];
            break;
        case 4: // East Midlands
            [region4ItemsArrayDict setObject:jobToAddArray forKey:nextKeyCalculation];
            break;
        case 5: // West Midlands
            [region5ItemsArrayDict setObject:jobToAddArray forKey:nextKeyCalculation];
            break;
        case 6: // East of England
            [region6ItemsArrayDict setObject:jobToAddArray forKey:nextKeyCalculation];
            break;
        case 7: // London
            [region7ItemsArrayDict setObject:jobToAddArray forKey:nextKeyCalculation];
            break;
        case 8: // South East
            [region8ItemsArrayDict setObject:jobToAddArray forKey:nextKeyCalculation];
            break;
        case 9: // South West
            [region9ItemsArrayDict setObject:jobToAddArray forKey:nextKeyCalculation];
            break;
        case 10: // Outside of UK
            [region10ItemsArrayDict setObject:jobToAddArray forKey:nextKeyCalculation];
            break;
        default: // Any number other than ones above, then not in any of the regions
            break;
    }
    
}

-(NSInteger)whichRegion:(NSString*)jobLocation { // Uses the location posted with the job to decide which world region to put job into
    return 1; // Temporary
}

-(void)searchDone:(id)sender { // Called when search done button clicked
    [searchBar setText:@""]; // Clear search text
    
    [searchBar resignFirstResponder]; // Hide the keyboard from the search bar
    [searchResults removeAllObjects];
    
    isSearching = NO;
    
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
    }
    else // If the user has searched 
    {
        if([array count] > 1)
        {
            // Populate cells
            cell.textLabel.text = [array objectAtIndex:1]; // Main title of cell (job title)
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@", [array objectAtIndex:2], [array objectAtIndex:4]]; // Details of cell, company and date posted
        }
        else
        {
            cell.textLabel.text = [array objectAtIndex:0];
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
    NSArray *array = [dictionary objectForKey:@"job"]; // Get rows of data section from dictionary
    selectedCell = [array objectAtIndex:[indexPath row]]; // Dump contents of selected row into string
    
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
