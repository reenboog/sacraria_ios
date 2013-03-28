//
//  HelloWorldLayer.h
//  sacraria_ios
//
//  Created by Alex Gievsky on 06.03.13.
//  Copyright spotGames 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "SRWebSocket.h"

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface GameLayer : CCLayer <SRWebSocketDelegate>
{
    SRWebSocket *_webSocket;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
