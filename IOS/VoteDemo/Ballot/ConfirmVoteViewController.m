

#import "ConfirmVoteViewController.h"

@interface ConfirmVoteViewController ()<UITextFieldDelegate>{
    CustomTextfield *codeTF;
}
@property (nonatomic,retain)NSMutableArray *onionKeyArray;
@property (nonatomic,copy)NSString *encryptKey;
@property (nonatomic,copy)NSString *package;
@property (nonatomic,copy)NSString *encToken;
@end

@implementation ConfirmVoteViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    _onionKeyArray = [[NSMutableArray alloc]init];
    [self getOnionKey];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Ballots";
    _encryptKey = [[NSString alloc]init];
    _package = [[NSString alloc]init];
    [self configMainView];
}

- (void)configMainView{
    UILabel *tipLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(96)+Height_NavBar, FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40))];
    tipLab.text = @"Are you ready to submit your ballot?";
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(34)];
    tipLab.textColor = HexRGBAlpha(0x888888, 1);
    [self.view addSubview:tipLab];
    
    UIImageView *voteImage = [[UIImageView alloc]initWithFrame:CGRectMake((FUll_VIEW_WIDTH-YWIDTH_SCALE(276))/2, CGRectGetMaxY(tipLab.frame)+YHEIGHT_SCALE(56), YWIDTH_SCALE(276), YHEIGHT_SCALE(276))];
    voteImage.image = [UIImage imageNamed:@"vote"];
    [self.view addSubview:voteImage];
    
    UILabel *codeTip = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(voteImage.frame)+YHEIGHT_SCALE(56), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(80))];
    codeTip.text = @"Please enter any content (text, numbers, special symbols, etc.) as your verification code, which will be used to check whether the voting result of the election matches with your vote.";
    codeTip.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    codeTip.textColor = HexRGBAlpha(0x888888, 1);
    codeTip.numberOfLines = 0;
    [codeTip sizeToFit];
    [self.view addSubview:codeTip];
    
    codeTF = [[CustomTextfield alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(codeTip.frame)+YHEIGHT_SCALE(36), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72))];
    codeTF.insetX = 10;
    codeTF.delegate = self;
    codeTF.placeholder = @"Your code";
    codeTF.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:codeTF];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(YWIDTH_SCALE(60), CGRectGetMaxY(codeTF.frame)+YHEIGHT_SCALE(56), FUll_VIEW_WIDTH-YWIDTH_SCALE(120), YHEIGHT_SCALE(72));
    [submitBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
    [submitBtn setTitle:@"Submit" forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
}

- (void)submitBtnClick{
    if (codeTF.text.length > 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Check Information" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Use Fingerprint" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0){
                [VoteDemoHUD setHUD:@"TouchID is not supported in the system version"];
            }else{
                LAContext *laContext = [[LAContext alloc] init];
                laContext.localizedFallbackTitle = @"";
                NSError *error;
                if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
                    [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Please verify fingerprint" reply:^(BOOL success, NSError *error) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            if (success) {
                                if (![[UserManager userInfo].canTouchIDVerify isEqualToString:@"yes"]) {
                                    NSDictionary *userDic = @{@"canTouchIDVerify":@"yes"
                                    };
                                    [UserManager updateUserInfoWithDictionary:userDic];
                                }
                                [self submitVoteData];
                            }
                        });
                    }];
                }else {
                    switch (error.code) {
                        case LAErrorTouchIDNotEnrolled:{
                            [VoteDemoHUD setHUD:@"TouchID is not enrolled"];
                            NSLog(@"TouchID is not enrolled");
                            break;
                        }
                        case LAErrorPasscodeNotSet:{
                            [VoteDemoHUD setHUD:@"A passcode has not been set"];
                            NSLog(@"A passcode has not been set");
                            break;
                        }
                        default:{
                            [VoteDemoHUD setHUD:@"TouchID not available"];
                            NSLog(@"TouchID not available");
                            break;
                        }
                    }
                }
            }
        }];

//        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Use Signature" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//        }];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action];
//        [alertController addAction:action1];
        [alertController addAction:action2];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [VoteDemoHUD setHUD:@"Please Enter Your Code"];
    }
}

