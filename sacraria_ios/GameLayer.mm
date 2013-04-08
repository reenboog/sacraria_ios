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

#import "RoadsLayer.h"
#import "Tower.h"

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
	if((self = [super init])) {
        _map = [CCTMXTiledMap tiledMapWithTMXFile: @"tile.tmx"];
        
        [self addChild: _map];
        
        CCTMXObjectGroup *roadsGroup = [_map objectGroupNamed: @"roads"];
        NSMutableArray *roadsObjects = [roadsGroup objects];
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString: @", "];

        for(id object in roadsObjects) {
            Road road;
            
            NSString *pointsString = [object valueForKey: @"polylinePoints"];
            
            int baseX = [[object objectForKey: @"x"] intValue];
            int baseY = [[object objectForKey: @"y"] intValue];
            
            if(pointsString != NULL) {
                NSArray *pointsArray = [pointsString componentsSeparatedByCharactersInSet:characterSet];
                
                int n = pointsArray.count;
                
                for(int i = 0; i < n; i += 2) {
                    int x = [[pointsArray objectAtIndex: i] intValue];
                    int y = [[pointsArray objectAtIndex: i + 1] intValue];

                    road.points.push_back(ccp(x + baseX, (-1 * y) + baseY));
                }
            }
            
            _roads.push_back(road);
        }
        
        //get towers
        CCTMXObjectGroup *towersGroup = [_map objectGroupNamed: @"towers"];
        NSMutableArray *towersObjects = [towersGroup objects];
        
        towers.resize(towersObjects.count);
        vector<IntList> towerNeighbourDescriptors;
        
        towerNeighbourDescriptors.resize(towersObjects.count);
        
        for(id object in towersObjects) {
            //get the name
            NSString *name = [object valueForKey: @"name"];
            int towerIndex = [name intValue];
            
            Tower *tower = [[[Tower alloc] init] autorelease];
            tower.descriptor = towerIndex;
            
            towers[towerIndex] = tower;
            [self addChild: tower z: zTower];
            
            int towerX = [[object objectForKey: @"x"] intValue];
            int towerY = [[object objectForKey: @"y"] intValue];
            
            tower.position = ccp(towerX, towerY);
            
            NSString *neighboursStr = [object valueForKey: @"neighbours"];
            NSArray *neighbourArray = [neighboursStr componentsSeparatedByCharactersInSet: characterSet];
            
            for(id neighbour in neighbourArray) {
                towerNeighbourDescriptors[towerIndex].push_back([neighbour intValue]);
            }
            
            //CCLOG(@"name: %@", name);
        }
        
        //apply neighbours
        for(int i = 0; i < towers.size(); ++i) {
            for(IntList::iterator it = towerNeighbourDescriptors[i].begin(); it != towerNeighbourDescriptors[i].end(); ++it) {
                Tower *neighbour = towers[*it];
                
                [towers[i] addNeighbour: neighbour];
            }
        }
        
        //check path finding
        towers[0].group = 0;
        towers[1].group = 0;
        towers[2].group = 2;
        towers[3].group = 1;
        towers[4].group = 0;
        towers[6].group = 0;
        towers[7].group = 1;
        
        if([towers[10] sendUnitsToTower: towers[6]]) {
            CCLOG(@"ok!");
        }
        
        RoadsLayer *roadsLayer = [[[RoadsLayer alloc] initWithRoads: _roads] autorelease];
        [self addChild: roadsLayer z: 1000];
		      
        //[self reconnect];

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
                                                          [NSURL URLWithString:@"ws://localhost:8080/websocket/"]]];
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
