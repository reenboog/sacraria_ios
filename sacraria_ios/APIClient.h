//
//  APIClient.h
//  sacraria_ios
//
//  Created by Alex Gievsky on 06.03.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AFHTTPClient.h"

@interface APIClient : AFHTTPClient
{
    NSTimer *_pingTimer;
}

+ (APIClient *) sharedClient;

- (void) signup;
- (void) login;

- (APIClient *) reconnect;

//- (void) ping;

@end
