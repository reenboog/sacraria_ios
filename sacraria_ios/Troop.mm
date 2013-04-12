//
//  Unit.m
//  sacraria_ios
//
//  Created by Alex Gievsky on 08.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "Troop.h"

@implementation Troop

@synthesize health = _health;
@synthesize numOfUnits = _numOfUnits;
@synthesize nature = _nature;
@synthesize type = _type;

+ (Troop *) troopWithType: (UnitType) type nature: (NatureType) nature andAmount: (int) units {
    return [[[self alloc] initWithType: type nature: nature andAmount: units] autorelease];
}

- (Troop *) initWithType: (UnitType) type nature: (NatureType) nature andAmount: (int) units {
    
    if((self = [super init])) {
        _type = type;
        _nature = nature;
        _numOfUnits = units;
        _health = HealthForUnitTypeOfNature(type, nature);
        
        _spr = [CCSprite spriteWithFile: [NSString stringWithFormat: @"unit%i.png", (int)type]];
        [self addChild: _spr];
    }
    
    return self;
}

@end
