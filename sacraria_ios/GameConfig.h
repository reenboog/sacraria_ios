
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

typedef enum
{
    GS_idle,

    GS_signingup,
    GS_signedup,
    
    GS_loggingin,
    GS_loggedin,
    
    GS_ready
}GameState;

@interface GameConfig: NSObject {
    GameState _gameState;
    
    //NSString *_apiBaseUrl;
}

@property (nonatomic, assign) GameState gameState;
//@property (nonatomic, retain) NSString *apiBaseUrl;

+ (GameConfig *) sharedConfig;

@end