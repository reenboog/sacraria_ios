
#import "GameConfig.h"

float MultiplierForNatures(NatureType attacker, NatureType defender) {
    return 1.0;
}

float MultiplierForTowerAndUnit(TowerType tower, UnitType unit) {
    return 1.0;
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

@implementation GameConfig

@synthesize gameState = _gameState;
//@synthesize apiBaseUrl = _apiBaseUrl;

+ (GameConfig *) sharedConfig {
    static GameConfig *sharedConfig = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedConfig = [[GameConfig alloc] init];
    });
    
    return sharedConfig;
}

- (void) dealloc {
    //self.apiBaseUrl = nil;
    
    [super dealloc];
}

- (id) init
{
    if((self = [super init])) {
        _gameState = GS_idle;
    }
    
    return self;
}

@end