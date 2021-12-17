

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [HttpTool getPublicKeySuccess:^(id  _Nullable data) {
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"encryptpublickey"];
    }];
    
    NSArray *stateCacheArray = [StateInfo getStateArray];
    if (stateCacheArray.count <= 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"StateInfo" ofType:@"txt"];
        NSString *JSONString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *stateDic = [CustomMethodTool stringToJSONDictionary:JSONString];
        NSArray *stateArray = stateDic[@"result"];
        [StateInfo saveStateInfo:stateArray];
    }
    
    NSArray *countyCacheArray = [CountyInfo getCountyArray];
    if (countyCacheArray.count <= 0) {
        NSString *countyPath = [[NSBundle mainBundle] pathForResource:@"CountyInfo" ofType:@"txt"];
        NSString *countyString = [NSString stringWithContentsOfFile:countyPath encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *countyDic = [CustomMethodTool stringToJSONDictionary:countyString];
        NSArray *countyArray = countyDic[@"result"];
        [CountyInfo saveCountyInfo:countyArray];
    }
    
    NSArray *precinctCacheArray = [PrecinctInfo getPrecinctArray];
    if (precinctCacheArray.count <= 0) {
        NSMutableArray *precintArray = [NSMutableArray array];
        NSString *filepath=[[NSBundle mainBundle] pathForResource:@"Precincts" ofType:@"csv"];
        FILE *fp = fopen([filepath UTF8String], "r");
        if (fp) {
            char buf[BUFSIZ];
            fgets(buf, BUFSIZ, fp);
            NSString *a = [[NSString alloc] initWithUTF8String:(const char *)buf];
            NSString *aa = [a stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            aa = [aa stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            aa = [aa stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSArray *b = [aa componentsSeparatedByString:@","];
            
            while (!feof(fp)) {
                char buff[BUFSIZ];
                fgets(buff, BUFSIZ, fp);
                NSString *s = [[NSString alloc] initWithUTF8String:(const char *)buff];
                NSString *ss = [s stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                ss = [ss stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                ss = [ss stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                NSArray *a = [ss componentsSeparatedByString:@","];
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                for (int i = 0; i < b.count ; i ++) {
                    dic[b[i]] = a[i];
                }
                [precintArray addObject:dic];
            }
            if (precintArray.count > 0) {
                [PrecinctInfo savePrecinctInfo:precintArray];
            }
        }
    }
    
    
    NSArray *linkCacheArray = [RegisterLinkModel getRegisterLinkArray];
    if (linkCacheArray.count <= 0) {
        NSMutableArray *soeLinkArray = [NSMutableArray array];
        NSString *linkfilepath=[[NSBundle mainBundle] pathForResource:@"Links" ofType:@"csv"];
        FILE *linkfp = fopen([linkfilepath UTF8String], "r");
        if (linkfp) {
            char buf[BUFSIZ];
            fgets(buf, BUFSIZ, linkfp);
            NSString *a = [[NSString alloc] initWithUTF8String:(const char *)buf];
            NSString *aa = [a stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            aa = [aa stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            aa = [aa stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSArray *b = [aa componentsSeparatedByString:@","];
            
            while (!feof(linkfp)) {
                char buff[BUFSIZ];
                fgets(buff, BUFSIZ, linkfp);
                NSString *s = [[NSString alloc] initWithUTF8String:(const char *)buff];
                NSString *ss = [s stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                ss = [ss stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                ss = [ss stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                NSArray *a = [ss componentsSeparatedByString:@","];
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                for (int i = 0; i < b.count ; i ++) {
                    dic[b[i]] = a[i];
                }
                [soeLinkArray addObject:dic];
            }
        }
        if (soeLinkArray.count > 0) {
            [RegisterLinkModel saveRegisterLinkInfo:soeLinkArray];
        }
        
    }
    
    if ([UserManager userInfo].privateKey.length <= 0 || [UserManager userInfo].publicKey.length <= 0) {
        RSATool *rsa = [[RSATool alloc]init];
        [rsa CreatekeyWith];
        BOOL sss = [rsa importKeyWithType:KeyTypePrivate andkeyString:rsa.PrivateKey];
        NSString *signature = [[NSString alloc]init];
        if (sss) {
            signature = [rsa signString:rsa.PublicKey];
        }
        NSDictionary *keyDic = @{@"privateKey":rsa.PrivateKey,
                                 @"publicKey":rsa.PublicKey,
                                 @"ECPublicKey":@"",
                                 @"ECPrivateKey":@"",
                                 @"county":@"",
                                  @"email":@"",
                                  @"firstName":@"",
                                  @"middleName":@"",
                                  @"lastName":@"",
                                 @"precinctNumber":@"",
                                 @"imageData":@"",
                                 @"state":@"",
                                 @"mobileNumber":@"",
                                 @"accessToken":@"",
                                 @"nameSuffix":@"",
                                 @"address":@"",
                                 @"publicKeySignature":signature.length > 0 ?signature:@"",
                                 @"accessTokenSignature":@""
        };
        [UserManager saveUserInfo:keyDic];
    }
    MainViewController *vc = [[MainViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    nav.navigationBar.barTintColor = HexRGBAlpha(0x075a93, 1);
    nav.navigationBar.tintColor = HexRGBAlpha(0xffffff, 1);
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: HexRGBAlpha(0xffffff, 1), NSFontAttributeName : [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(36)]};
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
