//
//  JobListingViewController.h
//  iFindAJob
//
//  Created by Jordan Hancock on 02/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceDelegate.h"

@interface JobListingViewController : UITableViewController <ServiceDelegate> {
    NSMutableArray *searchResults;
    
    NSOperationQueue *serviceQueue;
}

@property (nonatomic, retain) NSDictionary *location;

@end
