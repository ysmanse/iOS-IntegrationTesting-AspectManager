//
//  AspectManagerHelper.h
//  Starbucks_iOS_Renewal
//
//  Created by yunseok choi on 2017. 10. 10..
//  Copyright © 2017년 Media Plus K2L App development Dept. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AspectManagerHelper : NSObject

+ (BOOL)isPrepareTesting;
+ (BOOL)isTestingAPI:(NSString *)url;
+ (NSDictionary *)getConfig;
+ (NSArray *)getTestingAPIs;
+ (NSDictionary *)getResponseDummyHeaderData:(NSString *)testingUrl;
+ (NSString *)getResponseDummyBodyData:(NSString *)testingUrl;
+ (NSString *)getDataInFile:(NSString *)filename;
+ (NSDictionary *)getTestingAPI:(NSString *)url;

@end
