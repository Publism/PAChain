//
//  ResultBallotViewController.m
//  VoteDemo


#import "ResultBallotViewController.h"

@interface ResultBallotViewController ()
@property (nonatomic,retain)UIScrollView *resultScroll;
@property (nonatomic,copy)NSString *voteCount;
@property (nonatomic,copy)NSString *votePercent;
@property (nonatomic,copy)NSString *lastUpdateDate;
@property (nonatomic,retain)DropListView *stateDrop;
@property (nonatomic,retain)DropListView *countyDrop;
@property (nonatomic,retain)DropListView *precinctNumberDrop;
@property (nonatomic,retain)UIView *freshView;
@property (nonatomic,retain)NSMutableDictionary *candidateDic;
@property (nonatomic,retain)NSMutableArray *voteDataArray;
@property (nonatomic,retain)NSMutableArray *candidateModelArray;
@end

@implementation ResultBallotViewController

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
    self.title = @"Result";
    _voteCount = [[NSString alloc]init];
    _votePercent = [[NSString alloc]init];
    _voteDataArray = [[NSMutableArray alloc]init];
    _candidateModelArray = [[NSMutableArray alloc]init];
    
    [self getVotingResultWithState:[UserManager userInfo].state withCounty:[UserManager userInfo].county withPrecinct:[UserManager userInfo].precinctNumber];
}

- (void)getVotingResultWithState:(NSString *)state withCounty:(NSString *)county withPrecinct:(NSString *)precinct{
    [VoteDemoHUD showLoding];
    ElectionListModel *eleModel = [self.ballotModel.elections firstObject];
    NSDictionary *para = @{@"state":state,
                              @"county":county,
                              @"precinctNumber":precinct,
                              @"electionID":eleModel.election.electionid
    };
    [HttpTool requestWithUrl:@"getvoteresult" withDictionary:para success:^(id  _Nullable data) {
        NSString *ret = [NSString stringWithFormat:@"%@",data[@"ret"]];
        NSLog(@"%@",data);
        if ([ret isEqualToString:@"1"]) {
            NSDictionary *responseDic = data[@"response"];
            if (![responseDic isKindOfClass:[NSNull class]]) {
                NSArray *dataArray = responseDic[@"data"];
                [self.voteDataArray removeAllObjects];
                if (dataArray.count > 0) {
                    for (NSDictionary *dic in dataArray) {
                        VoteDataModel *model = [VoteDataModel yy_modelWithDictionary:dic];
                        [self.voteDataArray addObject:model];
                    }
                }
                NSArray *canArray = responseDic[@"candidates"];
                [self.candidateModelArray removeAllObjects];
                if (canArray.count > 0) {
                    for (NSDictionary *dic in canArray) {
                        BallotResultModel *model = [BallotResultModel yy_modelWithDictionary:dic];
                        [self.candidateModelArray addObject:model];
                    }
                }
                NSString *cout = [NSString stringWithFormat:@"%@",responseDic[@"voteCount"]];
                if (![cout isEqualToString:@"0"]) {
                    self.voteCount = [NSString stringWithFormat:@"%@",responseDic[@"voteCount"]];
                    self.votePercent = [NSString stringWithFormat:@"%@",responseDic[@"percent"]];
                    NSString *dateStr = [NSString stringWithFormat:@"%@",responseDic[@"latedVoteDate"]];
                    self.lastUpdateDate = [CustomMethodTool getTimeFromTimestamp:[[dateStr substringToIndex:10] doubleValue] withFormat:@"MM/dd/yyyy"];
                    NSLog(@"%@==%@==%@",self.voteCount,self.votePercent,self.lastUpdateDate);
                }else{
                    self.voteCount = @"";
                    self.votePercent = @"";
                    self.lastUpdateDate = @"";
                }
                [self configMainView];
            }
        }
        [VoteDemoHUD hideLoding];
    } failure:^(NSString * _Nullable error) {
        [VoteDemoHUD hideLoding];
        NSLog(@"some mistake");
    }];
    
}

