//
//  SavedJobViewController.h
//  iFindAJob
//
//  Created by Jordan Hancock on 10/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedJobViewController : UITableViewController {
    NSMutableArray *savedJobs;
}

// Properties for core data
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
