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

#import <CommonCrypto/CommonDigest.h>

#define kSalt @"adlfu3489tyh2jnkLIUGI&%EV(&0982cbgrykxjnk8855"

#pragma mark - HelloWorldLayer

@implementation GameLayer

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
	//[[NSNotificationCenter defaultCenter] removeObserver: self];
    
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
        
        [self reconnect];

	}
	return self;
}

#pragma mark - Websocket stuff

- (void) reconnect
{
    _webSocket.delegate = nil;
    [_webSocket close];
    [_webSocket release];
    
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:
                                                          [NSURL URLWithString:@"ws://169.254.19.146:8080/websocket/"]]];
    _webSocket.delegate = self;
    
    CCLOG(@"oppening connection");
    [_webSocket open];
}

#pragma mark SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    CCLOG(@"Websocket Connected");
    
    //test transmition
    //----------------------------------------------------------------------
    [_webSocket send: @"hi"];
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    CCLOG(@"Websocket Failed With Error %@", error);
    
    [_webSocket release];
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    CCLOG(@"Received \"%@\"", message);
    //----------------------------------------------------------------------
    //parse test message
    NSError* error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: message //1
                                                         options: kNilOptions
                                                           error: &error];
    
    NSDictionary *data = [json objectForKey: @"data"];
    
    NSString *name = [data objectForKey: @"name"];
    NSNumber *age = [data objectForKey: @"age"];
    NSArray *nums = [data objectForKey: @"nums"];
    
    CCLOG(@"name is %@", name);
    CCLOG(@"age is %i", [age intValue]);
    for(NSNumber *num in nums)
    {
        CCLOG(@"subnum is %i", [num intValue]);
    }
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    CCLOG(@"WebSocket closed");
    [_webSocket release];
    _webSocket = nil;
}

@end
