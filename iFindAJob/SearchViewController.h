//
//  SearchViewController.h
//  iFindAJob
//
//  Created by Jordan Hancock on 18/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceDelegate.h"

@interface SearchViewController : UITableViewController <UISearchBarDelegate, ServiceDelegate> {
    BOOL isSearching;
    
    NSMutableArray *locations;
    NSMutableArray *searchResults;
    
    NSOperationQueue *serviceQueue;
    
    NSArray *imageNames;
    NSMutableArray *images;
    UIImageView *animationImageView;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

// Properties for core data
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
