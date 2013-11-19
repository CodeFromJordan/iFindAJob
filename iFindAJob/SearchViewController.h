//
//  SearchViewController.h
//  iFindAJob
//
//  Created by Jordan Hancock on 18/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController <UISearchBarDelegate> {
    BOOL isSearching;
    
    NSMutableArray *dataArray;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
