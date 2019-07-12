//
//  ViewController.m
//  AppAndWeb
//
//  Created by 周泽舟 on 2019/7/12.
//  Copyright © 2019 zhouzezhou. All rights reserved.
//  App与网页交互DEMO

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

// 屏幕的宽度
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
// 屏幕的高度
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
// 系统状态栏高度
#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height


@interface ViewController () <WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) JSContext *context;
@property (nonatomic, strong) WKUserContentController *userContentController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 公共的参数
    CGFloat padding = 20.f;
    CGFloat commWidth = kScreenWidth - padding * 2;
    CGFloat webviewHeight = kScreenHeight - (kStatusBarHeight + 20 + 50 * 2 + 40);
    
    // 写个标题避免迷路
    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(padding, kStatusBarHeight + 20, commWidth, 50)];
    [hint setText:@"iOS原生App与网页交互"];
    [hint setTextColor:[UIColor blackColor]];
    [hint setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:hint];
    
    // App调用网页方法，同时传参的触发按钮
    UIButton *btnCallWeb = [[UIButton alloc] initWithFrame:CGRectMake(padding, kStatusBarHeight + 70, commWidth, 50)];
    [btnCallWeb setTitle:@"App调网页，同时传参" forState:UIControlStateNormal];
    [btnCallWeb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCallWeb setBackgroundColor:[UIColor orangeColor]];
    [btnCallWeb.layer setCornerRadius:4.0];
    [btnCallWeb addTarget:self action:@selector(btnCallWebClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCallWeb];
    
    // 网页的背景View
    UIView *webviewBg = [[UIView alloc] initWithFrame:CGRectMake(padding,
                                                                 kStatusBarHeight + 70 + 70,
                                                                 commWidth,
                                                                 webviewHeight)];
    [webviewBg setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:webviewBg];
    
    
    // ============= 以下是App里嵌入的网页 =============
    // 为WKWebViewConfiguration设置偏好设置
    WKPreferences *preferences = [[WKPreferences alloc] init];
    // 允许native和js交互
    preferences.javaScriptEnabled = YES;
    
    // 创建配置对象
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences = preferences;
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addScriptMessageHandler:self name:@"callApp"];
    configuration.userContentController = userContentController;
    self.userContentController = userContentController;
    
    // 初始化webview
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(2, 2, commWidth - 4, webviewHeight - 4) configuration:configuration];
    
    // 此处替换为你的网页地址
    // 请求Http地址，请在info.plist里NSAppTransportSecurity下加入NSAllowsArbitraryLoads
    NSURL *url = [NSURL URLWithString:@"http://www.zhouzezhou.com/appCalled.html"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
    
    [webviewBg addSubview:self.webView];
    // ============= 以上是App里嵌入的网页 =============
}

#pragma mark - Private Mothed

-(NSString *) getDeviceInfo {
    // 获取设备名称
    NSString *name = [[UIDevice currentDevice] name];
    // 获取设备系统名称
    NSString *systemName = [[UIDevice currentDevice] systemName];
    // 获取系统版本
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    // 获取设备模型
    NSString *model = [[UIDevice currentDevice] model];
    
    return [NSString stringWithFormat:@"设备名称：%@ 系统名称：%@ 系统版本：%@ 设备模型：%@",
            name,
            systemName,
            systemVersion,
            model];
}

#pragma mark - Button Respond

// 调用网页方法，同时传参给网页
-(void) btnCallWebClick {
    // 执行网页里的js脚本，receive2App为js的方法名，括号里为传递的参数，参数里不要传递换行符
    NSString *callStr = [NSString stringWithFormat:@"receive2App('%@')", [self getDeviceInfo]];
    [self.webView evaluateJavaScript:callStr completionHandler:nil];
}

#pragma mark - WKScriptMessageHandler

// 接受js发送的消息
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    // message.name为上面WKWebview初始化时设置的和js通信的名称
    // message.body是js里传递给App里数据
    if ([message.name isEqualToString:@"callApp"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:(NSString *)message.body message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *btnOk = [UIAlertAction actionWithTitle:@"收到了" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:btnOk];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)dealloc{
    // remove
    // 必须和add一起出现，否则导致内存泄漏
    [self.userContentController removeScriptMessageHandlerForName:@"callApp"];
}

@end
