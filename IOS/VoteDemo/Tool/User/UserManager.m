

#import "UserManager.h"
#import "UserInfo.h"

@implementation UserManager

NSString * const UserInfoKey = @"com.voteDemo.userinfo";

+ (BOOL)saveUserInfo:(NSDictionary *)dic
{
    [UserManager save:UserInfoKey data:dic];
    return YES;
}

+ (UserInfo *)userInfo
{
    id  data = [UserManager load:UserInfoKey];
    UserInfo *model = [[UserInfo alloc]initWithDictionary:data];
    return model;
}

+ (BOOL)updateUserInfoWithDictionary:(NSDictionary *)dic{
    NSDictionary *para = @{@"county":[UserManager userInfo].county.length>0?[UserManager userInfo].county:@"",
                           @"email":[UserManager userInfo].email.length>0?[UserManager userInfo].email:@"",
                           @"firstName":[UserManager userInfo].firstName.length>0?[UserManager userInfo].firstName:@"",
                           @"middleName":[UserManager userInfo].middleName.length>0?[UserManager userInfo].middleName:@"",
                           @"lastName":[UserManager userInfo].lastName.length>0?[UserManager userInfo].lastName:@"",
                           @"precinctNumber":[UserManager userInfo].precinctNumber.length>0?[UserManager userInfo].precinctNumber:@"",
                           @"imageData":[UserManager userInfo].imageData.length>0?[UserManager userInfo].imageData:@"",
                           @"state":[UserManager userInfo].state.length>0?[UserManager userInfo].state:@"",
                           @"mobileNumber":[UserManager userInfo].mobileNumber.length>0?[UserManager userInfo].mobileNumber:@"",
                           @"publicKey":[UserManager userInfo].publicKey.length>0?[UserManager userInfo].publicKey:@"",
                           @"privateKey":[UserManager userInfo].privateKey.length>0?[UserManager userInfo].privateKey:@"",
                           @"verifyPublickey":[UserManager userInfo].verifyPublickey.length>0?[UserManager userInfo].verifyPublickey:@"",
                           @"ECPublicKey":[UserManager userInfo].ECPublicKey.length>0?[UserManager userInfo].ECPublicKey:@"",
                           @"ECPrivateKey":[UserManager userInfo].ECPrivateKey.length>0?[UserManager userInfo].ECPrivateKey:@"",
                           @"accessToken":[UserManager userInfo].accessToken.length>0?[UserManager userInfo].accessToken:@"",
                           @"nameSuffix":[UserManager userInfo].nameSuffix.length>0?[UserManager userInfo].nameSuffix:@"",
                           @"address":[UserManager userInfo].address.length>0?[UserManager userInfo].address:@"",
                           @"accessTokenSignature":[UserManager userInfo].accessTokenSignature.length>0?[UserManager userInfo].accessTokenSignature:@"",
                           @"publicKeySignature":[UserManager userInfo].publicKeySignature.length>0?[UserManager userInfo].publicKeySignature:@"",
                           @"voterId":[UserManager userInfo].voterId.length>0?[UserManager userInfo].voterId:@"",
                           @"signature":[UserManager userInfo].signature.length>0?[UserManager userInfo].signature:@"",
                           @"certificateType":[UserManager userInfo].certificateType.length>0?[UserManager userInfo].certificateType:@"",
                           @"appAuthorizationId":[UserManager userInfo].appAuthorizationId.length>0?[UserManager userInfo].appAuthorizationId:@"",
                           @"votedJson":[UserManager userInfo].votedJson.length>0?[UserManager userInfo].votedJson:@"",
                           @"canTouchIDVerify":[UserManager userInfo].canTouchIDVerify.length>0?[UserManager userInfo].canTouchIDVerify:@"",
                           @"unSubmitVoteJson":[UserManager userInfo].unSubmitVoteJson.length>0?[UserManager userInfo].unSubmitVoteJson:@"",//
                           @"deviceVerifyDate":[UserManager userInfo].deviceVerifyDate.length>0?[UserManager userInfo].deviceVerifyDate:@"",
                           @"userVerifyDate":[UserManager userInfo].userVerifyDate.length>0?[UserManager userInfo].userVerifyDate:@"",
                           @"voteNumbers":[UserManager userInfo].voteNumbers.count>0?[UserManager userInfo].voteNumbers:@[],
                           @"signatureImageData":[UserManager userInfo].signatureImageData.length>0?[UserManager userInfo].signatureImageData:@""
                           
                          };
    NSMutableDictionary *mutable = [[NSMutableDictionary alloc]initWithDictionary:para];
    for (NSString *key in dic.allKeys) {
        if ([key isEqualToString:@"voteNumbers"]) {
            NSArray *array = [dic objectForKey:key];
            if (array.count > 0) {
                [mutable setObject:array forKey:key];
            }else{
                [mutable setObject:@[] forKey:key];
            }
        }else{
            NSString *obj = [dic objectForKey:key];
            if (obj.length > 0) {
                [mutable setObject:obj forKey:key];
            }else{
                [mutable setObject:@"" forKey:key];
            }
        }
    }
    [UserManager delete:UserInfoKey];
    [UserManager save:UserInfoKey data:mutable];
    return YES;
}

+ (NSMutableDictionary*) getKeychainQuery: (NSString*)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassGenericPassword, (id)kSecClass,service, (id)kSecAttrService,service, (id)kSecAttrAccount,(id)kSecAttrAccessibleAfterFirstUnlock, (id)kSecAttrAccessible,nil];
}

+ (BOOL) save:(NSString*)service data:(id)data {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    return SecItemAdd((CFDictionaryRef)keychainQuery, NULL) == noErr;
}

+ (id) load:(NSString*)service {
    id ret = NULL;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    NSData *keyData = NULL;
    if(SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef*)(void*)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:keyData];
        }@catch (NSException *exception) {
            NSLog(@"Unarchive of %@ failed: %@", service, exception);
        }
        @finally {}
    }
    return ret;

}

+ (void) delete:(NSString*)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

@end
