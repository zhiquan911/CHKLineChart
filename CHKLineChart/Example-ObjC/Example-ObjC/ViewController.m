//
//  ViewController.m
//  Example-ObjC
//
//  Created by hongfei xu on 2018/8/19.
//  Copyright © 2018年 xuhongfei. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "KlineInfo.h"

#import "ExampleObjC-Swift.h"

@interface ViewController () <NSURLSessionTaskDelegate>

@property (nonatomic, strong) LineChartView *lineChartView;
@property (nonatomic, strong) NSArray *klineData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self fetchRemoteData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.lineChartView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark -
- (LineChartView *)lineChartView
{
    if (_lineChartView == nil) {
        _lineChartView = [[LineChartView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_lineChartView];
    }
    
    return _lineChartView;
}

- (void)setKlineData:(NSArray<KlineInfo *> *)klineData
{
    _klineData = klineData;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lineChartView.klineData = klineData;
    });
}

#pragma mark -
#pragma mark fetch data
- (void)fetchRemoteData
{
    NSString *urlString = @"https://api.gdax.com/products/BTC-USD/candles?granularity=300";
    
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/json", @"application/json", @"text/javascript", @"text/html", nil];
    [sessionManager GET:urlString parameters:@{} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *responseArray = responseObject;
        NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:responseArray.count];
        for (NSArray *arr in responseArray) {
            KlineInfo *klineInfo = [KlineInfo klineInfoWithArray:arr];
            [arrM addObject:klineInfo];
        }
        self.klineData = [arrM copy];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


@end
