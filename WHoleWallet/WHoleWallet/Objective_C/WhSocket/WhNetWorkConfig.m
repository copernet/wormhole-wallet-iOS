//
/*******************************************************************************

        WhNetWorkConfig.m
        WHoleWallet
   
        Created by ffy on 2018/11/22
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

#import "WhNetWorkConfig.h"

//0 测试， 1 正式
#define NetLine 0
@implementation WhNetWorkConfig
+ (NSString *)host {
#if NetLine
    return @"13.229.155.155";
#else
    return @"13.229.155.155";
#endif
}
+ (NSInteger )port {
#if NetLine
    return 9629;
#else
    return 9629;
#endif
}

+ (NSString *)baseURL {
#if NetLine
    return @"https://wormhole.cash/";
#else
    return @"https://dev.wormhole.cash/";
#endif
}
@end
