//
//  JobDetailViewController.h
//  iFindAJob
//
//  Created by Jordan Hancock on 03/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobDetailViewController : UIViewController {
        UIBarButtonItem* shareButton;
}
@property (weak, nonatomic) IBOutlet UILabel *txtJobTitle;
@property (weak, nonatomic) IBOutlet UILabel *txtJobCompany;
@property (weak, nonatomic) IBOutlet UILabel *txtJobPostDate;
@property (weak, nonatomic) IBOutlet UISwitch *swtRelocation;
@property (weak, nonatomic) IBOutlet UISwitch *swtCommuting;
@property (weak, nonatomic) IBOutlet UITextView *txtJobDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnOpenBrowser;

@property (nonatomic, retain) NSDictionary *job;

@end
