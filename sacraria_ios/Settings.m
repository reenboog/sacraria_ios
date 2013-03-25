
#import "Settings.h"

//private constants
#define kUserUUIDKey            @"userUUIDKey"
#define kUserIDKey              @"userIDKey"
#define kDefaultAppHostsKey     @"defaultHosts"

@implementation Settings

@synthesize userUUID        = _userUUID;
@synthesize userID          = _userID;
@synthesize appHosts        = _appHosts;

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
    
    self.userID = nil;
    self.userUUID = nil;
    self.appHosts = nil;
    
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
        self.appHosts = [NSMutableArray arrayWithArray: data];
    }
    else {
        
        NSArray *plistAr = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"AppHosts" ofType: @"plist"]];
        if(!plistAr) {
            NSLog(@"no such file!");
        }
        else {
            self.appHosts = [NSMutableArray arrayWithArray: plistAr];
        }
    }
}

- (void) save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject: self.userID forKey: kUserIDKey];
    [defaults setObject: self.userUUID forKey: kUserUUIDKey];
    
    [defaults setObject: self.appHosts forKey: kDefaultAppHostsKey];
    
    [defaults synchronize];
}

- (void) swapAppHosts {
    
    NSInteger hostsCount = [_appHosts count];
    [_appHosts exchangeObjectAtIndex: random() % hostsCount withObjectAtIndex: random() % hostsCount];
}

@end
