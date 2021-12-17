//
//  VotingProgressViewController.m
//  VoteDemo
//


#import "VotingProgressViewController.h"

@interface VotingProgressViewController ()
@property (nonatomic,retain)NSMutableArray *votedArray;
@property (nonatomic,copy)NSString *votePercent;
@property (nonatomic,copy)NSString *voteDate;
@property (nonatomic,retain)DropListView *startDateDrop;
@property (nonatomic,retain)DropListView *endDateDrop;
@property (nonatomic,retain)DropListView *stateDrop;
@property (nonatomic,retain)DropListView *countyDrop;
@property (nonatomic,retain)DropListView *seatDrop;
@property (nonatomic,retain)DropListView *districtDrop;
@property (nonatomic,retain)DropListView *precinctNumberDrop;
@property (nonatomic,retain)UIScrollView *dropScro;
@property (nonatomic,retain)UIScrollView *resultScro;
@property (nonatomic,assign)CGFloat dateMaxWidth;
@property (nonatomic,assign)CGFloat stateMaxWidth;
@property (nonatomic,assign)CGFloat countyMaxWidth;
@property (nonatomic,assign)CGFloat precinctWidth;
@property (nonatomic,assign)CGFloat numberMaxWidth;
@property (nonatomic,retain)NSMutableArray *widthArray;
@property (nonatomic,assign)BOOL isResult;
@property (nonatomic,retain)NSMutableDictionary *param;
@property (nonatomic,retain)NSMutableDictionary *seatDic;
@property (nonatomic,copy)NSString *encToken;
@end

@implementation VotingProgressViewController

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
    self.title = @"Voting Progress";
    _votedArray = [[NSMutableArray alloc]init];
    _widthArray = [[NSMutableArray alloc]init];
    _param = [[NSMutableDictionary alloc]init];
    _seatDic = [[NSMutableDictionary alloc]init];
    [self getElectionSeats];
    
    
}

- (void)getElectionSeats{
    [VoteDemoHUD showLoding];
    ElectionListModel *eleModel = [_ballotModel.elections firstObject];
    ElectionModel *electionModel = eleModel.election;
    NSArray *dateArray = [CustomMethodTool getMonthDate];
    NSString *starteDate = [dateArray lastObject];
    NSArray *array = [starteDate componentsSeparatedByString:@"/"];
    starteDate = [NSString stringWithFormat:@"%@-%@-%@",[array lastObject],[array firstObject],array[1]];
    NSString *endDate = [dateArray firstObject];
    NSArray *array2 = [endDate componentsSeparatedByString:@"/"];
    endDate = [NSString stringWithFormat:@"%@-%@-%@",[array2 lastObject],[array2 firstObject],array2[1]];
    NSDictionary *signDic = [[NSDictionary alloc]init];
    if (self.ballotModel.isopenvoting){
        signDic = @{@"offset":@"0",
                    @"limit":@"10000",
                    @"start":starteDate,
                    @"end":endDate,
                    @"seatID":@"",
                    @"electionID":electionModel.electionid,
                    @"state":[UserManager userInfo].state,
                    @"county":[UserManager userInfo].county,
                    @"precinctNumber":[UserManager userInfo].precinctNumber
        };
    }else{
        signDic = @{@"offset":@"0",
                    @"limit":@"10000",
                    @"start":starteDate,
                    @"end":endDate,
                    @"electionID":electionModel.electionid,
                    @"ballotNumber":self.ballotModel.ballotno,
                    @"state":[UserManager userInfo].state,
                    @"county":[UserManager userInfo].county,
                    @"precinctNumber":[UserManager userInfo].precinctNumber
        };
    }
    self.param = [[NSMutableDictionary alloc]initWithDictionary:signDic];
    NSDictionary *dic = @{@"electionID":electionModel.electionid};
    [HttpTool requestWithUrl:@"queryseatsbyelectionid" withDictionary:dic success:^(id  _Nullable data) {
        NSDictionary *dic = data[@"response"];
        NSArray *array = dic[@"data"];
        if (array.count > 0) {
            [self.seatDic removeAllObjects];
            [array enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SeatModel *model = [SeatModel yy_modelWithDictionary:obj];
                if ([self.seatDic.allKeys containsObject:model.office]) {
                    NSMutableArray *muarray = [[self.seatDic objectForKey:model.office] mutableCopy];
                    [muarray addObject:model];
                    [self.seatDic setObject:muarray forKey:model.office];
                }else{
                    NSMutableArray *muarray = [[NSMutableArray alloc]init];
                    [muarray addObject:model];
                    [self.seatDic setObject:muarray forKey:model.office];
                }
            }];
        }
        NSArray *muarray = [self.seatDic objectForKey:[self.seatDic.allKeys firstObject]];
        SeatModel *model = [muarray firstObject];
        [self.param setObject:@(model.seatid) forKey:@"seatID"];
        [self configMainView];
        if (self.ballotModel.isopenvoting) {
            [self getVotingProgressafter:NO];
        }else{
            [self getVotingProgressbefore:NO];
        }
    } failure:^(NSString * _Nullable error) {
        if (self.ballotModel.isopenvoting) {
            [self getVotingProgressafter:NO];
        }else{
            [self getVotingProgressbefore:NO];
        }
    }];
}

