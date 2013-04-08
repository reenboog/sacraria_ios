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
@end

TowerPathList GetPathFromTowerToTower(Tower *from, Tower *to, TowerPathList path, TowerList excludedTowers) {
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
                
                TowerPathList thePath = GetPathFromTowerToTower(neighbour, to, path, excludedTowers);
                if(thePath.empty()) {
                    continue;
                } else {
                    return thePath;
                }
            }
        }
    }
    
    return TowerPathList();
}

@implementation Tower

@synthesize descriptor = _descriptor;
@synthesize numOfUnits = _numOfUnits;
@synthesize group = _group;
@synthesize owner = _owner;
@synthesize type = _type;
@synthesize nature = _nature;
@synthesize shieldLevel = _shieldLevel;

@synthesize neighbours = _neighbours;

- (void) dealloc {
    [super dealloc];
}

- (Tower *) init {
    if((self = [super init])) {
        //debug only
        spr = [CCSprite spriteWithFile: @"Icon.png"];
        [self addChild: spr];
        
        label = [CCLabelTTF labelWithString: @"" fontName: @"Arial" fontSize: 20];
        [self addChild: label];
        
        label.position = ccp(40, 40);
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

- (BOOL) sendUnitsToTower: (Tower *) tower {
    
    if(tower == self) {
        return NO;
    }
    
    TowerPathList path;
    TowerList excludedTowers;

    //excludedTowers.push_back(tower);
    
    path = GetPathFromTowerToTower(tower, self, TowerPathList(), excludedTowers);
    
    if(!path.empty()) {
        //get full path to the destination tower
        //apply this path to a game layer
        //we a're looking the backward path (it's faster) from the destination point to the initial one,
        //so we're to reverse the path if found any
        reverse(path.begin(), path.end());
        
        for(int i = 0; i < path.size(); ++i) {
            CCLOG(@"%i", path[i].descriptor);
        }
        //get roads for this path
        
        return YES;
    } else {
        //can't send the unit to the specified point
        return NO;
    }
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
        case 0: spr.color = ccc3(255, 0, 0); break;
        case 1: spr.color = ccc3(0, 255, 0); break;
        case 2: spr.color = ccc3(255, 0, 255); break;
    }
}

@end
