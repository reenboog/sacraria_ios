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
    TroopVector _troops;
    
    CGPoint _touchPos;
    
    //CCSpriteBatchNode *_troopsBatch;
    CCLayer *_troopsBatch;
    
    int _ownershipId;
    
    //debug stuff
    RoadsLayer *roadsLayer;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
