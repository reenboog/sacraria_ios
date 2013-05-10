//
//  ConnectionLayer.h
//  sacraria_ios
//
//  Created by Alex Gievsky on 25.03.13.
//  Copyright (c) 2013 spotGames. All rights reserved.
//

@interface UpdateManager : NSObject {
    //
}

+ (void) checkStatus;
+ (void) updateAssets;

@end

#import "cocos2d.h"

@interface ConnectionLayer : CCLayer {
    CCLabelTTF *statusLabel;
}

+ (id) scene;

@end
