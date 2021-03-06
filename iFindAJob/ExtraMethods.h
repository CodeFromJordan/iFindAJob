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
+(void)showErrorMessageWithTitle:(NSString*)title andMessage:(NSString*)message;
+(BOOL) connectedToInternet;
@end
