//
//  NSString+Additionals.m
//  whwallet
//
//  Created by ffy on 2018/11/5.
//  Copyright © 2018年 wormhole. All rights reserved.
//

#import "NSString+Additionals.h"

@implementation NSString (Additionals)
- (NSDictionary *)parseJsonStringToDictionary{
    NSString *jsonString = [self copy];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSError *error2=nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error2];
    return dict;
}
@end
