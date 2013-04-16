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

@interface  GameLayer ()

- (void) onGameOver;
- (Road) roadBetweenTower: (Tower *) src andTower: (Tower *) dst;
- (void) sendUnitsFromTower: (Tower *) src toTower: (Tower *) dst;
- (void) checkIfAnyoneWantsToFight;


@end

@implementation GameLayer

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
        
        _towerToCapture = nil;
        
        _map = [CCTMXTiledMap tiledMapWithTMXFile: @"tile.tmx"];
        
        [self addChild: _map];
        
        _troopsBatch = [CCLayer node];
        [self addChild: _troopsBatch z: zTroop];
        
        CCTMXObjectGroup *roadsGroup = [_map objectGroupNamed: @"roads"];
        NSMutableArray *roadsObjects = [roadsGroup objects];
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString: @", "];
        
        _gameType = GT_KillAll;
        
        NSString *gameTypeStr = [_map.properties objectForKey: @"gameType"];
        if(gameTypeStr) {
            if([gameTypeStr isEqualToString: @"kilAll"]) {
                _gameType = GT_KillAll;
            } else if([gameTypeStr isEqualToString: @"captureBase"]) {
                _gameType = GT_CaptureBase;
            }
        }
        
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
            //TODO: does tower need a gameDelegate at all?
            tower.gameLayer = self;
            //
            
            _towers[towerIndex] = tower;
            //TODO: what about a separate layer for towers?
            [self addChild: tower z: zTower];
            
            int towerX = [[object objectForKey: @"x"] intValue];
            int towerY = [[object objectForKey: @"y"] intValue];
            
            tower.position = ccp(towerX, towerY);
            
            NSString *neighboursStr = [object valueForKey: @"neighbours"];
            NSArray *neighbourArray = [neighboursStr componentsSeparatedByCharactersInSet: characterSet];
            
            for(id neighbour in neighbourArray) {
                towerNeighbourDescriptors[towerIndex].push_back([neighbour intValue]);
            }
            
            if([object valueForKey: @"isTowerToCapture"]) {
                _towerToCapture = tower;
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
        
        //TODO: apply groups ownership and so on
        
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
        
        [self sendUnitsFromTower: _towers[10] toTower: _towers[0]];
        
        [self scheduleUpdate];

	}
	return self;
}

#pragma mark - update

- (void) update: (ccTime) delta {
    for(Troop *troop in _troopsBatch.children) {
        troop.zOrder = 768 - troop.position.y;
        
        if(troop.state == TS_Walking) {
            
            BOOL applyFade = NO;
        
            for(int i = 0; i < _towers.size(); ++i) {
                Tower *tower = _towers[i];
                
                if(ccpDistance(troop.position, tower.position) < 25) {
                    applyFade = YES;
                    break;
                }
            }
            
            if(applyFade) {
                [troop fade];
            } else {
                [troop unfade];
            }
        }
    }
    
    [self checkIfAnyoneWantsToFight];
}

- (void) checkIfGameOver {
    switch (_gameType) {
        case GT_CaptureBase:
            if(_towerToCapture.owner != kOwnerNoOne) {
                [self onGameOver];
            }
            break;
        case GT_KillAll:
            //just check whether all the towers have the same group
            for(TowerList::iterator it = _towers.begin(); it != _towers.end(); ++it) {
                if((*it).group != _towers[0].group) {
                    break;
                }
            }
            [self onGameOver];
    }
}

- (void) checkIfAnyoneWantsToFight {
    
    static int i1 = 0;
    
    if(i1 > 0) {
        return;
    }
    
    CCArray *troops = _troopsBatch.children;
    int troopsCount = troops.count;
    
    for(int i = 0; i < troopsCount; ++i) {
        for(int j = 0; j < troopsCount; ++j) {
            
            Troop *leftTroop = [troops objectAtIndex: i];
            Troop *rightTroop = [troops objectAtIndex: j];
            if(leftTroop == rightTroop) {
                continue;
            }
            
            if(leftTroop.state == TS_Walking && rightTroop.state == TS_Walking && leftTroop.group != rightTroop.group &&
               ccpDistance(leftTroop.position, rightTroop.position) < kFightMinimalDistance) {
                //start fighting
                if(_shouldFightOnFirstTrooperSide) {
                    [leftTroop attackTroop: rightTroop];
                } else {
                    [rightTroop attackTroop: leftTroop];
                }
                i1++;
                //change the initial fighetr side
                _shouldFightOnFirstTrooperSide = !_shouldFightOnFirstTrooperSide;
            }
        }
    }
}

- (void) onGameOver {
    CCLOG(@"GameOver");
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
    
    TowerList keyTowers = [src pathToTower: dst];
    
    if(!keyTowers.empty() && src.numOfUnits > 0) {
        
        //prepare the path
        TowerPathVector path;
        
        for(int i = 0; i < keyTowers.size() - 1; ++i) {
            Tower *from = keyTowers[i];
            Tower *to = keyTowers[i + 1];
            
            Road road = [self roadBetweenTower: from andTower: to];
            
            path.push_back(make_pair(road.points, to));
        }
        
        //1 unit to send as a minimum
        int armySize = MAX(1, src.numOfUnits / 2);

        int armyIndex = 0;
        int troopSizeForTowerType = TroopSizeForUnitType((UnitType)src.type, src.nature);
        do {
            
            int troopSize = troopSizeForTowerType;
            
            if(armySize - troopSizeForTowerType < 0) {
                troopSize = troopSizeForTowerType - armySize;;
            }
            
            Troop *troop = [Troop troopWithType: (UnitType)src.type owner: src.owner tower: src group: src.group nature: src.nature amount: troopSize path: path];
            troop.position = src.position;
            [troop goAfterDelay: armyIndex * kArmyAttackDelay];
            
            [_troopsBatch addChild: troop];
            
            armyIndex++;
            armySize -= troopSize;
        } while(armySize > 0);
        
        [src sendTroops];
    } else {
        CCLOG(@"can't send units from %i to %i! not enough units", src.descriptor, dst.descriptor);
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
