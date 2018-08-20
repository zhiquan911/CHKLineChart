//
//  KlineInfo.h
//  Example-ObjC
//
//  Created by hongfei xu on 2018/8/19.
//  Copyright © 2018年 xuhongfei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KlineInfo : NSObject

@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *openPrice;
@property (nonatomic, copy) NSString *closePrice;
@property (nonatomic, copy) NSString *lowPrice;
@property (nonatomic, copy) NSString *highPrice;
@property (nonatomic, copy) NSString *vol;

+ (instancetype)klineInfoWithArray:(NSArray *)arr;
- (instancetype)initWithArray:(NSArray *)arr;

@end
