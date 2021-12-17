
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface votingProgressModel : NSObject
@property (nonatomic,assign)NSInteger count;
@property (nonatomic,copy)NSString *county;
@property (nonatomic,copy)NSString *precinctNumber;
@property (nonatomic,copy)NSString *candidateName;
@property (nonatomic,copy)NSString *state;
@property (nonatomic,copy)NSString *votingDate;
@property (nonatomic,copy)NSString *candidateID;
@property (nonatomic,copy)NSString *votingNumber;
@property (nonatomic,copy)NSString *verificationCode;

@end

NS_ASSUME_NONNULL_END
