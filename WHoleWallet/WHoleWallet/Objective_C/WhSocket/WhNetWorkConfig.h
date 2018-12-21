//
/*******************************************************************************

        WhNetWorkConfig.h
        WHoleWallet
   
        Created by ffy on 2018/11/22
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WhNetWorkConfig : NSObject

+(NSString *)host;
+(NSInteger )port;
+(NSString *)baseURL;

@end

NS_ASSUME_NONNULL_END
