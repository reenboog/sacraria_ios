
#ifndef GAME_CONFIG_H
#define GAME_CONFIG_H

#import <list>
#import <vector>
#import <algorithm>

using namespace std;

#define kVersion 0
#define kDefaultAssetPackageId 0

#define kUpdateRequired 204
#define kNewAssetsRequired 206
#define kNormalServerStatus 200

#define kScreenWidth 1024
#define kScreenHeight 768

#define zTower      2000
#define zTroop      2001
#define zObstacles  2001

#define kGameSessionRefreshPeriod           5
#define kMaxNumOfReconnections              5

#define kArmyAttackDelay                    0.25f

//network notifications
#define kPingLostNotification               @"pingLostNotification"

//#define kFailedToConnectNotification        @"failedToConnectNotification"

#define kNetworkConnectionRestored          @"networkConnectionRestored"

#define kOldVersionNotification             @"oldVersionNotification"
#define kGetNewAssetsNotification           @"getNewAssetsNotification"

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
#define kOwnerNoOne                         -24343

#define kFightMinimalDistance               10
#define kTroopFightMinimalDistance          300

#define ccSize(w, h) (CGSizeMake(w, h))

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
    UT_super,
    
    //separate unit types
    
} UnitType;

typedef enum {
    TS_Idle,
    TS_Walking,
    TS_GoingToFight,
    TS_Fighting,
    TS_Dying,
    TS_WonTheFight,
    TS_ReadyToCleanUp
} TroopState;

typedef enum {
    GT_KillAll,
    GT_CaptureBase
}GameType;

typedef list<int> IntList;
typedef vector<int> IntVector;
typedef vector<CGPoint> PointVector;

typedef pair<int, int> IntIntPair;
typedef vector<IntIntPair> IntPairsVector;

@class Tower;
@class Troop;

typedef struct {
    PointVector points;
    Tower *src;
    Tower *dst;
} Road;

typedef vector<Road> RoadVector;
//typedef RoadVector Field;

typedef vector<Tower *> TowerList;
typedef vector<Troop *> TroopVector;
typedef pair<PointVector, Tower *> PathChunkPair;
typedef vector<PathChunkPair> TowerPathVector;

#ifdef __cplusplus
extern "C" {
#endif

float MultiplierForNatures(NatureType attacker, NatureType defender);
float MultiplierForTowerAndUnit(TowerType tower, UnitType unit);
float AttackPowerForUnitAndUnit(UnitType attacker, UnitType defender);

int TroopSizeForUnitType(UnitType type, NatureType nature);
int HealthForUnitTypeOfNature(UnitType type, NatureType nature);
float SpeedForUnitTypeOfNature(UnitType type, NatureType nature);
float RespawnTimeForTowerTypeOfNature(UnitType type, NatureType nature);
CGSize SizeForTroopTypeAndNature(UnitType type, NatureType nature);
float FightDelayForTroopTypeAndNature(UnitType type, NatureType nature);
NSString * AttackAnimationNameForUnitType(UnitType type, NatureType nature);
int RandomDistanceForFight();
    
#ifdef __cplusplus
}
#endif

//protocols

@protocol GameDelegate <NSObject>

//- (void) sendUnitsFromTower: (Tower *) src toTower: (Tower *) dst;
- (void) checkIfGameOver;

@end

@interface GameConfig: NSObject {
    GameState _gameState;
    
    NSString *_host;
    int _currentHostIndex;
}

@property (nonatomic, assign) GameState gameState;
@property (nonatomic, readonly) NSString *host;

+ (GameConfig *) sharedConfig;

- (NSString *) pickUpAHost;

@end

#endif