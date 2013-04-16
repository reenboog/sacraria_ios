//
//  Unit.h
//  sacraria_ios
//
//  Created by Alex Gievsky on 08.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "cocos2d.h"
#import "GameConfig.h"

//shouldn't we inheriate from CCSPrite to use batch nodes?
@interface Troop : CCNode {
    int _health;
    int _numOfUnits;
    int _owner;
    int _group;
    Tower *_tower;

    NatureType _nature;
    UnitType _type;

    TroopState _state;
    
    CCSprite *_spr;
    
    TowerPathVector _path;
}

@property (nonatomic, readonly) int health;
@property (nonatomic, readonly) int numOfUnits;
@property (nonatomic, readonly) NatureType nature;
@property (nonatomic, readonly) UnitType type;
@property (nonatomic, readonly) int owner;
@property (nonatomic ,readonly) int group;

@property (nonatomic, readonly) Tower *tower;

@property (nonatomic, readonly) TroopState state;

//@property (nonatomic, assign) TowerPathVector path;

+ (Troop *) troopWithType: (UnitType) type
                    owner: (int) owner
                    tower: (Tower *) tower
                    group: (int) group
                   nature: (NatureType) nature
                   amount: (int) units
                     path: (TowerPathVector) path;

- (Troop *) initWithType: (UnitType) type
                   owner: (int) owner
                   tower: (Tower *) tower
                   group: (int) group
                  nature: (NatureType) nature
                  amount: (int) units
                    path: (TowerPathVector) path;

- (void) goAfterDelay: (float) delay;
- (void) go;

- (void) fade;
- (void) unfade;

- (void) attackTroop: (Troop *) troop;
- (void) moveToPoint: (CGPoint) pt;

@end