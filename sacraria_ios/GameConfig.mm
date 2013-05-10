
#import "GameConfig.h"
#import "cocos2d.h"
#import "Settings.h"

float MultiplierForNatures(NatureType attacker, NatureType defender) {
    return 1.0;
}

float MultiplierForTowerAndUnit(TowerType tower, UnitType unit) {
    return 1.0;
}

float AttackPowerForUnitAndUnit(UnitType attacker, UnitType defender) {
    return CCRANDOM_0_1() * 3;
}

int TroopSizeForUnitType(UnitType type, NatureType nature) {
    static const int numOfNatures = 4;
    static const int numOfUnitTypes = 5;
    
    static int sizes[numOfNatures][numOfUnitTypes] = {
        {2, 3, 2, 3, 4},
        {2, 3, 2, 3, 4},
        {2, 3, 2, 3, 4},
        {2, 3, 2, 3, 4}
    };
    
    return sizes[nature][type];
}

int HealthForUnitTypeOfNature(UnitType type, NatureType nature) {
    static const int numOfNatures = 4;
    static const int numOfUnitTypes = 5;
    static int health[numOfNatures][numOfUnitTypes] = {
        //0 - warrior, 1 - barbarian, 2 - fast unit, 3 - wizard, 4 - super-unit
        {5, 7, 3, 4, 10},
        {5, 7, 3, 4, 10},
        {5, 7, 3, 4, 10},
        {5, 7, 3, 4, 10}
    };
    
    return health[nature][type];
}

float SpeedForUnitTypeOfNature(UnitType type, NatureType nature) {
    static const int numOfNatures = 4;
    static const int numOfUnitTypes = 5;
    static int speeds[numOfNatures][numOfUnitTypes] = {
        //0 - warrior, 1 - barbarian, 2 - fast unit, 3 - wizard, 4 - super-unit
        {150.0, 40.0, 70.0, 55.0, 30.0},
        {50.0, 40.0, 70.0, 55.0, 30.0},
        {50.0, 40.0, 70.0, 55.0, 30.0},
        {50.0, 40.0, 70.0, 55.0, 30.0}
    };
    
    return speeds[nature][type];
}

float RespawnTimeForTowerTypeOfNature(UnitType type, NatureType nature) {
    static const int numOfNatures = 4;
    static const int numOfTowerTypes = 5;
    static int times[numOfNatures][numOfTowerTypes] = {
        //0 - warrior, 1 - barbarian, 2 - fast unit, 3 - wizard, 4 - super-unit
        {1.0, 1.0, 1.0, 1.0, 1.0},
        {1.0, 1.0, 1.0, 1.0, 1.0},
        {1.0, 1.0, 1.0, 1.0, 1.0},
        {1.0, 1.0, 1.0, 1.0, 1.0}
    };
    
    return times[nature][type];
}

CGSize SizeForTroopTypeAndNature(UnitType type, NatureType nature) {
    static const int numOfNatures = 4;
    static const int numOfUnitTypes = 5;
    static CGSize sizes[numOfNatures][numOfUnitTypes] = {
        //0 - warrior, 1 - barbarian, 2 - fast unit, 3 - wizard, 4 - super-unit
        {ccSize(30, 30), ccSize(50, 50), ccSize(25, 25), ccSize(40, 30), ccSize(70, 70)},
        {ccSize(30, 30), ccSize(50, 50), ccSize(25, 25), ccSize(40, 30), ccSize(70, 70)},
        {ccSize(30, 30), ccSize(50, 50), ccSize(25, 25), ccSize(40, 30), ccSize(70, 70)},
        {ccSize(30, 30), ccSize(50, 50), ccSize(25, 25), ccSize(40, 30), ccSize(70, 70)}
    };
    
    return sizes[nature][type];
}

