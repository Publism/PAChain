//
//  RYTRSAEncryptor.h
//  opensslTest
//


#import <Foundation/Foundation.h>
#import <openssl/rsa.h>

@interface RSAEncryptor : NSObject

@property (nonatomic, strong) NSString *PublicKey;
@property (nonatomic, strong) NSString *PrivateKey;

- (void)CreatekeyWith;

- (NSString *)encryptString:(NSString *)str;

+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;

+ (SecKeyRef)addPublicKey:(NSString *)key;

- (NSString *)decryptString:(NSString *)str;

+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey;

- (SecKeyRef)addPrivateKey:(NSString *)key;

@end

