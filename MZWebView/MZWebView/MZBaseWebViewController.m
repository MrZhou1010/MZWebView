//
//  MZBaseWebViewController.m
//  MZWebView
//
//  Created by Mr.Z on 2019/12/26.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

#import "MZBaseWebViewController.h"
#import <WebKit/WebKit.h>

#ifdef DEBUG
#define MZLog(fmt, ...) NSLog((@"[路径:%s]" "[函数名:%s]" "[行号:%d]" fmt), [[NSString stringWithFormat:@"%s", __FILE__].lastPathComponent UTF8String], __FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define MZLog(fmt, ...)
#endif

@interface MZBaseWebViewController () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation MZBaseWebViewController

#pragma mark - 初始化
- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithUrlString:(NSString *)urlStr {
    if (self = [super init]) {
        self.urlStr = urlStr;
        [self initialize];
    }
    return self;
}

- (instancetype)initWithHtmlString:(NSString *)htmlStr {
    if (self = [super init]) {
        self.htmlStr = htmlStr;
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.configuration = [WKWebViewConfiguration new];
    self.progressViewFrame = CGRectZero;
    self.progressViewTintColor = [UIColor blueColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    // 添加监测网页加载进度的观察者
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:nil];
    if (self.urlStr) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];
    }
    if (self.htmlStr) {
        [self.webView loadHTMLString:self.htmlStr baseURL:nil];
    }
}

#pragma mark - Lazy
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:self.configuration];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        // 是否允许手势左滑返回上一级,类似导航控制的左滑返回
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        CGRect frame = CGRectIsEmpty(self.progressViewFrame) ? CGRectMake(0, self.view.bounds.origin.y, self.view.bounds.size.width, 2) : self.progressViewFrame;
        _progressView = [[UIProgressView alloc] initWithFrame:frame];
        _progressView.tintColor = self.progressViewTintColor;
        _progressView.trackTintColor = [UIColor clearColor];
    }
    return _progressView;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if (self.webView.estimatedProgress >= 1.0) {
            [UIView animateWithDuration:0.3 delay:0.2 options:0 animations:^{
                self.progressView.alpha = 0;
            } completion:^(BOOL finished) {
                self.progressView.progress = 0;
            }];
        }
    }
}

#pragma mark - WKNavigationDelegate
/// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    MZLog(@"页面开始加载");
}

/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    MZLog(@"页面加载失败");
    [self.progressView setProgress:0.0 animated:NO];
}

/// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    MZLog(@"当内容开始返回");
}

/// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    MZLog(@"页面加载完成");
}

/// 提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    MZLog(@"提交发生错误");
    [self.progressView setProgress:0.0 animated:NO];
}

/// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    MZLog(@"接收到服务器跳转请求即服务重定向");
}

/// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    MZLog(@"根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转");
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
    MZLog(@"根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转");
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/// 需要响应身份验证时调用,同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    MZLog(@"需要响应身份验证时调用,同样在block中需要传入用户身份凭证");
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

/// 进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    MZLog(@"进程被终止");
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    MZLog(@"AlertPanel");
    completionHandler();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    MZLog(@"ConfirmPanel");
    completionHandler(YES);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    MZLog(@"TextInputPanelWithPrompt");
    completionHandler(defaultText);
}

#pragma mark - 销毁
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

@end
