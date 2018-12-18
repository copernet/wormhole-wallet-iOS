//
//  WhSocketManager.m
//  whwallet
//
//  Created by ffy on 2018/10/30.
//  Copyright © 2018年 wormhole. All rights reserved.
//

#import "WhSocketManager.h"
#import "WhWalletHeader.h"
#import "WhRPCInterfaces.h"
#import "NSString+Additionals.h"

static const NSString *WHJSONRPCErrorDomain = @"WHJSONRPCErrorDomain";

static NSString * AFJSONRPCLocalizedErrorMessageForCode(NSInteger code) {
    switch(code) {
        case -32700:
            return @"Parse Error";
        case -32600:
            return @"Invalid Request";
        case -32601:
            return @"Method Not Found";
        case -32602:
            return @"Invalid Params";
        case -32603:
            return @"Internal Error";
        default:
            return @"Server Error";
    }
}

static void handleJsonRPCResponse(id responseObject, id<WhJSONRPCInterface>rpcObj){
    id result = nil;
    id error = nil;
    id data = nil;
    NSString *message;
    NSInteger code = 0;

    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        rpcObj.rpc_id  = responseObject[@"id"];
        
        result = responseObject[@"result"];
        error = responseObject[@"error"];
        if (result && result != [NSNull null]) {
            rpcObj.result  = result;
            rpcObj.success = YES;
            
        } else if (error && error != [NSNull null]) {
            if ([error isKindOfClass:[NSDictionary class]]) {
                if (error[@"code"]) {
                    code = [error[@"code"] integerValue];
                }
                if (error[@"message"]) {
                    message = error[@"message"];
                } else if (code) {
                    message = AFJSONRPCLocalizedErrorMessageForCode(code);
                }
                data = error[@"data"];
            } else {
                message = @"Unknown Error";
            }
        } else {
            message = @"Unknown JSON-RPC Response";
        }
    } else {
        message = @"Unknown JSON-RPC Response";
        //NSLocalizedStringFromTable(@"Unknown JSON-RPC Response", @"AFJSONRPCClient", nil)
    }
    
    if (message||data) {
       NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (message) {
            userInfo[NSLocalizedDescriptionKey] = message;
        }
        if (data) {
            userInfo[@"data"] = data;
        }
        NSError *error = [NSError errorWithDomain:(NSString *)WHJSONRPCErrorDomain code:code userInfo:userInfo];
        rpcObj.error = error;
    }
}

#if BCH_TESTNET
#define HOST @"13.229.155.155"
#define PORT 9629
#else
#define HOST @"13.229.155.155"
#define PORT 9629
#endif



@interface WhSocketManager ()
@property(nonatomic)WhAsyncSocket *socket;
@property(nonatomic)NSMutableDictionary *requestDictionary;
@property(nonatomic)dispatch_source_t skipTimer;
@property(nonatomic)NSMutableArray *unSpendUtxos;

@end

@implementation WhSocketManager{
    NSString *_walletBase58Address;
    WhHeartSkipObject *heartSkipObj;
}

static WhSocketManager *_shareSocketManager;
+(WhSocketManager *)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareSocketManager = [[self alloc] init];
    });
    return _shareSocketManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
       
        WhAsyncSocket *socket   = [[WhAsyncSocket alloc] initWithDelegate:self];
        self.socket = socket;
        
        self.requestDictionary  = [NSMutableDictionary dictionary];
        
        self.unSpendUtxos       = [NSMutableArray array];
        
        [self connect];
        
        heartSkipObj = [WhHeartSkipObject new];
    }
    return self;
}
-(void)setWalletBaes58Address:(NSString *)address{
    _walletBase58Address = [address copy];
}

-(BOOL)isConnected{
    return self.socket.isConnected;
}


- (void)close{
    [self.socket close];
}

-(BOOL)connect{
    if (!self.socket.isConnected) {
        NSError *error = nil;
        BOOL success = [self.socket connectToServer];
        if (!success) {
            return success;
        }
        if (error) {
            WHLog(@"connect error: %@",error.userInfo);
            return NO;
        }
    }
    return YES;
}

