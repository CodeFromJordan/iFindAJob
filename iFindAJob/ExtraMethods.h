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
+(NSMutableArray*)getShareButton:(BOOL)getSB getSettingsButton:(BOOL)gSB;
+(void)showErrorMessageWithTitle:(NSString*)title andMessage:(NSString*)message;
@end
