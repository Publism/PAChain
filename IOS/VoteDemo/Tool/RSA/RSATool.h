//
//  RSATool.h
//  Power Voter
//


#import <Foundation/Foundation.h>

typedef enum {
    KeyTypePublic = 0,
    KeyTypePrivate
}KeyType;

@interface RSATool : NSObject
@property (nonatomic, strong) NSString *PublicKey;
@property (nonatomic, strong) NSString *PrivateKey;

- (void)CreatekeyWith;


+(NSString *)decryptString:(NSString *)value privateKey:(NSString *)privateKey;

+(NSString *)encryptString:(NSString *)value publicKey:(NSString *)publicKey;



- (BOOL)importKeyWithType:(KeyType)type andkeyString:(NSString *)keyString;
- (NSString *)signString:(NSString *)string;
- (BOOL)verifyString:(NSString *)string withSign:(NSString *)signString;

@end
