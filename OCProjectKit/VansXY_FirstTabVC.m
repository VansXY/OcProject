//
//  VansXY_FirstTabVC.m
//  OCProjectKit
//
//  Created by HXB-xiaoYang on 2018/3/20.
//Copyright © 2018年 VansXY. All rights reserved.
//

#import "VansXY_FirstTabVC.h"
#import "XYTabBarItemButton.h"
#import "GCDAsyncSocket.h"
#import "XYGCDAsyncSocketManage.h"
#import "XYConnectConfig.h"
#import "XYKeyChainManager.h"
#import "XYBaseRequest.h"
#import "XYBaseNetwork.h"
#import "HXBHFBankHudView.h"
#import "PRESENTVC.h"
#import "VansXY_SecondTabVC.h"
#import "TempView.h"
#import "CallBackName.h"
// 安全认证
#import <LocalAuthentication/LocalAuthentication.h>

#define kDefaultChannel     @"dkf"
#define kToken              @"f14c4e6f6c89335ca5909031d1a6efa9"



@interface VansXY_FirstTabVC ()<CallBackNameDelegate> {
    NSInteger count;
}


@property (nonatomic, strong) XYTabBarItemButton *button;
@property (nonatomic, strong) XYConnectConfig *config;
@property (nonatomic, strong) UICKeyChainStore *keychain;
@property (nonatomic, strong) TempView *tempView;
@property (nonatomic, strong) UIButton *testButton;
@property (nonatomic, strong) UIImageView *imageView;


/** 定时器文本 */
@property (nonatomic, strong) UILabel *timerLabel;
/** NSTimer *timer */
@property (nonatomic, strong) NSTimer *timer;
/** scrollview */
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation VansXY_FirstTabVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.testA = @"1111";
//    self.testB = @"1111";
//    //输出结果为：self.testA = 1111,_testA = 1111,self.testB = 1111,testBBBBB = 1111,_testB = (null)
//    NSLog(@"self.testA = %@,_testA = %@,self.testB = %@,testBBBBB = %@,_testB = %@",self.testA,_testA,self.testB,testBBBBB,_testB);
//
//    _testA = @"2222222";
//    _testB = @"2222222";
//    //输出结果为：self.testA = 2222222,_testA = 2222222,self.testB = 1111,_testB = 2222222,testBBBBB = 1111
//    NSLog(@"self.testA = %@,_testA = %@,self.testB = %@,_testB = %@,testBBBBB = %@",self.testA,_testA,self.testB,_testB,testBBBBB);
//
//    testBBBBB = @"333333";
//    //输出结果：self.testB = 333333,testBBBBB = 333333,_testB =2222222
//    NSLog(@"self.testB = %@,testBBBBB = %@,_testB =%@",self.testB,testBBBBB,_testB);
    
    [self buildButton];
    [self loadData];
    
//    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@""] options:(SDWebImageOptions) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
//    }];
    
    [self checkIsSupportFaceID];
    [self buildButton];
    [self loadData];
    
    [self.view addSubview:self.scrollView];
    
    count = 60;
//    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(addTimerMethod) userInfo:nil repeats:YES];
//    _timer = timer;
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addTimerMethod) userInfo:nil repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    });
    
#pragma mark - RAC button
    UIButton *testButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    testButton.frame = CGRectMake(100, 200, 175, 50);
    [testButton setTitle:@"点我" forState:(UIControlStateNormal)];
    [testButton setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:testButton];
    self.testButton = testButton;
    [[self.testButton rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"你点我了");
    }];
    
    
    
//    TempView *tempView = [[TempView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    _tempView = tempView;
//    [tempView addObserver:self forKeyPath:@"tempViewHeight" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
//    [tempView setValue:@180 forKeyPath:@"tempViewHeight"];
}



- (void)addTimerMethod {
    self.timerLabel.text = [NSString stringWithFormat:@"倒计时：%ld", count];
    count--;
    if (count < 0) {
        [_timer invalidate];
        _timer = nil;
        self.timerLabel.hidden = YES;
        return;
    }
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tempViewHeight"]) {
        NSLog(@"tempViewHeight = %@", [change valueForKey:@"new"]);
    }
}

- (void)dealloc {
    [_tempView removeObserver:self forKeyPath:@"tempViewHeight"];
}

//static __inline__ NSData *dataWithImage:(UIImage *)image {
//    return UIImage
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 1. 使用默认的连接环境
    //    [[GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithToken:@"f14c4e6f6c89335ca5909031d1a6efa9" channel:kDefaultChannel];
    
    // 2.自定义配置连接环境
    [[XYGCDAsyncSocketManage shareInstance] createSocketWithConfig:self.config];
}

#pragma mark - UI

