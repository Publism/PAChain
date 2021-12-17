

#import "BallotsViewController.h"


@interface BallotsViewController ()<UITableViewDelegate,UITableViewDataSource>;
@property (nonatomic,retain)NSMutableDictionary *sourceDic;
@property (nonatomic,retain)NSMutableArray *sourceKeyArray;
@property (nonatomic,retain)UITableView *ballotTab;
@property (nonatomic,retain)NSMutableArray *verifyBallotArray;
@property (nonatomic,assign)BOOL isSample;
@property (nonatomic,copy)NSString *encToken;
@property (nonatomic,retain)NSMutableArray *invitationArray;
@property (nonatomic,retain)NSMutableArray *inviteBallotNoArray;
@end

@implementation BallotsViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _sourceDic = [[NSMutableDictionary alloc]init];
    _sourceKeyArray = [[NSMutableArray alloc]init];
    _verifyBallotArray = [[NSMutableArray alloc]init];
    _invitationArray = [[NSMutableArray alloc]init];
    _inviteBallotNoArray = [[NSMutableArray alloc]init];
    _encToken = [[NSString alloc]init];
    self.title = @"GOTV";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(balltoRefresh) name:@"ballotrefresh" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(balltoRefresh) name:@"verifyvotesuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshInviteData) name:@"inviterefresh" object:nil];
    [self getInvitationList:YES];
}

- (void)refreshInviteData{
    [self getInvitationList:NO];
}

- (void)balltoRefresh{
    [self getBallots:YES];
}

