//
//  RoadsLayer.m
//  sacraria_ios
//
//  Created by Alex Gievsky on 04.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "RoadsLayer.h"
#import "Tower.h"

@implementation RoadsLayer

@synthesize selectedTowers = _selectedTowers;
@synthesize touchPos = _touchPos;

- (RoadsLayer *) initWithRoads: (const RoadVector&) roads {
    
    if((self = [super init])) {
        _roads = roads;
    }
    
    return self;
    
}

- (void) draw {
    
    for(int i = _roads.size() - 1 ; i >= 0; --i) {
        PointVector &points = _roads[i].points;

        for(int j = 0; j < points.size() - 1; ++j) {
            CGPoint a = points[j];
            CGPoint b = points[j + 1];

            ccDrawLine(a, b);
        }
    }
    
    //draw selected towers
    for(TowerList::iterator it = _selectedTowers.begin(); it != _selectedTowers.end(); ++it) {
        ccDrawLine((*it).position, _touchPos);
    }
    
}

@end