- (void)configMainView{
    
    if (!_resultScroll) {
        _resultScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, Height_NavBar, FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-Height_NavBar)];
        _resultScroll.backgroundColor = [UIColor whiteColor];
        _resultScroll.bounces = NO;
        [self.view addSubview:_resultScroll];
        
        UILabel *electionLab = [[UILabel alloc]init];
        electionLab.frame = CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(40), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40));
        electionLab.textAlignment = NSTextAlignmentCenter;
        electionLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(34)];
        electionLab.text = _ballotModel.ballotname;
        [_resultScroll addSubview:electionLab];
        
        
        UILabel *eleDateLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(electionLab.frame), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(30))];
        eleDateLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(32)];
        eleDateLab.textAlignment = NSTextAlignmentCenter;
        eleDateLab.text = [_ballotModel.ballotdate transformDateStringWithFormat:@"yyyy-MM-dd" toformat:@"MMM. dd, yyyy"];
        [_resultScroll addSubview:eleDateLab];
        
        CGFloat allWidth = (FUll_VIEW_WIDTH-YWIDTH_SCALE(90))/2;
        NSArray *stateInfoArray = [StateInfo getStateArray];
        NSMutableArray *stateArray = [[NSMutableArray alloc]init];
        DropdownListItem *stateItem = [[DropdownListItem alloc] initWithItem:@"10000" itemName:@"National"];
        [stateArray addObject:stateItem];
        for (int i = 0; i < stateInfoArray.count; i ++) {
            StateInfo *info = stateInfoArray[i];
            DropdownListItem *item = [[DropdownListItem alloc] initWithItem:[NSString stringWithFormat:@"%@",info.code] itemName:info.name];
            [stateArray addObject:item];
        }
        
        _stateDrop = [[DropListView alloc] initWithDataSource:stateArray];
        _stateDrop.frame = CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(eleDateLab.frame)+YHEIGHT_SCALE(40), allWidth, YHEIGHT_SCALE(70));
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
        [_resultScroll addSubview:_stateDrop];
        
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
        
        NSArray *countyInfoArray = [CountyInfo getCountyInfoWithStateName:_stateDrop.selectedItem.itemId];
        NSMutableArray *countyArray = [[NSMutableArray alloc]init];
        DropdownListItem *countyItem = [[DropdownListItem alloc]initWithItem:@"10000" itemName:@"All"];
        [countyArray addObject:countyItem];
        for (CountyInfo *info in countyInfoArray) {
            DropdownListItem *item = [[DropdownListItem alloc]initWithItem:info.code itemName:info.name];
            [countyArray addObject:item];
        }
        _countyDrop = [[DropListView alloc] initWithDataSource:countyArray];
        _countyDrop.frame = CGRectMake(CGRectGetMaxX(_stateDrop.frame)+YWIDTH_SCALE(30), _stateDrop.y, allWidth, YHEIGHT_SCALE(70));
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
        [_resultScroll addSubview:_countyDrop];
        

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
        _precinctNumberDrop.frame = CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(_stateDrop.frame)+YHEIGHT_SCALE(20), allWidth, YHEIGHT_SCALE(70));
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
        [_resultScroll addSubview:_precinctNumberDrop];
        
        UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        goBtn.frame = CGRectMake(CGRectGetMaxX(_precinctNumberDrop.frame)+YWIDTH_SCALE(30), _precinctNumberDrop.y, allWidth/2, YHEIGHT_SCALE(70));
        [goBtn setTitle:@"GO" forState:UIControlStateNormal];
        [goBtn setBackgroundColor:HexRGBAlpha(0x0390fc, 1)];
        [goBtn addTarget:self action:@selector(goMethod) forControlEvents:UIControlEventTouchUpInside];
        [_resultScroll addSubview:goBtn];
    }
    
    if (_freshView) {
        for (UIView *view in _freshView.subviews) {
            [view removeFromSuperview];
        }
        [_freshView removeFromSuperview];
    }
    
    _freshView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_precinctNumberDrop.frame), FUll_VIEW_WIDTH, FUll_VIEW_HEIGHT-CGRectGetMaxY(_precinctNumberDrop.frame))];
    _freshView.backgroundColor = [UIColor whiteColor];
    [_resultScroll addSubview:_freshView];
    
    CGFloat seatViewHeight = 0;
    if (self.voteCount.length > 0) {
        NSString *typeStr = [[NSString alloc]init];
        
        UILabel *totalLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(20), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40))];
        totalLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(30)];
        [_freshView addSubview:totalLab];
        
        if ([self.votePercent floatValue] > 0) {
            if ([_stateDrop.selectedItem.itemName isEqualToString:@"National"] && [_countyDrop.selectedItem.itemName isEqualToString:@"All"] && [_precinctNumberDrop.selectedItem.itemName isEqualToString:@"All"]) {
                typeStr = [NSString stringWithFormat:@"%.2f%% States reporting",([self.votePercent floatValue]*100)];
            }else if (![_stateDrop.selectedItem.itemName isEqualToString:@"National"] && [_countyDrop.selectedItem.itemName isEqualToString:@"All"] && [_precinctNumberDrop.selectedItem.itemName isEqualToString:@"All"]){
                typeStr = [NSString stringWithFormat:@"%.2f%% Counties reporting",([self.votePercent floatValue]*100)];
            }else if (![_stateDrop.selectedItem.itemName isEqualToString:@"National"] && ![_countyDrop.selectedItem.itemName isEqualToString:@"All"] && [_precinctNumberDrop.selectedItem.itemName isEqualToString:@"All"]){
                typeStr = [NSString stringWithFormat:@"%.2f%% Precincts reporting",([self.votePercent floatValue]*100)];
            }else{
                typeStr = [NSString stringWithFormat:@"Precinct %@:%.2f%%",_precinctNumberDrop.selectedItem.itemName,([self.votePercent floatValue]*100)];
            }
            totalLab.text = [NSString stringWithFormat:@"Total: %@ (%@)",self.voteCount,typeStr];
        }else{
            totalLab.text = [NSString stringWithFormat:@"Total: %@",self.voteCount];
        }
        
        UILabel *updateLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(totalLab.frame)+YHEIGHT_SCALE(10), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40))];
        updateLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(30)];
        updateLab.text = [NSString stringWithFormat:@"Last Update: %@",[self.lastUpdateDate transformDateStringWithFormat:@"MM/dd/yyyy" toformat:@"MMM. dd, yyyy"]];
        [_freshView addSubview:updateLab];
        
        UIView *grayView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(updateLab.frame)+YHEIGHT_SCALE(10), FUll_VIEW_WIDTH, YHEIGHT_SCALE(20))];
        grayView.backgroundColor = HexRGBAlpha(0xfafafa, 1);
        [_freshView addSubview:grayView];
        seatViewHeight = CGRectGetMaxY(grayView.frame);
    }
    
    if (_candidateModelArray.count > 0) {
        for (int i = 0; i < _candidateModelArray.count; i ++) {
            BallotResultModel *resultModel = _candidateModelArray[i];
            
            UIView *seatView = [[UIView alloc]initWithFrame:CGRectMake(0, seatViewHeight, FUll_VIEW_WIDTH, YHEIGHT_SCALE(100))];
            seatView.backgroundColor = [UIColor whiteColor];
            [_freshView addSubview:seatView];
            
            UILabel *color = [[UILabel alloc]init];
            color.frame =CGRectMake(YWIDTH_SCALE(30), YHEIGHT_SCALE(20), YWIDTH_SCALE(8), YHEIGHT_SCALE(40));
            color.backgroundColor = HexRGBAlpha(0x0090ff, 1);
            [seatView addSubview:color];
            
            UILabel *seatLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(50), color.y, FUll_VIEW_WIDTH-YWIDTH_SCALE(110), YHEIGHT_SCALE(40))];
            seatLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(32)];
            if (![resultModel.seat.name isEqualToString:resultModel.seat.office]) {
                seatLab.text = [NSString stringWithFormat:@"%@ %@",resultModel.seat.office,resultModel.seat.name];
            }else{
                seatLab.text = resultModel.seat.name;
            }
            [seatView addSubview:seatLab];
            
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(seatLab.frame)+YHEIGHT_SCALE(15), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(2))];
            line.backgroundColor = HexRGBAlpha(0xf6f6f6, 1);
            [seatView addSubview:line];
            
            CGFloat viewHeight = YHEIGHT_SCALE(30)+CGRectGetMaxY(seatLab.frame);
            
            NSMutableDictionary *muDic = [[NSMutableDictionary alloc]init];
            [resultModel.candidates enumerateObjectsUsingBlock:^(CandidateModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([muDic.allKeys containsObject:obj.party]) {
                    NSMutableArray *muarray = [[muDic objectForKey:obj.party] mutableCopy];
                    [muarray addObject:obj];
                    [muDic setObject:muarray forKey:obj.party];
                }else{
                    NSMutableArray *muarray = [[NSMutableArray alloc]init];
                    [muarray addObject:obj];
                    [muDic setObject:muarray forKey:obj.party];
                }
            }];
            for (int i = 0; i < muDic.allKeys.count; i ++) {
                UILabel *partyLab = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), viewHeight, FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(40))];
                partyLab.text = [NSString stringWithFormat:@"%@",muDic.allKeys[i]];
                partyLab.font = [UIFont boldSystemFontOfSize:YFONTSIZEFROM_PX(34)];
                [seatView addSubview:partyLab];
                
                NSArray *candidateArray = [muDic objectForKey:muDic.allKeys[i]];
                for (int j = 0; j < candidateArray.count; j ++) {
                    CandidateModel *canModel = candidateArray[j];
                    UIImageView *candidatePhoto = [[UIImageView alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(partyLab.frame)+YHEIGHT_SCALE(20), YWIDTH_SCALE(126), YHEIGHT_SCALE(140))];
                    candidatePhoto.backgroundColor = [UIColor grayColor];
                    [candidatePhoto sd_setImageWithURL:[NSURL URLWithString:canModel.photo] placeholderImage:[UIImage imageNamed:@"1.jpg"]];
                    [seatView addSubview:candidatePhoto];
                    
                    if (canModel.party.length > 0) {
                        UIButton *partyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        partyBtn.frame = CGRectMake(candidatePhoto.width-YWIDTH_SCALE(35), candidatePhoto.height-YWIDTH_SCALE(35), YWIDTH_SCALE(35), YWIDTH_SCALE(35));
                        partyBtn.titleLabel.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(28)];
                        if ([canModel.party isEqualToString:@"Republican"]) {
                            [partyBtn setTitle:@"R" forState:UIControlStateNormal];
                            partyBtn.backgroundColor = [UIColor redColor];
                        }else if ([canModel.party isEqualToString:@"Democratic"]){
                            [partyBtn setTitle:@"D" forState:UIControlStateNormal];
                            partyBtn.backgroundColor = [UIColor blueColor];
                        }else if ([canModel.party isEqualToString:@"Independent"]){
                            [partyBtn setTitle:@"I" forState:UIControlStateNormal];
                            partyBtn.backgroundColor = HexRGBAlpha(0x9c17df, 1);
                        }else{
                            [partyBtn setTitle:@"O" forState:UIControlStateNormal];
                            partyBtn.layer.borderWidth = 0.5;
                            partyBtn.layer.borderColor = [UIColor grayColor].CGColor;
                            [partyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                            partyBtn.backgroundColor = [UIColor whiteColor];
                        }
                            
                        [candidatePhoto addSubview:partyBtn];
                    }
                    
                    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(YWIDTH_SCALE(30), CGRectGetMaxY(candidatePhoto.frame)+YHEIGHT_SCALE(20), FUll_VIEW_WIDTH-YWIDTH_SCALE(60), YHEIGHT_SCALE(2))];
                    line.backgroundColor = HexRGBAlpha(0xf6f6f6, 1);
                    [seatView addSubview:line];
                    
                    YYLabel *candidateName = [[YYLabel alloc]init];
                    candidateName.frame = CGRectMake(CGRectGetMaxX(candidatePhoto.frame)+YWIDTH_SCALE(20), candidatePhoto.y, FUll_VIEW_WIDTH-CGRectGetMaxX(candidatePhoto.frame)-YWIDTH_SCALE(50), YHEIGHT_SCALE(140));
                    candidateName.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(32)];
                    candidateName.textAlignment = NSTextAlignmentLeft;
                    candidateName.textVerticalAlignment = YYTextVerticalAlignmentCenter;
                    candidateName.textColor = HexRGBAlpha(0x333333, 1);
                    candidateName.numberOfLines = 0;
                    NSMutableAttributedString *nameAtt = [[NSMutableAttributedString alloc]initWithString:canModel.name];
                    nameAtt.yy_font =[UIFont systemFontOfSize:YFONTSIZEFROM_PX(32)];
                    candidateName.attributedText = nameAtt;
                    [candidateName sizeToFit];
                    [seatView addSubview:candidateName];
                    
                    VoteDataModel *model = [[VoteDataModel alloc]init];
                    for (VoteDataModel *mmodel in _voteDataArray) {
                        if (mmodel.candidateID == canModel.candidateid) {
                            model = mmodel;
                            break;
                        }
                    }
                    
                    CGFloat ratePercent = [model.percent floatValue]*[self.votePercent floatValue];
                    UILabel *rateLab = [[UILabel alloc]init];
                    rateLab.frame = CGRectMake(candidateName.x, candidateName.frame.origin.y+candidateName.frame.size.height+YHEIGHT_SCALE(11), YWIDTH_SCALE(((180*(ratePercent*100))/100)*2), YHEIGHT_SCALE(14));
                    rateLab.backgroundColor = HexRGBAlpha(0x2ba542, 1);
                    [seatView addSubview:rateLab];
                    
                    UILabel *norateLab = [[UILabel alloc]init];
                    norateLab.frame = CGRectMake(rateLab.x+rateLab.width, candidateName.frame.origin.y+candidateName.frame.size.height+YHEIGHT_SCALE(11), YWIDTH_SCALE(360)-rateLab.width, YHEIGHT_SCALE(14));
                    norateLab.backgroundColor = HexRGBAlpha(0xe9e9e9, 1);
                    [seatView addSubview:norateLab];
                    
                    UILabel *pctLab = [[UILabel alloc]initWithFrame:CGRectMake(norateLab.x+norateLab.width+YWIDTH_SCALE(10), candidateName.frame.origin.y+candidateName.frame.size.height+YHEIGHT_SCALE(2), 20, YHEIGHT_SCALE(32))];
                    NSString *ballots = [NSString stringWithFormat:@"%.2f",(ratePercent*100)];
                    pctLab.text = [NSString stringWithFormat:@"%@%%",ballots];
                    pctLab.textColor = HexRGBAlpha(0x666666, 1);
                    pctLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(28)];
                    [pctLab sizeToFit];
                    [seatView addSubview:pctLab];
                    
                    UILabel *ballotsLab = [[UILabel alloc]initWithFrame:CGRectMake(rateLab.x, pctLab.frame.origin.y+pctLab.frame.size.height+YHEIGHT_SCALE(10), FUll_VIEW_WIDTH-rateLab.x-YWIDTH_SCALE(30), YHEIGHT_SCALE(32))];
                    ballotsLab.text = [NSString stringWithFormat:@"Votes:%ld",(long)model.count];
                    ballotsLab.textColor = HexRGBAlpha(0x666666, 1);
                    ballotsLab.font = [UIFont systemFontOfSize:YFONTSIZEFROM_PX(28)];
                    [ballotsLab sizeToFit];
                    [seatView addSubview:ballotsLab];
                    
                    viewHeight = CGRectGetMaxY(candidatePhoto.frame)+YHEIGHT_SCALE(40);
                }
                
                seatView.height = viewHeight;
            }
            seatViewHeight = seatView.height+seatView.y;
        }
    }
    
    
    _freshView.frame = CGRectMake(0, CGRectGetMaxY(_precinctNumberDrop.frame), FUll_VIEW_WIDTH, seatViewHeight);
    _resultScroll.contentSize = CGSizeMake(FUll_VIEW_WIDTH, CGRectGetMaxY(_freshView.frame));
    
}

- (void)goMethod{
    StateInfo *staInfo = [StateInfo getStateInfoWithName:_stateDrop.selectedItem.itemName];
    [self getVotingResultWithState:staInfo.shortName.length>0?staInfo.shortName:@"" withCounty:[_countyDrop.selectedItem.itemName isEqualToString:@"All"]?@"":_countyDrop.selectedItem.itemId withPrecinct:[_precinctNumberDrop.selectedItem.itemName isEqualToString:@"All"]?@"":_precinctNumberDrop.selectedItem.itemName];
}

@end