float FightDelayForTroopTypeAndNature(UnitType type, NatureType nature) {
    static const int numOfNatures = 4;
    static const int numOfTroopTypes = 5;
    static int times[numOfNatures][numOfTroopTypes] = {
        //0 - warrior, 1 - barbarian, 2 - fast unit, 3 - wizard, 4 - super-unit
        {0.4, 0.8, 0.2, 0.3, 1.0},
        {0.4, 0.8, 0.2, 0.3, 1.0},
        {0.4, 0.8, 0.2, 0.3, 1.0},
        {0.4, 0.8, 0.2, 0.3, 1.0}
    };
    
    return times[nature][type];
}

int RandomDistanceForFight() {
    const int numOfDistances = 9;
    static int distances[numOfDistances] = {
      10, 15, 20, 25, 30, 35, 40, 45, 50
    };
    
    static int counter = 0;
    static int distance = distances[counter % numOfDistances];
    
    if(counter % 2 == 0) {
        distance = distances[counter % numOfDistances];
    }
    
    counter++;
    
    //3 calls for 2 gith pairs
    if(counter > numOfDistances * 2) {
        counter = 0;
        distance = distances[counter];
    }
    
    return distance;
}

NSString * AttackAnimationNameForUnitType(UnitType type, NatureType nature) {
    
    int maxNumOfAnimations = 1;
    
    switch(nature) {
        case NT_Earth:
            switch(type) {
                case UT_simple:
                    maxNumOfAnimations = 1;
                    break;
                case UT_big:
                    maxNumOfAnimations = 1;
                case UT_fast:
                    maxNumOfAnimations = 1;
                case UT_magic:
                    maxNumOfAnimations = 1;
                    case UT_super:
                    maxNumOfAnimations = 1;
                default:
                    break;
            } break;
        case NT_Fire:
            switch(type) {
                case UT_simple:
                    maxNumOfAnimations = 1;
                    break;
                case UT_big:
                    maxNumOfAnimations = 1;
                case UT_fast:
                    maxNumOfAnimations = 1;
                case UT_magic:
                    maxNumOfAnimations = 1;
                case UT_super:
                    maxNumOfAnimations = 1;
                default:
                    break;
            } break;
        case NT_Water:
            switch(type) {
                case UT_simple:
                    maxNumOfAnimations = 1;
                    break;
                case UT_big:
                    maxNumOfAnimations = 1;
                case UT_fast:
                    maxNumOfAnimations = 1;
                case UT_magic:
                    maxNumOfAnimations = 1;
                case UT_super:
                    maxNumOfAnimations = 1;
                default:
                    break;
            } break;
        case NT_Evil:
            switch(type) {
                case UT_simple:
                    maxNumOfAnimations = 1;
                    break;
                case UT_big:
                    maxNumOfAnimations = 1;
                case UT_fast:
                    maxNumOfAnimations = 1;
                case UT_magic:
                    maxNumOfAnimations = 1;
                case UT_super:
                    maxNumOfAnimations = 1;
                default:
                    break;
            }
    }
    
    //int animationIndex = rand() % maxNumOfAnimations;
    
    //NSString *name = [NSString stringWithFormat: @""];
    
    return @"";
}

@implementation GameConfig

@synthesize gameState = _gameState;
@synthesize host = _host;

+ (GameConfig *) sharedConfig {
    static GameConfig *sharedConfig = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedConfig = [[GameConfig alloc] init];
    });
    
    return sharedConfig;
}

- (void) dealloc {
    [_host release];
    
    [super dealloc];
}

- (id) init
{
    if((self = [super init])) {
        _gameState = GS_idle;
    }
    
    return self;
}

- (NSString *) pickUpAHost {
    int hostsCount = [[Settings sharedSettings].appHosts count];
    
    if(_host) {
        _currentHostIndex = rand() % hostsCount;
    } else {
        _currentHostIndex++;
        _currentHostIndex = _currentHostIndex % hostsCount;
    }
    
    _host = [[Settings sharedSettings].appHosts objectAtIndex: _currentHostIndex];
    
    return _host;
}

@end