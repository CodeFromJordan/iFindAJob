//
//  SearchViewController.m
//  iFindAJob
//
//  Created by Jordan Hancock on 18/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "SearchViewController.h"
#import "ExtraMethods.h"


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
    
    // Section 0 - North East
    NSArray *firstItemsArray = [[NSArray alloc] initWithObjects:@"Job 1", @"Job 2", @"Job 3", nil];
    NSDictionary *firstItemsArrayDict = [NSDictionary dictionaryWithObject:firstItemsArray forKey:@"data"];
    [dataArray addObject: firstItemsArrayDict];
    
    // Section 1 - North West
    NSArray *secondItemsArray = [[NSArray alloc] initWithObjects:@"Job 1", @"Job 2", @"Job 3", nil];
    NSDictionary *secondItemsArrayDict = [NSDictionary dictionaryWithObject:secondItemsArray forKey:@"data"];
    [dataArray addObject: secondItemsArrayDict];
    
    // Section 2 - Yorkshire and the Humber
    NSArray *thirdItemsArray = [[NSArray alloc] initWithObjects:@"Job 1", @"Job 2", @"Job 3", nil];
    NSDictionary *thirdItemsArrayDict = [NSDictionary dictionaryWithObject:thirdItemsArray forKey:@"data"];
    [dataArray addObject: thirdItemsArrayDict];
    
    // Section 3 - East Midlands
    NSArray *fourthItemsArray = [[NSArray alloc] initWithObjects:@"Job 1", @"Job 2", @"Job 3", nil];
    NSDictionary *fourthItemsArrayDict = [NSDictionary dictionaryWithObject:fourthItemsArray forKey:@"data"];
    [dataArray addObject: fourthItemsArrayDict];
    
    // Section 4 - West Midlands
    NSArray *fifthItemsArray = [[NSArray alloc] initWithObjects:@"Job 1", @"Job 2", @"Job 3", nil];
    NSDictionary *fifthItemsArrayDict = [NSDictionary dictionaryWithObject:fifthItemsArray forKey:@"data"];
    [dataArray addObject: fifthItemsArrayDict];
    
    // Section 5 - East of England
    NSArray *sixthItemsArray = [[NSArray alloc] initWithObjects:@"Job 1", @"Job 2", @"Job 3", nil];
    NSDictionary *sixthItemsArrayDict = [NSDictionary dictionaryWithObject:sixthItemsArray forKey:@"data"];
    [dataArray addObject: sixthItemsArrayDict];
    
    // Section 6 - London
    NSArray *seventhItemsArray = [[NSArray alloc] initWithObjects:@"Job 1", @"Job 2", @"Job 3", nil];
    NSDictionary *seventhItemsArrayDict = [NSDictionary dictionaryWithObject:seventhItemsArray forKey:@"data"];
    [dataArray addObject: seventhItemsArrayDict];
    
    // Section 7 - South East
    NSArray *eigthItemsArray = [[NSArray alloc] initWithObjects:@"Job 1", @"Job 2", @"Job 3", nil];
    NSDictionary *eigthItemsArrayDict = [NSDictionary dictionaryWithObject:eigthItemsArray forKey:@"data"];
    [dataArray addObject: eigthItemsArrayDict];
    
    // Section 8 - South West
    NSArray *ninthItemsArray = [[NSArray alloc] initWithObjects:@"Job 1", @"Job 2", @"Job 3", nil];
    NSDictionary *ninthItemsArrayDict = [NSDictionary dictionaryWithObject:ninthItemsArray forKey:@"data"];
    [dataArray addObject: ninthItemsArrayDict];
    
    
    // End data array initialization --
    
    [self setTitle:@"Search"]; // Set title of window
    
    [self.navigationController.navigationBar setTintColor:[ExtraMethods getColorFromHexString:@"7D3A0A"]]; // Make navigation bar brown
    
    [self.navigationController.topViewController.navigationItem setRightBarButtonItems:[ExtraMethods getShareButton:YES getDatasourcesButton:YES]]; // Set buttons on navigation bar
    
    [[UISearchBar appearance] setTintColor:[ExtraMethods getColorFromHexString:@"6E370F"]]; // Make search bar brown
    
    //[[UITabBar appearance] setImage:[UIImage imageNamed:@"search.png"]];
    [self.tabBarItem setImage:[UIImage imageNamed:@"search.png"]]; // Set tab bar image
    //[self.searchBar setPlaceholder:@"Hello"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar { // When the user clicks search bar to perform text
    isSearching = YES; // Set searching to YES
    
    [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(searchDone:)]]; // Add Cancel/Done button to navigation bar
     
     [[self tableView] reloadData]; // Force table to reload and redraw contents
}

-(void)searchDone:(id)sender { // Called when search done button clicked
    [searchBar setText:@""]; // Clear search text
    
    [searchBar resignFirstResponder]; // Hide the keyboard from the search bar
    
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
    return [dataArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section // Get number of rows in each section
{
    NSDictionary *dictionary = [dataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"data"];
    return [array count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Section headers for table
    if(section==0)
    {
        return @"North East";
    }
    if(section==1)
    {
        return @"North West";
    }
    if(section==2)
    {
        return @"Yorkshire and the Humber";
    }
    if(section==3)
    {
        return @"East Midlands";
    }
    if(section==4)
    {
        return @"West Midlands";
    }
    if(section==5)
    {
        return @"East of England";
    }
    if(section==6)
    {
        return @"London";
    }
    if(section==7)
    {
        return @"South East";
    }
    if(section==8)
    {
        return @"South West";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath // Populate rows
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) { // If cell is empty
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]; // Initialize cell
    }
    
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section]; // Select each row from data array
    NSArray *array = [dictionary objectForKey:@"data"]; // Get rows of data section from array
    NSString *cellValue = [array objectAtIndex:indexPath.row]; // String to store value to populate cell with
    
    cell.textLabel.text = cellValue; // Populate main title parts of each cell
    cell.textLabel.textColor = [ExtraMethods getColorFromHexString:@"7D3A0A"]; // Change color of main title
    cell.detailTextLabel.text = @"Salary: £.00";
    
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
