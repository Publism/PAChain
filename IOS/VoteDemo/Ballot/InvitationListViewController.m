//
//  InvitationListViewController.m
//  VoteDemo


#import "InvitationListViewController.h"

@interface InvitationListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,copy)NSString *encToken;
@property (nonatomic,retain)NSMutableDictionary *invitationDic;
@property (nonatomic,retain)UITableView *invitationTab;
@end

@implementation InvitationListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
}

- (void)backClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Invitation";
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData) name:@"inviterefresh" object:nil];
    
    _invitationDic = [[NSMutableDictionary alloc]init];
    if (_sourceArray.count > 0) {
        NSMutableArray *currentArray = [[NSMutableArray alloc]init];
        NSMutableArray *pastArray = [[NSMutableArray alloc]init];
        for (InvitationModel *model in _sourceArray) {
            if (model.status == 0) {
                [currentArray addObject:model];
            }else{
                [pastArray addObject:model];
            }
            if (currentArray.count > 0) {
                [self.invitationDic setObject:currentArray forKey:@"No response"];
            }
            if (pastArray.count > 0) {
                [self.invitationDic setObject:pastArray forKey:@"Responsed"];
            }
            [self invitationTab];
        }
    }else{
        [self getInvitationList:YES];
    }
    
}

- (void)refreshData{
    [self getInvitationList:NO];
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
                        [self.invitationDic removeAllObjects];
                        NSMutableArray *currentArray = [[NSMutableArray alloc]init];
                        NSMutableArray *pastArray = [[NSMutableArray alloc]init];
                        for (NSDictionary *dic in response) {
                            NSString *electionKey = [NSString stringWithFormat:@"%@",dic[@"electionKey"]];
                            if ([electionKey isEqualToString:@"base"]) {
                                NSDictionary *dataDic = dic[@"data"];
                                if (dataDic != nil) {
                                    InvitationModel *model = [InvitationModel yy_modelWithDictionary:dataDic];
                                    if (model.status == 0) {
                                        [currentArray addObject:model];
                                    }else{
                                        [pastArray addObject:model];
                                    }
                                }
                            }
                        }
                        if (currentArray.count > 0) {
                            [self.invitationDic setObject:currentArray forKey:@"No response"];
                        }
                        if (pastArray.count > 0) {
                            [self.invitationDic setObject:pastArray forKey:@"Responsed"];
                        }
                        [self invitationTab];
                        [VoteDemoHUD hideLoding];
                    }else{
                        [VoteDemoHUD hideLoding];
                        [VoteDemoHUD setHUD:@"No data"];
                    }
                }else{
                    [VoteDemoHUD hideLoding];
                }
                
            } failure:^(NSString * _Nullable error) {
                [VoteDemoHUD hideLoding];
            }];
        });
    });
}

- (UITableView *)invitationTab{
    if (!_invitationTab) {
        _invitationTab = [[UITableView alloc]initWithFrame:CGRectMake(0, Height_NavBar, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar) style:UITableViewStyleGrouped];
        _invitationTab.delegate = self;
        _invitationTab.dataSource = self;
        _invitationTab.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_invitationTab];
    }else{
        [_invitationTab reloadData];
    }
    return _invitationTab;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _invitationDic.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = [_invitationDic objectForKey:_invitationDic.allKeys[section]];
    return array.count;
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
    }
    NSArray *modelArray = [self.invitationDic objectForKey:self.invitationDic.allKeys[indexPath.section]];
    InvitationModel *model = modelArray[indexPath.row];
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]init];
    headerView.backgroundColor = HexRGBAlpha(0xf6f6f6, 1);
    
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), 0, FUll_VIEW_WIDTH-YWIDTH_SCALE(30), YHEIGHT_SCALE(100))];
    titleLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(36)];
    titleLab.text = self.invitationDic.allKeys[section];
    [headerView addSubview:titleLab];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]init];
    footerView.backgroundColor = [UIColor whiteColor];
    return footerView;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *modelArray = [self.invitationDic objectForKey:self.invitationDic.allKeys[indexPath.section]];
    InvitationHomeViewController *vc = [[InvitationHomeViewController alloc]init];
    vc.dataModel = modelArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
