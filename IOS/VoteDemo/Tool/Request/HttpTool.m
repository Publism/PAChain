

#import "HttpTool.h"

@implementation HttpTool

+ (void)requestWithUrl:(NSString *)url withDictionary:(NSDictionary *)dic success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock{
    NSString *Host = @"http://Server api url/api/voter/";
    NSString *httpUrl = [NSString stringWithFormat:@"%@%@",Host,url];
    
    NSString *encryKey = [[NSUserDefaults standardUserDefaults]objectForKey:@"encryptpublickey"];
    NSString *paraJson = [CustomMethodTool toJsonStrWithDictionary:dic];
    paraJson = [RSATool encryptString:paraJson publicKey:encryKey];
    paraJson = [NSString stringWithFormat:@"RSA_%@",paraJson];
    
    NSString *pathStr = [NSString stringWithFormat:@"params=%@",[CustomMethodTool stringBase64AndUrlEncode:paraJson]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *requestUrl = [NSURL URLWithString:httpUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [pathStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
        NSLog(@"%@:%@",url,dataDic);
        NSString *ret =[NSString stringWithFormat:@"%@",dataDic[@"ret"]];
        if (![ret isEqualToString:@"0"]) {
            if ([url isEqualToString:@"register"]) {
                NSDictionary *dic = @{@"publicKey":[UserManager userInfo].publicKey,
                                      @"signature":[UserManager userInfo].publicKeySignature
                };
                [self requestWithUrl:@"verify" withDictionary:dic success:^(id  _Nullable data) {
                    NSDictionary *resposeDic = data[@"response"];
                    NSString *accessToken = [NSString stringWithFormat:@"%@",resposeDic[@"accessToken"]];
                    NSString *pub = [NSString stringWithFormat:@"%@",resposeDic[@"publickey"]];
                    RSATool *rsa = [[RSATool alloc]init];
                    BOOL isKey = [rsa importKeyWithType:KeyTypePrivate andkeyString:[UserManager userInfo].privateKey];
                    NSString *signature = [[NSString alloc]init];
                    if (isKey) {
                        signature = [rsa signString:accessToken];
                    }
                    NSDictionary *para = @{@"verifyPublickey":pub,
                                           @"accessToken":accessToken,
                                           @"accessTokenSignature":signature.length>0?signature:@""
                    };
                    [UserManager updateUserInfoWithDictionary:para];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            successBlock(data);
                        });
                    });
                } failure:^(NSString * _Nullable error) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            failureBlock(error);
                        });
                    });
                }];
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        successBlock(dataDic);
                    });
                });
            } 
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock(@"error");
                });
            });
            NSLog(@"dataDic Error :%@",dataDic);
        }
        
        
    }];
    [dataTask resume];
}

+ (void)encryDataRequest:(NSString *)response withUrl:(NSString *)url success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock{
    if (url.length <= 0) {
        url = [UserManager userInfo].verifyPublickey;
    }
    NSDictionary *para = @{@"opt":@"e",
                           @"key":url,
                           @"data":response
    };
    NSString *httpUrl = @"http://Server api url/api/ead";
    NSString *encryKey = [[NSUserDefaults standardUserDefaults]objectForKey:@"encryptpublickey"];
    NSString *paraJson = [CustomMethodTool toJsonStrWithDictionary:para];
    paraJson = [RSATool encryptString:paraJson publicKey:encryKey];
    paraJson = [NSString stringWithFormat:@"RSA_%@",paraJson];
    
    NSString *pathStr = [NSString stringWithFormat:@"params=%@",[CustomMethodTool stringBase64AndUrlEncode:paraJson]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *requestUrl = [NSURL URLWithString:httpUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [pathStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
        NSString *ret =[NSString stringWithFormat:@"%@",dataDic[@"ret"]];
        if (![ret isEqualToString:@"0"]) {
            NSString *dataStr = [NSString stringWithFormat:@"%@",dataDic[@"data"]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock(dataStr);
                });
            });
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock([NSString stringWithFormat:@"%@",dataDic[@"error"]]);
                });
            });
        }
        
    }];
    [dataTask resume];
}

+ (void)getPublicKeySuccess:(SuccessBlock)successBlock{
    NSDictionary *dic = @{@"kp":@"rsa"};
    NSString *Host = @"http://Server api url/api/";
    NSString *url = @"getpublickey";
    NSString *httpUrl = [NSString stringWithFormat:@"%@%@",Host,url];
    NSString *pathStr = [[NSString alloc]init];
    for (NSString *key in dic) {
        if (pathStr.length <= 0) {
            pathStr = [NSString stringWithFormat:@"%@=%@",key,[dic objectForKey:key]];
        }else{
            pathStr = [NSString stringWithFormat:@"%@&%@=%@",pathStr,key,[dic objectForKey:key]];
        }
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *requestUrl = [NSURL URLWithString:httpUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [pathStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
        NSString *ret =[NSString stringWithFormat:@"%@",dataDic[@"ret"]];
        NSLog(@"%@:%@",url,dataDic);
        if ([ret isEqualToString:@"1"]) {
            NSString *dataStr = [NSString stringWithFormat:@"%@",dataDic[@"publicKey"]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock(dataStr);
                });
            });
        }
    }];
    [dataTask resume];
}

@end