- (void)submitVoteData{
    [VoteDemoHUD showLoding];
    NSString *UUIDStr = [CustomMethodTool getUUID];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currrntDate = [formatter stringFromDate:date];
    NSMutableDictionary *mudic = [[NSMutableDictionary alloc]init];
    [mudic setObject:_votingData forKey:@"votingData"];
    [mudic setObject:currrntDate forKey:@"votingDate"];
    [mudic setObject:codeTF.text forKey:@"verificationCode"];
    [mudic setObject:[UserManager userInfo].state forKey:@"state"];
    [mudic setObject:[UserManager userInfo].county forKey:@"county"];
    [mudic setObject:[UserManager userInfo].precinctNumber forKey:@"precinctNumber"];
    NSString *encStr = [RSATool encryptString:[codeTF.text base64Encoded] publicKey:[UserManager userInfo].publicKey];
    [mudic setObject:encStr forKey:@"key"];
    self.encryptKey = [NSString stringWithFormat:@"%@",encStr];
    NSString *mudicJason = [CustomMethodTool toJsonStrWithDictionary:mudic];
    if (self.onionKeyArray.count > 0) {
        NSMutableArray *onionArray = [[NSMutableArray alloc]init];
        NSDictionary *encryDic = @{@"key":@"",
                                   @"package":@""
        };
        NSMutableDictionary *onionMuDic = [[NSMutableDictionary alloc]initWithDictionary:encryDic];
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_group_async(group, queue, ^{
            dispatch_group_async(group, queue, ^{
                dispatch_semaphore_t semaphore2 = dispatch_semaphore_create(0);
                dispatch_semaphore_signal(semaphore2);
                for (NSDictionary *onionDic in self.onionKeyArray) {
                    self.package = mudicJason;
                    NSArray *keyArray = onionDic[@"values"];
                    for (int i = 0; i <keyArray.count; i ++) {
                        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                        [HttpTool encryDataRequest:self.encryptKey withUrl:@"" success:^(id  _Nullable data) {
                            self.encryptKey = [NSString stringWithFormat:@"%@",data];
                            dispatch_semaphore_signal(semaphore);
                        } failure:^(NSString * _Nullable error) {
                            dispatch_semaphore_signal(semaphore);
                        }];
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        
                        [onionMuDic setObject:self.encryptKey forKey:@"key"];
                        NSString *onionKey = [NSString stringWithFormat:@"%@",keyArray[i]];
                        self.package = [RSATool encryptString:self.package publicKey:onionKey];
                        
                        [onionMuDic setObject:self.package forKey:@"package"];
                        if (i == keyArray.count-1) {
                        }else{
                            self.package = [CustomMethodTool toJsonStrWithDictionary:onionMuDic];
                        }
                    }
                    NSMutableDictionary *mmudic = [[NSMutableDictionary alloc]init];
                    [mmudic setObject:[UserManager userInfo].county.length>0?[UserManager userInfo].county:@"" forKey:@"county"];
                    [mmudic setObject:UUIDStr.length>0?UUIDStr:@"" forKey:@"votingnumber"];
                    [mmudic setObject:[onionDic objectForKey:@"key"] forKey:@"onionkey"];
                    [mmudic setObject:self.package forKey:@"packages"];
                    NSError *parseError = nil;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mmudic options:NSJSONWritingPrettyPrinted error:&parseError];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [onionArray addObject:jsonString];
                    dispatch_semaphore_signal(semaphore2);
                    dispatch_semaphore_wait(semaphore2, DISPATCH_TIME_FOREVER);
                }
                NSString *paramStr = [self toString:onionArray];
                NSString *accessToken = [UserManager userInfo].accessToken;
                NSString *privateKey = [UserManager userInfo].privateKey;
                if (accessToken.length > 0 && privateKey.length > 0) {
                    dispatch_semaphore_t semaphore3 = dispatch_semaphore_create(0);
                    NSDictionary *signDic =@{@"accessToken":accessToken,
                                            @"signature":[UserManager userInfo].accessTokenSignature,
                                            @"params":paramStr,
                                            @"votingDate":currrntDate,
                                            @"ballotNumber":self.ballotNumber,
                                            @"electionID":self.eleModel.electionid
                    };
                    [HttpTool encryDataRequest:[CustomMethodTool toJsonStrWithDictionary:signDic] withUrl:@"" success:^(id  _Nullable data) {
                        self.encToken = [NSString stringWithFormat:@"%@",data];
                        dispatch_semaphore_signal(semaphore3);
                    } failure:^(NSString * _Nullable error) {
                        dispatch_semaphore_signal(semaphore3);
                    }];
                    dispatch_semaphore_wait(semaphore3, DISPATCH_TIME_FOREVER);
                    NSDictionary *param = @{@"accessToken":accessToken,
                                            @"params":self.encToken.length>0?self.encToken:@""
                    };
                    [HttpTool requestWithUrl:@"vote" withDictionary:param success:^(id  _Nullable data) {
                        
                        if (self.votingData.count > 0) {
                            NSMutableArray *votedBallotArray = [[NSMutableArray alloc]init];
                            NSMutableDictionary *ballotVoteDic = [[NSMutableDictionary alloc]init];
                            for (NSDictionary *dic in self.votingData) {
                                ballotVoteDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
                                [ballotVoteDic setObject:self.ballotNumber forKey:@"ballotNumber"];
                                 if ([UserManager userInfo].votedJson.length > 0) {
                                     NSString *votejson = [RSATool decryptString:[UserManager userInfo].votedJson privateKey:[UserManager userInfo].privateKey];
                                     votedBallotArray = [[CustomMethodTool stringToJSONArray:votejson] mutableCopy];
                                     if (votedBallotArray.count > 0) {
                                         [votedBallotArray addObject:ballotVoteDic];
                                     }
                                 }else{
                                     [votedBallotArray addObject:ballotVoteDic];
                                 }
                            }
                            if (votedBallotArray.count > 0) {
                                NSString *jsonStr = [CustomMethodTool arrayToJSONString:votedBallotArray].length>0?[CustomMethodTool arrayToJSONString:votedBallotArray]:@"";
                                if (jsonStr.length > 0) {
                                    jsonStr = [RSATool encryptString:jsonStr publicKey:[UserManager userInfo].publicKey];
                                    NSDictionary *userDic = @{@"votedJson":jsonStr.length>0?jsonStr:@""};
                                    [UserManager updateUserInfoWithDictionary:userDic];
                                }
                            }
                        }
                        
                        if ([UserManager userInfo].voteNumbers.count > 0) {
                            NSMutableArray *muArray = [[UserManager userInfo].voteNumbers mutableCopy];
                            [muArray addObject:UUIDStr];
                            NSDictionary *userDic = @{@"voteNumbers":muArray};
                            [UserManager updateUserInfoWithDictionary:userDic];
                        }else{
                            NSMutableArray *muArray = [[NSMutableArray alloc] init];
                            [muArray addObject:UUIDStr];
                            NSDictionary *userDic = @{@"voteNumbers":muArray};
                            [UserManager updateUserInfoWithDictionary:userDic];
                        }
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"ballotrefresh" object:nil];
                        NSArray *pushVCAry=[self.navigationController viewControllers];
                        UIViewController *popVC=[pushVCAry objectAtIndex:pushVCAry.count-3];
                        [self.navigationController popToViewController:popVC animated:YES];
                        [VoteDemoHUD setHUD:@"Successfully"];
                        [VoteDemoHUD hideLoding];
                    } failure:^(NSString * _Nullable error) {
                        [VoteDemoHUD hideLoding];
                    }];
                }
            });
        });
    }
}

