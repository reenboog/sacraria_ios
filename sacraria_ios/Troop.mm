//
//  Unit.m
//  sacraria_ios
//
//  Created by Alex Gievsky on 08.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "Troop.h"
#import "Tower.h"

@interface Troop ()

- (void) done;
//- (void) onControlTowerReached: (Tower *) tower;

@end

@implementation Troop

@synthesize health = _health;
@synthesize numOfUnits = _numOfUnits;
@synthesize nature = _nature;
@synthesize type = _type;
@synthesize owner = _owner;
@synthesize group = _group;
@synthesize tower = _tower;
@synthesize state = _state;

+ (Troop *) troopWithType: (UnitType) type
                    owner: (int) owner
                    tower: (Tower *) tower
                    group: (int) group
                   nature: (NatureType) nature
                   amount: (int) units
                     path: (TowerPathVector) path {
    return [[[self alloc] initWithType: type owner: owner tower: (Tower *) tower group: group nature: nature amount: units path: path] autorelease];
}

- (void) dealloc {
    
    CCLOG(@"dealloc");
    [super dealloc];
}

- (Troop *) initWithType: (UnitType) type
                   owner: (int) owner
                   tower: (Tower *) tower
                   group: (int) group
                  nature: (NatureType) nature
                  amount: (int) units
                    path: (TowerPathVector) path {
    
    if((self = [super init])) {
        _type = type;
        _owner = owner;
        _group = group;
        _nature = nature;
        _numOfUnits = units;
        _health = HealthForUnitTypeOfNature(type, nature);
        _tower = tower;
        
        _path = path;
        
        _state = TS_Idle;
        
        _spr = [CCSprite spriteWithFile: [NSString stringWithFormat: @"unit%i.png", (int)type]];
        [self addChild: _spr];
        
        [self scheduleUpdate];
    }
    
    return self;
}

- (void) go {
    [self goAfterDelay: 0.0];
}

- (void) goAfterDelay: (float) delay {
     NSMutableArray *actions = [NSMutableArray array];
    
    __block Troop *bself = self;
    
    //TODO:r
    _spr.opacity = 0;
    
    CGPoint startPoint = self.position;
    //so apply this path to a specified unit type
    for(int i = 0; i < _path.size(); ++i) {
        PointVector roadPoints = _path[i].first;

        NSMutableArray *segmentMoveActions = [NSMutableArray array];

        for(int j = 0; j < roadPoints.size(); ++j) {
            CGPoint checkPoint = roadPoints[j];
            
            float distance = 0;
            
            distance = ccpDistance(startPoint, checkPoint);
            
            startPoint = checkPoint;
            
            float time = distance / SpeedForUnitTypeOfNature(_type, _nature);

            CCMoveTo *move = nil;
            
            if(i == 0 && j == 0) {
                move = [CCSequence actions:
                                        [CCMoveTo actionWithDuration: time position: checkPoint],
                                        [CCCallBlock actionWithBlock: ^{
                                            [_spr runAction: [CCFadeIn actionWithDuration: 0.3]];
                                        }], nil];
            } else {
                move = [CCMoveTo actionWithDuration: time position: checkPoint];
            }
            
            CCCallBlock *clearCheckPoint = [CCCallBlock actionWithBlock: ^{
                //popfront the segment point
                _path[0].first.erase(_path[0].first.begin());
            }];

            [segmentMoveActions addObject: [CCSequence actions: move, clearCheckPoint, nil]];
        }

        Tower *tower = _path[i].second;
        
        CCAction *roadAction = [CCSequence actions:
                                                    [CCSequence actionWithArray: segmentMoveActions],
                                                    [CCCallBlock actionWithBlock: ^{
                                                        if(tower.group == self.group) {
                                                            _path.erase(_path.begin());
                                                        } else {
                                                            [tower applyUnits: self.numOfUnits
                                                                       ofType: self.type
                                                                        group: self.group
                                                                       nature: self.nature
                                                                    fromOwner: self.owner];
                                                            
                                                            [bself done];
                                                        }
                                                    }], nil];
        [actions addObject: roadAction];
    }
    
     [self runAction:
                    [CCSequence actions:
                                    [CCDelayTime actionWithDuration: delay],
                                    [CCCallBlock actionWithBlock: ^{
                                        _state = TS_Walking;
                                    }],
                                    [CCSequence actionWithArray: actions],
                                    [CCCallFunc actionWithTarget: self selector: @selector(done)],
                                    nil]];

}

//- (void) clear

- (void) done {
    
    __block Troop *bself = self;

    _state = TS_ReadyToCleanUp;
    
    [_spr runAction:
                    [CCSequence actions:
                                        [CCFadeTo actionWithDuration: 0.2 opacity: 0],
                                        [CCCallBlock actionWithBlock: ^{
                                            [bself removeFromParentAndCleanup: YES];
                                        }], nil]
     ];
}

- (void) onTowerReached: (Tower *) tower {
    //todo
}

- (void) fade {
    if(_spr.opacity == 255) {
        _spr.opacity = 70;
    }
}

- (void) unfade {
    if(_spr.opacity < 255) {
        _spr.opacity = 255;
    }
}

- (void) update: (ccTime) dt {
    
}

@end
