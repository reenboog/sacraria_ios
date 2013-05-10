
#import "Settings.h"
#import "GameConfig.h"

//private constants
#define kUserUUIDKey            @"userUUIDKey"
#define kUserIDKey              @"userIDKey"
#define kDefaultAppHostsKey     @"defaultHosts"
#define kAssetPackageId         @"assetPackageId"

@implementation Settings

@synthesize userUUID        = _userUUID;
@synthesize userID          = _userID;
@synthesize appHosts        = _appHosts;
@synthesize assetPackageId  = _assetPackageId;

Settings *sharedSettings = nil;

+ (Settings *) sharedSettings {
    static Settings *sharedSettings = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedSettings = [[Settings alloc] init];
    });
    
    return sharedSettings;
}

- (id) init {
    if((self = [super init])) {
    }
    
    return self;
}

- (void) dealloc {
    [self save];
    
    [_userID release];
    [_userUUID release];
    [_appHosts release];
    
    [super dealloc];
}

#pragma mark -

#pragma mark load/save
- (void) load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    id data;

    data = [defaults objectForKey: kUserIDKey];
    if(data) {
        self.userID = data;
    }
    
    data = [defaults objectForKey: kUserUUIDKey];
    if(data) {
        self.userUUID = data;
    }
    
    data = [defaults objectForKey: kDefaultAppHostsKey];
    if(data) {
        _appHosts = [[NSMutableArray arrayWithArray: data] retain];
    }
    else {
        
        NSArray *plistAr = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"AppHosts" ofType: @"plist"]];
        if(!plistAr) {
            NSLog(@"no such file!");
        }
        else {
            _appHosts = [[NSMutableArray arrayWithArray: plistAr] retain];
        }
    }
    
    data = [defaults objectForKey: kAssetPackageId];
    
    if(data) {
        _assetPackageId = [data intValue];
    } else {
        _assetPackageId = kDefaultAssetPackageId;
    }
    
    [[GameConfig sharedConfig] pickUpAHost];
}

- (void) save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject: self.userID forKey: kUserIDKey];
    [defaults setObject: self.userUUID forKey: kUserUUIDKey];
    
    [defaults setObject: self.appHosts forKey: kDefaultAppHostsKey];
    
    [defaults synchronize];
}

- (void) applyHosts: (NSArray *) hosts {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [_appHosts release];
    _appHosts = hosts;
    
    [defaults setObject: _appHosts forKey: kDefaultAppHostsKey];
    
    [defaults synchronize];
}

- (void) applyAssetPackageId: (int) packageId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject: [NSNumber numberWithInt: self.assetPackageId] forKey: kAssetPackageId];
    
    [defaults synchronize];
}

@end