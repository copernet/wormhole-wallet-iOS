//
//  WhAsyncSocket.h
//  whwallet
//
//  Created by ffy on 2018/11/6.
//  Copyright © 2018年 wormhole. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class WhAsyncSocket;
@protocol WhAsyncSocketProtocol <NSObject>

-(void)socket:(WhAsyncSocket *)socket didReadData:(NSDictionary *)responseObject tag:(long)tag;
@end

@interface WhAsyncSocket : NSObject
@property(nonatomic,readonly)BOOL isConnected;

@property(nonatomic,weak)id<WhAsyncSocketProtocol> delegate;
-(instancetype)initWithDelegate:(id<WhAsyncSocketProtocol>)delegate;

-(BOOL)connectToServer;

-(void)writeData:(NSData *)data length:(NSInteger)length identifier:(long)identifier;

-(void)close;


@end



NS_ASSUME_NONNULL_END
