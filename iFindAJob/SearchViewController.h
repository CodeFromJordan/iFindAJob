//
//  SearchViewController.h
//  iFindAJob
//
//  Created by Jordan Hancock on 18/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ServiceDelegate.h"
#import "LocationSearchService.h"
#import "ExtraMethods.h"

@interface SearchViewController : UITableViewController <UISearchBarDelegate, ServiceDelegate> {
    BOOL isSearching;
    
    NSMutableArray *locations;
    NSMutableArray *searchResults;
    
    NSOperationQueue *serviceQueue;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
