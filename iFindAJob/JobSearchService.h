//
//  JobSearchService.h
//  iFindAJob
//
//  Created by Jordan Hancock on 02/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServiceDelegate.h"

@interface JobSearchService : NSOperation {
    NSString *searchTerm;
    NSString* locationId;
    id<ServiceDelegate> delegate;
    
    NSArray *results;
}

@property (nonatomic, retain) NSString *locationId;
@property (nonatomic, retain) NSString *searchTerm;
@property (nonatomic, retain) id<ServiceDelegate> delegate;

@property (nonatomic, retain) NSArray *results;

@end