- (void)getVotingProgressafter:(BOOL)load{
    if (load) {
        [VoteDemoHUD showLoding];
    }
    ElectionListModel *eleModel = [_ballotModel.elections firstObject];
    
    [HttpTool requestWithUrl:@"queryvoteresult" withDictionary:_param success:^(id  _Nullable data) {
        NSString *ret = [NSString stringWithFormat:@"%@",data[@"ret"]];
        if ([ret isEqualToString:@"1"]) {
            NSDictionary *reponseDic = data[@"response"];
            NSArray *dataArray = reponseDic[@"data"];
            if (dataArray.count > 0) {
                self.isResult = YES;
                [self.votedArray removeAllObjects];
                [self.widthArray removeAllObjects];
                self.dateMaxWidth = 0;
                self.stateMaxWidth = 0;
                self.countyMaxWidth = 0;
                self.precinctWidth = 0;
                for (NSDictionary *dic in dataArray) {
                    votingProgressModel *model = [votingProgressModel yy_modelWithDictionary:dic];
                    model.votingDate = [CustomMethodTool getTimeFromTimestamp:[[model.votingDate substringToIndex:10] doubleValue] withFormat:@"MM/dd/yyyy"];
                    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
                    CGRect dateRect = [model.votingDate boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];

                    if (self.dateMaxWidth < dateRect.size.width) {
                        self.dateMaxWidth = dateRect.size.width;
                    }
                    
                    CGRect stateRect = [model.votingNumber boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
                    if (self.stateMaxWidth < stateRect.size.width) {
                        self.stateMaxWidth = stateRect.size.width;
                    }
                    NSString *candidateName = [[NSString alloc]init];
                    for (SeatListModel *seatModel in eleModel.seats) {
                        for (CandidateModel *candidateDic in seatModel.candidates) {
                            NSString *candidateID = [NSString stringWithFormat:@"%ld",(long)candidateDic.candidateid];
                            if ([candidateID isEqualToString:model.candidateID]) {
                                candidateName = candidateDic.name;
                                break;
                            }
                        }
                    }
                    
                    model.candidateID = candidateName;
                    CGRect countyRect = [candidateName boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
                    CGRect countyStrRect = [@"Voting Result" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
                    countyRect.size.width = countyRect.size.width>countyStrRect.size.width?countyRect.size.width:countyStrRect.size.width;
                    if (self.countyMaxWidth < countyRect.size.width) {
                        self.countyMaxWidth = countyRect.size.width;
                    }
                    CGRect precinctRect = [model.verificationCode boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
                    CGRect precinctStrRect = [@"Verification Code" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
                    precinctRect.size.width = precinctRect.size.width>precinctStrRect.size.width?precinctRect.size.width:precinctStrRect.size.width;
                    if (self.precinctWidth < precinctRect.size.width) {
                        self.precinctWidth = precinctRect.size.width;
                    }
                    [self.votedArray addObject:model];
                }
                [self.widthArray addObject:@(self.dateMaxWidth)];
                [self.widthArray addObject:@(self.stateMaxWidth)];
                [self.widthArray addObject:@(self.countyMaxWidth)];
                [self.widthArray addObject:@(self.precinctWidth)];

                [self configDataView];
                [VoteDemoHUD hideLoding];
            }else{
                if (self.resultScro) {
                    for (UIView *view in self.resultScro.subviews) {
                        [view removeFromSuperview];
                    }
                    [self.resultScro removeFromSuperview];
                }
                [VoteDemoHUD hideLoding];
                [VoteDemoHUD setHUD:@"No Data"];
            }
        }
        
    } failure:^(NSString * _Nullable error) {
        [VoteDemoHUD hideLoding];
        NSLog(@"some mistake");
    }];
}

- (void)getVotingProgressbefore:(BOOL)load{
    if (load) {
        [VoteDemoHUD showLoding];
    }
    [HttpTool requestWithUrl:@"queryvoted" withDictionary:_param success:^(id  _Nullable data) {
        NSString *ret = [NSString stringWithFormat:@"%@",data[@"ret"]];
        NSLog(@"%@",data);
        if ([ret isEqualToString:@"1"]) {
            NSDictionary *responseDic = data[@"response"];
            if (![responseDic isKindOfClass:[NSNull class]]) {
                NSArray *dataArray = responseDic[@"data"];
                if (dataArray.count > 0) {
                    [self.votedArray removeAllObjects];
                    [self.widthArray removeAllObjects];
                    self.dateMaxWidth = 0;
                    self.stateMaxWidth = 0;
                    self.countyMaxWidth = 0;
                    self.precinctWidth = 0;
                    self.numberMaxWidth = 0;
                    for (NSDictionary *dic in dataArray) {
                        votingProgressModel *model = [votingProgressModel yy_modelWithDictionary:dic];
                        model.votingDate = [CustomMethodTool getTimeFromTimestamp:[[model.votingDate substringToIndex:10] doubleValue] withFormat:@"MM/dd/yyyy"];
                        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
                        CGRect dateRect = [model.votingDate boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];

                        if (self.dateMaxWidth < dateRect.size.width) {
                            self.dateMaxWidth = dateRect.size.width;
                        }
                        StateInfo *staInfo = [StateInfo getStateInfoWithShortName:model.state];
                        model.state = staInfo.name;
                        CGRect stateRect = [staInfo.name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
                        if (self.stateMaxWidth < stateRect.size.width) {
                            self.stateMaxWidth = stateRect.size.width;
                        }
                        CountyInfo *couInfo = [CountyInfo getCountyInfoWithCode:model.county];
                        model.county = couInfo.name;
                        CGRect countyRect = [couInfo.name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
                        if (self.countyMaxWidth < countyRect.size.width) {
                            self.countyMaxWidth = countyRect.size.width;
                        }
                        CGRect precinctRect = [model.precinctNumber boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
                        CGRect precinctStrRect = [@"Precinct" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
                        precinctRect.size.width = precinctRect.size.width>precinctStrRect.size.width?precinctRect.size.width:precinctStrRect.size.width;
                        if (self.precinctWidth < precinctRect.size.width) {
                            self.precinctWidth = precinctRect.size.width;
                        }
                        CGRect numberRect = [@"Number of Voting" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
                        if (self.numberMaxWidth < numberRect.size.width) {
                            self.numberMaxWidth = numberRect.size.width;
                        }
                        [self.votedArray addObject:model];
                    }
                    [self.widthArray addObject:@(self.dateMaxWidth)];
                    [self.widthArray addObject:@(self.stateMaxWidth)];
                    [self.widthArray addObject:@(self.countyMaxWidth)];
                    [self.widthArray addObject:@(self.precinctWidth)];
                    [self.widthArray addObject:@(self.numberMaxWidth)];

                    [self configDataView];
                    [VoteDemoHUD hideLoding];
                }else{
                    if (self.resultScro) {
                        for (UIView *view in self.resultScro.subviews) {
                            [view removeFromSuperview];
                        }
                        [self.resultScro removeFromSuperview];
                    }
                    [VoteDemoHUD hideLoding];
                    [VoteDemoHUD setHUD:@"No Data"];
                }
            }
        }
    } failure:^(NSString * _Nullable error) {
        [VoteDemoHUD hideLoding];
        NSLog(@"some mistake");
    }];
    
}

- (void)configMainView{
    UILabel *electionNameLab = [[UILabel alloc]init];
    electionNameLab.textAlignment = NSTextAlignmentCenter;
    electionNameLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(34)];
    electionNameLab.frame = CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(40)+Height_NavBar, FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40));
    electionNameLab.text = _ballotModel.ballotname;
    [self.view addSubview:electionNameLab];
    
    UILabel *eleDateLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(electionNameLab.frame), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(30))];
    eleDateLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(32)];
    eleDateLab.textAlignment = NSTextAlignmentCenter;
    eleDateLab.text = [_ballotModel.ballotdate transformDateStringWithFormat:@"yyyy-MM-dd" toformat:@"MMM. dd, yyyy"];
    [self.view addSubview:eleDateLab];
    
    _dropScro = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(eleDateLab.frame)+YHEIGHT_SCALE(40), FUll_VIEW_WIDTH, YHEIGHT_SCALE(240))];
    _dropScro.backgroundColor = [UIColor whiteColor];
    _dropScro.bounces = NO;
    _dropScro.showsVerticalScrollIndicator = NO;
    _dropScro.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_dropScro];
    
    CGFloat allWidth = (FUll_VIEW_WIDTH-YWIDTH_SCALE(152))/2;
    //State
    NSArray *stateInfoArray = [StateInfo getStateArray];
    NSMutableArray *stateArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < stateInfoArray.count; i ++) {
        StateInfo *info = stateInfoArray[i];
        DropdownListItem *item = [[DropdownListItem alloc] initWithItem:[NSString stringWithFormat:@"%@",info.code] itemName:info.name];
        [stateArray addObject:item];
    }
    
    _stateDrop = [[DropListView alloc] initWithDataSource:stateArray];
    _stateDrop.frame = CGRectMake(YWIDTH_SCALE(30), 0, (FUll_VIEW_WIDTH-YWIDTH_SCALE(80))/2, YHEIGHT_SCALE(70));
    StateInfo *staInfo = [StateInfo getStateInfoWithShortName:[UserManager userInfo].state];
    DropdownListItem *item = [[DropdownListItem alloc] init];
    for (DropdownListItem *iitem in stateArray) {
        if ([staInfo.name isEqualToString:iitem.itemName]) {
            item = iitem;
            break;
        }
    }
    _stateDrop.selectedIndex = [stateArray indexOfObject:item];
    _stateDrop.layer.borderWidth = 1;
    _stateDrop.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
    _stateDrop.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    _stateDrop.textColor = [UIColor blackColor];
    [_dropScro addSubview:_stateDrop];
    
    __weak typeof(self) weakSelf = self;
    [_stateDrop setDropdownListViewSelectedBlock:^(DropListView *dropdownListView) {
        NSArray *array = [CountyInfo getCountyInfoWithStateName:dropdownListView.selectedItem.itemId];
        NSMutableArray *countyArray = [[NSMutableArray alloc]init];
        DropdownListItem *countyItem = [[DropdownListItem alloc]initWithItem:@"10000" itemName:@"All"];
        [countyArray addObject:countyItem];
        for (CountyInfo *info in array) {
            DropdownListItem *item = [[DropdownListItem alloc]initWithItem:info.code itemName:info.name];
            [countyArray addObject:item];
        }
        weakSelf.countyDrop.dataSource = countyArray;
        weakSelf.countyDrop.selectedIndex = 0;
        
        NSMutableArray *precinctArray = [[NSMutableArray alloc]init];
        DropdownListItem *preItem2 = [[DropdownListItem alloc]initWithItem:@"10000" itemName:@"All"];
        [precinctArray addObject:preItem2];
        weakSelf.precinctNumberDrop.dataSource = precinctArray;
        weakSelf.precinctNumberDrop.selectedIndex = 0;
    }];
    
    //County
    NSArray *countyInfoArray = [CountyInfo getCountyInfoWithStateName:_stateDrop.selectedItem.itemId];
    NSMutableArray *countyArray = [[NSMutableArray alloc]init];
    DropdownListItem *countyItem = [[DropdownListItem alloc] initWithItem:[NSString stringWithFormat:@"%d",100000] itemName:@"All"];
    [countyArray addObject:countyItem];
    for (CountyInfo *info in countyInfoArray) {
        DropdownListItem *item = [[DropdownListItem alloc]initWithItem:info.code itemName:info.name];
        [countyArray addObject:item];
    }
    _countyDrop = [[DropListView alloc] initWithDataSource:countyArray];
    _countyDrop.frame = CGRectMake(CGRectGetMaxX(_stateDrop.frame)+YWIDTH_SCALE(20), _stateDrop.y, (FUll_VIEW_WIDTH-YWIDTH_SCALE(80))/2, YHEIGHT_SCALE(70));
    CountyInfo *couInfo = [CountyInfo getCountyInfoWithCode:[UserManager userInfo].county];
    DropdownListItem *coutyItem = [[DropdownListItem alloc] init];
    for (DropdownListItem *iitem in countyArray) {
        if ([couInfo.name isEqualToString:iitem.itemName]) {
            coutyItem = iitem;
            break;
        }
    }
    _countyDrop.selectedIndex = [countyArray indexOfObject:coutyItem];
    _countyDrop.layer.borderWidth = 1;
    _countyDrop.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
    _countyDrop.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    _countyDrop.textColor = [UIColor blackColor];
    [_dropScro addSubview:_countyDrop];

    [_countyDrop setDropdownListViewSelectedBlock:^(DropListView *dropdownListView) {
        NSMutableArray *precinctArray = [[NSMutableArray alloc]init];
        DropdownListItem *preItem2 = [[DropdownListItem alloc]initWithItem:@"10000" itemName:@"All"];
        [precinctArray addObject:preItem2];
        NSMutableArray *temArray = [[NSMutableArray alloc]init];
        NSArray *precinctInfoArray = [PrecinctInfo getPrecinctInfoWithState:weakSelf.stateDrop.selectedItem.itemName withCounty:weakSelf.countyDrop.selectedItem.itemId];
        for (PrecinctInfo *info in precinctInfoArray) {
            DropdownListItem *preItem = [[DropdownListItem alloc]initWithItem:info.CountyNumber itemName:info.PrecinctNumber];
            [temArray addObject:preItem];
        }
        temArray = (NSMutableArray *) [temArray sortedArrayUsingComparator:^NSComparisonResult(DropdownListItem * _Nonnull obj1, DropdownListItem *  _Nonnull obj2) {
            return [obj1.itemName compare:obj2.itemName options:NSNumericSearch];
        }];
        [precinctArray addObjectsFromArray:temArray];
        weakSelf.precinctNumberDrop.dataSource = precinctArray;
        weakSelf.precinctNumberDrop.selectedIndex = 0;
    }];
    
    //Precinct
    NSMutableArray *precinctArray = [[NSMutableArray alloc]init];
    DropdownListItem *preItem2 = [[DropdownListItem alloc]initWithItem:@"10000" itemName:@"All"];
    [precinctArray addObject:preItem2];
    NSMutableArray *temArray = [[NSMutableArray alloc]init];
    NSArray *precinctInfoArray = [PrecinctInfo getPrecinctInfoWithState:_stateDrop.selectedItem.itemName withCounty:_countyDrop.selectedItem.itemId];
    for (PrecinctInfo *info in precinctInfoArray) {
        DropdownListItem *preItem = [[DropdownListItem alloc]initWithItem:info.CountyNumber itemName:info.PrecinctNumber];
        [temArray addObject:preItem];
    }
    temArray = (NSMutableArray *) [temArray sortedArrayUsingComparator:^NSComparisonResult(DropdownListItem * _Nonnull obj1, DropdownListItem *  _Nonnull obj2) {
        return [obj1.itemName compare:obj2.itemName options:NSNumericSearch];
    }];
    [precinctArray addObjectsFromArray:temArray];
    _precinctNumberDrop = [[DropListView alloc] initWithDataSource:precinctArray];
    _precinctNumberDrop.frame = CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(80), allWidth/2, YHEIGHT_SCALE(70));
    PrecinctInfo *preIitem = [PrecinctInfo getPrecinctInfoWithPrecinctNumber:[UserManager userInfo].precinctNumber];
    DropdownListItem *precinctItem = [[DropdownListItem alloc] init];
    for (DropdownListItem *iitem in precinctArray) {
        if ([preIitem.PrecinctNumber isEqualToString:iitem.itemName]) {
            precinctItem = iitem;
            break;
        }
    }
    _precinctNumberDrop.selectedIndex = [precinctArray indexOfObject:precinctItem];
    _precinctNumberDrop.layer.borderWidth = 1;
    _precinctNumberDrop.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
    _precinctNumberDrop.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    _precinctNumberDrop.textColor = [UIColor blackColor];
    [_dropScro addSubview:_precinctNumberDrop];
    
    //Seat
    NSMutableArray *seatArray = [[NSMutableArray alloc]init];
    if (self.seatDic.allKeys.count > 0) {
        for (NSString *seatName in self.seatDic.allKeys) {
            NSArray *modelArray = [self.seatDic objectForKey:seatName];
            SeatModel *model = [modelArray firstObject];
            DropdownListItem *seatItem = [[DropdownListItem alloc]initWithItem:[NSString stringWithFormat:@"%ld",(long)model.seatid] itemName:seatName];
            [seatArray addObject:seatItem];
        }
    }
    _seatDrop = [[DropListView alloc] initWithDataSource:seatArray];
    _seatDrop.frame = CGRectMake(CGRectGetMaxX(_precinctNumberDrop.frame)+YWIDTH_SCALE(20), YHEIGHT_SCALE(80), allWidth/2+allWidth/4, YHEIGHT_SCALE(70));
    _seatDrop.selectedIndex = 0;
    _seatDrop.layer.borderWidth = 1;
    _seatDrop.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
    _seatDrop.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    _seatDrop.textColor = [UIColor blackColor];
    [_dropScro addSubview:_seatDrop];
    
    [_seatDrop setDropdownListViewSelectedBlock:^(DropListView *dropdownListView) {
        NSMutableArray *districtArray = [[NSMutableArray alloc]init];
        NSArray *array = [weakSelf.seatDic objectForKey:dropdownListView.selectedItem.itemName];
        [weakSelf.param setObject:dropdownListView.selectedItem.itemId forKey:@"seatID"];
        for (SeatModel *model in array) {
            if (![model.name isEqualToString:@"President"]) {
                DropdownListItem *seatItem = [[DropdownListItem alloc]initWithItem:[NSString stringWithFormat:@"%ld",(long)model.seatid] itemName:model.name];
                [districtArray addObject:seatItem];
            }
        }
        if (districtArray.count <= 0) {
            DropdownListItem *seatItem = [[DropdownListItem alloc]initWithItem:@"" itemName:@""];
            [districtArray addObject:seatItem];
        }
        weakSelf.districtDrop.dataSource = districtArray;
        weakSelf.districtDrop.selectedIndex = 0;
    }];
    
    NSMutableArray *districtArray = [[NSMutableArray alloc]init];
    if (self.seatDic.allKeys.count > 0) {
        NSArray *array = [self.seatDic objectForKey:[self.seatDic.allKeys firstObject]];
        for (SeatModel *model in array) {
            if (![model.name isEqualToString:@"President"]) {
                DropdownListItem *seatItem = [[DropdownListItem alloc]initWithItem:[NSString stringWithFormat:@"%ld",(long)model.seatid] itemName:model.name];
                [districtArray addObject:seatItem];
            }
        }
    }
    _districtDrop = [[DropListView alloc] initWithDataSource:districtArray];
    _districtDrop.frame = CGRectMake(CGRectGetMaxX(_precinctNumberDrop.frame)+YWIDTH_SCALE(20)+allWidth/2+allWidth/4+YWIDTH_SCALE(20), YHEIGHT_SCALE(80), FUll_VIEW_WIDTH-(CGRectGetMaxX(_precinctNumberDrop.frame)+YWIDTH_SCALE(20)+allWidth/2+allWidth/4+YWIDTH_SCALE(20))-YWIDTH_SCALE(30), YHEIGHT_SCALE(70));
    _districtDrop.selectedIndex = 0;
    _districtDrop.layer.borderWidth = 1;
    _districtDrop.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
    _districtDrop.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    _districtDrop.textColor = [UIColor blackColor];
    [_dropScro addSubview:_districtDrop];
    
    [_districtDrop setDropdownListViewSelectedBlock:^(DropListView *dropdownListView) {
        if (dropdownListView.selectedItem.itemName.length > 0) {
            for (DropdownListItem *seatItem in weakSelf.districtDrop.dataSource) {
                if ([seatItem.itemName isEqualToString:dropdownListView.selectedItem.itemName]) {
                    [weakSelf.param setObject:dropdownListView.selectedItem.itemId forKey:@"seatID"];
                }
            }
        }
    }];
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect dateRect = [@"00/00/0000" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, YHEIGHT_SCALE(40)) options:options attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)]} context:nil];
    
    NSArray *dateArray = [CustomMethodTool getMonthDate];
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:dateArray];
    tempArray = (NSMutableArray *)[[tempArray reverseObjectEnumerator] allObjects];
    NSMutableArray *startDateArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < tempArray.count; i ++) {
        DropdownListItem *item = [[DropdownListItem alloc] initWithItem:[NSString stringWithFormat:@"%d",i+1] itemName:tempArray[i]];
        [startDateArray addObject:item];
    }
    _startDateDrop = [[DropListView alloc] initWithDataSource:startDateArray];
    _startDateDrop.frame = CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(160), dateRect.size.width+YWIDTH_SCALE(90), YHEIGHT_SCALE(70));
    _startDateDrop.selectedIndex = 0;
    _startDateDrop.layer.borderWidth = 1;
    _startDateDrop.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
    _startDateDrop.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    _startDateDrop.textColor = [UIColor blackColor];
    [_dropScro addSubview:_startDateDrop];
    
    NSMutableArray *endDateArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < dateArray.count; i ++) {
        DropdownListItem *item = [[DropdownListItem alloc] initWithItem:[NSString stringWithFormat:@"%d",i+1] itemName:dateArray[i]];
        [endDateArray addObject:item];
    }
    _endDateDrop = [[DropListView alloc] initWithDataSource:endDateArray];
    _endDateDrop.frame = CGRectMake(CGRectGetMaxX(_startDateDrop.frame)+YWIDTH_SCALE(20), YHEIGHT_SCALE(160), dateRect.size.width+YWIDTH_SCALE(90), YHEIGHT_SCALE(70));
    _endDateDrop.selectedIndex = 0;
    _endDateDrop.layer.borderWidth = 1;
    _endDateDrop.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
    _endDateDrop.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
    _endDateDrop.textColor = [UIColor blackColor];
    [_dropScro addSubview:_endDateDrop];
    
    UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    goBtn.frame = CGRectMake(CGRectGetMaxX(_endDateDrop.frame)+YWIDTH_SCALE(20), _endDateDrop.y, allWidth/2, YHEIGHT_SCALE(70));
    [goBtn setTitle:@"GO" forState:UIControlStateNormal];
    [goBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
    [goBtn addTarget:self action:@selector(goMethod) forControlEvents:UIControlEventTouchUpInside];
    [_dropScro addSubview:goBtn];
    
    _dropScro.contentSize = CGSizeMake(FUll_VIEW_WIDTH, CGRectGetMaxY(goBtn.frame));
    
}

