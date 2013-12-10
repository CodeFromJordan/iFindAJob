//
//  MapDownloadService.h
//  iFindAJob
//
//  Created by Jordan Hancock on 10/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceDelegate.h"

@interface MapDownloadService : NSOperation {
    NSString *cityName;
    
    UIImage *mapImage;
}

@property (nonatomic, retain) id<ServiceDelegate> delegate;
@property (nonatomic, retain) NSString *cityName;

@property (nonatomic, retain) UIImage *mapImage;

@end
