//
//  MZWeakWebViewScriptMessageDelegate.h
//  MZWebView
//
//  Created by Mr.Z on 2019/12/23.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 解决WKWebView内存不释放的问题 */
@interface MZWeakWebViewScriptMessageDelegate : NSObject <WKScriptMessageHandler>

/** WKScriptMessageHandler这个协议类专门用来处理JS调用原生OC的方法 */
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

/**
 *  初始化方法
 *
 *  @param scriptDelegate 代理
 *  @return self
 */
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end

NS_ASSUME_NONNULL_END