- (void)getInvitationList:(BOOL)load{
    if (load) {
        [VoteDemoHUD showLoding];
    }
    NSString *signature = [UserManager userInfo].accessTokenSignature;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_group_async(group, queue, ^{
        dispatch_group_async(group, queue, ^{
            if (self.encToken.length <= 0) {
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                NSDictionary *signDic = @{@"signature":signature};
                [HttpTool encryDataRequest:[CustomMethodTool toJsonStrWithDictionary:signDic] withUrl:@"" success:^(id  _Nullable data) {
                    self.encToken = [NSString stringWithFormat:@"%@",data];
                    dispatch_semaphore_signal(semaphore);
                } failure:^(NSString * _Nullable error) {
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            NSDictionary *dic = @{@"accessToken":[UserManager userInfo].accessToken,
                                  @"params":self.encToken.length>0?self.encToken:@""
            };
            [HttpTool requestWithUrl:@"getvoteinvitestatus" withDictionary:dic success:^(id  _Nullable data) {
                NSString *ret= [NSString stringWithFormat:@"%@",data[@"ret"]];
                if ([ret isEqualToString:@"1"]) {
                    NSArray *response = data[@"response"];
                    if (response.count > 0) {
                        [self.invitationArray removeAllObjects];
                        [self.inviteBallotNoArray removeAllObjects];
                        for (NSDictionary *dic in response) {
                            NSString *electionKey = [NSString stringWithFormat:@"%@",dic[@"electionKey"]];
                            if ([electionKey isEqualToString:@"base"]) {
                                NSDictionary *dataDic = dic[@"data"];
                                if (dataDic != nil) {
                                    InvitationModel *model = [InvitationModel yy_modelWithDictionary:dataDic];
                                    [self.invitationArray addObject:model];
                                    if (model.status == 1 && model.ballotno.length>0) {
                                        [self.inviteBallotNoArray addObject:model.ballotno];
                                    }
                                }
                            }
                        }
                        [self getSampleBallot:NO];
                    }else{
                        [self getSampleBallot:NO];
                    }
                }else{
                    [self getSampleBallot:NO];
                }
                
            } failure:^(NSString * _Nullable error) {
                [self getSampleBallot:NO];
            }];
        });
    });
}

- (void)getSampleBallot:(BOOL)load{
    NSString *accessToken = [UserManager userInfo].accessToken;
    if (accessToken.length > 0) {
        if (load) {
            [VoteDemoHUD showLoding];
        }
        NSDictionary *dic = @{@"accessToken":accessToken,
                              @"params":self.encToken.length>0?self.encToken:@""
        };
        
        [HttpTool requestWithUrl:@"getsampleballot" withDictionary:dic success:^(id  _Nullable data) {
            NSString *ret = [NSString stringWithFormat:@"%@",data[@"ret"]];
            if ([ret isEqualToString:@"1"]) {
                NSDictionary *resopnse = data[@"response"];
                NSDictionary *dataDic = resopnse[@"data"];
                if (![dataDic isKindOfClass:[NSNull class]] && dataDic != nil) {
                    [self.sourceKeyArray removeAllObjects];
                    [self.sourceDic removeAllObjects];
                    [self.verifyBallotArray removeAllObjects];
                    NSMutableArray *upcomingArray = [[NSMutableArray alloc]init];
                    BallotListModel *model = [BallotListModel yy_modelWithDictionary:dataDic];
                    [upcomingArray addObject:model];
                    if (upcomingArray.count > 0) {
                        self.isSample = YES;
                        [self.sourceDic setObject:upcomingArray forKey:@"Upcoming Elections"];
                        [self.sourceKeyArray addObject:@"Upcoming Elections"];
                    }
                    [self getBallots:NO];
                }else{
                    [self getBallots:NO];
                }
            }else{
                [self getBallots:NO];
            }
        } failure:^(NSString * _Nullable error) {
            [self getBallots:NO];
        }];
    }
}

- (void)getBallots:(BOOL)load{
    NSString *accessToken = [UserManager userInfo].accessToken;
    if (accessToken.length > 0) {
        NSDictionary *dic = @{@"accessToken":accessToken,
                              @"params":self.encToken.length > 0?self.encToken:@""
        };
        if (load) {
            [VoteDemoHUD showLoding];
        }
        [HttpTool requestWithUrl:@"getballots" withDictionary:dic success:^(id  _Nullable data) {
            NSArray *dataArray = data[@"response"];
            if (dataArray.count > 0 && self.inviteBallotNoArray.count > 0) {
                [self.sourceKeyArray removeAllObjects];
                [self.sourceDic removeAllObjects];
                [self.verifyBallotArray removeAllObjects];
                NSMutableArray *upcomingArray = [[NSMutableArray alloc]init];
                NSMutableArray *resultArray = [[NSMutableArray alloc]init];
                for (NSDictionary *dataDic in dataArray) {
                    NSDictionary *dic = dataDic[@"data"];
                    if (![dic isKindOfClass:[NSNull class]] && dic != nil) {
                        BallotListModel *model = [BallotListModel yy_modelWithDictionary:dic];
                        if (model.isvoted) {
                            [self.verifyBallotArray addObject:model];
                        }
                        if ([self.inviteBallotNoArray containsObject:model.ballotno]) {
                            [upcomingArray addObject:model];
                            if (model.isopenvoting ) {
                                [resultArray addObject:model];
                            }
                        }
                    }
                }
                if (upcomingArray.count > 0 ) {
                    [self.sourceDic setObject:upcomingArray forKey:@"My Ballots"];
                    [self.sourceKeyArray addObject:@"My Ballots"];
                }
                if (resultArray.count > 0) {
                    [self.sourceDic setObject:resultArray forKey:@"Results"];
                    [self.sourceKeyArray addObject:@"Results"];
                }
                self.isSample = NO;
            }
            [self ballotTab];
            [self.ballotTab reloadData];
            [VoteDemoHUD hideLoding];
        } failure:^(NSString * _Nullable error) {
            [self ballotTab];
            [VoteDemoHUD hideLoding];
        }];
    }
}

- (UITableView *)ballotTab{
    if (!_ballotTab) {
        _ballotTab = [[UITableView alloc]initWithFrame:CGRectMake(0, Height_NavBar, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar) style:UITableViewStyleGrouped];
        _ballotTab.backgroundColor = [UIColor whiteColor];
        _ballotTab.bounces = NO;
        _ballotTab.delegate = self;
        _ballotTab.dataSource = self;
        [self.view addSubview:_ballotTab];
    }
    return _ballotTab;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1+_sourceKeyArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.invitationArray.count>0?5:4;
    }else{
        NSArray *array = [self.sourceDic objectForKey:self.sourceKeyArray[section-1]];
        return array.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return YHEIGHT_SCALE(136);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return YHEIGHT_SCALE(100);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        VerifycationCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[VerifycationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        if (_invitationArray.count > 0) {
            cell.hasInvite = YES;
        }
        cell.index = indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
        }
        NSArray *modelArray = [self.sourceDic objectForKey:self.sourceKeyArray[indexPath.section-1]];
        BallotListModel *model = modelArray[indexPath.row];
        NSString *ballotDate = [model.ballotdate transformDateStringWithFormat:@"yyyy-MM-dd" toformat:@"MMM. dd, yyyy"];
        
        UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(28), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40))];
        nameLab.textColor = HexRGBAlpha(0x075a93, 1);
        nameLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(32)];
        nameLab.text = model.ballotname;
        [cell.contentView addSubview:nameLab];
        
        UILabel *dateLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(nameLab.frame), (FUll_VIEW_WIDTH-YWIDTH_SCALE(60))/2, YHEIGHT_SCALE(40))];
        dateLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        dateLab.text = [NSString stringWithFormat:@"(%@)",ballotDate];
        [cell.contentView addSubview:dateLab];
        
        if (_isSample) {
            UILabel *sampleballot = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(dateLab.frame), dateLab.y, dateLab.width, dateLab.height)];
            sampleballot.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
            sampleballot.textColor = HexRGBAlpha(0x888888, 1);
            sampleballot.textAlignment = NSTextAlignmentRight;
            sampleballot.text = @"Sample Ballot";
            [cell.contentView addSubview:sampleballot];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = HexRGBAlpha(0xf6f6f6, 1);
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), 0, FUll_VIEW_WIDTH-YWIDTH_SCALE(30), YHEIGHT_SCALE(100))];
    titleLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(36)];
    titleLab.text = section==0?@"Verifications":self.sourceKeyArray[section-1];
    [headerView addSubview:titleLab];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]init];
    footerView.backgroundColor = [UIColor whiteColor];
    return footerView;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            NSLog(@"Invitation");
            if (_invitationArray.count > 0) {
                if (_invitationArray.count > 1) {
                    InvitationListViewController *vc = [[InvitationListViewController alloc]init];
                    vc.sourceArray = _invitationArray;
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    InvitationHomeViewController *vc = [[InvitationHomeViewController alloc]init];
                    vc.dataModel = [_invitationArray firstObject];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }else if (indexPath.row == 2 && _verifyBallotArray.count > 0) {
            VerifyVoteViewController *vc = [[VerifyVoteViewController alloc]init];
            vc.verifySourceArray = _verifyBallotArray;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        NSString *sectionKey = self.sourceKeyArray[indexPath.section-1];
        if ([sectionKey isEqualToString:@"My Ballots"] || [sectionKey isEqualToString:@"Upcoming Elections"]) {
            NSArray *modelArray = [self.sourceDic objectForKey:sectionKey];
            BallotHomeViewController *vc = [[BallotHomeViewController alloc]init];
            vc.ballotModel = modelArray[indexPath.row];
            vc.isSample = _isSample;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            NSArray *modelArray = [self.sourceDic objectForKey:sectionKey];
            ResultBallotViewController *vc = [[ResultBallotViewController alloc]init];
            vc.ballotModel = modelArray[indexPath.row];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)backClick{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)updateTouchIDStatus:(BOOL)status{
    NSDictionary *userDic = @{@"canTouchIDVerify":@(status)};
    [UserManager updateUserInfoWithDictionary:userDic];
}

@end
