//
//  JobDetailViewController.h
//  iFindAJob
//
//  Created by Jordan Hancock on 03/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceDelegate.h"

@interface JobDetailViewController : UIViewController <ServiceDelegate> {
    UIBarButtonItem* shareButton;
    NSOperationQueue *serviceQueue;
    UIImage *mapImage;
}
@property (weak, nonatomic) IBOutlet UILabel *txtJobTitle;
@property (weak, nonatomic) IBOutlet UILabel *txtJobCompany;
@property (weak, nonatomic) IBOutlet UILabel *txtJobPostDate;
@property (weak, nonatomic) IBOutlet UILabel *txtRelocationSwitch;
@property (weak, nonatomic) IBOutlet UILabel *txtCommutingSwitch;
@property (weak, nonatomic) IBOutlet UIButton *btnOpenBrowser;
@property (weak, nonatomic) IBOutlet UIButton *btnSaveJob;
@property (weak, nonatomic) IBOutlet UIWebView *txtJobDescription;
@property (nonatomic, retain) NSDictionary *job;
@property (strong, nonatomic) IBOutlet UIImageView *imgJobMap;

// Properties for core data
@property(nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property bool openedFromSavedJobs;

@end
