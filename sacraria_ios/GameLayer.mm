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
#import "Troop.h"

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
        self.isTouchEnabled = YES;
        _map = [CCTMXTiledMap tiledMapWithTMXFile: @"tile.tmx"];
        
        [self addChild: _map];
        
        _troopsBatch = [CCLayer node];
        [self addChild: _troopsBatch z: zTroop];
        
        CCTMXObjectGroup *roadsGroup = [_map objectGroupNamed: @"roads"];
        NSMutableArray *roadsObjects = [roadsGroup objects];
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString: @", "];
        
        IntPairsVector roadLinks;

        for(id object in roadsObjects) {
            Road road;
            
            NSString *pointsString = [object valueForKey: @"polylinePoints"];
            
            int baseX = [[object objectForKey: @"x"] intValue];
            int baseY = [[object objectForKey: @"y"] intValue];
            
            int srcTowerDesc = [[object valueForKey: @"srcTower"] intValue];
            int dstTowerDesc = [[object valueForKey: @"dstTower"] intValue];
            
            roadLinks.push_back(make_pair(srcTowerDesc, dstTowerDesc));
            
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
        
        _towers.resize(towersObjects.count);
        vector<IntList> towerNeighbourDescriptors;
        
        towerNeighbourDescriptors.resize(towersObjects.count);
        
        for(id object in towersObjects) {
            //get the name
            NSString *name = [object valueForKey: @"name"];
            int towerIndex = [name intValue];
            
            Tower *tower = [[[Tower alloc] init] autorelease];
            tower.descriptor = towerIndex;
            tower.gameLayer = self;
            
            _towers[towerIndex] = tower;
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
        for(int i = 0; i < _towers.size(); ++i) {
            for(IntList::iterator it = towerNeighbourDescriptors[i].begin(); it != towerNeighbourDescriptors[i].end(); ++it) {
                Tower *neighbour = _towers[*it];
                
                [_towers[i] addNeighbour: neighbour];
            }
        }
        
        //apply roads
        for(int i = 0; i < roadLinks.size(); ++i) {
            _roads[i].src = _towers[roadLinks[i].first];
            _roads[i].dst = _towers[roadLinks[i].second];
        }
        
        //check path finding
        _towers[0].group = 0;
        _towers[1].group = 0;
        _towers[2].group = 0;
        _towers[3].group = 0;
        _towers[4].group = 0;
        _towers[5].group = 0;
        _towers[6].group = 1;
        _towers[7].group = 0;
        _towers[8].group = 0;
        _towers[9].group = 0;
        _towers[10].group = 0;
                
        roadsLayer = [[[RoadsLayer alloc] initWithRoads: _roads] autorelease];
        [self addChild: roadsLayer z: 1000];
        
        [self sendUnits: 10 fromTower: _towers[10] toTower: _towers[0]];
        
        [self scheduleUpdate];

	}
	return self;
}

#pragma mark - update

- (void) update: (ccTime) delta {
    for(CCNode *unit in _troopsBatch.children) {
        unit.zOrder = 768 - unit.position.y;
    }
}

#pragma mark - Game Delegate

- (Road) roadBetweenTower: (Tower *) src andTower: (Tower *) dst {
    //direct links only!
    Road road = {PointVector(), nil, nil};
    for(RoadVector::iterator it = _roads.begin(); it != _roads.end(); ++it) {
        if(it->src == src && it->dst == dst) {
            road = *it;
            break;
        } else if(it->src == dst && it->dst == src) {
            //there's a road in opposite direction, so let's reverse it
            road = *it;
            reverse(road.points.begin(), road.points.end());
            road.src = src;
            road.dst = dst;
            break;
        }
    }
    
    return road;
}

