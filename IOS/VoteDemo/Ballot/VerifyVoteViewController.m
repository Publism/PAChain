

#import "VerifyVoteViewController.h"

@interface VerifyVoteViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,retain)NSMutableArray *sourceKeyArray;
@property (nonatomic,retain)NSMutableDictionary *sourceDic;
@property (nonatomic,retain)UITableView *verifyTab;
@property (nonatomic,copy)NSString *encToken;
@end

@implementation VerifyVoteViewController

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
    self.title = @"Verify Vote";
    _sourceDic = [[NSMutableDictionary alloc]init];
    _sourceKeyArray = [[NSMutableArray alloc]init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMethod) name:@"verifyvotesuccess" object:nil];
    
    NSMutableArray *unVerifiedArray = [[NSMutableArray alloc]init];
    NSMutableArray *verifiedArray = [[NSMutableArray alloc]init];
    for (BallotListModel *model in _verifySourceArray) {
        if (model.isconfirm) {
            [verifiedArray addObject:model];
        }else{
            [unVerifiedArray addObject:model];
        }
    }
    if (unVerifiedArray.count > 0) {
        [_sourceKeyArray addObject:@"Unverified"];
        [_sourceDic setObject:unVerifiedArray forKey:@"Unverified"];
    }
    if (verifiedArray.count > 0) {
        [_sourceKeyArray addObject:@"Verified"];
        [_sourceDic setObject:verifiedArray forKey:@"Verified"];
    }
    
    [self verifyTab];
}

- (void)refreshMethod{
    NSString *accessToken = [UserManager userInfo].accessToken;
    NSString *privateKey = [UserManager userInfo].privateKey;
    if (accessToken.length > 0 && privateKey.length > 0) {
        [VoteDemoHUD showLoding];
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
            });
        });
        NSDictionary *dic = @{@"accessToken":accessToken,
                              @"params":self.encToken.length>0?self.encToken:@""
        };
        [HttpTool requestWithUrl:@"getballots" withDictionary:dic success:^(id  _Nullable data) {
            NSArray *dataArray = data[@"response"];
            if (dataArray.count > 0) {
                [self.sourceKeyArray removeAllObjects];
                [self.sourceDic removeAllObjects];
                NSMutableArray *unVerifiedArray = [[NSMutableArray alloc]init];
                NSMutableArray *verifiedArray = [[NSMutableArray alloc]init];
                for (NSDictionary *dataDic in dataArray) {
                    BallotListModel *model = [BallotListModel yy_modelWithDictionary:dataDic];
                    if (model.isconfirm) {
                        [verifiedArray addObject:model];
                    }else{
                        [unVerifiedArray addObject:model];
                    }
                }
                if (unVerifiedArray.count > 0) {
                    [self.sourceKeyArray addObject:@"Unverified"];
                    [self.sourceDic setObject:unVerifiedArray forKey:@"Unverified"];
                }
                if (verifiedArray.count > 0) {
                    [self.sourceKeyArray addObject:@"Verified"];
                    [self.sourceDic setObject:verifiedArray forKey:@"Verified"];
                }
            }
            [self verifyTab];
            [self.verifyTab reloadData];
            [VoteDemoHUD hideLoding];
        } failure:^(NSString * _Nullable error) {
            [self verifyTab];
            [VoteDemoHUD hideLoding];
        }];
    }
}

- (UITableView *)verifyTab{
    if (!_verifyTab) {
        _verifyTab = [[UITableView alloc]initWithFrame:CGRectMake(0, Height_NavBar, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar) style:UITableViewStyleGrouped];
        _verifyTab.backgroundColor = [UIColor whiteColor];
        _verifyTab.delegate = self;
        _verifyTab.dataSource = self;
        _verifyTab.tableFooterView = [UIView new];
        [self.view addSubview:_verifyTab];
    }
    return _verifyTab;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _sourceKeyArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = [_sourceDic objectForKey:_sourceKeyArray[section]];
    return  array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return YHEIGHT_SCALE(136);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return YHEIGHT_SCALE(100);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSArray *modelArray = [_sourceDic objectForKey:_sourceKeyArray[indexPath.section]];
    BallotListModel *model = modelArray[indexPath.row];
    NSString *ballotDate = [model.ballotdate transformDateStringWithFormat:@"yyyy-MM-dd" toformat:@"MMM. dd, yyyy"];
    
    UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(28), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40))];
    nameLab.textColor = HexRGBAlpha(0x075a93, 1);
    nameLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(32)];
    nameLab.text = model.ballotname;
    [cell.contentView addSubview:nameLab];
    
    UILabel *dateLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(nameLab.frame), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40))];
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
    titleLab.text = [NSString stringWithFormat:@"%@",_sourceKeyArray[section]];
    [headerView addSubview:titleLab];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *modelArray = [_sourceDic objectForKey:_sourceKeyArray[indexPath.section]];
    BallotListModel *model = modelArray[indexPath.row];
    BallotHomeViewController *vc = [[BallotHomeViewController alloc]init];
    vc.type = @"verify";
    vc.ballotModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
