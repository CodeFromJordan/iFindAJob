//
//  ServiceDelegate.h
//  iFindAJob
//
//  Created by Jordan Hancock on 20/11/2013.
//  Copyright (c) 2013 Jordan Hancock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServiceDelegate <NSObject>

- (void)serviceFinished:(id)service withError:(BOOL)error;

@end
