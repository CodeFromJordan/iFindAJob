//
//  JobSearchService.m
//  iFindAJob
//
//  Created by Jordan Hancock on 20/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "JobSearchService.h"

@implementation JobSearchService

@synthesize searchTerm;
@synthesize delegate;

@synthesize results;

- (void)main {
    NSString *search_term = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    // Begin API declarations --
    // AuthenticJobs
    NSString *api_key = @"5e389f733b28cfe33ac2f03aef32fb1a";
    NSString *url = [NSString stringWithFormat:@"http://www.authenticjobs.com/api/?api_key=%@&method=aj.jobs.search&keywords=%@&format=json", api_key, search_term];
    // End API declarations --
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [theRequest setHTTPMethod:@"GET"];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
    
    if(responseData != nil) {
        /*
         DEBUGGING: Uncomment the following two lines to print what API call returns
         NSString *dataReturned = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
         NSLog(dataReturned);
        */
        
        NSError *error = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        
        /*
         DEBUGGING: Uncomment the next line to see contents of error from JSON parsing
         NSLog(@"Error: %@", error);
         */
        
        if(error) {
            [delegate serviceFinished:self withError:YES forSearchTerm:search_term];
        } else {
            results = (NSArray *)[json valueForKeyPath:@"listings.listing"];
            [delegate serviceFinished:self withError:NO forSearchTerm:search_term];
        }
    } else {
        [delegate serviceFinished:self withError:YES forSearchTerm:search_term];
    }
}

@end
