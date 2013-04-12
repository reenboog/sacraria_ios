//
//  RoadsLayer.h
//  sacraria_ios
//
//  Created by Alex Gievsky on 04.04.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

#import "GameConfig.h"
#import "cocos2d.h"

@interface RoadsLayer : CCLayer {
    RoadVector _roads;
    
    TowerList _selectedTowers;
    CGPoint _touchPos;
}

@property (nonatomic, assign) TowerList selectedTowers;
@property (nonatomic, assign) CGPoint touchPos;

- (RoadsLayer *) initWithRoads: (const RoadVector&) roads;

@end
