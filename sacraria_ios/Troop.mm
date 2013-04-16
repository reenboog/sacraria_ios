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

- (void) doneWithTower: (Tower *) tower;

- (void) die;
- (void) fight: (Troop *) troop;
- (void) onFightFinished;
- (void) applyDamageFromTroop: (Troop *) troop;

- (CCMoveTo *) actionFromPoint: (CGPoint) src toPoint: (CGPoint) dst;

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
    Tower *dstTower = nil;
    
    //TODO:r
    _spr.opacity = 0;
    
    CGPoint startPoint = self.position;
    //so apply this path to a specified unit type
    for(int i = 0; i < _path.size(); ++i) {
        PointVector roadPoints = _path[i].first;

        NSMutableArray *segmentMoveActions = [NSMutableArray array];

        for(int j = 0; j < roadPoints.size(); ++j) {
            CGPoint checkPoint = roadPoints[j];
            
            CCMoveTo *move = nil;
                        
            if(i == 0 && j == 0) {
                move = [CCSequence actions:
                                        [self actionFromPoint: startPoint toPoint: checkPoint],
                                        [CCCallBlock actionWithBlock: ^{
                                            [_spr runAction: [CCFadeIn actionWithDuration: 0.3]];
                                        }], nil];
            } else {
                move = [CCSequence actions:
                                        [self actionFromPoint: startPoint toPoint: checkPoint], nil];
            }
            
            startPoint = checkPoint;
            
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
                                                            [bself doneWithTower: tower];
                                                        }
                                                    }], nil];
        [actions addObject: roadAction];
    }
    
    dstTower = _path[_path.size() - 1].second;
    
    [self runAction:
                    [CCSequence actions:
                                    [CCDelayTime actionWithDuration: delay],
                                    [CCCallBlock actionWithBlock: ^{
                                        _state = TS_Walking;
                                    }],
                                    [CCSequence actionWithArray: actions],
                                    [CCCallFuncO actionWithTarget: self selector: @selector(doneWithTower:) object: dstTower],
                                    nil]];

}

//- (void) clear

- (void) doneWithTower: (Tower *) tower {
    
    __block Troop *bself = self;

    _state = TS_ReadyToCleanUp;
    
    //apply units
    
    [tower applyUnits: self.numOfUnits
               ofType: self.type
                group: self.group
               nature: self.nature
            fromOwner: self.owner];
    
    [_spr runAction:
                    [CCSequence actions:
                                        [CCFadeTo actionWithDuration: 0.2 opacity: 0],
                                        [CCCallBlock actionWithBlock: ^{
                                            [bself removeFromParentAndCleanup: YES];
                                        }], nil]
     ];
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

#pragma mark - fight logic

- (void) die {
    //stop all actions?
    [self stopAllActions];
    _state = TS_Dying;

    __block Troop *bself = self;
    [bself runAction:
                    [CCSequence actions:
                            [CCScaleTo actionWithDuration: 1 scale: 0.01],
                            //notify the enemy nower
                            [CCCallBlock actionWithBlock:^{
                                [self removeFromParentAndCleanup: YES];
                            }], nil]];
}

- (void) fight: (Troop *) troop {
    if(_state != TS_Fighting) {
        _state = TS_Fighting;
    }
    
    //NSString *animationName = AttackAnimationNameForUnitType(self.type, self.nature);
    
    //play animation
    [self runAction:
            [CCSequence actions:
                        [CCDelayTime actionWithDuration: FightDelayForTroopTypeAndNature(self.type, self.nature)],
                        [CCBlink actionWithDuration: 1 blinks: 3],
                        [CCCallFuncO actionWithTarget: troop selector: @selector(applyDamageFromTroop:) object: self], nil]];
                        //[CCCallFuncO actionWithTarget: self selector: @selector(fight:) object: troop], nil]];
}

- (void) onFightFinished {
    [self stopAllActions];
    //
    self.scale = 1;
    //

    [self go];
}

- (void) applyDamageFromTroop: (Troop *) troop {
    
//    if(troop.state != TS_Fighting) {
//        return;
//    }
    
    float attackPower = AttackPowerForUnitAndUnit(troop.type, self.type);
    
    _numOfUnits -= attackPower;
    
    if(_numOfUnits <= 0) {
        //one is the looser
        [self die];
        //the winner continues his path
        
        [troop onFightFinished];
    } else {
        [self fight: troop];
    }
}

- (void) attackTroop: (Troop *) troop {
    
//    if(self.state != TS_Idle && self.state != TS_Walking) {
//        return;
//    }
//    
    [self stopAllActions];

    //
    self.scale = 1.5;
    //
    
    _state = TS_GoingToFight;
    
    CGPoint delta;
    delta = ccpSub(troop.position, self.position);
    delta = ccpNormalize(delta);
    delta = ccpMult(delta, RandomDistanceForFight());
    
    __block Troop *me = self;
    
    CCCallBlock *turnToAnEnemyBlock = [CCCallBlock actionWithBlock:^{
        if(me.position.x > troop.position.x) {
            me.scaleX = -1;
        } else {
            me.scaleX = 1;
        }
        
        CCLOG(@"me: %@", me);
    }];
    
    if(troop.state == TS_Walking) {
        
        [troop attackTroop: self];
        
        CGSize troopSize = SizeForTroopTypeAndNature(troop.type, troop.nature);
        CGSize mySize = SizeForTroopTypeAndNature(self.type, self.nature);
        
        delta = ccpAdd(delta, ccp(mySize.height / 2.0 + troopSize.height / 2.0, ccpSub(troop.position, self.position).y));

        [self runAction:
                        [CCSequence actions:
                                            [self actionFromPoint: self.position toPoint: ccpAdd(self.position, delta)],
                                            turnToAnEnemyBlock,
                                            [CCCallFuncO actionWithTarget: troop selector: @selector(fight:) object: self],
                                            [CCCallFuncO actionWithTarget: self selector: @selector(fight:) object: troop], nil]
        ];
    } else {
        [self runAction:
                    [CCSequence actions:
                                    [self actionFromPoint: self.position toPoint: ccpAdd(self.position, ccpMult(delta, -1))],
                                    turnToAnEnemyBlock, nil]
        ];
    }
}

- (CCMoveTo *) actionFromPoint: (CGPoint) src toPoint: (CGPoint) dst {
    //reset sprite
    //run walk animation
    float distance = ccpDistance(src, dst);
    
    float time = distance / SpeedForUnitTypeOfNature(_type, _nature);
    //should we apply scaling to a sprite instead?
    
    CCCallBlock *scaleXBlock = [CCCallBlock actionWithBlock:^{
        if(dst.x > src.x) {
            self.scaleX = 1;
        } else if(dst.x < src.x) {
            self.scaleX = -1;
        }
    }];

    return [CCSequence actions:
                scaleXBlock,
                [CCMoveTo actionWithDuration: time position: dst], nil];
}

- (void) moveToPoint: (CGPoint) pt {
    [self runAction:
                    [self actionFromPoint: self.position toPoint: pt]
    ];
}

@end