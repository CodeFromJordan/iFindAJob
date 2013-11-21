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
    NSString *url = [NSString stringWithFormat:@"http://www.authenticjobs.com/api/?api_key=%@0&method=aj.jobs.search&keywords=%@", api_key, search_term];
    // End API declarations --
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [theRequest setHTTPMethod:@"GET"];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
    
    if(responseData != nil) {
        NSString *dataReturned = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        // NSLog(dataReturned);
        
        NSError *error = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        // NSLog(error);
        
        if(error) {
            [delegate serviceFinished:self withError:YES];
        } else {
            results = (NSArray *)[json valueForKey:@"movies"];
            [delegate serviceFinished:self withError:NO];
        }
    } else {
        [delegate serviceFinished:self withError:YES];
    }
}

@end
