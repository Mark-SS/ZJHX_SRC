//
//  CallNativePlugin.h
//  HXTest
//
//  Created by gongliang on 2016/10/26.
//  Copyright © 2016年 AB. All rights reserved.
//

#import <Cordova/CDV.h>

@interface CallNativePlugin : CDVPlugin

- (void)login:(CDVInvokedUrlCommand *)command;

- (void)videoCall:(CDVInvokedUrlCommand *)command;

- (void)logout:(CDVInvokedUrlCommand *)command;

@end
