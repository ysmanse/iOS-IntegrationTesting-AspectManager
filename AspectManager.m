//
//  AspectManager.m
//  Starbucks_iOS_Renewal
//
//  Created by yunseok choi on 2017. 10. 8..
//  Copyright © 2017년 Media Plus K2L App development Dept. All rights reserved.
//

#import "AspectManager.h"
#import "Aspects.h"
#import "AspectManagerHelper.h"


@implementation AspectManager

//싱글턴
+ (AspectManager *) sharedInstance {
    static AspectManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

//초기화
- (id)init {
    self = [super init];
    if(self != nil) {
        [self initIntegrationTestingAspect];
    }
    return self;
}

//Aspect 생성
- (void)initIntegrationTestingAspect {
    //Config 파일의 테스팅 API 등록 여부 체크
    //테스팅 API 가 등록되지 않았다면 성능을 위해 포인트컷 선언 안함.
    if (![AspectManagerHelper isPrepareTesting]) return;
    
    
    //클라이언트에서 발생하는 서버 요청 감지를 위해
    //포인트컷 선언 => initWithRequest:delegate:startImmediately:
    [NSURLConnection aspect_hookSelector:
     @selector(initWithRequest:delegate:startImmediately:)
                             withOptions:AspectPositionInstead
                              usingBlock:^(id<AspectInfo> aspectRequestInfo) {
                                  
                                  //요청된 Request 객체
                                  NSMutableURLRequest *request = [aspectRequestInfo.arguments objectAtIndex:0];
                                  
                                  NSString *requestBody = requestBody = [[NSString alloc] initWithData:request.HTTPBody
                                                                                              encoding:NSUTF8StringEncoding];
                                  
                                  NSLog(@"Request body : %@", requestBody);
                                  NSLog(@"Request URL : %@", request.URL.absoluteString);
                                  
                                  //요청 API의 URL 선언
                                  NSString *requestUrl = request.URL.absoluteString;
                                  
                                  //요청된 API의 URL을 토대로 테스트 등록 여부 체크
                                  if ([AspectManagerHelper isTestingAPI:requestUrl]) {
                                      
                                      //config.json 파일을 토대로 config 객체 생성
                                      NSDictionary *config = [AspectManagerHelper getConfig];
                                      
                                      //응답 지연 시간
                                      NSInteger responseDelay = [[config objectForKey:@"simulated-delay"] integerValue];
                                      
                                      
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, responseDelay * NSEC_PER_MSEC),dispatch_get_main_queue(), ^(void){
                                          
                                          //선언된 테스팅 API 객체 생성
                                          NSDictionary *testingApi = [AspectManagerHelper getTestingAPI:requestUrl];
                                          
                                          //더미 헤더 생성
                                          NSDictionary *headers = [AspectManagerHelper getResponseDummyHeaderData:requestUrl];
                                          
                                          //응답 데이터 생성
                                          NSString *responseData = [AspectManagerHelper getResponseDummyBodyData:requestUrl];
                                          NSData *requestBodyData = [responseData dataUsingEncoding:NSUTF8StringEncoding];
                                          
                                          //Http 응답 코드 선언
                                          NSInteger statusCode = [[testingApi objectForKey:@"response-http-status"] integerValue];
                                          
                                          //Response 객체 생성
                                          NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:requestUrl]
                                                                                                    statusCode:statusCode
                                                                                                   HTTPVersion:nil
                                                                                                  headerFields:headers];
                                          
                                          //NSURLConnection Delegate 의 응답 객체 리스너 메소드를 직접 호출
                                          [[aspectRequestInfo.arguments objectAtIndex:1] connection:[NSURLConnection new]
                                                                                 didReceiveResponse:response];
                                          
                                          //NSURLConnection Delegate 의 응답 데이터 리스너 메소드를 직접 호출
                                          [[aspectRequestInfo.arguments objectAtIndex:1] connection:[NSURLConnection new]
                                                                                     didReceiveData:requestBodyData];
                                          
                                          //NSURLConnection Delegate 의 응답 완료 리스너 메소드를 직접 호출
                                          [[aspectRequestInfo.arguments objectAtIndex:1] connectionDidFinishLoading:[NSURLConnection new]];
                                          
                                      });
                                  }
                                  else {
                                      //발생된 서버 요청 URL이 테스트 등록된 URL이 아니라면
                                      //정상적으로 실제 서버 연결
                                      BOOL processTouches;
                                      NSInvocation *invocation = aspectRequestInfo.originalInvocation;
                                      [invocation invoke];
                                      [invocation getReturnValue:&processTouches];
                                      
                                      if (processTouches) {
                                          [invocation setReturnValue:&processTouches];
                                      }
                                  }
                                  
                              } error:NULL];
}

@end
