//
//  WhAsyncSocket.m
//  whwallet
//
//  Created by ffy on 2018/11/6.
//  Copyright © 2018年 wormhole. All rights reserved.
//

#import "WhAsyncSocket.h"
#import "NSString+Additionals.h"
#import "WhNetWorkConfig.h"
#import "WhWalletHeader.h"
#import <objc/runtime.h>

static NSInteger SocketAutoConnectMax = 5;
static NSString *socketOpenkey = @"hasBeenOpen";

@interface WhAsyncSocket ()<NSStreamDelegate>
@property(nonatomic)dispatch_queue_t writeQueue;
@property(nonatomic)dispatch_queue_t readQueue;

@property(nonatomic)NSInputStream  *inputStream;
@property(nonatomic)NSOutputStream *outputStream;
@property(nonatomic)NSMutableDictionary *bufferDictionary;

@property(nonatomic)NSMutableString *tempStringBuffer;

@property(nonatomic)BOOL isReading;

@property(nonatomic)NSInteger maxAutoConnect;

@end

@implementation WhAsyncSocket{
    NSInteger connectIndex;
    NSString *tempHost;
    NSInteger tempPort;
}

-(instancetype)initWithDelegate:(id<WhAsyncSocketProtocol>)delegate{
    self = [super init];
    if (self) {
        self.delegate   = delegate;
        self.writeQueue = dispatch_queue_create("fft.wormhole.writequeue", DISPATCH_QUEUE_SERIAL);
        self.readQueue  = dispatch_queue_create("fft.wormhole.readqueue", DISPATCH_QUEUE_SERIAL);
;
        self.bufferDictionary = [NSMutableDictionary dictionary];
        self.tempStringBuffer = [NSMutableString string];
        
        [self connectToServer];
        
        [self.outputStream addObserver:self forKeyPath:@"streamStatus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self.inputStream addObserver:self forKeyPath:@"streamStatus" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

/*
 NSStreamStatusNotOpen = 0,
 NSStreamStatusOpening = 1,
 NSStreamStatusOpen = 2,
 NSStreamStatusReading = 3,
 NSStreamStatusWriting = 4,
 NSStreamStatusAtEnd = 5,
 NSStreamStatusClosed = 6,
 NSStreamStatusError = 7
 */

-(void)close{
    // 关闭输出输入流
    [self.inputStream close];
    [self.outputStream close];
    
    //从主运行循环中移除
    [self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

-(BOOL)isConnected{
    /*
     NSStreamStatusNotOpen = 0,
     NSStreamStatusOpening = 1,
     NSStreamStatusOpen = 2,
     NSStreamStatusReading = 3,
     NSStreamStatusWriting = 4,
     NSStreamStatusAtEnd = 5,
     NSStreamStatusClosed = 6,
     NSStreamStatusError = 7
     */
    return (self.inputStream.streamStatus==NSStreamStatusOpen||self.inputStream.streamStatus==NSStreamStatusReading||self.inputStream.streamStatus==NSStreamStatusAtEnd)&&(self.outputStream.streamStatus==NSStreamStatusOpen||self.outputStream.streamStatus==NSStreamStatusWriting||self.outputStream.streamStatus==NSStreamStatusAtEnd);
}

-(BOOL)connectToServer{
    if (!self.isConnected) {
        return [self connectToHost:WhNetWorkConfig.host onPort:WhNetWorkConfig.port error:nil];
    }
    return YES;
}


- (BOOL)connectToHost:(NSString*)host onPort:(uint16_t)port error:(NSError **)errPtr{
    //save host and port for reconnect
    tempHost = [host copy];
    tempPort = port;
    
    //close and
    [self close];
    
    //reconnect
    NSString * basehost = [host copy];
    
    // 1.use corefoundation cfstream
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)(basehost), port, &readStream, &writeStream);
    
    // 2.transfer to NSStream
    NSInputStream  *inputStream  = (__bridge NSInputStream *)(readStream);
    NSOutputStream *outputStream = (__bridge NSOutputStream *)(writeStream);
    
    
    // 3.add streams to runloop
    [inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    
    // 4.open streams
    [inputStream open];
    [outputStream open];
    
    //add custom key
    objc_setAssociatedObject(inputStream, &socketOpenkey, @(NO), OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(outputStream, &socketOpenkey, @(NO), OBJC_ASSOCIATION_RETAIN);
    
    self.inputStream  = inputStream;
    self.outputStream = outputStream;
    
    
    // 5.set delegate
    self.inputStream.delegate = self;
    self.outputStream.delegate = self;
    return YES;
}


-(void)writeData:(NSData *)data length:(NSInteger)length identifier:(long)identifier{
    dispatch_async(self.writeQueue, ^{
        [self.outputStream write:data.bytes maxLength:length];
        [self.bufferDictionary setObject:[NSMutableData data] forKey:@(identifier)];
    });
    
}


- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
    /**
     * NSStreamEventOpenCompleted = 1UL << 0      //输入输出流打开完成
     * NSStreamEventHasBytesAvailable = 1UL << 1  //有字节可读
     * NSStreamEventHasSpaceAvailable = 1UL << 2  //可以发放字节
     * NSStreamEventErrorOccurred = 1UL << 3      //连接出现错误
     * NSStreamEventEndEncountered = 1UL << 4     //连接结束
     */
    __weak typeof(self) weakSelf = self;
    switch (eventCode) {
        case NSStreamEventOpenCompleted:{
            NSLog(@"NSStreamEventOpenCompleted");
            if (aStream == self.inputStream) {
                objc_setAssociatedObject(self.inputStream, &socketOpenkey, @(YES), OBJC_ASSOCIATION_RETAIN);
            }else if (aStream == self.outputStream){
                
                objc_setAssociatedObject(self.outputStream, &socketOpenkey, @(YES), OBJC_ASSOCIATION_RETAIN);
            }
            BOOL inOpen  = [objc_getAssociatedObject(self.inputStream, &socketOpenkey) boolValue];
            BOOL outOpen = [objc_getAssociatedObject(self.outputStream,&socketOpenkey) boolValue];
            if (inOpen&&outOpen){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:WhSocketConnectedCompleteKey object:nil];
                });
                self.maxAutoConnect = 0;
            }
        }
            break;
            
        case NSStreamEventHasBytesAvailable:{
            dispatch_async(self.readQueue, ^{
                if (!weakSelf.isReading) {
                    [weakSelf havaBytesToRead];
                }
            });
            NSLog(@"NSStreamEventHasBytesAvailable");
            break;
        }
        case NSStreamEventHasSpaceAvailable:{
            NSLog(@"NSStreamEventHasSpaceAvailable");
        }
            break;
            
        case NSStreamEventErrorOccurred:{
            NSLog(@"NSStreamEventErrorOccurred");
            if (!self.isConnected) {
                if (self.maxAutoConnect < SocketAutoConnectMax) {
                    self.maxAutoConnect++;
                    [self connectToServer];
                }
            }
        }
            break;
            
        case NSStreamEventEndEncountered:{
            [[NSNotificationCenter defaultCenter] postNotificationName:WhSocketCloseCompleteKey object:nil];
            [weakSelf close];
            self.maxAutoConnect = 0;
        }
            NSLog(@"NSStreamEventEndEncountered");
            break;
        default:
            break;
    }
    
}


//有字节可读
-(void)havaBytesToRead{
    
    self.isReading = YES;
    
    // 1.建立一个缓冲区 可以放4096字节
    uint8_t buf[4096];
    NSInteger position = 0;
    while (1) {
        @autoreleasepool {
            // 2.返回实际装的字节数
            NSInteger length = [self.inputStream read:buf maxLength:sizeof(buf)];
            //有数据
            if (length <= 0) {
                self.isReading = NO;
                self.tempStringBuffer = [NSMutableString string];
                break;
            }
            
            
            // 3.把字节数组转化成字符串
            NSData * data = [NSData dataWithBytes:buf length:length];
            
            NSString * readStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
//            NSLog(@"readStr: %@",readStr);
            
            [self.tempStringBuffer appendString:readStr];

            NSString *subString = [self.tempStringBuffer substringFromIndex:position];
            
            if ([subString containsString:@"\n"]){
                NSRange range = [subString rangeOfString:@"\n"];
                NSString *fullString = [subString substringToIndex:range.location];
                if (fullString.length > 0) {
                    [self handleFullString:fullString];
                }
                position += range.location + 1;
            }
        }
        
    }
    
    
    
    /*
     if (endChar=='\n') {
     [self.tempStringBuffer appendString:readStr];
     
     NSString *fullString  = [self.tempStringBuffer copy];
     self.tempStringBuffer = [NSMutableString string];
     [self handleFullString:fullString];
     
     }else
     
     
     const char endChar ;
     [data getBytes:(void *)&endChar range:NSMakeRange(data.length-1, 1)];
     */
}

-(void)handleFullString:(NSString *)fullString{
    NSLog(@"fullString: %@",fullString);
//    NSLog(@"length: %ld",fullString.length);
    NSDictionary *responseObject = [fullString parseJsonStringToDictionary];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(socket:didReadData:tag:)]) {
        NSString *rpcID = [NSString stringWithFormat:@"%@",responseObject[@"id"]];
        [self.delegate socket:self didReadData:responseObject tag:rpcID.longLongValue];
    }
}


@end

