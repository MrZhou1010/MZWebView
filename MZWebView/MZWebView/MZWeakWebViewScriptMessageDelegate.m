//
//  WeakWebViewScriptMessageDelegate.m
//  MZWebView
//
//  Created by Mr.Z on 2019/12/23.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

#import "MZWeakWebViewScriptMessageDelegate.h"

@implementation MZWeakWebViewScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    if (self = [super init]) {
        self.scriptDelegate = scriptDelegate;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
