//
//  CallNativePlugin.m
//  HXTest
//
//  Created by gongliang on 2016/10/26.
//  Copyright © 2016年 AB. All rights reserved.
//

#import "CallNativePlugin.h"
#import "VideoChatObject.h"
#import <UIKit/UIKit.h>

@interface CallNativePlugin()

@property (nonatomic, strong) VideoChatObject *videoChat;

@end

@implementation CallNativePlugin

- (void)dealloc {
    _videoChat = nil;
}

- (void)pluginInitialize {
    [super pluginInitialize];
    _videoChat = [VideoChatObject sharedInstance];
    _videoChat.controller = self.viewController;
}

- (void)login:(CDVInvokedUrlCommand *)command {
    NSArray *argument = command.arguments;
    if ([argument count] < 2) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [_videoChat loginUser:argument[0] password:argument[1]];
        dispatch_async(dispatch_get_main_queue(), ^{
            CDVPluginResult *result = nil;
            if (error == nil) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        });
    });
}

- (void)logout:(CDVInvokedUrlCommand *)command {
    [_videoChat logout];
}

- (void)videoCall:(CDVInvokedUrlCommand *)command {
    NSArray *argument = command.arguments;
    if ([argument count] < 2) {
        return;
    }
    [_videoChat videoCall:argument[0] name:argument[1]];
}

@end