-(void)doHeartSkip{
    if (!self.skipTimer) {
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC, 2 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            [self sendServerBanner];
        });
        dispatch_resume(timer);
        self.skipTimer = timer;
    }
}



-(BOOL)sendJsonRPCDataWithID:(NSString *)rpcID method:(NSString *)rpcMethod parameters:(NSArray *)parameters tag:(long)tag{
    
    if (!rpcID||!rpcMethod) {
        WHLog(@"rpcID or rpcMethod is nil");
        return NO;
    }
    NSArray *rpcParameters = parameters;
    if (!parameters) {
        rpcParameters = @[];
    }
    
    NSMutableDictionary  *payload = [NSMutableDictionary dictionary];
    payload[@"jsonrpc"] = @"2.0";
    payload[@"id"] = rpcID;
    payload[@"method"] = rpcMethod;
    payload[@"params"] = rpcParameters;
    
    if (![NSJSONSerialization isValidJSONObject:payload]) {
        WHLog(@"invalad json");
        return NO;
    }
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
    if (error) {
        WHLog(@"error: %@",error.userInfo);
        return NO;
    }
    
    //insert end flag
    NSMutableString *jsonString = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [jsonString appendString:@"\n"];
    WHLog(@"send rpc: %@",jsonString);
    NSData *rpcData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (rpcData) {
        [self.socket writeData:rpcData length:rpcData.length identifier:tag];
        return YES;
    }else{
        WHLog(@"error: rpc json error");
    }
    return NO;
}



#pragma mark - GCDAsyncSocketDelegate

-(void)socket:(WhAsyncSocket *)socket didReadData:(NSDictionary *)responseObject tag:(long)tag{
    id <WhJSONRPCInterface> reqObj = [self.requestDictionary objectForKey:StringLong(tag)];
    if (!reqObj) {
        reqObj = [self.requestDictionary objectForKey:responseObject[@"method"]];
    }
    if (reqObj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handleJsonRPCResponse(responseObject, reqObj);
            reqObj.responseBlock(reqObj);
            if (!reqObj.maintain) {
                [self.requestDictionary removeObjectForKey:StringLong(tag)];
            }
        });
        
    }
    
}


#pragma mark- RPC Interfaces
-(BOOL)sendMessageWithObject:(id <WhJSONRPCInterface>)object{
    return [self sendJsonRPCDataWithID:object.rpc_id method:object.method parameters:object.parameters tag:object.rpc_id.longLongValue];
}


-(void)sendServerBanner{
    if ([self sendMessageWithObject:heartSkipObj]) {
        [self.requestDictionary setObject:heartSkipObj forKey:heartSkipObj.rpc_id];
    }
}


-(void)subScribeMessagesWithBase58Address:(NSString *)address maintain:(BOOL)maintain withResponseBlock:(WhJsonRpcResponseBlock)responseBlock{
    if (![self connect]||!address) {
        return;
    }
    id<WhJSONRPCInterface> obj = [WhRPCScribeAdress new];
    obj.parameters = @[address.copy];
    obj.responseBlock = responseBlock;
    obj.maintain = maintain;
    if ([self sendMessageWithObject:obj]) {
        [self.requestDictionary setObject:obj forKey:obj.rpc_id];
        [self.requestDictionary setObject:obj forKey:obj.method];
    }
}


-(void)getBananceWithAddress:(NSString *)address withResponseBlock:(WhJsonRpcResponseBlock)responseBlock{
    if (![self connect]||!address) {
        return;
    }
    id<WhJSONRPCInterface> obj = [WhRPCBalance new];
    obj.parameters = @[address.copy];
    obj.responseBlock = responseBlock;
    
    if ([self sendMessageWithObject:obj]) {
        [self.requestDictionary setObject:obj forKey:obj.rpc_id];
    }
}

-(void)getUnSpentUtxosWithAddress:(NSString *)address{
    if (![self connect]||!address) {
        return;
    }
    id<WhJSONRPCInterface> obj = [WhRPCUnSpendUtxos new];
    
    obj.parameters   = @[address.copy];
    
    obj.responseBlock = ^(id<WhJSONRPCInterface>  _Nonnull jsonRpcInterface) {
        FLog(@"unspend utxos: %@",jsonRpcInterface.result);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:WhDidReceivesUtxosNotificationKey object:jsonRpcInterface.result userInfo:@{@"address":address}];
        });
    };
    if ([self sendMessageWithObject:obj]) {
        [self.requestDictionary setObject:obj forKey:obj.rpc_id];
    }
}

