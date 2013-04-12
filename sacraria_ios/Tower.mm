//
//  Tower.m
//  sacraria_ios
//
//  Created by Alex Gievsky on 03.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "Tower.h"

@interface Tower ()

@property (nonatomic, readonly) const TowerList &neighbours;
@property (nonatomic, readwrite) int numOfUnits;
@end

TowerList GetPathFromTowerToTower(Tower *from, Tower *to, TowerList path, TowerList excludedTowers) {
    path.push_back(from);

    //never return any containers as a property:
    //its copy is returned, not the container itself
    //let's just return a const reference for a while
    TowerList::const_iterator itEnd = from.neighbours.end();
    for(TowerList::const_iterator it = from.neighbours.begin(); it != itEnd; ++it) {
        Tower *neighbour = *it;
        
        if(neighbour == to) {
            path.push_back(neighbour);
            return path;
        } else {
            
            BOOL isThisNeighbourExcluded = NO;
            
            TowerList::iterator excItEnd = excludedTowers.end();
            for(TowerList::iterator excIt = excludedTowers.begin(); excIt != excItEnd;++excIt) {
                Tower *excludedNeighbour = *excIt;
                if(neighbour == excludedNeighbour) {
                    isThisNeighbourExcluded = YES;
                    break;
                }
            }
            
            if(!isThisNeighbourExcluded && neighbour.group == to.group) {
                excludedTowers.push_back(from);
                
                TowerList thePath = GetPathFromTowerToTower(neighbour, to, path, excludedTowers);
                if(thePath.empty()) {
                    continue;
                } else {
                    return thePath;
                }
            }
        }
    }
    
    return TowerList();
}

@implementation Tower

@synthesize descriptor = _descriptor;
@synthesize numOfUnits = _numOfUnits;
@synthesize group = _group;
@synthesize owner = _owner;
@synthesize type = _type;
@synthesize nature = _nature;
@synthesize shieldLevel = _shieldLevel;
@synthesize gameLayer = _gameLayer;

@synthesize neighbours = _neighbours;

- (void) dealloc {
    [super dealloc];
}

- (Tower *) init {
    if((self = [super init])) {
        
        _numOfUnits = 30;
        //debug only
        _spr = [CCSprite spriteWithFile: @"Icon.png"];
        [self addChild: _spr];
        
        label = [CCLabelTTF labelWithString: @"" fontName: @"Arial" fontSize: 20];
        label.position = ccp(40, 40);
        [self addChild: label];
        
        unitsLabel = [CCLabelTTF labelWithString: @"" fontName: @"Arial" fontSize: 20];
        unitsLabel.position = ccp(40, -40);
        [self addChild: unitsLabel];
        
        typeLabel = [CCLabelTTF labelWithString: @"" fontName: @"Arial" fontSize: 20];
        typeLabel.position = ccp(-40, -40);
        [self addChild: typeLabel];
        
        [self setContentSize: CGSizeMake(100, 100)];
        
        //let's just use default time for now
        [self schedule: @selector(spawnUnits:) interval: 1];
        //
    }
    
    return self;
}

- (void) addNeighbour: (Tower *) neighbour {
    if(find(_neighbours.begin(), _neighbours.end(), neighbour) == _neighbours.end()) {
        _neighbours.push_back(neighbour);
    }
}

- (BOOL) isNeighbour: (Tower *) neighbour {
    return find(_neighbours.begin(), _neighbours.end(), neighbour) == _neighbours.end();
}

- (void) applyUnits: (int) numOfAttackers
             ofType: (UnitType) attackerType
              group: (int) attackerGroup
             nature: (NatureType) attackerNature
          fromOwner: (int) owner {
    int groupMultiplier = (_group == attackerGroup);
    
    //all the balance goes here
    //get the nature multiplier first
    float natureMultiplier = MultiplierForNatures(attackerNature, _nature);
    //keep in mind the difference between unit weights
    float unitTypeMultiplier = MultiplierForTowerAndUnit(_type, attackerType);
    
    _numOfUnits += groupMultiplier * natureMultiplier * unitTypeMultiplier * numOfAttackers;
    
    if(_numOfUnits < 0) {
        //change the owner
        _numOfUnits *= -1;
        
        _owner = owner;
        _group = attackerGroup;
        //
        {
            //should we keep the previous nature?
            _nature = attackerNature;
            //should we keep the previous tower type?
            _type = (TowerType)attackerType;
            
            
            //so, we should recalculate the respawn speed
        }
        //apply new changes visually
    }
}

- (TowerList) pathToTower: (Tower *) tower {
    
    TowerList path;
    TowerList excludedTowers;

    if(tower != self) {
        path = GetPathFromTowerToTower(tower, self, TowerList(), excludedTowers);
        
        reverse(path.begin(), path.end());
    }

    return path;
}

- (void) sendUnitToTower: (Tower *) tower {
    self.numOfUnits = _numOfUnits / 2;
    
    //blahblah
}

- (void) addCrystal: (int) crystal {
    
}

//debug only
- (void) setDescriptor:(int)descriptor {
    _descriptor = descriptor;
    label.string = [NSString stringWithFormat: @"%i", descriptor];
}
//

- (void) setGroup:(int)group {
    _group = group;
    switch(group) {
        case 0: _spr.color = ccc3(255, 0, 0); break;
        case 1: _spr.color = ccc3(0, 255, 0); break;
        case 2: _spr.color = ccc3(255, 0, 255); break;
    }
}

- (void) spawnUnits: (ccTime) dt {
    
    self.numOfUnits = _numOfUnits + 1;
}

- (void) setNumOfUnits: (int) numOfUnits {
    _numOfUnits = MAX(1, numOfUnits);
    unitsLabel.string = [NSString stringWithFormat: @"%i", _numOfUnits];
}

@end
