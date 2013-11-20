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
    // Uncomment apikey declaration as necessary
    NSString *api_key = @"10143e0cc4cde57187987a2c3b72575b"; 
    NSString *search_term = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *url = [NSString stringWithFormat:@"http://www.authenticjobs.com/api/?api_key=%@0&method=aj.jobs.search&keywords=%@", api_key, search_term];
    NSMutableURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [theRequest setHTTPMethod:@"GET"];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:nil error:nil];
    
    if(responseData != nil) {
        NSError *error = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        
        if(error) {
            [delegate serviceFinished:self withError:YES];
        } else {
            results = (NSArray *)[json valueForKey:@"listings"];
            [delegate serviceFinished:self withError:NO];
        }
    } else {
        [delegate serviceFinished:self withError:YES];
    }
}

@end