//WhRPCConfirmedHistory
-(void)getConfirmedHistoryWithAddress:(NSString *)address withResponseBlock:(WhJsonRpcResponseBlock)responseBlock{
    if (![self connect]||!address) {
        return;
    }
    id<WhJSONRPCInterface> obj = [WhRPCConfirmedHistory new];
    
    obj.parameters = @[address.copy];
    
    obj.responseBlock = responseBlock;
    
    if([self sendMessageWithObject:obj]){
        [self.requestDictionary setObject:obj forKey:obj.rpc_id];
    }
}


-(void)getMerkleWithTransaction:(NSString *)txHash andHeight:(NSInteger)height responseBlock:(WhJsonRpcResponseBlock)responseBlock{
    id<WhJSONRPCInterface> obj = [WhRPCGetTxMerkelPath new];
    
    obj.parameters = @[txHash.copy,@(height)];
    
    obj.responseBlock = responseBlock;
    
    if([self sendMessageWithObject:obj]){
        [self.requestDictionary setObject:obj forKey:obj.rpc_id];
    }
}

-(void)getBlockHeaderWithHeight:(NSInteger)height cpHeight:(NSInteger)cpHeight responseBlock:(WhJsonRpcResponseBlock)responseBlock{
    id<WhJSONRPCInterface> obj = [WhRPCGetBlockHeader new];
    
    obj.parameters = @[@(height),@(cpHeight)];
    
    obj.responseBlock = responseBlock;
    
    if([self sendMessageWithObject:obj]){
        [self.requestDictionary setObject:obj forKey:obj.rpc_id];
    }
}



-(void)getTransactionWithAddress:(NSString *)address withResponseBlock:(WhJsonRpcResponseBlock)responseBlock{
    if (![self connect]||!address) {
        return;
    }
    id<WhJSONRPCInterface> obj = [WhRPCGetTransaction new];
    
    obj.parameters = @[address.copy];
    
    obj.responseBlock = responseBlock;
    
    if([self sendMessageWithObject:obj]){
        [self.requestDictionary setObject:obj forKey:obj.rpc_id];
    }
}


-(void)publishTransitionWithRawData:(NSString *)rawData{
    if (![self connect]||!rawData) {
        return;
    }
    id<WhJSONRPCInterface> obj = [WhRPCBroadcastTranscation new];
    
    obj.parameters = @[rawData.copy];
    
    obj.responseBlock = ^(id<WhJSONRPCInterface>  _Nonnull jsonRpcInterface) {
        FLog(@"publish result: %@",jsonRpcInterface.result);
    };
    
    if([self sendMessageWithObject:obj]){
        [self.requestDictionary setObject:obj forKey:obj.rpc_id];
    }
}




-(void)subScribeHeadersResponse:(WhJsonRpcResponseBlock)responseBlock{

    if (![self connect]) {
        return;
    }
    id<WhJSONRPCInterface> obj = [WhRPCBlockHeadersSubscribe new];
    obj.responseBlock = responseBlock;
    obj.parameters = @[@(1)];
    obj.maintain = YES;
    if ([self sendMessageWithObject:obj]) {
        [self.requestDictionary setObject:obj forKey:obj.rpc_id];
        [self.requestDictionary setObject:obj forKey:obj.method];
    }
}

-(void)getChunkBlockHeaders:(NSInteger)start count:(NSInteger)count response:(WhJsonRpcResponseBlock)responseBlock{
    if (![self connect]) {
        return;
    }
    id<WhJSONRPCInterface> obj = [WhRPCChunkBlockHeaders new];
    obj.parameters = @[@(start),@(count)];
    obj.responseBlock = responseBlock;
    if ([self sendMessageWithObject:obj]) {
        [self.requestDictionary setObject:obj forKey:obj.rpc_id];
    }
}


@end
