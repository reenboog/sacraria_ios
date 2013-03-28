//
//  APIClient.m
//  sacraria_ios
//
//  Created by Alex Gievsky on 06.03.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "APIClient.h"
#import "AFJSONRequestOperation.h"
#import "Settings.h"

#import "GameConfig.h"

//static NSString * const kAPIClientBaseURLString = @"http://rainbow:8097/";
static APIClient *SharedClient = nil;

//required to mark the impossibility to reconnect to the server
//and send kFailedToConnectNotification
static NSInteger NumOfReconnections = 0;
static NSInteger NumOfUnrespondedPings = 0;

@interface APIClient (Ping) {
}

- (void) stopPinging;
- (void) ping: (NSTimer *) timer;
- (void) startPinging;

- (void) checkPingResponse: (NSString *) response;

@end

@implementation APIClient

+ (APIClient *) sharedClient {
    if(!SharedClient) {
        
        Settings *settings = [Settings sharedSettings];
        [settings load];
        
        NSString *baseURL = [settings.appHosts objectAtIndex: random() % [settings.appHosts count]];
        
        [settings swapAppHosts];
        
        SharedClient = [[APIClient alloc] initWithBaseURL: [NSURL URLWithString: baseURL]];
    }
    
    return SharedClient;
}

- (void) dealloc {
    [self stopPinging];
    
    [super dealloc];
}

- (id) initWithBaseURL: (NSURL *) url {
    self = [super initWithBaseURL: url];
    
    if(!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass: [AFJSONRequestOperation class]];
    
	[self setDefaultHeader: @"Accept" value: @"application/json"];
    [self setParameterEncoding: AFJSONParameterEncoding];
    
    return self;
}

- (void) signup {
    Settings *settings = [Settings sharedSettings];
    
    [self putPath: @"login/"
       parameters: nil
          success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
              
              NSString *userID = [responseObject objectForKey: @"id"];
              NSString *userUUID = [responseObject objectForKey: @"uuid"];
              
              settings.userID = userID;
              settings.userUUID = userUUID;
              
              [settings save];
              
              NSLog(@"Signed up.");
              
              [GameConfig sharedConfig].gameState = GS_signedup;
              
              [[NSNotificationCenter defaultCenter] postNotificationName: kSignedUpNotification
                                                                  object: nil
                                                                userInfo: nil];
              
              //don't login automatically
              //[self login];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              //show error
              NSLog(@"error: %@", error.localizedDescription);

              [GameConfig sharedConfig].gameState = GS_idle;
              
              [[NSNotificationCenter defaultCenter] postNotificationName: kFailedToSignUpNotificatin
                                                                  object: nil
                                                                userInfo: nil];
          }];

}

- (void) login {
    NSLog(@"Trying to login.");
    
    if(_pingTimer) {
        [self stopPinging];
    }
    
    Settings *settings = [Settings sharedSettings];
    if(!settings.userID) {
        
        NSLog(@"You're not signed up. Trying to sign up.");
        
        [GameConfig sharedConfig].gameState = GS_signingup;

        [self signup];
    }
    else {
        //just login
        [GameConfig sharedConfig].gameState = GS_loggingin;
        
        [self getPath: @"login/"
           parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                            settings.userID, @"user_id",
                            settings.userUUID, @"user_uuid", nil]
              success:
                    ^(AFHTTPRequestOperation *operation,
                              NSDictionary *responseObject) {
                        NSArray *newHosts = [responseObject objectForKey: @"hosts"];
                        
                        if(newHosts) {
                            settings.appHosts = [NSMutableArray arrayWithArray: newHosts];
                            [settings save];
                        }
                        
                        NSString *response = [responseObject objectForKey: @"response"];
                        NSLog(@"Logged in. Response: %@", response);
                        
                        //we're in normal mode now, so forget about previous failed attempts to connect
                        NumOfReconnections = 0;
                        NumOfUnrespondedPings = 0;
                        
                        //validate the response first
                        [self startPinging];
                        
                        [GameConfig sharedConfig].gameState = GS_loggedin;
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName: kLoggedInNotification
                                                                            object: nil
                                                                          userInfo: nil];
                        
                    }
              failure:
                    ^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Couldn't login. Error: %@", error.localizedDescription);
                        
                        [GameConfig sharedConfig].gameState = GS_idle;
                        
                        //should we reconnect?
                        //[self reconnect];
                        
                        //should we reconnect when reachability status changes?
//                        [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//                            NSLog(@"reachability status changed: %i", status);
//                            
//                            if(status != AFNetworkReachabilityStatusNotReachable) {
//                                //[self reconnect];
//                                //just broadcast that we're fine now
//                                [[NSNotificationCenter defaultCenter] postNotificationName: kNetworkConnectionRestored
//                                                                                    object: nil];
//                            }
//                            
//                        }];
                        
                        //it's better to try reconnecting permanently
                        [[NSNotificationCenter defaultCenter] postNotificationName: kFailedToLogInNotification
                                                                            object: nil
                                                                          userInfo: nil];
                    }
        ];
    }
}

