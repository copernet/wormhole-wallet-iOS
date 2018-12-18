//
//  WhRPCInterfaces.m
//  whwallet
//
//  Created by ffy on 2018/10/31.
//  Copyright © 2018年 wormhole. All rights reserved.
//

#import "WhRPCInterfaces.h"
#import <stdatomic.h>
#import "WhWalletHeader.h"

static atomic_long rpc_id_count = 0;
@implementation WhRPCBaseObject
@synthesize parameters;
@synthesize rpc_id;

@synthesize maintain;

@synthesize error;
@synthesize result;
@synthesize success;

@synthesize receivedData;
@synthesize receivedDataBlock;
@synthesize responseBlock;

-(NSString *)version{
    return @"2.0";
}
-(NSString *)method{
    return nil;
}

-(NSString *)rpc_id{
    if (!rpc_id) {
        atomic_fetch_add(&rpc_id_count, 1);
        rpc_id = [[NSString stringWithFormat:@"%ld",rpc_id_count] copy];
    }
    return rpc_id;
}

-(NSMutableData *)receivedData{
    if (!receivedData) {
        receivedData = [NSMutableData data];
    }
    return receivedData;
}


-(WhJsonRpcReceivedData)receivedDataBlock{
    if (!receivedDataBlock) {
        receivedDataBlock = ^(id<WhJSONRPCInterface>interface,NSData *data,long tag){
            [interface.receivedData appendData:data];
        };
    }
    return receivedDataBlock;
}

-(WhJsonRpcResponseBlock)responseBlock{
    if (!responseBlock) {
        responseBlock = ^(id<WhJSONRPCInterface> jsonRpcInterface){
            WHLog(@"%@: %@",jsonRpcInterface.method,jsonRpcInterface.result);
        };
    }
    return responseBlock;
    
}

-(NSMutableString *)tempString{
    if (!tempString) {
        tempString = [NSMutableString string];
    }
    return tempString;
}

@synthesize tempString;

@end


@implementation WhHeartSkipObject

-(NSString *)method{
    return @"server.banner";
}

-(NSArray *)parameters{
    return @[];
}

-(NSString *)rpc_id{
    return @"-1";
}

@end


@implementation WhRPCScribeAdress

-(NSString *)method{
    return @"blockchain.address.subscribe";
}

@end


@implementation WhRPCBalance

-(NSString *)method{
    return @"blockchain.address.get_balance";
}

@end

@implementation WhRPCUnSpendUtxos

-(NSString *)method{
    return @"blockchain.address.listunspent";
}


@end

@implementation WhRPCConfirmedHistory
-(NSString *)method{
    return @"blockchain.address.get_history";
}

@end


@implementation WhRPCGetTxMerkelPath

-(NSString *)method{
    return @"blockchain.transaction.get_merkle";
}

@end


@implementation WhRPCGetBlockHeader

-(NSString *)method{
    return @"blockchain.block.header";
}

@end



@implementation WhRPCGetTransaction

-(NSString *)method{
    return @"blockchain.transaction.get";
}
@end


@implementation WhRPCBroadcastTranscation
-(NSString *)method{
    return @"blockchain.transaction.broadcast";
}
@end


//WhRPBlockHeadersSubscribe
@implementation WhRPCBlockHeadersSubscribe

-(NSString *)method{
    return @"blockchain.headers.subscribe";
}
@end

//WhRPCChunkBlockHeaders
@implementation WhRPCChunkBlockHeaders
-(NSString *)method{
    return @"blockchain.block.headers";
}
@end
