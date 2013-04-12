
#import "GameConfig.h"

float MultiplierForNatures(NatureType attacker, NatureType defender) {
    return 1.0;
}

float MultiplierForTowerAndUnit(TowerType tower, UnitType unit) {
    return 1.0;
}

int TroopSizeForUnitType(UnitType type) {
    static const int numOfUnitTypes = 5;
    static int sizes[numOfUnitTypes] = {2, 3, 2, 3, 4};
    
    return sizes[type];
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