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

    NatureType _nature;
    UnitType _type;
    
    CCSprite *_spr;
    
    TowerPathVector path;
}

@property (nonatomic, readonly) int health;
@property (nonatomic, readonly) int numOfUnits;
@property (nonatomic, readonly) NatureType nature;
@property (nonatomic, readonly) UnitType type;

+ (Troop *) troopWithType: (UnitType) type nature: (NatureType) nature andAmount: (int) units;
- (Troop *) initWithType: (UnitType) type nature: (NatureType) nature andAmount: (int) units;

@end
