//
//  ExtraMethods.h
//  iFindAJob
//
//  Created by Jordan Hancock on 18/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExtraMethods : NSObject
+(UIColor*)getColorFromHexString:(NSString*)hex;
//+(NSArray*)getNavigationBarButtonArray;
+(NSMutableArray*)getShareButton:(BOOL)getSB getDatasourcesButton:(BOOL)gDsB;
@end