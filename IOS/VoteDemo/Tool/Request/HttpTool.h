

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SuccessBlock)(id _Nullable data);
typedef void(^FailureBlock)(NSString * _Nullable error);
@interface HttpTool : NSObject

+ (void)requestWithUrl:(NSString *)url withDictionary:(NSDictionary *)dic success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;
+ (void)encryDataRequest:(NSString *)response withUrl:(NSString *)url success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;
+ (void)getPublicKeySuccess:(SuccessBlock)successBlock;
@end

NS_ASSUME_NONNULL_END
