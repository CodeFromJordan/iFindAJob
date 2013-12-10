//
//  Job.h
//  iFindAJob
//
//  Created by Jordan Hancock on 10/12/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Job : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * company_name;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * post_date;
@property (nonatomic, retain) NSNumber * relocation_assistance;
@property (nonatomic, retain) NSNumber * requires_commuting;
@property (nonatomic, retain) NSString * j_description;
@property (nonatomic, retain) NSString * url;

@end
