

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo : NSObject
@property (nonatomic,copy)NSString *address;
@property (nonatomic,copy)NSString *state;
@property (nonatomic,copy)NSString *county;
@property (nonatomic,copy)NSString *email;
@property (nonatomic,copy)NSString *firstName;
@property (nonatomic,copy)NSString *middleName;
@property (nonatomic,copy)NSString *lastName;
@property (nonatomic,copy)NSString *nameSuffix;
@property (nonatomic,copy)NSString *mobileNumber;
@property (nonatomic,copy)NSString *precinctNumber;

@property (nonatomic,copy)NSString *signatureImageData;
@property (nonatomic,copy)NSString *imageData;
@property (nonatomic,copy)NSString *verifyPublickey;
@property (nonatomic,copy)NSString *publicKey;
@property (nonatomic,copy)NSString *privateKey;
@property (nonatomic,copy)NSString *ECPublicKey;
@property (nonatomic,copy)NSString *ECPrivateKey;
@property (nonatomic,copy)NSString *accessToken;
@property (nonatomic,copy)NSString *accessTokenSignature;
@property (nonatomic,copy)NSString *publicKeySignature;

@property (nonatomic,copy)NSString *signature;
@property (nonatomic,copy)NSString *voterId;
@property (nonatomic,copy)NSString *certificateType;
@property (nonatomic,copy)NSString *appAuthorizationId;
@property (nonatomic,copy)NSString *votedJson;
@property (nonatomic,copy)NSString *unSubmitVoteJson;
@property (nonatomic,copy)NSString *deviceVerifyDate;
@property (nonatomic,copy)NSString *userVerifyDate;
@property (nonatomic,copy)NSString *canTouchIDVerify;

@property (nonatomic,retain)NSArray *voteNumbers;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