- (void)goMethod{
    StateInfo *staInfo = [StateInfo getStateInfoWithName:_stateDrop.selectedItem.itemName];
    [_param setObject:staInfo.shortName.length>0?staInfo.shortName:@"" forKey:@"state"];
    [_param setObject:[_countyDrop.selectedItem.itemName isEqualToString:@"All"]?@"":_countyDrop.selectedItem.itemId forKey:@"county"];
    [_param setObject:[_precinctNumberDrop.selectedItem.itemName isEqualToString:@"All"]?@"":_precinctNumberDrop.selectedItem.itemName forKey:@"precinctNumber"];
    NSArray *array = [_startDateDrop.selectedItem.itemName componentsSeparatedByString:@"/"];
    NSString *startDate = [NSString stringWithFormat:@"%@-%@-%@",[array lastObject],[array firstObject],array[1]];
    NSArray *array2 = [_endDateDrop.selectedItem.itemName componentsSeparatedByString:@"/"];
    NSString *endDate = [NSString stringWithFormat:@"%@-%@-%@",[array2 lastObject],[array2 firstObject],array2[1]];
    [_param setObject:startDate forKey:@"start"];
    [_param setObject:endDate forKey:@"end"];
    if (_ballotModel.isopenvoting) {
        [self getVotingProgressafter:YES];
    }else{
        [self getVotingProgressbefore:YES];
    }
}

