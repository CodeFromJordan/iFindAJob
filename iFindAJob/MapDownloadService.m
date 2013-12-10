//
//  MapDownloadService.m
//  iFindAJob
//
//  Created by Jordan Hancock on 10/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "MapDownloadService.h"

@implementation MapDownloadService

@synthesize cityName;
@synthesize delegate;
@synthesize mapImage;

-(void) main {
    // Begin API declarations --
    // Google Maps
    
    // Build URL
    NSString *cityNameEscaped = [cityName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=11&size=120x93&sensor=false", cityNameEscaped]];
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL]; // Get data
    
    mapImage = [UIImage imageWithData: data]; // Set image
    
    [delegate serviceFinished:self withError:NO forSearchTerm:cityName]; // Finish service
}

@end
