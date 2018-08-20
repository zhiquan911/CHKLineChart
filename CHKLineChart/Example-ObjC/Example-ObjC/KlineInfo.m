//
//  KlineInfo.m
//  Example-ObjC
//
//  Created by hongfei xu on 2018/8/19.
//  Copyright © 2018年 xuhongfei. All rights reserved.
//

#import "KlineInfo.h"

@implementation KlineInfo

+ (instancetype)klineInfoWithArray:(NSArray *)arr
{
    return [[self alloc] initWithArray:arr];
}

- (instancetype)initWithArray:(NSArray *)arr
{
    if (self = [super init]) {
        self.time = [NSString stringWithFormat:@"%@", arr[0]];
        self.lowPrice = [NSString stringWithFormat:@"%@", arr[1]];
        self.highPrice = [NSString stringWithFormat:@"%@", arr[2]];
        self.openPrice = [NSString stringWithFormat:@"%@", arr[3]];
        self.closePrice = [NSString stringWithFormat:@"%@", arr[4]];
        self.vol = [NSString stringWithFormat:@"%@", arr[5]];
    }
    
    return self;
}

@end