- (void)configDataView{
    if (self.resultScro) {
        for (UIView *view in self.resultScro.subviews) {
            [view removeFromSuperview];
        }
        [self.resultScro removeFromSuperview];
    }
    _resultScro = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_dropScro.frame)+YHEIGHT_SCALE(20), FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-CGRectGetMaxY(_dropScro.frame)-YHEIGHT_SCALE(20))];
    _resultScro.backgroundColor = [UIColor whiteColor];
    _resultScro.bounces = NO;
    [self.view addSubview:_resultScro];

    CGFloat scrollWidth = 0;
    CGFloat scrollHeight = (_votedArray.count+1)*YHEIGHT_SCALE(60)+YHEIGHT_SCALE(30);
    CGFloat titleX = YWIDTH_SCALE(30);
    int count = _isResult?4:5;
    for (int i = 0; i < count; i ++) {
        UILabel *titleLab= [[UILabel alloc]initWithFrame:CGRectMake(titleX, 0, [_widthArray[i] floatValue]+YWIDTH_SCALE(20), YHEIGHT_SCALE(60))];
        titleLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        if (_isResult) {
            if (i == 0) {
                titleLab.text = @"Date";
            }else if (i == 1){
                titleLab.text = @"Voter";
            }else if (i == 2){
                titleLab.text = @"Voting Result";
            }else if (i == 3){
                titleLab.text = @"Verification Code";
            }
        }else{
            if (i == 0) {
                titleLab.text = @"Date";
            }else if (i == 1){
                titleLab.text = @"State";
            }else if (i == 2){
                titleLab.text = @"County";
            }else if (i == 3){
                titleLab.text = @"Precinct";
            }else if (i == 4){
                titleLab.text = @"Number of Voting";
            }
        }
        titleLab.layer.borderWidth = 0.5;
        titleLab.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
        titleLab.textAlignment = NSTextAlignmentCenter;
        [_resultScro addSubview:titleLab];
        titleX = titleX + [_widthArray[i] floatValue]+YWIDTH_SCALE(20);
    }
    for (int i = 0; i < _votedArray.count ; i ++) {
        votingProgressModel *model = _votedArray[i];
        CGFloat labX = YWIDTH_SCALE(30);
        for (int j = 0; j < count; j ++) {
            UILabel *dateLab= [[UILabel alloc]initWithFrame:CGRectMake(labX, YHEIGHT_SCALE(60)*i+YHEIGHT_SCALE(60), [_widthArray[j] floatValue]+YWIDTH_SCALE(20), YHEIGHT_SCALE(60))];
            dateLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
            if (_isResult) {
                if (j == 0) {
                    dateLab.text = model.votingDate;
                }else if (j == 1){
                    dateLab.text = model.votingNumber;
                }else if (j == 2){
                    dateLab.text = model.candidateID;
                }else if (j == 3){
                    dateLab.text = model.verificationCode;
                }
                if ([[UserManager userInfo].voteNumbers containsObject:model.votingNumber]) {
                    dateLab.textColor = [UIColor redColor];
                }
            }else{
                if (j == 0) {
                    dateLab.text = model.votingDate;
                }else if (j == 1){
                    dateLab.text = model.state;
                }else if (j == 2){
                    dateLab.text = model.county;
                }else if (j == 3){
                    dateLab.text = model.precinctNumber;
                }else if (j == 4){
                    dateLab.text = [NSString stringWithFormat:@"%ld",(long)model.count];
                }
            }
            dateLab.layer.borderWidth = 0.5;
            dateLab.layer.borderColor = HexRGBAlpha(0x888888, 1).CGColor;
            dateLab.textAlignment = NSTextAlignmentCenter;
            [_resultScro addSubview:dateLab];
            labX = labX + [_widthArray[j] floatValue]+YWIDTH_SCALE(20);
        }
        scrollWidth = labX;
    }
    _resultScro.contentSize = CGSizeMake(scrollWidth+YWIDTH_SCALE(30), scrollHeight);
}


@end
