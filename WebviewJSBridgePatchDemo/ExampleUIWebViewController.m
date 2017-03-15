//
//  ExampleUIWebViewController.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import "ExampleUIWebViewController.h"
#import "WebViewJavascriptBridge.h"

#import "JPEngine.h"
#import <objc/runtime.h>
#import <objc/message.h>


@interface ExampleUIWebViewController () <WebViewJavascriptBridgeExceptionDelegate>
@property WebViewJavascriptBridge* bridge;
@end

@implementation ExampleUIWebViewController

- (void)viewWillAppear:(BOOL)animated {
    if (_bridge) { return; }
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    [_bridge setWebViewDelegate:self];
    [_bridge setWebViewExceptionDelegate:self];
    
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [_bridge callHandler:@"testJavascriptHandler" data:@{ @"foo":@"before ready" }];
    
    [self renderButtons:webView];
    [self loadExamplePage:webView];
    
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"js"];
//    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
//    
//    [JPEngine evaluateScript:script];
//    
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 50)];
//    [btn setTitle:@"Push JPTableViewController" forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(testObjcCallbacks:) forControlEvents:UIControlEventTouchUpInside];
//    [btn setBackgroundColor:[UIColor grayColor]];
//    [self.view addSubview:btn];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
}

- (void)renderButtons:(UIWebView*)webView {
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
    callbackButton.frame = CGRectMake(0, 400, 100, 35);
    callbackButton.titleLabel.font = font;
    
    UIButton* reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reloadButton setTitle:@"Reload webview" forState:UIControlStateNormal];
    [reloadButton addTarget:webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:reloadButton aboveSubview:webView];
    reloadButton.frame = CGRectMake(90, 400, 100, 35);
    reloadButton.titleLabel.font = font;
    
    UIButton* safetyTimeoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [safetyTimeoutButton setTitle:@"Disable safety timeout" forState:UIControlStateNormal];
    [safetyTimeoutButton addTarget:self action:@selector(disableSafetyTimeout) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:safetyTimeoutButton aboveSubview:webView];
    safetyTimeoutButton.frame = CGRectMake(190, 400, 120, 35);
    safetyTimeoutButton.titleLabel.font = font;
}

- (void)disableSafetyTimeout {
    [self.bridge disableJavscriptAlertBoxSafetyTimeout];
}

- (void)callHandler:(id)sender {
    id data = @{ @"greetingFromObjC": @"Hi there, JS!" };
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

- (void) _noHandlerForMessage:(NSString *)handlerName withData:(NSDictionary *)data callbackId:(NSString *)id {
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"js"];
    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    
    [JPEngine evaluateScript:script];
    
    [self performSelector:NSSelectorFromString(handlerName)];
    
    
//    NSMethodSignature*signature = [ExampleUIWebViewController instanceMethodSignatureForSelector:NSSelectorFromString(mSt)];
//    //1、创建NSInvocation对象
//    NSInvocation*invocation = [NSInvocation invocationWithMethodSignature:signature];
//    invocation.target = self;
//    //invocation中的方法必须和签名中的方法一致。
//    invocation.selector = NSSelectorFromString(mSt);
//    /*第一个参数：需要给指定方法传递的值
//     第一个参数需要接收一个指针，也就是传递值的时候需要传递地址*/
//    //第二个参数：需要给指定方法的第几个参数传值
////    NSString*number = @"1111";
////    //注意：设置参数的索引时不能从0开始，因为0已经被self占用，1已经被_cmd占用
////    [invocation setArgument:&number atIndex:2];
////    NSString*number2 = @"啊啊啊";
////    [invocation setArgument:&number2 atIndex:3];
//    //2、调用NSInvocation对象的invoke方法
//    //只要调用invocation的invoke方法，就代表需要执行NSInvocation对象中制定对象的指定方法，并且传递指定的参数
//    [invocation invoke];
}



@end
