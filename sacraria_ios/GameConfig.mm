
#import "GameConfig.h"

float MultiplierForNatures(NatureType attacker, NatureType defender) {
    return 1.0;
}

float MultiplierForTowerAndUnit(TowerType tower, UnitType unit) {
    return 1.0;
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