//
//  WhSocketManager.h
//  whwallet
//
//  Created by ffy on 2018/10/30.
//  Copyright © 2018年 wormhole. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "WhAsyncSocket.h"
#import "WhRPCInterfaces.h"


NS_ASSUME_NONNULL_BEGIN

@interface WhSocketManager : NSObject<WhAsyncSocketProtocol>

@property(nonatomic, readonly)BOOL isConnected;

+(WhSocketManager *)shareManager;

-(void)close;

-(void)setWalletBaes58Address:(NSString *)address;

-(BOOL)connect;

-(void)doHeartSkip;

-(void)sendServerBanner;

-(BOOL)sendJsonRPCDataWithID:(NSString *)rpcID method:(NSString *)rpcMethod parameters:(NSArray *)parameters tag:(long)tag;


-(void)subScribeMessagesWithBase58Address:(NSString *)address maintain:(BOOL)maintain withResponseBlock:(WhJsonRpcResponseBlock)responseBlock;

-(void)getBananceWithAddress:(NSString *)address withResponseBlock:(WhJsonRpcResponseBlock)responseBlock;

-(void)getUnSpentUtxosWithAddress:(NSString *)address;

-(void)getConfirmedHistoryWithAddress:(NSString *)address withResponseBlock:(WhJsonRpcResponseBlock)responseBlock;

-(void)getMerkleWithTransaction:(NSString *)txHash andHeight:(NSInteger)height responseBlock:(WhJsonRpcResponseBlock)responseBlock;

-(void)getBlockHeaderWithHeight:(NSInteger)height cpHeight:(NSInteger)cpHeight responseBlock:(WhJsonRpcResponseBlock)responseBlock;

-(void)getTransactionWithAddress:(NSString *)address withResponseBlock:(WhJsonRpcResponseBlock)responseBlock;

-(void)publishTransitionWithRawData:(NSString *)rawData;

-(void)subScribeHeadersResponse:(WhJsonRpcResponseBlock)responseBlock;

-(void)getChunkBlockHeaders:(NSInteger)start count:(NSInteger)count response:(WhJsonRpcResponseBlock)responseBlock;



@end

NS_ASSUME_NONNULL_END
