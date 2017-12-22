//
//  AspectManagerHelper.m
//  Starbucks_iOS_Renewal
//
//  Created by yunseok choi on 2017. 10. 10..
//  Copyright © 2017년 Media Plus K2L App development Dept. All rights reserved.
//

#import "AspectManagerHelper.h"

@implementation AspectManagerHelper

+ (BOOL)isPrepareTesting {
    NSArray *apis = [self getTestingAPIs];
    
    if (apis) {
        if (apis.count > 0) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

+ (BOOL)isTestingAPI:(NSString *)url {
    
    NSArray *apis = [self getTestingAPIs];
    
    BOOL isTestingApi = NO;
    
    for (NSDictionary *testingDict in apis) {
        if ([url isEqualToString:[testingDict objectForKey:@"url"]]) {
            
            if ([[testingDict objectForKey:@"isTest"] boolValue]) {
                isTestingApi = YES;
            }
            
        }
    }
    
    return isTestingApi;
    
}

+ (NSDictionary *)getTestingAPI:(NSString *)url {
    
    NSArray *apis = [self getTestingAPIs];
    NSDictionary *api;
    
    for (NSDictionary *testingDict in apis) {
        if ([url isEqualToString:[testingDict objectForKey:@"url"]]) {
            api = [NSDictionary dictionaryWithDictionary:testingDict];
        }
    }
    
    return api;
    
}

+ (NSDictionary *)getConfig {
    
    NSError *deserializingError;
    
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:@"config"
                                                               ofType:@"json"];
    
    NSDictionary *configDict;
    
    if (configFilePath) {
        NSURL *configFileUrl = [NSURL fileURLWithPath:configFilePath];
        NSData *config = [NSData dataWithContentsOfURL:configFileUrl];
        
        configDict = [NSJSONSerialization JSONObjectWithData:config
                                                     options:kNilOptions
                                                       error:&deserializingError];
    }
    else {
        NSLog(@"Not found config.json file.");
        return nil;
    }
    
    
    if (configDict) {
        return configDict;
    }
    else {
        NSLog(@"Error while parsing config.json file.");
        return nil;
    }
    
}

+ (NSArray *)getTestingAPIs {
    
    NSDictionary *configDict = [self getConfig];
    
    if (configDict) {
        NSArray *apis = [[NSArray alloc]initWithArray:[configDict objectForKey:@"testing-routes"]];
        return apis;
    }
    else {
        return nil;
    }
    
}

+ (NSDictionary *)getResponseDummyHeaderData:(NSString *)testingUrl {
    NSArray *apis = [self getTestingAPIs];
    
    NSDictionary *header = nil;
    
    if (apis != nil && apis.count > 0) {
        for (NSDictionary *dic in apis) {
            if ([testingUrl isEqualToString:[dic objectForKey:@"url"]]) {
                
                NSString *filename = [dic objectForKey:@"response-header"];
                
                if (filename) {
                    header = [self getHeaderResponse:filename];
                }
                else {
                    header = [self getHeaderResponse:@""];
                }
                
            }
        }
    }
    else {
        NSLog(@"Not found testing APIs from testing-routes in config file.");
        return nil;
    }
    
    return header;
}

+ (NSDictionary *)getHeaderResponse:(NSString *)filename {
    
    NSArray *filenames = [filename componentsSeparatedByString:@"."];
    NSDictionary *header = nil;
    
    if (filenames.count > 1) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[filenames objectAtIndex:0]
                                                         ofType:[filenames objectAtIndex:1]];
        
        NSURL *headerFileUrl = [NSURL fileURLWithPath:path];
        
        if (headerFileUrl) {
            NSData *headerData = [NSData dataWithContentsOfURL:headerFileUrl];
            
            header = [NSJSONSerialization JSONObjectWithData:headerData
                                                     options:kNilOptions
                                                       error:nil];
        }
        
    }
    
    if (header == nil) {
        header = @{@"Connection" : @"keep-alive",
                   @"Content-Language" : @"ko-KR",
                   @"Content-Type" : @"application/json;charset-UTF-8"};
    }
    
    return header;
    
}

+ (NSString *)getResponseDummyBodyData:(NSString *)testingUrl {
    NSArray *apis = [self getTestingAPIs];
    
    NSString *responseData = @"";
    
    if (apis != nil && apis.count > 0) {
        for (NSDictionary *dic in apis) {
            if ([testingUrl isEqualToString:[dic objectForKey:@"url"]]) {
                responseData = [self getDataInFile:[dic objectForKey:@"response-body"]];
            }
        }
    }
    else {
        NSLog(@"Not found testing APIs from testing-routes in config file.");
        return nil;
    }
    
    return responseData;
}

+ (NSString *)getDataInFile:(NSString *)filename {
    
    NSArray *filenames = [filename componentsSeparatedByString:@"."];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:[filenames objectAtIndex:0]
                                                     ofType:[filenames objectAtIndex:1]];
    
    NSString *stringData = [NSString stringWithContentsOfFile:path
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    return stringData;
}

- (NSXMLParser *)getGeneralSettingsFileParser {
    
    NSXMLParser *parser;
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"GeneralSettings" ofType:@"xml"];
    
    if (strPath) {
        parser = [[NSXMLParser alloc]initWithContentsOfURL:[NSURL fileURLWithPath:strPath]];
    }
    else {
        assert(@"Not found General Settings XML file");
    }
    
    if (parser == nil) {
        assert(@"Error while parsing General Settings XML file");
    }
    
    return parser;
    
}

@end