- (void)encrypWithPublicKey:(NSString *)encrypStr{
    [HttpTool encryDataRequest:encrypStr withUrl:@"" success:^(id  _Nullable data) {
        NSLog(@"1");
        self.encryptKey = [NSString stringWithFormat:@"%@",data];
    } failure:^(NSString * _Nullable error) {
        
    }];
}

- (void)encrypPackage:(NSString *)encrypP withKey:(NSString *)keyStr{
    [HttpTool encryDataRequest:encrypP withUrl:keyStr success:^(id  _Nullable data) {
        NSLog(@"2");
        self.package = [NSString stringWithFormat:@"%@",data];
    } failure:^(NSString * _Nullable error) {
        
    }];
}

- (void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [codeTF resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [codeTF resignFirstResponder];
}

- (void)getOnionKey{
    NSString *accessToken = [UserManager userInfo].accessToken;
    if (accessToken.length > 0) {
        NSString *signature = [UserManager userInfo].accessTokenSignature;
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_group_async(group, queue, ^{
            dispatch_group_async(group, queue, ^{
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                NSDictionary *signDic = @{@"signature":signature};
                [HttpTool encryDataRequest:[CustomMethodTool toJsonStrWithDictionary:signDic] withUrl:@"" success:^(id  _Nullable data) {
                    self.encToken = [NSString stringWithFormat:@"%@",data];
                    dispatch_semaphore_signal(semaphore);
                } failure:^(NSString * _Nullable error) {
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                NSDictionary *dic = @{@"accessToken":accessToken,
                                      @"params":self.encToken.length>0?self.encToken:@""
                };
                [HttpTool requestWithUrl:@"getonionkeys" withDictionary:dic success:^(id  _Nullable data) {
                    NSLog(@"==%@",data);
                    NSDictionary *response = data[@"response"];
                    self.onionKeyArray = response[@"data"];
                } failure:^(NSString * _Nullable error) {
                    
                }];
            });
        });
        
    }
}


- (NSString *)toString:(NSArray *)sourceArray{
    if (sourceArray.count == 0) {
        return @"";
    }
    
    NSString *str = @"[";
    for (int i = 0;i < sourceArray.count;i++) {
        if ([sourceArray[i] isKindOfClass:[NSString class]]) {
            str = [str stringByAppendingString:sourceArray[i]];
        }
        if (i == sourceArray.count - 1) {
            str = [str stringByAppendingString:@"]"];
        } else {
            str = [str stringByAppendingString:@","];
        }
    }
    return str;
}

@end
