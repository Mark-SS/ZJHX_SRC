//
//  VideoChatObject.h
//  HXTest
//
//  Created by gongliang on 2016/10/26.
//  Copyright © 2016年 AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EMSDKFull.h"

@interface VideoChatObject : NSObject

+ (instancetype)sharedInstance;
@property (weak, nonatomic) UIViewController *controller;
- (EMError *)loginUser:(NSString *)userId password:(NSString *)password;
- (void)videoCall:(NSString *)callId name:(NSString *)name;

- (void)logout;

- (void)hangupCallWithReason:(EMCallEndReason)aReason;

@end
