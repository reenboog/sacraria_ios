//
//  Tower.h
//  sacraria_ios
//
//  Created by Alex Gievsky on 03.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "cocos2d.h"
#import "GameConfig.h"

using namespace std;

@interface Tower : CCNode {
    int _descriptor;
    int _numOfUnits;
    int _group;
    int _owner;
    int _shieldLevel;
    int respawnSpeed;

    TowerType _type;
    NatureType _nature;

    IntList _crystals;
    TowerList _neighbours;
    
    //debug purpose only
    CCSprite *spr;
    CCLabelTTF *label;
    
    //GameDelegate *gameLayer;
}

@property (nonatomic/*, readonly*/) int descriptor;
@property (nonatomic, readonly) int numOfUnits;
@property (nonatomic/*, readonly*/) int group;
@property (nonatomic, readonly) int owner;
@property (nonatomic, readonly) int shieldLevel;

@property (nonatomic, assign) TowerType type;
@property (nonatomic, assign) NatureType nature;

- (void) addNeighbour: (Tower *) neighbour;
- (BOOL) isNeighbour: (Tower *) neighbour;

/*
- (Tower *) initWithDescriptor: (int) descriptor
                         units: (int) units
                         group: (int) group
                         owner: (int) owner
                   shieldLevel: (int) shieldLevel
                          type: (TowerType) type
                    natureType: (NatureType) natureType;
*/

- (void) applyUnits: (int) numOfAttackers
             ofType: (UnitType) attackerType
              group: (int) attackerGroup
             nature: (NatureType) attackerNature
          fromOwner: (int) owner;

- (BOOL) sendUnitsToTower: (Tower *) tower;

- (void) addCrystal: (int) crystal;

@end