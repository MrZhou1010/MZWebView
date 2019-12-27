//
//  MZWebViewController.m
//  MZWebView
//
//  Created by Mr.Z on 2019/12/26.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

#import "MZWebViewController.h"
#import "MZWeakWebViewScriptMessageDelegate.h"

// 以下代码适配文本大小
static NSString * const jsString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";

@interface MZWebViewController () <WKScriptMessageHandler>

@end

@implementation MZWebViewController

- (instancetype)init {
    if (self = [super init]) {
        [self webViewConfiguration];
    }
    return self;
}

- (void)webViewConfiguration {
    // 创建设置对象
    WKPreferences *preferences = [[WKPreferences alloc] init];
    // 最小字体大小,当将javaScriptEnabled属性设置为NO时,可以看到明显的效果
    preferences.minimumFontSize = 0.0;
    // 设置是否支持javaScript,默认是支持的
    preferences.javaScriptEnabled = YES;
    // 在iOS上默认为NO,表示是否允许不经过用户交互由javaScript自动打开窗口
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    self.configuration.preferences = preferences;
    // 自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
    MZWeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[MZWeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
    // 这个类主要用来做native与JavaScript的交互管理
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    // 注册一个name为jsToOcNoPrams的js方法 设置处理接收JS方法的对象
    [userContentController addScriptMessageHandler:weakScriptMessageDelegate  name:@"jsToOcNoPrams"];
    [userContentController addScriptMessageHandler:weakScriptMessageDelegate  name:@"jsToOcWithPrams"];
    // 用于进行JavaScript注入
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [userContentController addUserScript:userScript];
    self.configuration.userContentController = userContentController;
    // 是否使用h5的视频播放器在线播放,还是使用原生播放器全屏播放
    self.configuration.allowsInlineMediaPlayback = YES;
    if (@available(iOS 10.0, *)) {
        self.configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
    } else {
        if (@available(iOS 9.0, *)) {
            // 设置视频是否需要用户手动播放,设置为NO则会允许自动播放
            self.configuration.requiresUserActionForMediaPlayback = YES;
            // 设置是否允许画中画技术,在特定设备上有效
            self.configuration.allowsPictureInPictureMediaPlayback = YES;
            // 设置请求的User-Agent信息中应用程序名称(iOS9后可用)
            self.configuration.applicationNameForUserAgent = @"ChinaDailyForiPad";
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - WKNavigationDelegate
/// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

/// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

/// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

/// 提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

/// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
}

/// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *urlStr = navigationAction.request.URL.absoluteString;
    if ([urlStr hasPrefix:@"itms-apps://itunes.apple.com"] || [urlStr hasPrefix:@"https://itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr] options:@{} completionHandler:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

/// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/// 需要响应身份验证时调用,同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

/// 进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    completionHandler(YES);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    completionHandler(defaultText);
}

/// 通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
}

#pragma mark - 销毁
- (void)dealloc {
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"jsToOcNoPrams"];
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"jsToOcWithPrams"];
}

@end