- (void) sendUnitsFromTower: (Tower *) src toTower: (Tower *) dst {
    
    TowerList path = [src pathToTower: dst];
        
    if(!path.empty() && src.numOfUnits > 1) {
        int armySize = src.numOfUnits / 2;
        //loop through all the troops
        int armyIndex = 0;
        int troopSizeForTowerType = TroopSizeForUnitType((UnitType)src.type);
        do {
            
            int troopSize;
            
            if(armySize - troopSizeForTowerType >= 0) {
                troopSize = troopSizeForTowerType;
            } else {
                troopSize = troopSizeForTowerType - armySize;
            }
        
            NSMutableArray *unitWholePathAcitons = [NSMutableArray array];
            
            //so apply this path to a specified unit type
            for(int i = 0; i < path.size() - 1; ++i) {
                Tower *from = path[i];
                Tower *to = path[i + 1];
                Road road = [self roadBetweenTower: from andTower: to];
                
                NSMutableArray *segmentMoveActions = [NSMutableArray array];
                for(int j = 0; j < road.points.size(); ++j) {
                    CCAction *segmentMove = [CCMoveTo actionWithDuration: 0.3 position: road.points[j]];
                    [segmentMoveActions addObject: segmentMove];
                }
                
                CCAction *roadAction = [CCSequence actions:
                                                            [CCSequence actionWithArray: segmentMoveActions],
                                                            [CCCallBlock actionWithBlock:^{
                                                                CCLOG(@"one segment completed.");
                                                            }],
                                                            nil];
                [unitWholePathAcitons addObject: roadAction];
            }
            
            //create the unit and apply these actions
            //CCSprite *unit = [CCSprite spriteWithFile: [NSString stringWithFormat: @"unit%i.png", (int)src.type]];
            //unit.position = src.position;
            //[self addChild: unit z: zUnit];
            
            int units = 10;
            
            Troop *troop = [Troop troopWithType: (UnitType)src.type nature: src.nature andAmount: units];
            troop.position = src.position;
            
            [_troopsBatch addChild: troop];
            
            [troop runAction:
                            [CCSequence actions:
                                                [CCDelayTime actionWithDuration: armyIndex * 0.3],
                                                [CCSequence actionWithArray: unitWholePathAcitons], nil]];
            
            [src sendUnitToTower: dst];
            
            armyIndex++;
            armySize -= troopSize;
        } while(armySize > 0);
    } else {
        CCLOG(@"can't get %i from %i!", src.descriptor, dst.descriptor);
    }
}

#pragma mark - Touches

- (void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan: (UITouch *) touch withEvent: (UIEvent *) event
{
    return YES;
}

- (void) ccTouchMoved: (UITouch *) touch withEvent: (UIEvent *) event
{
    _touchPos = [touch locationInView: [touch view]];
    _touchPos = [[CCDirector sharedDirector] convertToGL: _touchPos];
    _touchPos = [self convertToNodeSpace: _touchPos];

    for(TowerList::iterator it = _towers.begin(); it != _towers.end(); ++it) {
        if(ccpDistance((*it).position, _touchPos) < 100 &&
           std::find(_selectedTowers.begin(), _selectedTowers.end(), *it) == _selectedTowers.end() &&
           (*it).owner == _ownershipId) {
            _selectedTowers.push_back(*it);
            
            roadsLayer.selectedTowers = _selectedTowers;
        }
    }
    
    roadsLayer.touchPos = _touchPos;
}

- (void) ccTouchEnded: (UITouch *) touch withEvent: (UIEvent *) event
{
    _touchPos = [touch locationInView: [touch view]];
    _touchPos = [[CCDirector sharedDirector] convertToGL: _touchPos];
    _touchPos = [self convertToNodeSpace: _touchPos];
    
    CCLOG(@"TOUCH: %i, %i", (int)_touchPos.x, (int)_touchPos.y);
    
    for(TowerList::iterator it = _towers.begin(); it != _towers.end(); ++it) {
        if(ccpDistance((*it).position, _touchPos) < 100) {
            CCLOG(@"CONTAINS!!!!!");
            for(TowerList::iterator selIt = _selectedTowers.begin(); selIt != _selectedTowers.end(); ++selIt) {
                if((*selIt) != (*it)) {
                    [self sendUnitsFromTower: (*selIt) toTower: (*it)];
                }
            }

            break;
        }
    }
    
    _selectedTowers.clear();
    roadsLayer.selectedTowers = _selectedTowers;
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