- (APIClient *) reconnect {
    
    //don't track reachability now
    [self setReachabilityStatusChangeBlock: nil];
    
    NumOfReconnections++;

    [GameConfig sharedConfig].gameState = GS_idle;
    
    [SharedClient autorelease];
    SharedClient = nil;
    
    [self stopPinging];
    
    //should we try to reconnect permanently unitll succeeded?
    //if(NumOfReconnections == kMaxNumOfReconnections) {
    //    [[NSNotificationCenter defaultCenter] postNotificationName: kFailedToConnectNotification
    //                                                        object: nil
    //                                                      userInfo: nil];
    //    return nil;
    //} else
    //let;s just reconnect permanently
    {
        APIClient *apiClient = [APIClient sharedClient];
        [apiClient login];
        
        return apiClient;
    }
}

@end

@implementation APIClient (Ping)

- (void) stopPinging {
    if(_pingTimer) {
        [_pingTimer invalidate];
        _pingTimer = nil;
        
        [self cancelAllHTTPOperationsWithMethod: @"GET" path: @"ping/"];
    }
}

- (void) ping: (NSTimer *) timer {
    Settings *settings = [Settings sharedSettings];
    
    [self getPath: @"ping/"
       parameters: [NSDictionary dictionaryWithObjectsAndKeys:
                        settings.userID, @"user_id",
                        settings.userUUID, @"user_uuid", nil]
          success:
                ^(AFHTTPRequestOperation *operation,
                          NSDictionary *responseObject) {
                    
                    
                    //should we compare with 'ok'?
                    NSString *response = [responseObject objectForKey: @"response"];
                    [self checkPingResponse: response];
                }
          failure:
                ^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Didn't receive ping response. Error: %@", error.localizedDescription);
                    
                    //which self is used here?
                    [self checkPingResponse: nil];
                }
    ];
}

- (void) startPinging {
    [self stopPinging];
    
    _pingTimer = [NSTimer scheduledTimerWithTimeInterval: kPingTimeInterval
                                                  target: self
                                                selector: @selector(ping:)
                                                userInfo: nil
                                                 repeats: YES];
                
}

- (void) checkPingResponse: (NSString *) response {
    if(response && [response isEqualToString: kNormalPingResponse]) {
        NSLog(@"Ok. Keep working. Ping response: %@", response);
        
        NumOfUnrespondedPings = 0;
    } else {
        NumOfUnrespondedPings++;
        
        if(NumOfUnrespondedPings == kMaxNumOfUnrespondedPings) {
            //don't reconnect automatically
            //should we stop pinging?
            [self stopPinging];
            //[self reconnect];
            [[NSNotificationCenter defaultCenter] postNotificationName: kPingLostNotification
                                                                object: nil];
        }
    }
}

@end
