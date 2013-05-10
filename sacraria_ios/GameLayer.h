//
//  HelloWorldLayer.h
//  sacraria_ios
//
//  Created by Alex Gievsky on 06.03.13.
//  Copyright spotGames 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "SRWebSocket.h"

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GameConfig.h"

@class RoadsLayer;

// HelloWorldLayer
@interface GameLayer : CCLayer <SRWebSocketDelegate, GameDelegate>
{
    SRWebSocket *_webSocket;
    
    //CCSprite *back;
    CCTMXTiledMap *_map;
    RoadVector _roads;

    TowerList _towers;
    TowerList _selectedTowers;
    //TroopVector _troops;
    
    //required to decide where to move units to start fighting:
    //the side of the 1st fighter or the side of the 2nd one
    BOOL _shouldFightOnFirstTrooperSide;
    
//    CGPoint _touchPos;
//    CGPoint _lastTouchPos;
    
    //CCSpriteBatchNode *_troopsBatch;
    CCLayer *_troopsBatch;
    CCSpriteBatchNode *_obstacles;
    
    int _numOfActiveTouches;
    
    GameType _gameType;
    //a tower to capture in 'capture the base' game mode
    Tower *_towerToCapture;
    
    int _ownershipId;
    
    //debug stuff
    RoadsLayer *roadsLayer;    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
