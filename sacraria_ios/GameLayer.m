//
//  HelloWorldLayer.m
//  sacraria_ios
//
//  Created by Alex Gievsky on 06.03.13.
//  Copyright spotGames 2013. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"
#import "GameConfig.h"

#import "ConnectionLayer.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "Settings.h"

#import "APIClient.h"
#import <CommonCrypto/CommonDigest.h>

#define kSalt @"adlfu3489tyh2jnkLIUGI&%EV(&0982cbgrykxjnk8855"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@interface GameLayer (APINotifications)

//- (void) onLoggedIn;
//- (void) onFailedToLogIn;
//
//- (void) onSignedUp;
//- (void) onFailedToSignUp;

- (void) onPingLost;
//- (void) onFailedToConnect;

//- (void) onNetworkConnectionRestored;

@end


@implementation GameLayer

//-(NSString*)UUIDString {
//    CFUUIDRef theUUID = CFUUIDCreate(NULL);
//    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
//    CFRelease(theUUID);
//    return (NSString *)string;
//}

- (void) test {    

        
        //[ar addObject: hashedStr];
}

+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
    
	[super dealloc];
}

-(id) init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if((self = [super init])) {
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"The game" fontName:@"Marker Felt" fontSize:64];

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
		
		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString: @"test" target: self selector: @selector(test)];
		CCMenu *menu = [CCMenu menuWithItems: itemLeaderboard, nil];
		
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp( size.width/2, size.height/2 - 50)];
		
		// Add the menu to the layer
		[self addChild:menu];
        
        //subscribe for connection notifications
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onPingLost)
                                                     name: kPingLostNotification
                                                   object: nil];
        
        //
        
        [self test];

	}
	return self;
}

@end

@implementation GameLayer (APINotifications)

- (void) onPingLost {
    //the ping is lost, so let's reconnect
    //free all the resources maybe
    [[CCDirector sharedDirector] pushScene: [ConnectionLayer scene]];
}

@end