//
//  PRESENTVC.h
//  OCProjectKit
//
//  Created by HXB-xiaoYang on 2018/5/4.
//Copyright © 2018年 VansXY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^pushClick)(NSString *name);

@interface PRESENTVC : UIViewController

@property (nonatomic, copy) pushClick block;

@end