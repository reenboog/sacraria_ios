//
//  ConnectionLayer.m
//  sacraria_ios
//
//  Created by Alex Gievsky on 25.03.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "ConnectionLayer.h"
#import "GameLayer.h"
#import "GameConfig.h"
#import "AFJSONRequestOperation.h"
#import "Settings.h"

@implementation UpdateManager

+ (void) checkStatus {
    NSString *urlStr = [NSString stringWithFormat: @"%@/login/?client_version=%i&asset_package_id=%i",
                        [GameConfig sharedConfig].host, kVersion, [Settings sharedSettings].assetPackageId];

    NSURL *url = [NSURL URLWithString: urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    id successBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        int status = response.statusCode;
        
        switch(status) {
            case kUpdateRequired:
                //update
                CCLOG(@"Update required");
                
                break;
            case kNewAssetsRequired:
                CCLOG(@"Downloading files...");
                [self updateAssets];
                break;
            case kNormalServerStatus:
                CCLOG(@"Normal status");
                break;
            default:
                break;
        }
    };
    
    id failureBlock = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //show alert and try to reconnect to a next host
        [[GameConfig sharedConfig] pickUpAHost];
        CCLOG(@"ERROR!");
    };
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest: request
                                                                                 success: successBlock
                                                                                 failure: failureBlock];
    [op start];
}

+ (void) updateAssets {
    
}

@end

@interface ConnectionLayer (APINotifications)

- (void) onLoggedIn;
- (void) onFailedToLogIn;

- (void) onSignedUp;
- (void) onFailedToSignUp;

- (void) onPingLost;
//- (void) onFailedToConnect;

- (void) onNetworkConnectionRestored;

@end

@implementation ConnectionLayer

+ (id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ConnectionLayer *layer = [ConnectionLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    CCLOG(@"dealloc of connection layer.");
    
    [super dealloc];
}

// on "init" you need to initialize your instance
- (id) init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if((self = [super init])) {
        statusLabel = [CCLabelTTF labelWithString: @"Connecting" fontName: @"Marker Felt" fontSize: 30];
        statusLabel.position = ccp(240, 160);
        
        [self addChild: statusLabel];
        
        //subscribe for connection notifications
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onSignedUp)
                                                     name: kSignedUpNotification
                                                   object: nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onFailedToSignUp)
                                                     name: kFailedToSignUpNotificatin
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onLoggedIn)
                                                     name: kLoggedInNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onFailedToLogIn)
                                                     name: kFailedToLogInNotification
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onPingLost)
                                                     name: kPingLostNotification
                                                   object: nil];
        
        //[[NSNotificationCenter defaultCenter] addObserver: self
        //                                         selector: @selector(onFailedToConnect)
        //                                             name: kFailedToConnectNotification
        //                                           object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onNetworkConnectionRestored)
                                                     name: kNetworkConnectionRestored
                                                   object: nil];
        
        //
        //[[APIClient sharedClient] login];
        
    }
    
    return self;
}

@end

#pragma mark - Networking stuff

@implementation ConnectionLayer (APINotifications)

- (void) onLoggedIn {
    //just load the game scene
    statusLabel.string = @"Logged in";
    
    [self runAction:
                    [CCSequence actions:
                                        [CCDelayTime actionWithDuration: 0.5],
                                        [CCCallBlock actionWithBlock:^{
                                            [[CCDirector sharedDirector] replaceScene: [GameLayer scene]];
                                        }],
                                        nil]];
}

- (void) onFailedToLogIn {
    statusLabel.string = @"Failed to log in";
    
    //[[APIClient sharedClient] reconnect];
}

- (void) onSignedUp {
    statusLabel.string = @"Signed up";
    
    //we've just signed up, so let's login
//    [self runAction:
//                    [CCSequence actions:
//                                        [CCDelayTime actionWithDuration: 0.5],
//                                        [CCCallBlock actionWithBlock:^{
//                                            [[APIClient sharedClient] login];
//                                        }],
//                                        nil]];
}

- (void) onFailedToSignUp {
    statusLabel.string = @"Failed to sign up";
    
    //[[APIClient sharedClient] reconnect];
}

- (void) onPingLost {
    //the ping is lost, so let's reconnect
    //[[APIClient sharedClient] reconnect];
}

//- (void) onFailedToConnect {
//    statusLabel.string = @"Connection lost";
//}

- (void) onNetworkConnectionRestored {
    //[[APIClient sharedClient] reconnect];
}

@end