
#import <Foundation/Foundation.h>

@interface Settings: NSObject
{
    NSString *_userUUID;
    NSString *_userID;
    
    NSMutableArray *_appHosts;
}

@property (nonatomic, retain) NSString *userUUID;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSMutableArray *appHosts;

+ (Settings *) sharedSettings;

- (void) load;
- (void) save;
- (void) swapAppHosts;

@end