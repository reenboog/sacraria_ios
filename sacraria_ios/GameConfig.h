
#ifndef GAME_CONFIG_H
#define GAME_CONFIG_H

#import <list>
#import <vector>
#import <algorithm>

using namespace std;

typedef list<int> IntList;
typedef vector<int> IntVector;
typedef vector<CGPoint> PointVector;

#define zTower 2000

#define kGameSessionRefreshPeriod           5
#define kMaxNumOfReconnections              5

//network notifications
#define kPingLostNotification               @"pingLostNotification"

//#define kFailedToConnectNotification        @"failedToConnectNotification"

#define kNetworkConnectionRestored          @"networkConnectionRestored"

#define kLoggedInNotification               @"loggedInNotification"
#define kFailedToLogInNotification          @"failedToLogInNotification"

#define kSignedUpNotification               @"signedUpNotification"
#define kFailedToSignUpNotificatin          @"failedToSignUpNotification"

#define kPingTimeInterval                   5
#define kNormalPingResponse                 @"ok"
#define kMaxNumOfUnrespondedPings           5
//

//towers
#define kTowerInvalidGroup                  -93721

typedef enum {
    GS_idle,

    GS_signingup,
    GS_signedup,
    
    GS_loggingin,
    GS_loggedin,
    
    GS_ready
}GameState;

typedef enum {
    NT_Water,
    NT_Fire,
    NT_Earth,
    NT_Evil
}NatureType;

typedef enum {
    TT_simple,
    TT_big,
    TT_fast,
    TT_magic,
    TT_super,
} TowerType;

typedef enum {
    UT_simple,
    UT_big,
    UT_fast,
    UT_magic,
    UT_super
    
} UnitType;

typedef struct {
    PointVector points;
} Road;

typedef vector<Road> RoadVector;
typedef RoadVector Field;

@class Tower;

typedef vector<Tower *> TowerList;
typedef vector<Tower *> TowerPathList;

#ifdef __cplusplus
extern "C" {
#endif

float MultiplierForNatures(NatureType attacker, NatureType defender);
float MultiplierForTowerAndUnit(TowerType tower, UnitType unit);
    
#ifdef __cplusplus
}
#endif

@interface GameConfig: NSObject {
    GameState _gameState;
    
    //NSString *_apiBaseUrl;
}

@property (nonatomic, assign) GameState gameState;
//@property (nonatomic, retain) NSString *apiBaseUrl;

+ (GameConfig *) sharedConfig;

@end

#endif