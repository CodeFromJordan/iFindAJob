//
//  ExtraMethods.m
//  iFindAJob
//
//  Created by Jordan Hancock on 18/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import "ExtraMethods.h"

@implementation ExtraMethods
+(UIColor*)getColorFromHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

//+(NSArray*)getNavigationBarButtonArray {
    // Buttons
    //UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //UIBarButtonItem* datasourcesButton = [[UIBarButtonItem alloc] initWithTitle:@"Data Sources" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //NSArray *buttonArray = [[NSArray alloc] initWithObjects: shareButton, datasourcesButton, nil];
    
    //return buttonArray;
//}

+(NSMutableArray*)getShareButton:(BOOL)getSB getDatasourcesButton:(BOOL)gDsB {
    
    NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
    
    if(getSB) { // If share button parameter passed
        UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:nil action:nil]; // Create the button
        
        [buttonArray addObject:shareButton]; // Add it to the array
    }
    
    if(gDsB) { // If datasources button parameter passed
        UIBarButtonItem* datasourcesButton = [[UIBarButtonItem alloc] initWithTitle:@"Data Sources" style:UIBarButtonItemStylePlain target:nil action:nil]; // Create the button
        
        [buttonArray addObject:datasourcesButton]; // Add it to the array
    }
    
    return buttonArray;
}

@end
