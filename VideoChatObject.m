//
//  VideoChatObject.m
//  HXTest
//
//  Created by gongliang on 2016/10/26.
//  Copyright © 2016年 AB. All rights reserved.
//

#import "VideoChatObject.h"
//#import "IEMCallManager.h"
#import "CallViewController.h"

@interface VideoChatObject() <EMCallManagerDelegate>

@property (nonatomic, strong) CallViewController *callViewController;

@property (nonatomic, strong) NSString *showName;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, strong) NSTimer *callTimer;

@property (nonatomic, strong) EMCallSession *callSession;

@end

@implementation VideoChatObject

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static VideoChatObject *object;
    dispatch_once(&onceToken, ^{
        object = [[VideoChatObject alloc] init];
    });
    return object;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"HXConfig" ofType:@"plist"];
        if (plistPath == nil) {
            NSLog(@"error: HXConfig.plist not found");
            assert(0);
        }
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSString *appkey = dict[@"APP_KEY"];
        EMOptions *options = [EMOptions optionsWithAppkey:appkey];
        EMError *error = [[EMClient sharedClient] initializeSDKWithOptions:options];
        if (error != nil) {
        }
        [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    }
    return self;
}

- (EMError *)loginUser:(NSString *)userId
              password:(NSString *)password {
    EMError *error = [[EMClient sharedClient] loginWithUsername:userId password:password];
    return error;
}

- (void)videoCall:(NSString *)callId
             name:(NSString *)name {
    _showName = name;
    [[EMClient sharedClient].callManager startVideoCall:callId completion:^(EMCallSession *aCallSession, EMError *aError) {
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"创建实时通话失败，请稍后重试" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            [self enterCallViewisCall:YES session:aCallSession];
        }
    }];
}

- (void)startCallTimer {
    [self stopCallTimer];
    _callTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(cancelCall) userInfo:nil repeats:NO];
}

- (void)stopCallTimer
{
    if (_callTimer == nil) {
        return;
    }
    
    [_callTimer invalidate];
    _callTimer = nil;
}


- (void)cancelCall {
    [self hangupCallWithReason:EMCallEndReasonNoResponse];
}

- (void)hangupCallWithReason:(EMCallEndReason)aReason
{
    [self stopCallTimer];
    
    EMCallSession *tmpSession = self.callSession;
    if (tmpSession) {
        [[EMClient sharedClient].callManager endCall:tmpSession.callId reason:aReason];
    }
}

- (void)enterCallViewisCall:(BOOL)isCall session:(EMCallSession *)aSession {
    _callSession = aSession;
    if (isCall) {
        [self startCallTimer];
    }
    CallViewController *callVC = [[CallViewController alloc] initWithSession:aSession isCaller:isCall status:@"正在建立连接..."];
    callVC.showName = _showName;
    _callViewController = callVC;
    [self.controller presentViewController:callVC animated:NO completion:nil];
    [self playisCall:isCall];
}

- (void)playisCall:(BOOL)isCall {
    NSString *audioName = isCall? @"outgoing" : @"ingoing";
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:audioName withExtension:@".mp3"];
    // 2.创建 AVAudioPlayer 对象
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    // 4.设置循环播放
    self.audioPlayer.numberOfLoops = -1;
    // 5.开始播放
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)stop {
    [self.audioPlayer stop];
    self.audioPlayer = nil;
}

#pragma mark - EMCallManagerDelegate
- (void)callDidReceive:(EMCallSession *)aSession {
    [self enterCallViewisCall:NO session:aSession];
}

- (void)callDidConnect:(EMCallSession *)aSession {
    [self.callViewController stateToConnected];
}

- (void)callDidAccept:(EMCallSession *)aSession
{
    [self stop];
    [self stopCallTimer];
    [self.callViewController stateToAnswered];
}

- (void)callDidEnd:(EMCallSession *)aSession reason:(EMCallEndReason)aReason error:(EMError *)aError {
    [self stop];
    [self stopCallTimer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.callViewController dismissViewControllerAnimated:NO completion:nil];
        self.callViewController = nil;
    });
    
    if (aReason != EMCallEndReasonHangup) {
        NSString *reasonStr = @"";
        switch (aReason) {
            case EMCallEndReasonNoResponse:
            {
                reasonStr = @"对方没有回应";
            }
                break;
            case EMCallEndReasonDecline:
            {
                reasonStr = @"拒接通话";
            }
                break;
            case EMCallEndReasonBusy:
            {
                reasonStr = @"正在通话中...";
            }
                break;
            case EMCallEndReasonFailed:
            {
                reasonStr = @"建立连接失败";
            }
                break;
            case EMCallEndReasonUnsupported:
            {
                reasonStr = @"功能不支持";
            }
                break;
                
            default:
                break;
        }
        
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:aError.errorDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:reasonStr delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
}

- (void)didReceiveCallNetworkChanged:(EMCallSession *)aSession status:(EMCallNetworkStatus)aStatus {
    [self.callViewController setNetwork:aStatus];
}

@end
