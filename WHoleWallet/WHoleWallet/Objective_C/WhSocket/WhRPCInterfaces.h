//
//  WhRPCInterfaces.h
//  whwallet
//
//  Created by ffy on 2018/10/31.
//  Copyright © 2018年 wormhole. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WhJSONRPCInterface;

typedef void(^WhJsonRpcReceivedData)(id<WhJSONRPCInterface>interface,NSData*data, long tag);
typedef void(^WhJsonRpcResponseBlock)(id<WhJSONRPCInterface> jsonRpcInterface);

@protocol WhJSONRPCInterface <NSObject>
@property(readonly)NSString *version;
@property(readonly)NSString *method;
@property(copy)NSString *rpc_id;
@property(copy)NSArray  *parameters;

//config
@property(nonatomic)BOOL maintain;

//data
@property(nonatomic)NSMutableData *receivedData;
//parse result from data
@property(nonatomic)id result;
@property(nonatomic)NSError *error;
@property(nonatomic)BOOL success;

//handle data and complete
@property(nonatomic,copy)WhJsonRpcReceivedData receivedDataBlock;
@property(nonatomic,copy)WhJsonRpcResponseBlock responseBlock;

@property(nonatomic)NSMutableString *tempString;

@end

@interface WhRPCBaseObject : NSObject<WhJSONRPCInterface>
@end


@interface WhHeartSkipObject : WhRPCBaseObject

@end

@interface WhRPCScribeAdress : WhRPCBaseObject

@end

@interface WhRPCBalance : WhRPCBaseObject

@end


@interface WhRPCUnSpendUtxos : WhRPCBaseObject

@end


@interface WhRPCConfirmedHistory : WhRPCBaseObject

@end


@interface WhRPCGetTxMerkelPath : WhRPCBaseObject

@end


@interface WhRPCGetBlockHeader : WhRPCBaseObject

@end


@interface WhRPCGetTransaction : WhRPCBaseObject

@end


@interface WhRPCBroadcastTranscation : WhRPCBaseObject

@end


@interface WhRPCBlockHeadersSubscribe : WhRPCBaseObject

@end

@interface WhRPCChunkBlockHeaders : WhRPCBaseObject

@end

NS_ASSUME_NONNULL_END
