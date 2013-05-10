
#import <Foundation/Foundation.h>

@interface Settings: NSObject
{
    NSString *_userUUID;
    NSString *_userID;
    
    NSArray *_appHosts;
    int _assetPackageId;
}

@property (nonatomic, retain) NSString *userUUID;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, readonly) NSArray *appHosts;
@property (nonatomic, readonly) int assetPackageId;

+ (Settings *) sharedSettings;

- (void) load;
- (void) save;

- (void) applyHosts: (NSArray *) hosts;
- (void) applyAssetPackageId: (int) packageId;

@end