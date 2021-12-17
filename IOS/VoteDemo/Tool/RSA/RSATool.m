//
//  RSATool.m
//  Power Voter
//


#import "RSATool.h"
#import "RSAEncryptor.h"
typedef enum {
    RSA_PADDING_TYPE_NONE       = RSA_NO_PADDING,
    RSA_PADDING_TYPE_PKCS1      = RSA_PKCS1_PADDING,
    RSA_PADDING_TYPE_SSLV23     = RSA_SSLV23_PADDING
}RSA_PADDING_TYPE;

#define  PADDING   RSA_PADDING_TYPE_PKCS1
@implementation RSATool

{
    RSA* _rsa_pub;
    RSA* _rsa_pri;
}

- (void)CreatekeyWith{
    RSAEncryptor * rsa =[[RSAEncryptor alloc] init];
    [rsa CreatekeyWith];
    _PublicKey = rsa.PublicKey;
    _PrivateKey = rsa.PrivateKey;
}
+(NSString *)decryptString:(NSString *)str privateKey:(NSString *)privateKey{
    
    return [RSAEncryptor decryptString:str privateKey:privateKey];
}
+(NSString *)encryptString:(NSString *)str publicKey:(NSString *)publicKey{
    return [RSAEncryptor encryptString:str publicKey:publicKey];
}


- (BOOL)importKeyWithType:(KeyType)type andkeyString:(NSString *)keyString
{
    if (!keyString) {
        return NO;
    }
    BOOL status = NO;
    BIO *bio = NULL;
    RSA *rsa = NULL;
    bio = BIO_new(BIO_s_file());
    NSString* temPath = NSTemporaryDirectory();
    NSString* rsaFilePath = [temPath stringByAppendingPathComponent:@"RSAKEY"];
    NSString* formatRSAKeyString = [self formatRSAKeyWithKeyString:keyString andKeytype:type];
    BOOL writeSuccess = [formatRSAKeyString writeToFile:rsaFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (!writeSuccess) {
        return NO;
    }
    const char* cPath = [rsaFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    BIO_read_filename(bio, cPath);
    if (type == KeyTypePrivate) {
        rsa = PEM_read_bio_RSAPrivateKey(bio, NULL, NULL, "");
        _rsa_pri = rsa;
        if (rsa != NULL && 1 == RSA_check_key(rsa)) {
            status = YES;
        } else {
            status = NO;
        }
        
        
    }
    else{
        rsa = PEM_read_bio_RSA_PUBKEY(bio, NULL, NULL, NULL);
        _rsa_pub = rsa;
        if (rsa != NULL) {
            status = YES;
        } else {
            status = NO;
        }
    }
    
    BIO_free_all(bio);
    [[NSFileManager defaultManager] removeItemAtPath:rsaFilePath error:nil];
    return status;
}

- (NSString*)formatRSAKeyWithKeyString:(NSString*)keyString andKeytype:(KeyType)type
{
    NSInteger lineNum = -1;
    NSMutableString *result = [NSMutableString string];
    
    if (type == KeyTypePrivate) {
        [result appendString:@"-----BEGIN PRIVATE KEY-----\n"];
        lineNum = 79;
    }else if(type == KeyTypePublic){
        [result appendString:@"-----BEGIN PUBLIC KEY-----\n"];
        lineNum = 76;
    }
    
    int count = 0;
    for (int i = 0; i < [keyString length]; ++i) {
        unichar c = [keyString characterAtIndex:i];
        if (c == '\n' || c == '\r') {
            continue;
        }
        [result appendFormat:@"%c", c];
        if (++count == lineNum) {
            [result appendString:@"\n"];
            count = 0;
        }
    }
    if (type == KeyTypePrivate) {
        [result appendString:@"\n-----END PRIVATE KEY-----"];
        
    }else if(type == KeyTypePublic){
        [result appendString:@"\n-----END PUBLIC KEY-----"];
    }
    return result;
}

- (BOOL)verifyString:(NSString *)string withSign:(NSString *)signString
{
    if (!_rsa_pub) {
        NSLog(@"please import public key first");
        return NO;
    }
    
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int messageLength = (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSData *signatureData = [[NSData alloc]initWithBase64EncodedString:signString options:0];
    unsigned char *sig = (unsigned char *)[signatureData bytes];
    unsigned int sig_len = (int)[signatureData length];
    
    
    
    
    unsigned char sha1[20];
    SHA1((unsigned char *)message, messageLength, sha1);
    int verify_ok = RSA_verify(NID_sha1
                               , sha1, 20
                               , sig, sig_len
                               , _rsa_pub);
    
    if (1 == verify_ok){
        return   YES;
    }
    return NO;
    
    
}

- (NSString *)signString:(NSString *)string
{
    if (!_rsa_pri) {
        NSLog(@"please import private key first");
        return nil;
    }
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int messageLength = (int)strlen(message);
    unsigned char *sig = (unsigned char *)malloc(256);
    unsigned int sig_len;
    
    unsigned char sha256[32];
    SHA256((unsigned char *)message, messageLength, sha256);
    
    int rsa_sign_valid = RSA_sign(NID_sha256
                                  , sha256, 32
                                  , sig, &sig_len
                                  , _rsa_pri);
    if (rsa_sign_valid == 1) {
        NSData* data = [NSData dataWithBytes:sig length:sig_len];
        
        NSString * base64String = [data base64EncodedStringWithOptions:0];
        free(sig);
        return base64String;
    }
    
    free(sig);
    return nil;
}

@end
