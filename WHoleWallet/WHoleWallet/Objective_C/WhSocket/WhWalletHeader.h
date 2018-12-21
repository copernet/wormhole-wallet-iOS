//
//  WhWalletHeader.h
//  whwallet
//
//  Created by ffy on 2018/10/30.
//  Copyright © 2018年 wormhole. All rights reserved.
//

#ifndef WhWalletHeader_h
#define WhWalletHeader_h

#import <Foundation/Foundation.h>


#if DEBUG

#define WHLog(format, ...) NSLog((@"[文件名:%s]" "[函数名:%s]" "[行号:%d]" format), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#define FLog(format, ...)  NSLog((format), ##__VA_ARGS__);
#elif
#define WHLog(format, ...)
#define FLog(format,  ...)
#endif


#define StringLong(num) [NSString stringWithFormat:@"%ld",num]
#define LongString(str) [str longLongValue]


#ifndef BCH_TESTNET
#define BCH_TESTNET 1
#endif

#define WhDidReceivesUtxosNotificationKey @"WhDidReceivesUtxosNotificationKey"

#define WhSocketConnectedCompleteKey @"WhSocketConnectedSuccessKey"
#define WhSocketCloseCompleteKey     @"WhSocketConnectedSuccessKey"
//#define WhSocketConnectedSuccess  @"WhSocketConnectedSuccess"

#endif /* WhWalletHeader_h */
