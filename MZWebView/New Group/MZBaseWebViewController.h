//
//  MZBaseWebViewController.h
//  MZWebView
//
//  Created by Mr.Z on 2019/12/26.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WKWebViewConfiguration;

@interface MZBaseWebViewController : UIViewController

/** WKWebView的配置 */
@property (nonatomic, strong) WKWebViewConfiguration *configuration;
/** 进度条的颜色,默认为蓝色 */
@property (nonatomic, strong) UIColor *progressViewTintColor;
/** 进度条的Frame,默认为(0, self.view.bounds.origin.y, self.view.bounds.size.width, 2) */
@property (nonatomic, assign) CGRect progressViewFrame;
/** 网页地址的字符串 */
@property (nonatomic, copy) NSString *urlStr;
/** 本地网页的字符串 */
@property (nonatomic, copy) NSString *htmlStr;

/**
 *  初始化方法
 *
 *  @param urlStr 网页地址的字符串
 *  @return self
 */
- (instancetype)initWithUrlString:(NSString *)urlStr;

/**
 *  初始化方法
 *
 *  @param htmlStr 本地网页的字符串
 *  @return self
 */
- (instancetype)initWithHtmlString:(NSString *)htmlStr;

@end

NS_ASSUME_NONNULL_END