- (void)checkIsSupportFaceID {
    LAContext *context = [[LAContext alloc] init];
    NSString *localizedReason = @"开启面容解锁，获取更多服务";
    NSError *error = nil;
    if ([context canEvaluatePolicy:(kLAPolicyDeviceOwnerAuthenticationWithBiometrics) error:&error]) {
        [context evaluatePolicy:kLAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:localizedReason reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [self presentViewController:[PRESENTVC new] animated:YES completion:nil];
            } else {
                NSLog(@"暂不支持");
            }
        }];
    }
    
}
- (void)buildButton {
    
    /*
     点击按钮的响应者链是什么：
        button —— mainView —— viewController —— UIWindow —— UIApplication —— AppDelegate
     
        1. UIView 的 nextResponder 是直接管理它的 UIViewController （也就是 VC.view.nextResponder = VC ），如果当前 View 不是 ViewController 直接管理的 View，则 nextResponder 是它的 superView（ view.nextResponder = view.superView ）。
        2. UIViewController 的 nextResponder 是它直接管理的 View 的 superView（ VC.nextResponder = VC.view.superView ）。
        3. UIWindow 的 nextResponder 是 UIApplication 。
        4. UIApplication 的 nextResponder 是 AppDelegate。
     
     
     事件寻找顺序：
        UIWindow —— mainView —— UIButton —— UIButtonLabel
     
        1. 从视图层级最底层的 window 开始遍历它的子 View。
        2. 默认的遍历顺序是按照 UIView 中 Subviews 的逆顺序。
        3. 找到 hit-TestView 之后，寻找过程就结束了。
     */
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(137.5, 100, 100, 100)];
    label.backgroundColor = [UIColor blueColor];
    label.userInteractionEnabled = YES;
//    [self.view addSubview:label];
    
    
    //forControlEvents 和 tapGesture 先响应手势
    _button = [XYTabBarItemButton buttonWithType:(UIButtonTypeCustom)];
    _button.frame = CGRectMake(137.5, 100, 100, 100);
    _button.layer.masksToBounds = YES;
    _button.layer.cornerRadius = 50;
    _button.alpha = 0.5;
    _button.userInteractionEnabled = YES;
    [_button setBackgroundColor:[UIColor orangeColor]];
      [_button setTitle:@"点我" forState:(UIControlStateNormal)];
    [_button addTarget:self action:@selector(clickMe) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_button];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap)];
//    [_button addGestureRecognizer:tap];

}

- (void)labelTap {
    NSLog(@"点击的是label");
    
    /// 在地图上标记一个地址
//    NSString* addressText =@"1 Infinite Loop, Cupertino, CA 95014";
//
//    addressText =  [addressText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
//
//    NSString* urlText = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", addressText];
//
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlText]];
}

#pragma mark - Network
- (void)loadData {
    [XYBaseNetwork GET:@"https://www.sojson.com/open/api/weather/json.shtml" parameters:@{@"city": @"北京"} responseCache:nil success:^(id responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        
    } failure:^(NSError *error) {
        NSLog(@"error = %@", error);
        
    }];
    

}

#pragma mark - Action
- (void)clickMe {
    NSLog(@"点击的是button");
    PRESENTVC *presentVC = [[PRESENTVC alloc] init];
    presentVC.delegate = self;
    __block NSString *names = @"name";
//    __weak typeof(self) weakSelf = self;
    presentVC.block = ^(NSString *name) {
        NSLog(@"name1 = %@", name);
        names = name;
        [self.navigationController pushViewController:[VansXY_SecondTabVC new] animated:true];
    };
    [self presentViewController:presentVC animated:true completion:nil];
//    [self.navigationController pushViewController:[PRESENTVC new] animated:true];
//    HFHudVC *hfVC = [[HFHudVC alloc] init];
//    hfVC.modalPresentationStyle = UIModalPresentationCustom;
//    [self presentViewController:hfVC animated:NO completion:nil];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (100 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [hfVC dismissViewControllerAnimated:NO completion:nil];
//    });
    
//    HXBHFBankHudView *view = [[HXBHFBankHudView alloc] initWithFrame:UIScreen.mainScreen.bounds];
//    view.hudContent = @"正在跳转恒丰银行";
//    [self.view addSubview:view];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        view.backView.hidden = YES;
//    });
//    _keychain = XYKeyChain.keyChain;
//    _keychain[@"token"] = kToken;
//    NSLog(@"%d", [_keychain setString:kToken forKey:@"token"]);
//    [self loadData];
//    NSDictionary *requestParams =@{};
//    [[XYGCDAsyncSocketManage shareInstance] socketWriteDataWithRequestBody:requestParams completion:^(NSError * _Nullable error, id  _Nullable data) {
//        NSLog(@"error = %@,\ndata = %@", error, data);
//        if (error) {
//
//        } else {
//
//        }
//    }];
}

- (void)keyChainUse {
    _keychain = XYKeyChain.keyChain;
    [_keychain setValue:kToken forKey:@"token"];
}

#pragma mark - Setter / Getter / Lazy
- (XYConnectConfig *)config {
    if (!_config) {
        _config = [[XYConnectConfig alloc] init];
        _config.channels = kDefaultChannel;
        _config.currentChannel = kDefaultChannel;
        _config.host = @"online socket address";
        _config.port = 7070;
        _config.socketVersion = 5;
    }
    _config.token = kToken;
    return _config;
}

- (UILabel *)timerLabel {
    if (!_timerLabel) {
        _timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 200, 175, 30)];
        _timerLabel.font = [UIFont systemFontOfSize:20];
        _timerLabel.textColor = [UIColor whiteColor];
        _timerLabel.backgroundColor = [UIColor purpleColor];
        [self.scrollView addSubview:_timerLabel];
    }
    return _timerLabel;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.contentSize = CGSizeMake(kWidth, kHeight + 20);
        _scrollView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}
- (void)callBackName:(NSString *)name {
    NSLog(@"name = %@", name);
}

@end
