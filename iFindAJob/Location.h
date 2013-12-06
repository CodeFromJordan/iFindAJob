//
//  Location.h
//  iFindAJob
//
//  Created by Jordan Hancock on 06/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * keyword;

@end
